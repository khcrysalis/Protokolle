//
//  SYBaseViewController.swift
//  syslog
//
//  Created by samara on 17.05.2025.
//

import UIKit

class SYBaseViewController: UITableViewController {
	init() {
		super.init(style: .insetGrouped)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func dismissController() {
		dismiss(animated: true)
	}
	
	@objc func popController() {
		navigationController?.popViewController(animated: true)
	}
}
