//
//  UIApplication+open.swift
//  NimbleKit
//
//  Created by samara on 30.04.2025.
//

import UIKit.UIApplication

extension UIApplication {
	/// Opens a specified URL
	static public func open(_ url: URL) {
		Self.shared.open(url, options: [:])
	}
	/// Opens a specified urlString
	static public func open(_ urlString: String) {
		Self.shared.open(URL(string: urlString)!, options: [:])
	}
}
