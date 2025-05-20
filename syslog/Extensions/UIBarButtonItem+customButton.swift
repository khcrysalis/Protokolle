//
//  UIBarButtonItem+customButton.swift
//  syslog
//
//  Created by samara on 15.05.2025.
//

import UIKit.UIBarButtonItem

extension UIBarButtonItem {
	convenience init(
		systemImageName: String,
		pointSize: CGFloat = 26,
		scale: UIImage.SymbolScale = .large,
		weight: UIImage.SymbolWeight = .regular,
		highlighted: Bool = false,
		target: NSObject? = nil,
		action: ObjectiveC.Selector? = nil
	) {
		var config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight, scale: scale)
		
		if highlighted {
			config = config.applying(UIImage.SymbolConfiguration(paletteColors: [.white, .tintColor]))
		} else {
			config = config.applying(UIImage.SymbolConfiguration(paletteColors: [.tintColor, .quaternarySystemFill]))
		}
			
		let image = UIImage(systemName: systemImageName, withConfiguration: config)
		self.init(image: image, style: .plain, target: target, action: action)
	}
	
	func updateImage(systemImageName: String, highlighted: Bool) {
		var config = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular, scale: .large)
		if highlighted {
			config = config.applying(UIImage.SymbolConfiguration(paletteColors: [.white, .tintColor]))
		} else {
			config = config.applying(UIImage.SymbolConfiguration(paletteColors: [.tintColor, .quaternarySystemFill]))
		}
		self.image = UIImage(systemName: systemImageName, withConfiguration: config)
	}
}
