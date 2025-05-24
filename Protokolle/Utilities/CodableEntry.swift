//
//  CodableEntry.swift
//  Protokolle
//
//  Created by samara on 23.05.2025.
//

import Foundation

// MARK: - EntryDelegate Protocol

protocol LogEntryDelegate {
	var log: LogEntryModel { get }
}

// MARK: - CodableEntry

struct CodableLogEntry: Codable, LogEntryDelegate {
	var log: LogEntryModel
	
	init(log: LogEntryModel) {
		self.log = log
	}
	
	private enum CodingKeys: String, CodingKey {
		case log
	}
}

class LogEntry: LogEntryDelegate, Hashable {
	var log: LogEntryModel
	
	init(_ log: OsTraceLog) {
		self.log = LogEntryModel(log)
	}
	
	// MARK: - Hashable Conformance
	
	static func == (lhs: LogEntry, rhs: LogEntry) -> Bool {
		return lhs.log == rhs.log
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(log)
	}
}
