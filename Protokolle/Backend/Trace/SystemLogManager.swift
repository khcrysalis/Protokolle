//
//  SystemLogManager.swift
//  syslog
//
//  Created by samara on 14.05.2025.
//

import UIKit

// MARK: - Class extension: - Log Error
extension SystemLogManager {
	enum SYSystemLogError: Error, LocalizedError {
		case missingPairing
		case failedToConnect
		
		var errorDescription: String? {
			switch self {
			case .missingPairing:
				.localized("Unable to connect to TCP. Make sure you have loopback VPN enabled and you are on WiFi or Airplane mode.")
			case .failedToConnect:
				.localized("Unable to connect to relay.")
			}
		}
	}
}

// MARK: - Class
class SystemLogManager: NSObject {
	static let shared = SystemLogManager()
	let heartbeat = HeartbeatManager.shared
	
	typealias SyslogClientHandle = OpaquePointer
	typealias OsTraceRelayClientHandle = OpaquePointer
	typealias OsTraceRelayReceiverHandle = OpaquePointer
	
	var syslogClient: SyslogClientHandle?
	var osTraceRelayClient: OsTraceRelayClientHandle?
	var osTraceReceiverClient: OsTraceRelayReceiverHandle?
	
	var isStreaming: Bool = false {
		didSet {
			NotificationCenter.default.post(
				Notification(name: .isStreamingDidChange, object: isStreaming)
			)
		}
	}
	
	weak var delegate: SystemLogManagerDelegate?

	private func _connect() async throws {
		guard FileManager.default.fileExists(atPath: HeartbeatManager.pairingFile()) else {
			throw SYSystemLogError.missingPairing
		}
		
		guard self.heartbeat.checkSocketConnection().isConnected else {
			throw SYSystemLogError.missingPairing
		}
		
		guard (self.heartbeat.provider != nil) else {
			throw SYSystemLogError.missingPairing
		}
	}
	/// Connects to syslog relay
	func syslog_relay() async throws {
		try await Task.detached(priority: .utility) {
			try await self._connect()
			
			guard syslog_relay_connect_tcp(self.heartbeat.provider, &self.syslogClient) == IdeviceSuccess else {
				throw SYSystemLogError.failedToConnect
			}
			
			NSLog("we're going?")
					
			self.isStreaming = true
			
			while self.isStreaming {
				guard let syslogClient = self.syslogClient else {
					break
				}
				
				var logLinePointer: UnsafeMutablePointer<CChar>? = nil
				let result = syslog_relay_next(syslogClient, &logLinePointer)
				
				// This may crash due to accessing an invalid pointer
				// don't know how to fix it yet! If you do know how
				// to fix it, please tell me!!!
				if result == IdeviceSuccess, let logLinePointer = logLinePointer {
					if let logLine = String(validatingUTF8: logLinePointer) {
						self.delegate?.activityStream(didRecieveString: logLine)
						idevice_string_free(logLinePointer)
					} else {
						idevice_string_free(logLinePointer)
					}
				} else if result != IdeviceSuccess {
					break
				}
			}
						
			if let syslogClient = self.syslogClient {
				syslog_relay_client_free(syslogClient)
				self.syslogClient = nil
			}
			
			self.isStreaming = false
		}.value
	}
	/// Connects to os trace relay, this is the backbone of our app
	func os_trace_relay() async throws {
		try await Task.detached(priority: .utility) {
			try await self._connect()
			
			guard os_trace_relay_connect_tcp(self.heartbeat.provider, &self.osTraceRelayClient) == IdeviceSuccess else {
				throw SYSystemLogError.failedToConnect
			}
			
			guard os_trace_relay_start_trace(self.osTraceRelayClient, &self.osTraceReceiverClient, nil)  == IdeviceSuccess else {
				throw SYSystemLogError.failedToConnect
			}
			
			self.isStreaming = true
			
			while self.isStreaming {
				guard let recClient = self.osTraceReceiverClient else {
					break
				}
				
				var oslogg: UnsafeMutablePointer<OsTraceLog>? = nil
				let result = os_trace_relay_next(recClient, &oslogg)
				
				if result == IdeviceSuccess, let oslogg = oslogg {
					let logCopy = oslogg.pointee
					let model = LogEntry(logCopy)
					self.delegate?.activityStream(didRecieveEntry: model)
					os_trace_relay_free_log(oslogg)
				} else if result != IdeviceSuccess {
					break
				}
			}
			
			self.isStreaming = false
			
			if let recClient = self.osTraceReceiverClient {
				os_trace_relay_receiver_free(recClient)
				self.osTraceRelayClient = nil
				self.osTraceReceiverClient = nil
			}
		}.value
	}
	/// Stops streaming
	func stop() {
		isStreaming = false
	}
	
	deinit {
		stop()
	}
}
