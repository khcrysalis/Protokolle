//
//  SYSettingsView.swift
//  syslog
//
//  Created by samara on 17.05.2025.
//

import SwiftUI

struct SYSettingsView: View {
	@AppStorage("SY.refreshSpeed") var refreshSpeed: Double = 1.0
	@AppStorage("SY.bufferLimit") private var bufferLimit: Int = 75000
	
	private let refreshOptions = 1.0...10
	private let bufferOptions = Array(stride(from: 50_000, through: 150_000, by: 25_000))
	
	private let donationsUrl = "https://github.com/sponsors/khcrysalis"
	private let githubUrl = "https://github.com/khcrysalis/Feather"
	
	var body: some View {
		NavigationStack {
			Form {
				_general()
				
				Section {
					Toggle("Messages in Background", isOn: .constant(true))
						.disabled(true)
				} header: {
					Text("Background")
				} footer: {
					Text("We need Always-On location Authorization in order to enable Background Mode")
				}
				
				Section("Pairing") {
					Text("Tunnel & Pairing")
				}
				
				_feedback()
				_help()
			}
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.large)
			.scrollIndicators(.hidden)
			.onChange(of: refreshSpeed) { _ in
				NotificationCenter.default.post(
					Notification(name: .refreshSpeedDidChange, object: refreshSpeed)
				)
			}
		}
	}
}

extension SYSettingsView {
	
	@ViewBuilder
	private func _general() -> some View {
		Section {
			VStack {
				ZStack {
					Text("Refresh Rate")
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
				Slider(value: $refreshSpeed, in: refreshOptions, step: refreshOptions.lowerBound)
			}
			
			Picker("Message Threshold", selection: $bufferLimit) {
				ForEach(bufferOptions, id: \.self) { value in
					Text("\(value.formatted())").tag(value)
				}
			}
			.pickerStyle(.menu)
		} header: {
			Text("General")
		} footer: {
			Text(
			"""
			Refresh rate will change how often the messages list will refresh at a time.
			
			Message threshold is how many messages you can have at one instance at a time to avoid any excessive RAM usage.
			"""
			)
		}
	}
	
	@ViewBuilder
	private func _feedback() -> some View {
		Section {
			NavigationLink("About", destination: EmptyView())
			Button("GitHub Repository", systemImage: "safari") {
				UIApplication.open(githubUrl)
			}
		}
	}
	
	@ViewBuilder
	private func _help() -> some View {
		Section("Help") {
			Button("Pairing File Guide", systemImage: "questionmark.circle") {
				UIApplication.open("https://github.com/StephenDev0/StikDebug-Guide/blob/main/pairing_file.md")
			}
			Button("Download StosVPN", systemImage: "arrow.down.app") {
				UIApplication.open("https://apps.apple.com/us/app/stosvpn/id6744003051")
			}
		}
	}
}
