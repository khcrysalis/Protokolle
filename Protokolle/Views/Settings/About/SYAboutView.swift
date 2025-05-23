//
//  SYAboutView.swift
//  syslog
//
//  Created by samara on 22.05.2025.
//

import SwiftUI

struct SYAboutView: View {
    var body: some View {
		ZStack {
			VStack {
				Image(uiImage: (UIImage(named: Bundle.main.iconFileName ?? ""))! )
					.appIconStyle(size: 72)
				
				Text(Bundle.main.name)
					.font(.largeTitle)
					.bold()
					.foregroundStyle(.tint)
				
				HStack(spacing: 4) {
					Text("Version")
					Text(Bundle.main.version)
				}
				.font(.footnote)
				.foregroundStyle(.secondary)
			}
			.ignoresSafeArea(.all)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
		.navigationTitle("About")
    }
}
