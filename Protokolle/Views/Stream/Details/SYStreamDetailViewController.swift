//
//  SYStreamDetailViewController.swift
//  syslog
//
//  Created by samara on 17.05.2025.
//

import UIKit
import IDeviceSwift

// MARK: - Class extension: Unique Item
extension SYStreamDetailViewController {
	struct SYCollectionItem: Hashable {
		let id = UUID()
		let key: String
		let value: String?
		let subItems: [SYCollectionItem]
		let font: UIFont?
		
		init(key: String, value: String? = nil, subItems: [SYCollectionItem] = [], font: UIFont? = nil) {
			self.key = key
			self.value = value
			self.subItems = subItems
			self.font = font
		}
	}
}

// MARK: - Class
class SYStreamDetailViewController: UICollectionViewController {
	typealias CollectionDataSource = UICollectionViewDiffableDataSource<Int, SYCollectionItem>
	
	private var _data: [SYCollectionItem] = []
	
	var entry: LogEntryModel
	var dataSource: CollectionDataSource!
	
	init(with entry: LogEntryModel) {
		self.entry = entry
		super.init(collectionViewLayout: .insetGroupedSidebar())
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let font = UIFont.monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
		
		_data = [
			SYCollectionItem(key: .localized("Message"), subItems: [
				SYCollectionItem(key: entry.message ?? "", font: font)
			]),
			SYCollectionItem(key: .localized("Process"), subItems: [
				SYCollectionItem(key: .localized("Name"), value: entry.processName),
				SYCollectionItem(key: .localized("PID"), value: entry.pid.description),
				SYCollectionItem(key: .localized("Path"), value: entry.processPath ?? "")
			]),
			SYCollectionItem(key: .localized("Sender"), subItems: [
				SYCollectionItem(key: .localized("Name"), value: entry.senderName ?? ""),
				SYCollectionItem(key: .localized("Path"), value: entry.senderPath ?? "")
			]),
			SYCollectionItem(key: .localized("Date"), subItems: [
				SYCollectionItem(key: .localized("Date"), value: entry.timestamp.formattedDate()),
				SYCollectionItem(key: .localized("Timestamp (UNIX Time)"), value: entry.timestamp.description),
			]),
			SYCollectionItem(key: .localized("Category & Subsystem"), subItems: [
				SYCollectionItem(key: .localized("Category"), value: entry.label?.category ?? ""),
				SYCollectionItem(key: .localized("Subsystem"), value: entry.label?.subsystem ?? "")
			]),
			SYCollectionItem(key: .localized("Other"), subItems: [
				SYCollectionItem(key: .localized("Message Type"), value: "\(entry.type?.displayText ?? "") (\(entry.level.description))")
			]),
		]
		
		setupNavigation()
		setupDataSource()
		setupCollectionView()
	}
	
	func setupCollectionView() {
		collectionView.allowsSelection = false
	}
	#warning("fix header constaints for date/sender")
	
	func setupNavigation() {
		let appearance = UINavigationBarAppearance()
		navigationController?.navigationBar.standardAppearance = appearance
		navigationController?.navigationBar.scrollEdgeAppearance = appearance
		
		let titleView = navigationItem.setupNavigationTitleView()
		
		let headerView = SYStreamDetailHeaderView()
		headerView.configure(with: entry)
		headerView.translatesAutoresizingMaskIntoConstraints = false
		titleView.addSubview(headerView)
		
		let padding: CGFloat = 27
		
		NSLayoutConstraint.activate([
			headerView.topAnchor.constraint(equalTo: titleView.topAnchor, constant: padding),
			headerView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
			headerView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
			headerView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor)
		])
		
		let targetSize = CGSize(width: view.frame.width, height: UIView.layoutFittingCompressedSize.height)
		let height = headerView.systemLayoutSizeFitting(targetSize).height + padding
		
		navigationItem.setHeightForNavigationTitleView(with: height)
	}
	
	func setupDataSource() {
		let parentCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SYCollectionItem> { cell, indexPath, model in
			let titleLabel = UILabel()
			titleLabel.translatesAutoresizingMaskIntoConstraints = false
			titleLabel.text = model.key
			titleLabel.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .semibold)
			titleLabel.textColor = .label
			
			cell.contentView.addSubview(titleLabel)
			
			NSLayoutConstraint.activate([
				titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 2),
				titleLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
				titleLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
				titleLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10)
			])
			
			let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header)
			cell.accessories = [.outlineDisclosure(options: disclosureOptions)]
		}
		
		let leafCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SYCollectionItem> { cell, indexPath, model in
			var content = UIListContentConfiguration.valueCell()
			content.text = model.key
			content.secondaryText = model.value
			
			if let font = model.font {
				content.textProperties.font = font
				content.secondaryTextProperties.font = font
			}
			
			cell.contentConfiguration = content
			cell.accessories = []
		}
		
		dataSource = CollectionDataSource(collectionView: collectionView) { collectionView, indexPath, model in
			let reg = model.subItems.isEmpty ? leafCellRegistration : parentCellRegistration
			return collectionView.dequeueConfiguredReusableCell(using: reg, for: indexPath, item: model)
		}
		
		var mainSnapshot = NSDiffableDataSourceSnapshot<Int, SYCollectionItem>()
		for (sectionIndex, parentItem) in _data.enumerated() {
			mainSnapshot.appendSections([sectionIndex])
			mainSnapshot.appendItems([parentItem], toSection: sectionIndex)
		}
		
		dataSource.apply(mainSnapshot, animatingDifferences: false)
		
		for (sectionIndex, parentItem) in _data.enumerated() {
			var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<SYCollectionItem>()
			sectionSnapshot.append([parentItem])
			sectionSnapshot.append(parentItem.subItems, to: parentItem)
			
			sectionSnapshot.expand([parentItem])
			
			dataSource.apply(sectionSnapshot, to: sectionIndex, animatingDifferences: false)
		}
	}
}

// MARK: - Class extension: Cells
extension SYStreamDetailViewController {
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let item = dataSource.itemIdentifier(for: indexPath)
		
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			let copyAction = UIAction(title: .localized("Copy"), image: UIImage(systemName: "doc.on.doc")) { _ in
				UIPasteboard.general.string = item?.value ?? item?.key
			}
			return UIMenu(children: [copyAction])
		}
	}
}
