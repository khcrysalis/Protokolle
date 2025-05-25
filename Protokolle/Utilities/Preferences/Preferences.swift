//
//  Preferences.swift
//  Antoine
//
//  Created by Serena on 10/12/2022
//

import Foundation
import CoreLocation

/// A set of user controlled preferences.
enum Preferences {
	/// Stream refresh speed
    @Storage(key: "SY.refreshSpeed", defaultValue: 1.0, callback: refreshSpeedCallback)
    static var refreshSpeed: Double
	/// Stream buffer limit
	@Storage(key: "SY.bufferLimit", defaultValue: 75000, callback: bufferLimitCallback)
	static var bufferLimit: Int
	/// Users custom filters set
	@CodableStorage(key: "SY.entryFilter", defaultValue: nil, handler: { _, newValue in
		NotificationCenter.default.post(
			Notification(name: .entryFilterDidChange, object: newValue)
		)
	})
	static var entryFilter: EntryFilter?
}

extension Preferences {
    // MARK: - Callbacks
    static func refreshSpeedCallback(newValue: Double) {
        NotificationCenter.default.post(
			Notification(name: .refreshSpeedDidChange, object: newValue)
        )
    }
	
	static func bufferLimitCallback(newValue: Int) {
		NotificationCenter.default.post(
			Notification(name: .bufferLimitDidChange, object: newValue)
		)
	}
	
}
