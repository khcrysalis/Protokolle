//
//  UIApplication+currentScene.swift
//  syslog
//
//  Created by samara on 22.05.2025.
//

import UIKit.UIApplication

extension UIApplication {
	static var sceneDelegate: SceneDelegate? {
		let scene = UIApplication.shared.connectedScenes
			.first(where: { $0.activationState == .foregroundActive })
		
		return scene?.delegate as? SceneDelegate
	}
	
	static var currentScene: UIScene? {
		var scene: UIScene?
		DispatchQueue.main.async {
			scene = UIApplication.shared.connectedScenes
				.first(where: { $0.activationState == .foregroundActive })
		}
		return scene
	}
}
