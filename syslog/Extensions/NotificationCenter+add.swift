//
//  NotificationCenter+add.swift
//  syslog
//
//  Created by samara on 20.05.2025.
//

import Foundation

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
