//
//  SYStreamViewController+delegate.swift
//  syslog
//
//  Created by samara on 20.05.2025.
//

import UIKit

// MARK: - Class extension: SystemLogManagerDelegate
extension SYStreamViewController: SystemLogManagerDelegate {
	func activityStream(didRecieveEntry entry: LogEntryModel) {
		if filter?.entryPassesFilter(entry) ?? true {
			batch.append(entry)
		}
	}
	
	func activityStream(didRecieveString entryString: String) {}
}
