//
//  FileManager++.swift
//  syslog
//
//  Created by samara on 20.05.2025.
//

import Foundation.NSFileManager

extension FileManager {
	func removeFileIfNeeded(at url: URL) throws {
		if self.fileExists(atPath: url.path) {
			try self.removeItem(at: url)
		}
	}
}
