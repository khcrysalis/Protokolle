//
//  VPNLogger.swift
//  Protokolle
//
//  Created by samara on 24.05.2025.
//

import Foundation
import NetworkExtension
import OSLog

// MARK: - Class

class TunnelManager: ObservableObject {
    @Published var tunnelStatus: TunnelStatus = .disconnected
    static var shared = TunnelManager()
    
    private var vpnManager: NETunnelProviderManager?
    private var tunnelDeviceIp: String = "10.9.0.0"
    private var tunnelFakeIp: String = "10.9.0.1"
    private var tunnelSubnetMask: String = "255.255.255.0"
    private var tunnelBundleId: String = Bundle.main.bundleIdentifier!.appending(".ProtokolleTunnel")
    
    enum TunnelStatus: String {
        case disconnected = "Disconnected"
        case connecting = "Connecting"
        case connected = "Connected"
        case disconnecting = "Disconnecting"
        case error = "Error"
    }
    
    private init() {
        loadTunnelPreferences()
        NotificationCenter.default.addObserver(self, selector: #selector(statusDidChange(_:)), name: .NEVPNStatusDidChange, object: nil)
    }
    
    private func loadTunnelPreferences() {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] (managers, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
					Logger.vpn.error("Error loading preferences: \(error.localizedDescription)")
                    self.tunnelStatus = .error
                    return
                }
                if let managers = managers, !managers.isEmpty {
                    for manager in managers {
                        if let proto = manager.protocolConfiguration as? NETunnelProviderProtocol,
                           proto.providerBundleIdentifier == self.tunnelBundleId {
                            self.vpnManager = manager
                            self.updateTunnelStatus(from: manager.connection.status)
							Logger.vpn.info("Loaded existing tunnel configuration")
                            break
                        }
                    }
                    if self.vpnManager == nil, let firstManager = managers.first {
                        self.vpnManager = firstManager
                        self.updateTunnelStatus(from: firstManager.connection.status)
						Logger.vpn.info("Using existing tunnel configuration")
                    }
                } else {
					Logger.vpn.warning("No existing tunnel configuration found")
                }
            }
        }
    }
    
    @objc private func statusDidChange(_ notification: Notification) {
        if let connection = notification.object as? NEVPNConnection {
            updateTunnelStatus(from: connection.status)
        }
    }
    
    private func updateTunnelStatus(from connectionStatus: NEVPNStatus) {
        DispatchQueue.main.async {
            switch connectionStatus {
            case .invalid, .disconnected:
                self.tunnelStatus = .disconnected
            case .connecting:
                self.tunnelStatus = .connecting
            case .connected:
                self.tunnelStatus = .connected
            case .disconnecting:
                self.tunnelStatus = .disconnecting
            case .reasserting:
                self.tunnelStatus = .connecting
            @unknown default:
                self.tunnelStatus = .error
            }
			Logger.vpn.info("VPN status updated: \(self.tunnelStatus.rawValue)")
        }
    }
    
    private func createOrUpdateTunnelConfiguration(completion: @escaping (Bool) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] (managers, error) in
            guard let self = self else { return completion(false) }
            if let error = error {
				Logger.vpn.error("Error loading preferences: \(error.localizedDescription)")
                return completion(false)
            }
            
            let manager: NETunnelProviderManager
            if let existingManagers = managers, !existingManagers.isEmpty {
                if let matchingManager = existingManagers.first(where: {
                    ($0.protocolConfiguration as? NETunnelProviderProtocol)?.providerBundleIdentifier == self.tunnelBundleId
                }) {
                    manager = matchingManager
					Logger.vpn.info("Updating existing tunnel configuration")
                } else {
                    manager = existingManagers[0]
					Logger.vpn.info("Using first available tunnel configuration")
                }
            } else {
                manager = NETunnelProviderManager()
				Logger.vpn.info("Creating new tunnel configuration")
            }
            
            manager.localizedDescription = "Protokolle"
            let proto = NETunnelProviderProtocol()
            proto.providerBundleIdentifier = self.tunnelBundleId
            proto.serverAddress = "Protokolle's Local Network Tunnel"
            manager.protocolConfiguration = proto
            manager.isOnDemandEnabled = true
            manager.isEnabled = true
            
            manager.saveToPreferences { [weak self] error in
                guard let self = self else { return completion(false) }
                DispatchQueue.main.async {
                    if let error = error {
						Logger.vpn.error("Error saving tunnel configuration: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    self.vpnManager = manager
					Logger.vpn.info("Tunnel configuration saved successfully")
                    completion(true)
                }
            }
        }
    }
    
    func startVPN() {
        if let manager = vpnManager {
            startExistingVPN(manager: manager)
        } else {
            createOrUpdateTunnelConfiguration { [weak self] success in
                guard let self = self, success else { return }
                self.loadTunnelPreferences()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let manager = self.vpnManager {
                        self.startExistingVPN(manager: manager)
                    }
                }
            }
        }
    }
    
    private func startExistingVPN(manager: NETunnelProviderManager) {
        guard tunnelStatus != .connected else {
			Logger.vpn.warning("Network tunnel is already connected")
            return
        }
        tunnelStatus = .connecting
        let options: [String: NSObject] = [
            "TunnelDeviceIP": tunnelDeviceIp as NSObject,
            "TunnelFakeIP": tunnelFakeIp as NSObject,
            "TunnelSubnetMask": tunnelSubnetMask as NSObject
        ]
        do {
            try manager.connection.startVPNTunnel(options: options)
			Logger.vpn.info("Network tunnel start initiated")
        } catch {
            tunnelStatus = .error
			Logger.vpn.error("Failed to start tunnel: \(error.localizedDescription)")
        }
    }
    
    func stopVPN() {
        guard let manager = vpnManager else { return }
        tunnelStatus = .disconnecting
        manager.connection.stopVPNTunnel()
		Logger.vpn.info("Network tunnel stop initiated")
    }
}
