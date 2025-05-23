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
		showDot: Bool = false,
		target: NSObject? = nil,
		action: Selector? = nil
	) {
		let button = UIButton(type: .system)
		button.tintColor = .tintColor
		
		var config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight, scale: scale)
		let paletteColors: [UIColor] = highlighted ? [.white, .tintColor] : [.tintColor, .quaternarySystemFill]
		config = config.applying(UIImage.SymbolConfiguration(paletteColors: paletteColors))
		
		let image = UIImage(systemName: systemImageName, withConfiguration: config)
		button.setImage(image, for: .normal)
		button.addTarget(target, action: action ?? #selector(dummySelector), for: .touchUpInside)
		button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
		
		if showDot {
			let dotSize: CGFloat = 8
			let dotView = UIView(frame: CGRect(x: button.frame.width - dotSize - 2, y: 4, width: dotSize, height: dotSize))
			dotView.backgroundColor = .tintColor
			dotView.layer.cornerRadius = dotSize / 2
			dotView.tag = 999
			dotView.isUserInteractionEnabled = false
			button.addSubview(dotView)
		}
		
		self.init(customView: button)
	}
	
	func updateImage(systemImageName: String, highlighted: Bool, showDot: Bool = false) {
		guard let button = self.customView as? UIButton else { return }
		
		var config = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular, scale: .large)
		let paletteColors: [UIColor] = highlighted ? [.white, .tintColor] : [.tintColor, .quaternarySystemFill]
		config = config.applying(UIImage.SymbolConfiguration(paletteColors: paletteColors))
		
		let image = UIImage(systemName: systemImageName, withConfiguration: config)
		button.setImage(image, for: .normal)
		
		if let dotView = button.viewWithTag(999) {
			dotView.isHidden = !showDot
		} else if showDot {
			let dotSize: CGFloat = 8
			let dotView = UIView(frame: CGRect(x: button.frame.width - dotSize - 2, y: 4, width: dotSize, height: dotSize))
			dotView.backgroundColor = .tintColor
			dotView.layer.cornerRadius = dotSize / 2
			dotView.tag = 999
			dotView.isUserInteractionEnabled = false
			button.addSubview(dotView)
		}
	}
	
	@objc private func dummySelector() {}
}
