//
//  MessageEventModel.swift
//  syslog
//
//  Created by samara on 17.05.2025.
//

import UIKit.UIColor

struct LogMessageEventModel: Hashable, CustomStringConvertible {
	let displayText: String
	var displayColor: UIColor?
	let rawValue: UInt8
	
	private init(displayText: String, color: UIColor?, rawValue: UInt8) {
		self.displayText = displayText
		self.displayColor = color
		self.rawValue = rawValue
	}
	
	init?(_ cLogType: UInt8) {
		switch cLogType {
		case 0: 	self = .default
		case 1: 	self = .info
		case 2: 	self = .debug
		case 10: 	self = .error
		case 11: 	self = .fault
		default: 	return nil
		}
	}
	
	var description: String {
		displayText
	}
	
	enum CodingKeys: CodingKey {
		case displayText
		case color
		case rawValue
	}
	
	static func == (lhs: LogMessageEventModel, rhs: LogMessageEventModel) -> Bool {
		// TODO: - This is probably bad but it works /shrug
		lhs.displayText == rhs.displayText && lhs.rawValue == rhs.rawValue
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(displayText)
		hasher.combine(rawValue)
	}
}

extension LogMessageEventModel: CaseIterable {
	// MARK: - Log types
	static var `default` = LogMessageEventModel(
		displayText: "Default",
		color: .systemGray,
		rawValue: 0
	)
	
	static var debug = LogMessageEventModel(
		displayText: "Debug",
		color: .systemYellow,
		rawValue: 1
	)
	
	static var info = LogMessageEventModel(
		displayText: "Info",
		color: .systemGray,
		rawValue: 2
	)
	
	static var error = LogMessageEventModel(
		displayText: "Error",
		color: .systemRed,
		rawValue: 10
	)
	
	static var fault = LogMessageEventModel(
		displayText: "Fault",
		color: .systemRed,
		rawValue: 11
	)
	
	/// `allCases` can be a ``let`` constant initialized once
	/// because the actual list of item doesn't change,
	/// however, we use ``allCasesNonLazily`` for contexts when the items themselves change,
	/// ie, when reloading PreferencesViewController.
	static var allCasesNonLazily: [LogMessageEventModel] {
		[.default, .info, .debug, .fault, .error]
	}
	
	static let allCases: [LogMessageEventModel] = allCasesNonLazily
}

extension LogMessageEventModel: Codable {
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(displayText, forKey: .displayText)
		try container.encode(rawValue, forKey: .rawValue)
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.displayText = try container.decode(String.self, forKey: .displayText)
		self.rawValue = try container.decode(UInt8.self, forKey: .rawValue)
	}
}

