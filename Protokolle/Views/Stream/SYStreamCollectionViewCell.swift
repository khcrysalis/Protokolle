//
//  SYStreamCollectionViewCell.swift
//  syslog
//
//  Created by samara on 15.05.2025.
//

import UIKit

// MARK: - Class
class SYStreamCollectionViewCell: UICollectionViewCell {
	let padding: CGFloat = 14
	let cornerRadius: CGFloat = 14
	
	static let reuseIdentifier = "MessageCell"
	
	let nameLabel: UILabel = {
		let nameLabel = UILabel()
		nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
		return nameLabel
	}()
	
	let descriptionLabel: UILabel = {
		let nameLabel = UILabel()
		nameLabel.font = .systemFont(ofSize: 13)
		nameLabel.textColor = .secondaryLabel
		nameLabel.numberOfLines = 2
		return nameLabel
	}()
	
	let dotView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 5
		view.layer.masksToBounds = true
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
		return view
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		_setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var reuseIdentifier: String? {
		return Self.reuseIdentifier
	}
	
	override var isSelected: Bool {
		didSet {
			_updateSelectionAppearance()
		}
	}
	
	private func _updateSelectionAppearance() {
		if isSelected {
			backgroundColor = .systemGray.withAlphaComponent(0.4)
		} else {
			backgroundColor = .quaternarySystemFill
		}
	}
	
	private func _setup() {
		backgroundColor = .quaternarySystemFill
		clipsToBounds = true
		
		layer.cornerRadius = cornerRadius
		layer.cornerCurve = .continuous
		
		[nameLabel, descriptionLabel, dotView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview($0)
		}
		
		dotView.layer.cornerRadius = 5
		dotView.layer.masksToBounds = true
		
		NSLayoutConstraint.activate([
			nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
			nameLabel.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: 9),
			nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
			
			descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
			descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
			descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
			
			dotView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
			dotView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
			dotView.widthAnchor.constraint(equalToConstant: 10),
			dotView.heightAnchor.constraint(equalToConstant: 10)
		])
	}
	
	func configure(with entry: LogEntryModel) {
		nameLabel.text = entry.processName
		descriptionLabel.text = entry.message
		dotView.backgroundColor = entry.type?.displayColor
	}
}
