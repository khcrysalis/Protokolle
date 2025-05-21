//
//  LogEntryModel.swift
//  syslog
//
//  Created by samara on 17.05.2025.
//

import Foundation.NSURL

#warning("we need.. to make a codableentry for exporting :skull:")

struct LogEntryModel: Hashable {
	private let id = UUID() // Add a unique identifier
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
	
	#if DEBUG
	init() {
		self.pid = UInt32(Int.random(in: 100...9999))
		self.timestamp = Int64(Int(Date().timeIntervalSince1970))
		self.level = UInt8(Int.random(in: 0...2))
		
		let senderPaths = ["/usr/bin/app", "/System/Library", "/usr/local/bin", "/"]
		self.senderPath = senderPaths.randomElement() ?? "/"
		
		let senderNames = ["iOS", "SpringBoard", "BackBoard", "UIKit", "AppStore"]
		self.senderName = senderNames.randomElement() ?? "iOS"
		
		let processPaths = ["/kernel", "/usr/bin/bash", "/System/Core", "/Applications/MyApp.app"]
		self.processPath = processPaths.randomElement() ?? "/kernel"
		
		let processNames = ["kernel", "bash", "launchd", "installd", "myapp"]
		self.processName = processNames.randomElement() ?? "kernel"
		
		let messages = [
			"System call intercepted.",
			"Anomaly detected in user process.",
			"Connection established successfully.",
			"Permission denied.",
			"Silence! restrain thy tongue, for its ceaseless chatter doth disturb the tranquility of this sacred space."
		]
		self.message = messages.randomElement() ?? "Default log message."
		
		self.label = nil
		self.type = LogMessageEventModel(level)
	}

	#endif
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	static func == (lhs: LogEntryModel, rhs: LogEntryModel) -> Bool {
		return lhs.id == rhs.id
	}
}
