//
//  SystemLogManager.swift
//  syslog
//
//  Created by samara on 14.05.2025.
//

import UIKit

class SystemLogManager: NSObject {
	static let shared = SystemLogManager()
	let heartbeat = HeartbeatManager.shared
	
	typealias SyslogClientHandle = OpaquePointer
	typealias OsTraceRelayClientHandle = OpaquePointer
	typealias OsTraceRelayReceiverHandle = OpaquePointer
	
	var syslogClient: SyslogClientHandle?
	var osTraceRelayClient: OsTraceRelayClientHandle?
	var osTraceReceiverClient: OsTraceRelayReceiverHandle?
	
	var isStreaming: Bool = false
	
	weak var delegate: SystemLogManagerDelegate?
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	func connect() async throws {
		guard FileManager.default.fileExists(atPath: HeartbeatManager.pairingFile()) else {
			throw SYSystemLogError.noPairingFile
		}
		
		guard self.heartbeat.checkSocketConnection().isConnected else {
			throw SYSystemLogError.deviceNotConnected
		}
		
		guard (self.heartbeat.provider != nil) else {
			throw SYSystemLogError.noProviderAvailable
		}
	}
	
	func syslog_relay() async throws {
		try await Task.detached(priority: .utility) {
			try await self.connect()
			
			guard syslog_relay_connect_tcp(self.heartbeat.provider, &self.syslogClient) == IdeviceSuccess else {
				throw SYSystemLogError.failedToConnect
			}
			
			print("Successfully connected to syslog relay")
			
			self.isStreaming = true
			
			while self.isStreaming {
				guard let syslogClient = self.syslogClient else {
					break
				}
				
				var logLinePointer: UnsafeMutablePointer<CChar>? = nil
				let result = syslog_relay_next(syslogClient, &logLinePointer)
				
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
			
			print("Syslog relay connection closed")
			
			if let syslogClient = self.syslogClient {
				syslog_relay_client_free(syslogClient)
				self.syslogClient = nil
			}
			
			self.isStreaming = false
		}.value
	}
	
	func os_trace_relay() async throws {
		try await Task.detached(priority: .utility) {
			try await self.connect()
			
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
					defer { os_trace_relay_free_log(oslogg) }
					let logCopy = oslogg.pointee
					let model = LogEntryModel(logCopy)
					self.delegate?.activityStream(didRecieveEntry: model)
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
	
	func stop() {
		isStreaming = false
	}
	
	deinit {
		stop()
	}
	
	// Add error enum at the top of the file
	enum SYSystemLogError: Error {
		case noPairingFile
		case deviceNotConnected
		case noProviderAvailable
		case failedToConnect
	}
}
