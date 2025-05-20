//
//  UICollectionView+adaptive.swift
//  syslog
//
//  Created by samara on 15.05.2025.
//

import UIKit.UICollectionViewLayout

extension UICollectionViewLayout {
	static func padded() -> UICollectionViewLayout {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(76))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
		
		let padding: CGFloat = 12
		
		let section = NSCollectionLayoutSection(group: group)
		section.interGroupSpacing = padding
		section.contentInsets = .init(top: .zero, leading: padding, bottom: .zero, trailing: padding)
		
		return UICollectionViewCompositionalLayout(section: section)
	}
	
	static func insetGroupedSidebar() -> UICollectionViewLayout {
		var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		listConfiguration.headerMode = .firstItemInSection
		return UICollectionViewCompositionalLayout.list(using: listConfiguration)
	}
}
