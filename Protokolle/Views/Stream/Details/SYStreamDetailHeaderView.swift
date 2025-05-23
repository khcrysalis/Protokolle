//
//  SYStreamDetailHeaderCell.swift
//  syslog
//
//  Created by samara on 19.05.2025.
//

import UIKit

class SYStreamDetailHeaderView: UIView {
	let padding: CGFloat = 20
	
	let badgeLabel: SYPaddedLabel = {
		let label = SYPaddedLabel()
		label.font = .systemFont(ofSize: 12, weight: .semibold)
		label.textColor = .white
		label.backgroundColor = .systemIndigo
		label.textAlignment = .center
		label.layer.cornerRadius = 6
		label.layer.masksToBounds = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let nameLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize, weight: .bold)
		label.numberOfLines = 1
		label.sizeToFit()
		return label
	}()
	
	let senderLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
		label.textColor = .secondaryLabel
		label.numberOfLines = 1
		label.sizeToFit()
		return label
	}()
	
	let timestampLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
		label.textColor = .secondaryLabel
		label.numberOfLines = 1
		label.sizeToFit()
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setup() {
		[badgeLabel, nameLabel, senderLabel, timestampLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}
		
		badgeLabel.setContentHuggingPriority(.required, for: .horizontal)
		badgeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		
		badgeLabel.setContentHuggingPriority(.required, for: .vertical)
		badgeLabel.setContentCompressionResistancePriority(.required, for: .vertical)

		
		NSLayoutConstraint.activate([
			badgeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 7),
			badgeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
			badgeLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
			badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
			
			nameLabel.topAnchor.constraint(equalTo: topAnchor),
			nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
			nameLabel.trailingAnchor.constraint(equalTo: badgeLabel.leadingAnchor, constant: -3),
			
			senderLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
			senderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
			
			timestampLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
			timestampLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
			timestampLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
		])
	}
	
	func configure(with entry: LogEntryModel) {
		badgeLabel.text = entry.type?.displayText
		badgeLabel.backgroundColor = entry.type?.displayColor?.withAlphaComponent(0.5)
		
		nameLabel.text = entry.processName ?? ""
		senderLabel.text = entry.senderName ?? ""
		
		timestampLabel.text = entry.timestamp.formattedDate()
	}
}
