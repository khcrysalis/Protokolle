//
//  AppDelegate.swift
//  syslog
//
//  Created by samara on 14.05.2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	let heartbeart = HeartbeatManager.shared
	let tunnel = TunnelManager.shared
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		_createDocumentsDirectory()
		tunnel.startVPN()
		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
	
	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
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

