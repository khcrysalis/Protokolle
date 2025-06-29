//
//  SYStreamViewController.swift
//  syslog
//
//  Created by samara on 15.05.2025.
//

import UIKit
import SwiftUI
import IDeviceSwift

// MARK: - Class
class SYStreamViewController: UICollectionViewController {
	typealias StreamDataSourceSection = Int
	typealias StreamDataSource = UICollectionViewDiffableDataSource<StreamDataSourceSection, LogEntry>
	typealias StepDataSourceSnapshot = NSDiffableDataSourceSnapshot<StreamDataSourceSection, LogEntry>
	
	var dataSource: StreamDataSource!
	
	// MARK: Labels
	
	var titleLabel: UILabel = {
		let label = UILabel()
		label.text = Bundle.main.name
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
	
	lazy var filterButton: UIBarButtonItem = {
		UIBarButtonItem(systemImageName: "line.3.horizontal.decrease.circle.fill", showDot: filter?.isEnabled ?? false, target: self, action: #selector(filterAction))
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
	
	var automaticallyScrollToBottom: Bool = true
	var userInformedAboutThreshold: Bool = false
	var menuDelegate: SYMenuContainerViewDelegate?
	
	var batch: [LogEntry] = []
	var buffer = Preferences.bufferLimit
	var filter: EntryFilter? = Preferences.entryFilter
	
	lazy var timer = makeTimer()
		
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
		setupToolbar()
		setupDataSource()
		setupCollectionView()
		setupListeners()
		RunLoop.current.add(timer, forMode: .common)
	}
	
	// MARK: Setup
	
	func setupCollectionView() {
		collectionView.isPrefetchingEnabled = true
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
	}
	
	func setupToolbar() {
		let buttons = [
			filterButton,
			playButton,
			downButton,
			UIBarButtonItem(systemImageName: "xmark.circle.fill", target: self, action: #selector(clearAll))
		]
	
		toolbarItems = buttons.flatMap { [$0, UIBarButtonItem.flexibleSpace()] }.dropLast()
		navigationController?.setToolbarHidden(false, animated: false)
	}
	
	func setupDataSource() {
		let cellRegistration = UICollectionView.CellRegistration<SYStreamCollectionViewCell, LogEntry> { cell, indexPath, entry in
			cell.configure(with: entry.log)
		}
		dataSource = StreamDataSource(collectionView: collectionView) { collectionView, indexPath, entry in
			return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: entry)
		}
		var snapshot = dataSource.snapshot()
		snapshot.appendSections([0])
		dataSourceApply(snapshot: snapshot)
	}
	
	func setupListeners() {
		let _ = NotificationCenter.addObserver(
			name: .refreshSpeedDidChange,
			castTo: TimeInterval.self
		) { newValue in
			NSLog("Set timer to \(newValue)")
			self.timer.invalidate()
			self.timer = self.makeTimer(interval: newValue)
			RunLoop.main.add(self.timer, forMode: .common)
		}
		
		let _ = NotificationCenter.addObserver(
			name: .bufferLimitDidChange,
			castTo: Int.self
		) { newValue in
			NSLog("Set buffer to \(newValue)")
			self.buffer = newValue
		}
		
		let _ = NotificationCenter.addObserver(
			name: .isStreamingDidChange,
			castTo: Bool.self
		) { _ in
			let newValue = self.logManager.isStreaming
			NSLog("Is stream running? \(newValue)")
			DispatchQueue.main.async {
				self.playButton.updateImage(
					systemImageName: !newValue ? "play.circle.fill" : "pause.circle.fill",
					highlighted: newValue
				)
				
				if #available(iOS 17.0, *) {
					self.setNeedsUpdateContentUnavailableConfiguration()
				}
			}
		}
		
		let _ = NotificationCenter.addObserver(
			name: .entryFilterDidChange,
			castTo: EntryFilter.self
		) { newValue in
			self.filter = newValue
			
			DispatchQueue.main.async {
				self.filterButton.updateImage(
					systemImageName: "line.3.horizontal.decrease.circle.fill",
					highlighted: false,
					showDot: self.filter?.isEnabled ?? false
				)
			}
		}
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(showInvalidAlert),
			name: .heartbeatInvalidHost,
			object: nil
		)
	}
	
	// MARK: Actions
	
	@objc func settingsAction() {
		menuDelegate?.handleMenuToggle()
	}
	
	@objc func filterAction() {
		let controller = UIHostingController(rootView: SYFilterView())
		present(controller, animated: true)
	}
	
	@objc func scrollAllTheWayDown() {
		let generator = UIImpactFeedbackGenerator(style: .light)
		collectionView.scrollToItem(
			at: IndexPath(row: dataSource.snapshot().numberOfItems - 1, section: 0),
			at: .bottom,
			animated: false
		)
		downButton.isEnabled = false
		automaticallyScrollToBottom = true
		generator.impactOccurred()
	}
	
	@objc func showInvalidAlert() {
		DispatchQueue.main.async {
			UIAlertController.showAlertWithOk(
				title: "InvalidHostID",
				message: .localized("Your pairing file is invalid and is incompatible with your device, please import a valid pairing file.")
			)
		}
	}
}

