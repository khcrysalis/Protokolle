//
//  SYContainerViewController.swift
//  syslog
//
//  Created by samara on 17.05.2025.
//

import UIKit
import class SwiftUI.UIHostingController

// MARK: - Class
class SYMenuContainerViewController: UIViewController {
	var menuController: UIViewController!
	var centerController: UIViewController!
	var isExpanded = false
	
	private var menuWidth: CGFloat {
		view.bounds.width * (UIDevice.current.userInterfaceIdiom == .pad ? 0.33 : 0.87)
	}
	
	private var menuLeadingConstraint: NSLayoutConstraint!
	private var menuWidthConstraint: NSLayoutConstraint!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViewController()
		setupMenuController()
		configureGestures()
	}
	
	// MARK: Setup
	
	func setupViewController() {
		let controller = SYStreamViewController(collectionViewLayout: .padded())
		controller.menuDelegate = self
		centerController = UINavigationController(rootViewController: controller)
		
		view.addSubview(centerController.view)
		addChild(centerController)
		centerController.didMove(toParent: self)
		
		centerController.view.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			centerController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			centerController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			centerController.view.topAnchor.constraint(equalTo: view.topAnchor),
			centerController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
	
	func setupMenuController() {
		menuController = UIHostingController(rootView: SYSettingsView())
		
		view.insertSubview(menuController.view, at: 0)
		addChild(menuController)
		menuController.didMove(toParent: self)
		
		menuController.view.translatesAutoresizingMaskIntoConstraints = false
		
		menuLeadingConstraint = menuController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -menuWidth)
		menuWidthConstraint = menuController.view.widthAnchor.constraint(equalToConstant: menuWidth)
		
		let borderView = UIView()
		borderView.backgroundColor = .systemGray4.withAlphaComponent(0.3)
		borderView.translatesAutoresizingMaskIntoConstraints = false
		menuController.view.addSubview(borderView)
		
		NSLayoutConstraint.activate([
			menuLeadingConstraint,
			menuWidthConstraint,
			menuController.view.topAnchor.constraint(equalTo: view.topAnchor),
			menuController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			borderView.widthAnchor.constraint(equalToConstant: 1),
			borderView.topAnchor.constraint(equalTo: menuController.view.topAnchor),
			borderView.bottomAnchor.constraint(equalTo: menuController.view.bottomAnchor),
			borderView.trailingAnchor.constraint(equalTo: menuController.view.trailingAnchor)
		])
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		let newMenuWidth = size.width * (UIDevice.current.userInterfaceIdiom == .pad ? 0.33 : 0.87)
		
		coordinator.animate(alongsideTransition: { [weak self] _ in
			guard let self = self else { return }
			
			// Update the width constraint
			self.menuWidthConstraint.constant = newMenuWidth
			
			if self.isExpanded {
				self.menuLeadingConstraint.constant = 0
				self.centerController.view.transform = CGAffineTransform(translationX: newMenuWidth, y: 0)
			} else {
				self.menuLeadingConstraint.constant = -newMenuWidth
				self.centerController.view.transform = .identity
			}
			
			self.view.layoutIfNeeded()
		})
	}
	
	func configureGestures() {
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
		view.addGestureRecognizer(panGesture)
		
		let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePanGesture(_:)))
		edgeGesture.edges = .left
		view.addGestureRecognizer(edgeGesture)
		
		panGesture.require(toFail: edgeGesture)
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissTap))
		centerController.view.addGestureRecognizer(tapGesture)
		tapGesture.delegate = self
	}
	
	// MARK: Gestures
	
	@objc func handleEdgePanGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
		if !isExpanded {
			handlePanGesture(gesture)
		}
	}
	
	@objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
		let translation = gesture.translation(in: view)
		let velocity = gesture.velocity(in: view)
		let currentMenuWidth = menuWidth
		
		switch gesture.state {
		case .began, .changed:
			var dragAmount = translation.x
			if isExpanded { dragAmount = currentMenuWidth + translation.x }
			dragAmount = max(0, min(currentMenuWidth, dragAmount))
			let progress = dragAmount / currentMenuWidth
			
			menuLeadingConstraint.constant = -currentMenuWidth + dragAmount
			centerController.view.transform = CGAffineTransform(translationX: dragAmount, y: 0)
			centerController.view.alpha = 1.0 - (0.7 * progress)
			
			view.layoutIfNeeded()
		case .ended, .cancelled:
			let currentProgress = isExpanded ?
			1.0 + translation.x / currentMenuWidth :
			translation.x / currentMenuWidth
			
			let positionThreshold: CGFloat = 0.5
			let velocityThreshold: CGFloat = 500
			
			var shouldOpen = currentProgress > positionThreshold
			
			if velocity.x > velocityThreshold {
				shouldOpen = true
			} else if velocity.x < -velocityThreshold {
				shouldOpen = false
			}
			
			isExpanded = shouldOpen
			showMenuController(shouldExpand: shouldOpen)
		default:
			break
		}
	}
	
	@objc func handleDismissTap() {
		if isExpanded {
			isExpanded = false
			showMenuController(shouldExpand: false)
		}
	}
	
	func showMenuController(shouldExpand: Bool) {
		let generator = UIImpactFeedbackGenerator(style: .soft)
		generator.prepare()
		
		// Get current menu width
		let currentMenuWidth = menuWidth
		
		if shouldExpand {
			menuLeadingConstraint.constant = 0
			
			UIView.animate(
				withDuration: 0.5,
				delay: 0,
				usingSpringWithDamping: 0.85,
				initialSpringVelocity: 0,
				options: .curveEaseInOut,
				animations: {
					self.centerController.view.transform = CGAffineTransform(translationX: currentMenuWidth, y: 0)
					self.centerController.view.alpha = 0.3
					generator.impactOccurred()
					self.view.layoutIfNeeded()
				}
			)
		} else {
			menuLeadingConstraint.constant = -currentMenuWidth
			
			UIView.animate(
				withDuration: 0.5,
				delay: 0,
				usingSpringWithDamping: 0.85,
				initialSpringVelocity: 0,
				options: .curveEaseInOut,
				animations: {
					self.centerController.view.transform = .identity
					self.centerController.view.alpha = 1
					generator.impactOccurred()
					self.view.layoutIfNeeded()
				}
			)
		}
	}
}
