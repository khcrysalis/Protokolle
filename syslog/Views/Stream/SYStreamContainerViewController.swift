//
//  SYStreamDetailContainerViewController.swift
//  syslog
//
//  Created by samara on 21.05.2025.
//
/*

import UIKit

protocol SYStreamDetailContainerViewDelegate {
	func updateDetailView(with entry: LogEntryModel)
}

class SYStreamDetailContainerViewController: UIViewController {
	var centerController: UIViewController!
	
	private var detailHeight: CGFloat {
		view.bounds.height * 0.27
	}
	
	private var detailContainerView: SYStreamDetailHeaderView!
	private var detailContainerHeightConstraint: NSLayoutConstraint?
	private var centerControllerBottomConstraint: NSLayoutConstraint?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupDetailController()
		setupViewController()
		updateLayoutForCurrentDevice()
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateLayoutForCurrentDevice()
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate(alongsideTransition: { [weak self] _ in
			guard let self = self else { return }
			
			if UIDevice.current.userInterfaceIdiom == .pad {
				let newDetailHeight = size.height * 0.27
				self.detailContainerHeightConstraint?.constant = newDetailHeight
			}
			self.centerController.view.transform = .identity
			self.updateLayoutForCurrentDevice()
			self.view.layoutIfNeeded()
		})
	}
	
	private func updateLayoutForCurrentDevice() {
		if UIDevice.current.userInterfaceIdiom == .pad {
			// Show detail view on iPad
			detailContainerView.isHidden = false
			detailContainerHeightConstraint?.constant = detailHeight
			// Adjust center controller to not overlap with detail
			centerControllerBottomConstraint?.isActive = false
			centerControllerBottomConstraint = centerController.view.bottomAnchor.constraint(equalTo: detailContainerView.topAnchor)
			centerControllerBottomConstraint?.isActive = true
		} else {
			// Hide detail view on iPhone
			detailContainerView.isHidden = true
			detailContainerHeightConstraint?.constant = 0
			// Make center controller fill the entire view
			centerControllerBottomConstraint?.isActive = false
			centerControllerBottomConstraint = centerController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			centerControllerBottomConstraint?.isActive = true
		}
		view.layoutIfNeeded()
	}
	
	func setupDetailController() {
		let containerView = SYStreamDetailHeaderView()
//		containerView.configure(with: entry)
		containerView.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(containerView)
		self.detailContainerView = containerView
		
		let heightConstraint = containerView.heightAnchor.constraint(equalToConstant: detailHeight)
		self.detailContainerHeightConstraint = heightConstraint
		
		NSLayoutConstraint.activate([
			containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			heightConstraint
		])

	}
	
	func setupViewController() {
		let controller = SYStreamViewController(collectionViewLayout: .padded())
//		controller.detailDelegate = self
		centerController = UINavigationController(rootViewController: controller)
		
		addChild(centerController)
		view.addSubview(centerController.view)
		centerController.didMove(toParent: self)
		
		centerController.view.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			centerController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			centerController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			centerController.view.topAnchor.constraint(equalTo: view.topAnchor),
			// Bottom constraint will be set in updateLayoutForCurrentDevice
		])
		
		// Initial setup of the bottom constraint
		centerControllerBottomConstraint = centerController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		centerControllerBottomConstraint?.isActive = true
	}
}

extension SYStreamDetailContainerViewController: SYStreamDetailContainerViewDelegate {
	func updateDetailView(with entry: LogEntryModel) {
		self.detailContainerView.configure(with: entry)
	}
}
*/
