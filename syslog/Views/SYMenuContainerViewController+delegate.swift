//
//  SYContainerViewController+delegate.swift
//  syslog
//
//  Created by samara on 20.05.2025.
//

import UIKit.UIGestureRecognizer

// MARK: - SYContainerViewControllerDelegate
extension SYMenuContainerViewController: SYMenuContainerViewDelegate {
	func handleMenuToggle() {
		isExpanded.toggle()
		showMenuController(shouldExpand: isExpanded)
	}
}

// MARK: - UIGestureRecognizerDelegate
extension SYMenuContainerViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		return isExpanded
	}
}
