//
//  TimeInterval.swift
//  syslog
//
//  Created by samara on 20.05.2025.
//

import Foundation

extension Int64 {
	func formattedDate(style: Date.FormatStyle = .dateTime) -> String {
		let date = Date(timeIntervalSince1970: TimeInterval(self))
		return date.formatted(style)
	}
}

