//
//  SceneDelegate.swift
//  syslog
//
//  Created by samara on 14.05.2025.
//

import UIKit
import SwiftUI
import OnboardingKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var currentScene: UIScene?
	var window: UIWindow?

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		self.currentScene = scene
		guard let windowScene = scene as? UIWindowScene else { return }
		
		let window = UIWindow(windowScene: windowScene)
		let controller = SYMenuContainerViewController()

		window.tintColor = .systemGreen
		window.rootViewController = controller
		window.makeKeyAndVisible()
		self.window = window
		
		#if APPSTORE
		if Preferences.isOnboarding {
			if let topVC = UIApplication.topViewController() {
				let onboardingVC = UIHostingController(rootView: OnboardingView())
				
				if UIDevice.current.userInterfaceIdiom != .pad {
					onboardingVC.modalPresentationStyle = .fullScreen
				}
				topVC.present(onboardingVC, animated: true)
			}
		}
		#endif
	}
	
	func scene(
		_ scene: UIScene,
		openURLContexts URLContexts: Set<UIOpenURLContext>
	) {
		guard
			let url = URLContexts.first?.url,
			url.pathExtension == "protokolle"
		else {
			return
		}
		
		guard
			let data = try? Data(contentsOf: url),
			let decoded = try? JSONDecoder().decode(CodableLogEntry.self, from: data),
			let topController = UIApplication.topViewController()
		else {
			return
		}
		
		let controller = UINavigationController(
			rootViewController: SYStreamDetailViewController(with: decoded.log)
		)
		
		topController.present(
			controller,
			animated: true
		)
	}
}

