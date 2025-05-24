//
//  LogEntryModel.swift
//  syslog
//
//  Created by samara on 17.05.2025.
//

import Foundation.NSURL

#warning("we need.. to make a codableentry for exporting :skull:")

struct LogEntryModel: Hashable {
	private let _id = UUID()
	
	var pid: UInt32
	var timestamp: Int64
	var level: UInt8
	var senderPath: String?
	var senderName: String?
	var processPath: String?
	var processName: String?
	var message: String?
	var label: EntryLabel?
	var type: LogMessageEventModel?
	
	struct EntryLabel: Hashable {
		var subsystem: String?
		var category: String?
		
		init(from label: UnsafePointer<SyslogLabel>?) {
			guard let label = label?.pointee else { return }
			self.subsystem = label.subsystem.flatMap { String(cString: $0) }
			self.category = label.category.flatMap { String(cString: $0) }
		}
	}
	
	init(_ log: OsTraceLog) {
		self.pid = log.pid
		self.timestamp = log.timestamp
		self.level = log.level
		self.senderPath = log.image_name.flatMap { String(validatingUTF8: $0) }
		self.senderName = self.senderPath.flatMap { URL(string: $0)?.lastPathComponent }
		self.processPath = log.filename.flatMap { String(validatingUTF8: $0) }
		self.processName = self.processPath.flatMap { URL(string: $0)?.lastPathComponent }
		self.message = log.message.flatMap { String(validatingUTF8: $0) }
		self.label = EntryLabel(from: log.label)
		self.type = LogMessageEventModel(level)
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(_id)
	}
	
	static func == (lhs: LogEntryModel, rhs: LogEntryModel) -> Bool {
		return lhs._id == rhs._id
	}
}
