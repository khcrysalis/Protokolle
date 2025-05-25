//
//  TimeInterval.swift
//  syslog
//
//  Created by samara on 20.05.2025.
//

import Foundation

extension Int64 {
	/// Converts a UNIX timestamp to a readable date
	/// - Parameter style: Date format style
	/// - Returns: Formatted date
	func formattedDate(style: Date.FormatStyle = .dateTime) -> String {
		let date = Date(timeIntervalSince1970: TimeInterval(self))
		return date.formatted(style)
	}
}

