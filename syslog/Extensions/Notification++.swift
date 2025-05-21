//
//  Notification+custom.swift
//  Feather
//
//  Created by samara on 29.04.2025.
//

import Foundation.NSNotification

extension Notification.Name {
	static let heartbeat = Notification.Name("SY.heartBeat")
	
	static let refreshSpeedDidChange = Notification.Name("SY.refreshSpeedDidChange")
	static let bufferLimitDidChange = Notification.Name("SY.bufferLimitDidChange")
}
