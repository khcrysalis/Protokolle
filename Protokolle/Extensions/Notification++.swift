//
//  Notification+custom.swift
//  Feather
//
//  Created by samara on 29.04.2025.
//

import Foundation.NSNotification

extension Notification.Name {
	static let refreshSpeedDidChange = Notification.Name("SY.refreshSpeedDidChange")
	static let bufferLimitDidChange = Notification.Name("SY.bufferLimitDidChange")
	static let entryFilterDidChange = Notification.Name("SY.entryFilterDidChange")
}

extension NotificationCenter {
	static func addObserver<T>(
		name: Notification.Name,
		object: Any? = nil,
		queue: OperationQueue? = nil,
		castTo: T.Type,
		handler: @escaping (T) -> Void
	) -> NSObjectProtocol {
		return self.default.addObserver(forName: name, object: object, queue: queue) { notification in
			guard let object = notification.object as? T else {
				assertionFailure("Failed to cast notification object to \(T.self)")
				return
			}
			handler(object)
		}
	}
	
}