// MARK: - Class extension: Cells
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
	
	override func collectionView(
		_ collectionView: UICollectionView,
		contextMenuConfigurationForItemAt indexPath: IndexPath,
		point: CGPoint
	) -> UIContextMenuConfiguration? {
		guard let entry = dataSource.itemIdentifier(for: indexPath) else { return nil }
		
		return UIContextMenuConfiguration(
			identifier: indexPath as NSCopying,
			previewProvider: {
				SYStreamDetailViewController(with: entry.log)
			}
		) { _ in
			let copyProcess = UIAction(
				title: .localized("Copy Process"),
				image: UIImage(systemName: "doc.on.clipboard")
			) { _ in
				UIPasteboard.general.string = entry.log.processName
			}
			
			let exportProcess = UIAction(
				title: .localized("Export"),
				image: UIImage(systemName: "square.and.arrow.up")
			) { _ in
				self.export(entry: entry.log)
			}
			
			let hideItems = self.setupFilterActions(for: entry.log, hide: true)
			let showItems = self.setupFilterActions(for: entry.log, hide: false)
			
			let hideMenu = UIMenu(title: .localized("Hide.."), options: .singleSelection, children: hideItems)
			let showMenu = UIMenu(title: .localized("Show.."), options: .singleSelection, children: showItems)
			
			let filterMenus = UIMenu( options: .displayInline, children: [hideMenu, showMenu])

			
			return UIMenu(children: [copyProcess, filterMenus, exportProcess])
		}
	}
		
	override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) {
		guard let controller = animator.previewViewController as? SYStreamDetailViewController else { return }
		
		animator.addCompletion {
			self.presentEntryController(using: controller)
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let entry = dataSource.itemIdentifier(for: indexPath) else { return }
		
		collectionView.deselectItem(at: indexPath, animated: true)
		self.presentEntryController(using: SYStreamDetailViewController(with: entry.log))
	}
	
	@available(iOS 17.0, *)
	override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
		var config: UIContentUnavailableConfiguration?
		if dataSource.snapshot().numberOfItems == 0 {
			let isStreaming = logManager.isStreaming
			
			var buttonConfiguration: UIButton.Configuration
			if isStreaming {
				buttonConfiguration = .borderedProminent()
				buttonConfiguration.baseBackgroundColor = nil
				buttonConfiguration.title = .localized("Stop Streaming")
			} else {
				buttonConfiguration = .bordered()
				buttonConfiguration.baseBackgroundColor = .quaternarySystemFill
				buttonConfiguration.title = .localized("Start Streaming")
			}
			
			buttonConfiguration.cornerStyle = .capsule
			
			var empty = UIContentUnavailableConfiguration.empty()
			empty.background.backgroundColor = .systemBackground
			empty.image = UIImage(systemName: "internaldrive")
			empty.text = .localized("No Messages")
			empty.secondaryText = .localized("Streaming log messages will impact the app’s performance.")
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

// MARK: - Class extension: Filter
extension SYStreamViewController {
	func setupFilterActions(for entry: LogEntryModel, hide: Bool) -> [UIAction] {
		var actions: [UIAction] = []
		
		func action(title: String, handler: @escaping () -> Void) -> UIAction {
			UIAction(title: title) { _ in handler() }
		}
		
		if let processName = entry.processName {
			actions.append(action(title: .localized("Process '%@'", arguments: processName)) {
				self.filterMenuAction(text: processName, filter: .process, hide: hide)
			})
		}
		 
		actions.append(action(title: .localized("PID '%@'", arguments: entry.pid.description)) {
			self.filterMenuAction(text: entry.pid.description, filter: .pid, hide: hide)
		})
		
		if let typeText = entry.type {
			actions.append(action(title: .localized("Type '%@'", arguments: typeText.displayText)) {
				self.modifyAcceptedTypes(for: typeText, hide: hide)
			})
		}
		
		if let subsystem = entry.label?.subsystem {
			actions.append(action(title: .localized("Subsystem '%@'", arguments: subsystem)) {
				self.filterMenuAction(text: subsystem, filter: .subsystem, hide: hide)
			})
		}
		
		if let category = entry.label?.category {
			actions.append(action(title: .localized("Category '%@'", arguments: category)) {
				self.filterMenuAction(text: category, filter: .category, hide: hide)
			})
		}
		
		return actions
	}
	
	func filterMenuAction(text: String, filter: EntryFilter.AdditionalFilterType, hide: Bool) {
		var entryFilter = Preferences.entryFilter ?? EntryFilter()
		entryFilter.isEnabled = true
		
		var filter = EntryFilter.CustomFilter(type: filter, value: text, mode: .doesntContain)
		
		if !hide {
			filter.mode = .contains
		}
		
		entryFilter.customFilters.append(filter)
		Preferences.entryFilter = entryFilter
	}
	
	func modifyAcceptedTypes(for type: LogMessageEventModel, hide: Bool) {
		var entryFilter = Preferences.entryFilter ?? EntryFilter()
		entryFilter.isEnabled = true
		
		if hide {
			if entryFilter.acceptedTypes.contains(type) {
				entryFilter.acceptedTypes.remove(type)
			}
		} else {
			if !entryFilter.acceptedTypes.contains(type) {
				entryFilter.acceptedTypes.insert(type)
			}
		}
		
		Preferences.entryFilter = entryFilter
	}
}

// MARK: - Class extension: Export
extension SYStreamViewController {
	func export(entry: LogEntryModel) {
		let fileManager = FileManager.default
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
		
		guard let data = try? encoder.encode(CodableLogEntry(log: entry)) else {
			return
		}
		
		let fileName = "\(entry.processName ?? "Unknown")_\(entry.timestamp).protokolle"
		let fileURL = fileManager.exports.appendingPathComponent(fileName)
		
		guard fileManager.createFile(atPath: fileURL.path, contents: data) else {
			return
		}
		
		let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
		activityVC.popoverPresentationController?.sourceView = view
		activityVC.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
		
		present(activityVC, animated: true)
	}
}
