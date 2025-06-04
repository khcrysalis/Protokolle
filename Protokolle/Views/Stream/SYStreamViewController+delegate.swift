//
//  SYStreamViewController+delegate.swift
//  syslog
//
//  Created by samara on 20.05.2025.
//

import UIKit
import IDeviceSwift

// MARK: - Class extension: SystemLogManagerDelegate
extension SYStreamViewController: SystemLogManagerDelegate {
	func activityStream(didRecieveEntry entry: LogEntry) {
		if filter?.entryPassesFilter(entry.log) ?? true {
			batch.append(entry)
		}
	}
	
	func activityStream(didRecieveString entryString: String) {}
}
