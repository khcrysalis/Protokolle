//
//  SYStreamViewController+delegate.swift
//  syslog
//
//  Created by samara on 20.05.2025.
//

// MARK: - Class extension
extension SYStreamViewController: SystemLogManagerDelegate {
	func activityStream(didRecieveEntry entry: LogEntryModel) {
		batch.append(entry)
	}
	
	func activityStream(didRecieveString entryString: String) {}
}
