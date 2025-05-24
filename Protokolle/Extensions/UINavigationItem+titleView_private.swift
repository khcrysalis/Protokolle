//
//  UINavigationItem++.swift
//  Protokolle
//
//  Created by samara on 23.05.2025.
//

import UIKit.UINavigationItem

extension UINavigationItem {
	func setupNavigationTitleView() -> UIView {
		let classNameBase64 = "X1VJTmF2aWdhdGlvbkJhclRpdGxlVmlldw==" // _UINavigationBarTitleView
		
		guard
			let classNameData = Data(base64Encoded: classNameBase64),
			let className = String(data: classNameData, encoding: .utf8),
			let titleViewClass = NSClassFromString(className) as? UIView.Type
		else {
			return UIView()
		}
		
		let titleView = titleViewClass.init()
		self.titleView = titleView
		return titleView
	}
	
	func setHeightForNavigationTitleView(with height: CGFloat) {
		let selectorBase64 = "c2V0SGVpZ2h0Og==" // setHeight:
		
		guard
			let selectorData = Data(base64Encoded: selectorBase64),
			let selectorName = String(data: selectorData, encoding: .utf8)
		else {
			return
		}
		
		self.titleView?.perform(NSSelectorFromString(selectorName), with: height)
	}
}
