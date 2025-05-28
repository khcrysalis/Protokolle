//
//  OnboardingView.swift
//  Protokolle
//
//  Created by samara on 27.05.2025.
//

#if APPSTORE
import SwiftUI
import OnboardingKit

struct OnboardingView: View {
	@State private var currentStep: Int = 0
	
	private let _primaryColor: Color = Color(red: 54 / 255.0, green: 96 / 255.0, blue: 72 / 255.0)
	private let _secondaryColor: Color = Color(red: 67 / 255.0, green: 117 / 255.0, blue: 90 / 255.0)
	private let _prominantTextColor: Color = Color(red: 110 / 255, green: 199 / 255, blue: 152 / 255)
	
	var body: some View {
		OKOnboardingView(
			currentStep: $currentStep,
			amountOfSteps: 2,
			continueButtonText: .localized("Continue"),
			backButtonText: .localized("Back"),
			backgroundGradient: (
				primary: _primaryColor,
				secondary: _secondaryColor
			),
			content: {
				switch currentStep {
				case 0:
					_welcome()
				case 1:
					OKTitleWithDescriptionView(
						.localized("About %@", arguments: Bundle.main.name),
						.localized("This is a console app designed specifically to be used on mobile. It helps streamline testing by allowing users to view the logs of self-developed apps, without sending data to external servers.")
					)
				case 2:
					OKTitleWithDescriptionView(
						.localized("Next Steps"),
						.localized("Pressing continue will prompt you to allow VPN permissions. This is necessary for the app to function properly. The VPN configuration allows your device to securely connect to itself — nothing more. Rest assured, no data is collected or sent externally. Everything stays on your device.")
					)
				default:
					EmptyView()
				}
			},
			dismissAction: {
				Preferences.isOnboarding = false
				TunnelManager.shared.startVPN()
			}
		)
	}
}

extension OnboardingView {
	@ViewBuilder
	private func _welcome() -> some View {
		Group {
			Text(.localized("Welcome to"))
				.foregroundStyle(.white)
			Text(verbatim: Bundle.main.name)
				.foregroundStyle(_prominantTextColor)
		}
		.font(.largeTitle)
		.fontWeight(.heavy)
		.shadow(color: .black.opacity(0.2), radius: 20)
	}
}
#endif
