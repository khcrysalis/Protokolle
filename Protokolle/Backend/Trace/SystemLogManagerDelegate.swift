//
//  SystemLogManagerDelegate.swift
//  syslog
//
//  Created by samara on 18.05.2025.
//

import UIKit

protocol SystemLogManagerDelegate: AnyObject {
	func activityStream(didRecieveEntry entry: LogEntry)
	func activityStream(didRecieveString entryString: String)
}
