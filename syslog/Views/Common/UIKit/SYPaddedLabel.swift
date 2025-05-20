//
//  SYPaddedLabel.swift
//  syslog
//
//  Created by samara on 19.05.2025.
//


import UIKit

class SYPaddedLabel: UILabel {
	var contentInset: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
	
	override func drawText(in rect: CGRect) {
		super.drawText(in: rect.inset(by: contentInset))
	}
	
	override var intrinsicContentSize: CGSize {
		let superContentSize = super.intrinsicContentSize
		let width = superContentSize.width + contentInset.left + contentInset.right
		let height = superContentSize.height + contentInset.top + contentInset.bottom
		return CGSize(width: width, height: height)
	}
}
