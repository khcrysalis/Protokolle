//
//  SYAboutView.swift
//  syslog
//
//  Created by samara on 22.05.2025.
//

import SwiftUI

struct SYAboutView: View {
	typealias CreditsDataHandler = Result<[CreditsModel], Error>
	private let _dataService = FetchService()
	
	@State private var _credits: [CreditsModel] = []
	@State private var _donators: [CreditsModel] = []
	@State var isLoading = true
	
	private let _creditsUrl = "https://raw.githubusercontent.com/khcrysalis/project-credits/refs/heads/main/protokolle/credits.json"
	private let _donatorsUrl = "https://raw.githubusercontent.com/khcrysalis/project-credits/refs/heads/main/sponsors/credits.json"
	
    var body: some View {
		Form {
			Section {
				VStack {
					Image(uiImage: (UIImage(named: Bundle.main.iconFileName ?? ""))! )
						.appIconStyle(size: 72)
					
					Text(Bundle.main.name)
						.font(.largeTitle)
						.bold()
						.foregroundStyle(.tint)
					
					HStack(spacing: 4) {
						Text(.localized("Version"))
						Text(Bundle.main.version)
					}
					.font(.footnote)
					.foregroundStyle(.secondary)
					
				}
			}
			.frame(maxWidth: .infinity)
			.listRowBackground(EmptyView())
			
			Section(.localized("Credits")) {
				if !_credits.isEmpty {
					ForEach(_credits, id: \.github) { credit in
						_credit(name: credit.name, desc: credit.desc, github: credit.github)
					}
					.transition(.slide)
				}
			}
			
			Section(.localized("Sponsors")) {
				if !_donators.isEmpty {
					Group {
						Text(try! AttributedString(markdown: _donators.map {
							"[\($0.name ?? $0.github)](https://github.com/\($0.github))"
						}.joined(separator: ", ")))
						
						Text(.localized("💚 This couldn't of been done without my sponsors!"))
							.foregroundStyle(.secondary)
							.padding(.vertical, 2)
					}
					.transition(.slide)
				}
			}
		}
		.navigationTitle(.localized("About"))
		.animation(.default, value: isLoading)
		.task {
			await _fetchAllData()
		}
    }
	
	private func _fetchAllData() async {
		await withTaskGroup(of: (String, CreditsDataHandler).self) { group in
			group.addTask { return await _fetchCredits(self._creditsUrl, using: _dataService) }
			group.addTask { return await _fetchCredits(self._donatorsUrl, using: _dataService) }
			
			for await (type, result) in group {
				await MainActor.run {
					switch result {
					case .success(let data):
						if type == "credits" {
							self._credits = data
						} else {
							self._donators = data
						}
					case .failure(_): break
					}
				}
			}
		}
		
		await MainActor.run {
			isLoading = false
		}
	}
	
	private func _fetchCredits(_ urlString: String, using service: FetchService) async -> (String, CreditsDataHandler) {
		let type = urlString == _creditsUrl
		? "credits"
		: "donators"
		
		return await withCheckedContinuation { continuation in
			service.fetch(from: urlString) { (result: CreditsDataHandler) in
				continuation.resume(returning: (type, result))
			}
		}
	}
}

// MARK: - Extension: view
extension SYAboutView {
	@ViewBuilder
	private func _credit(
		name: String?,
		desc: String?,
		github: String
	) -> some View {
		Button {
			UIApplication.open("https://github.com/\(github)")
		} label: {
			VStack(alignment: .leading, spacing: 2) {
				Text(name ?? github)
					.font(.headline)
				Text(desc ?? "")
					.font(.subheadline)
					.foregroundColor(.secondary)
			}
		}
	}
}

