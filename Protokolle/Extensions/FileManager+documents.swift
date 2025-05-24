//
//  FileManager+documents.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import Foundation.NSFileManager

extension FileManager {
	/// Gives exports directory
	var exports: URL {
		URL.documentsDirectory.appendingPathComponent("Exports")
	}
}
