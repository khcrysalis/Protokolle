//
//  String+formattedDecimal.swift
//  syslog
//
//  Created by samara on 22.05.2025.
//

import Foundation.NSString

extension String {
	/// Formats the string as a decimal number with grouping separators (e.g., "1000" to "1,000")
	func formattedAsDecimal() -> String? {
		let formatter = NumberFormatter()
		formatter.usesGroupingSeparator = true
		formatter.numberStyle = .decimal
		
		if let number = Double(self) {
			return formatter.string(from: NSNumber(value: number))
		} else {
			return nil
		}
	}
}
