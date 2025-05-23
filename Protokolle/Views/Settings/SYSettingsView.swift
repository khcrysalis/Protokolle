//
//  SYSettingsView.swift
//  syslog
//
//  Created by samara on 17.05.2025.
//

import SwiftUI

// MARK: - View
struct SYSettingsView: View {
	@AppStorage("SY.refreshSpeed") var refreshSpeed = Preferences.refreshSpeed
	@AppStorage("SY.bufferLimit") var bufferLimit = Preferences.bufferLimit
	
	private let _refreshOptions = 1.0...10
	private let _bufferOptions = Array(stride(from: 50_000, through: 150_000, by: 25_000))
	
	private let _donationsUrl = "https://github.com/sponsors/khcrysalis"
	private let _githubUrl = "https://github.com/khcrysalis/Protokolle"
	
	// MARK: Body
	
	var body: some View {
		SYNavigationView(.localized("Settings"), displayMode: .large) {
			Form {
				_general()
				
				Section(.localized("Pairing")) {
					NavigationLink(.localized("Tunnel & Pairing")) {
						SYTunnelView()
					}
				}
				
				_feedback()
				_help()
			}
		}
		.onChange(of: refreshSpeed) { newValue in
			Preferences.refreshSpeedCallback(newValue: newValue)
		}
		.onChange(of: bufferLimit) { newValue in
			Preferences.bufferLimitCallback(newValue: newValue)
		}
	}
}

// MARK: - View extension
extension SYSettingsView {
	@ViewBuilder
	private func _general() -> some View {
		Section {
			VStack {
				ZStack {
					Text(.localized("Refresh Rate"))
						.frame(maxWidth: .infinity, alignment: .center)
					
					HStack {
						Text(verbatim: String(format: "%.2f", refreshSpeed))
							.foregroundStyle(.tint)
							.font(.subheadline)
							.contentTransition(.numericText())
						
						Spacer()
						
						Text(verbatim: "10.0")
							.foregroundStyle(.secondary)
							.font(.subheadline)
					}
				}
				Slider(value: $refreshSpeed, in: _refreshOptions, step: _refreshOptions.lowerBound)
			}
			
			Picker(.localized("Message Threshold"), selection: $bufferLimit) {
				ForEach(_bufferOptions, id: \.self) { value in
					Text(verbatim: "\(value.formatted())").tag(value)
				}
			}
			.pickerStyle(.menu)
		} header: {
			Text(.localized("General"))
		} footer: {
			Text(.localized("Refresh rate will change how often the messages list will refresh at a time.\n\nWhen the message threshold is succeeded and to avoid any excessive RAM usage we will periodically start deleting previous messages."))
		}
	}
	
	@ViewBuilder
	private func _feedback() -> some View {
		Section {
			NavigationLink(destination: SYAboutView()) {
				Label {
					Text(verbatim: .localized("About %@", arguments: Bundle.main.name))
				} icon: {
					Image(uiImage: UIImage(named: Bundle.main.iconFileName ?? "")!)
						.appIconStyle(size: 23)
				}
			}
			Button(.localized("GitHub Repository"), systemImage: "safari") {
				UIApplication.open(_githubUrl)
			}
			
			Button(.localized("Support My Work"), systemImage: "heart") {
				UIApplication.open(_donationsUrl)
			}
		}
	}
	
	@ViewBuilder
	private func _help() -> some View {
		Section(.localized("Help")) {
			Button(.localized("Pairing File Guide"), systemImage: "questionmark.circle") {
				UIApplication.open("https://github.com/StephenDev0/StikDebug-Guide/blob/main/pairing_file.md")
			}
			Button(.localized("Download StosVPN"), systemImage: "arrow.down.app") {
				UIApplication.open("https://apps.apple.com/us/app/stosvpn/id6744003051")
			}
		}
	}
}
