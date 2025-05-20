//
//  SYContainerViewController+delegate.swift
//  syslog
//
//  Created by samara on 20.05.2025.
//

import UIKit.UIGestureRecognizer

// MARK: - SYContainerViewControllerDelegate
extension SYContainerViewController: SYContainerViewDelegate {
	func handleMenuToggle() {
		isExpanded.toggle()
		showMenuController(shouldExpand: isExpanded)
	}
}

// MARK: - UIGestureRecognizerDelegate
extension SYContainerViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		return isExpanded
	}
}
