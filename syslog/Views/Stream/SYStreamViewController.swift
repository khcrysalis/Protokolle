//
//  SYStreamViewController.swift
//  syslog
//
//  Created by samara on 15.05.2025.
//

import UIKit
import SwiftUI

// MARK: - Class
class SYStreamViewController: UICollectionViewController {
	typealias StreamDataSourceSection = Int
	typealias StreamDataSource = UICollectionViewDiffableDataSource<StreamDataSourceSection, LogEntryModel>
	typealias StepDataSourceSnapshot = NSDiffableDataSourceSnapshot<StreamDataSourceSection, LogEntryModel>
	
	var dataSource: StreamDataSource!
	
	// MARK: Labels
	
	var titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Console"
		label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .semibold)
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()
	
	var subtitleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
		label.textAlignment = .center
		label.textColor = .secondaryLabel
		label.numberOfLines = 0
		return label
	}()
	
	let numberFormatter: NumberFormatter = {
		let fmt = NumberFormatter()
		fmt.usesGroupingSeparator = true
		fmt.numberStyle = .decimal
		return fmt
	}()
		
	lazy var playButton: UIBarButtonItem = {
		UIBarButtonItem(systemImageName: "play.circle.fill", target: self, action: #selector(stopOrStartStream))
	}()
	
	lazy var downButton: UIBarButtonItem = {
		let button = UIBarButtonItem(systemImageName: "chevron.down.circle.fill", target: self, action: #selector(self.scrollAllTheWayDown))
		button.isEnabled = false
		return button
	}()
	
	// MARK: Variables
	
	lazy var logManager: SystemLogManager = {
		let stream = SystemLogManager()
		stream.delegate = self
		return stream
	}()
	
	let searchController = UISearchController(searchResultsController: nil)
	var automaticallyScrollToBottom: Bool = true
	var menuDelegate: SYMenuContainerViewDelegate?
	
	var batch: [LogEntryModel] = []
	var buffer: Int = UserDefaults.standard.integer(forKey: "SY.bufferLimit")
	
	lazy var timer = makeTimer()
		
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
		setupToolbar()
		setupDataSource()
		setupCollectionView()
		RunLoop.current.add(timer, forMode: .common)
		setupListeners()
	}
	
	// MARK: Setup
	
	func setupCollectionView() {
		collectionView.isPrefetchingEnabled = true
		collectionView.allowsSelection = true
		collectionView.backgroundColor = .secondarySystemBackground
		collectionView.register(
			SYStreamCollectionViewCell.self,
			forCellWithReuseIdentifier: SYStreamCollectionViewCell.reuseIdentifier
		)
	}
	
	func setupNavigation() {
		let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
		stack.axis = .vertical
		navigationItem.titleView = stack
		
		let settingsButton = UIBarButtonItem(systemImageName: "gear.circle.fill", target: self, action: #selector(settingsAction))
		navigationItem.leftBarButtonItems = [settingsButton]
		
		searchController.searchBar.enablesReturnKeyAutomatically = false
		navigationItem.searchController = searchController
	}
	
	func setupToolbar() {
		let buttons = [
			UIBarButtonItem(systemImageName: "magnifyingglass.circle.fill", target: self, action: #selector(searchAction)),
			playButton,
			downButton,
			UIBarButtonItem(systemImageName: "xmark.circle.fill", target: self, action: #selector(clearAll))
		]
	
		toolbarItems = buttons.flatMap { [$0, UIBarButtonItem.flexibleSpace()] }.dropLast()
		navigationController?.setToolbarHidden(false, animated: false)
	}
	
	func setupDataSource() {
		let cellRegistration = UICollectionView.CellRegistration<SYStreamCollectionViewCell, LogEntryModel> { cell, indexPath, itemIdentifier in
			cell.configure(with: itemIdentifier)
		}
		dataSource = StreamDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
			return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
		}
		var snapshot = dataSource.snapshot()
		snapshot.appendSections([0])
		#if DEBUG
		let items = [
			LogEntryModel(),
			LogEntryModel(),
			LogEntryModel()
		]
		snapshot.appendItems(items)
		#endif
		
		dataSourceApply(snapshot: snapshot)
	}
	
	func setupListeners() {
		let _ = NotificationCenter.addObserver(
			name: .refreshSpeedDidChange,
			castTo: TimeInterval.self
		) { newValue in
			self.timer.invalidate()
			self.timer = self.makeTimer(interval: newValue)
			RunLoop.main.add(self.timer, forMode: .common)
		}
		
		let _ = NotificationCenter.addObserver(
			name: .bufferLimitDidChange,
			castTo: Int.self
		) { newValue in
			self.buffer = newValue
		}
	}
	
	// MARK: Actions
	
	@objc func settingsAction() {
		menuDelegate?.handleMenuToggle()
	}
	
	@objc func searchAction() {
		searchController.searchBar.becomeFirstResponder()
	}
	
	@objc func scrollAllTheWayDown() {
		collectionView.scrollToItem(
			at: IndexPath(row: dataSource.snapshot().numberOfItems - 1, section: 0),
			at: .bottom,
			animated: true
		)
		downButton.isEnabled = false
		automaticallyScrollToBottom = true
	}
}

// MARK: - Class extension
extension SYStreamViewController {
	func presentEntryController(using controller: UIViewController) {
		let controller = UINavigationController(rootViewController: controller)
		
		if let sheet = controller.sheetPresentationController {
			sheet.detents = [.medium(), .large()]
			sheet.preferredCornerRadius = 20
			sheet.prefersGrabberVisible = true
		}
		
		present(controller, animated: true)
	}
	
	override func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
		downButton.isEnabled = true
		automaticallyScrollToBottom = false
	}
	
	override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		downButton.isEnabled = true
		automaticallyScrollToBottom = false
	}
	
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let entry = dataSource.itemIdentifier(for: indexPath) else { return nil }
		
		return UIContextMenuConfiguration(
			identifier: indexPath as NSCopying,
			previewProvider: {
				SYStreamDetailViewController(with: entry)
			}
		) { _ in
			let favorite = UIAction(title: "Copy Process", image: UIImage(systemName: "document.on.clipboard")) { action in
				UIPasteboard.general.string = entry.processName
			}
			
			return UIMenu(children: [favorite])
		}
	}
		
	override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) {
		guard let controller = animator.previewViewController as? SYStreamDetailViewController else { return }
		
		animator.addCompletion {
			if UIDevice.current.userInterfaceIdiom == .phone {
				self.presentEntryController(using: controller)
			}
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let entry = dataSource.itemIdentifier(for: indexPath) else { return }
		
		collectionView.deselectItem(at: indexPath, animated: true)
		self.presentEntryController(using: SYStreamDetailViewController(with: entry))
	}
	
	@available(iOS 17.0, *)
	override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
		var config: UIContentUnavailableConfiguration?
		if dataSource.snapshot().numberOfItems == 0 {
			var buttonConfiguration = UIButton.Configuration.bordered()
			buttonConfiguration.cornerStyle = .capsule
			buttonConfiguration.title = "Start Streaming"
			buttonConfiguration.baseBackgroundColor = .quaternarySystemFill
			
			var empty = UIContentUnavailableConfiguration.empty()
			empty.background.backgroundColor = .systemBackground
			empty.image = UIImage(systemName: "internaldrive")
			empty.text = "No Messages"
			empty.secondaryText = "Streaming log messages will impact the apps performance."
			empty.background = .listSidebarCell()
			empty.button = buttonConfiguration
			empty.buttonProperties.primaryAction = UIAction { _ in self.stopOrStartStream() }
			
			config = empty
			contentUnavailableConfiguration = config
			return
		} else {
			contentUnavailableConfiguration = nil
			return
		}
	}
}
