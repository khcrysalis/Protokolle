//
//  Bundle+versions.swift
//  Loader
//
//  Created by samara on 18.03.2025.
//

import Foundation.NSBundle

extension Bundle {
	/// Get the name of the app
	var name: String {
		if let displayName = object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
			return displayName
		}
		if let name = object(forInfoDictionaryKey: "CFBundleName") as? String {
			return name
		}
		return object(forInfoDictionaryKey: "CFBundleExecutable") as? String ?? ""
	}
	/// Get the "short" version of the app
	var version: String {
		if let version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
			return version
		}
		
		return object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
	}
	/// Check if this app is from the App Store
	var appStoreReceiptExists: Bool {
		guard let receiptURL = Self.main.appStoreReceiptURL else { return false }
		return FileManager.default.fileExists(atPath: receiptURL.path)
	}
	/// Get the icon of the app
	var iconFileName: String? {
		if
			let icons = object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
			let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
			let files = primary["CFBundleIconFiles"] as? [String],
			let name = files.last
		{
			return name
		}
		
		if
			let iPadIcons = object(forInfoDictionaryKey: "CFBundleIcons~ipad") as? [String: Any],
			let primary = iPadIcons["CFBundlePrimaryIcon"] as? [String: Any],
			let files = primary["CFBundleIconFiles"] as? [String],
			let name = files.last
		{
			return name
		}
		
		if
			let iconFiles = object(forInfoDictionaryKey: "CFBundleIconFiles") as? [String],
			let name = iconFiles.last ?? iconFiles.first
		{
			return name
		}
		
		if
			let iPhoneIconFiles = object(forInfoDictionaryKey: "CFBundleIconFiles~iphone") as? [String],
			let name = iPhoneIconFiles.last ?? iPhoneIconFiles.first
		{
			return name
		}
		
		if
			let iPadIconFiles = object(forInfoDictionaryKey: "CFBundleIconFiles~ipad") as? [String],
			let name = iPadIconFiles.last ?? iPadIconFiles.first
		{
			return name
		}
		
		if let iconFile = object(forInfoDictionaryKey: "CFBundleIconFile") as? String {
			return iconFile
		}
		
		return nil
	}
}
