//
//  OKTitleWithDescriptionView.swift
//  OnboardingKit
//
//  Created by samara on 27.05.2025.
//

import SwiftUI

public struct OKTitleWithDescriptionView: View {
	private var _title: String
	private var _desc: String
	
	public init(
		_ title: String,
		_ desc: String
	) {
		self._title = title
		self._desc = desc
	}
	
	public var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Group {
				Text(verbatim: _title)
					.font(.title)
					.fontWeight(.bold)
				Text(verbatim: _desc)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.foregroundStyle(.white)
		}
	}
}
