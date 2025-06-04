//
//  AppDelegate.swift
//  syslog
//
//  Created by samara on 14.05.2025.
//

import UIKit
import IDeviceSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	let heartbeart = HeartbeatManager.shared
	
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		_createDocumentsDirectory()
		return true
	}
	
	private func _createDocumentsDirectory() {
		let fileManager = FileManager.default
		let directory = fileManager.exports
		
		try? fileManager.createDirectory(
			at: directory,
			withIntermediateDirectories: true,
			attributes: nil
		)
	}
}

