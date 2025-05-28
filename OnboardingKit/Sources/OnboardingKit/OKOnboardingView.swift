// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct OKOnboardingView<Content>: View where Content: View {
	@Environment(\.dismiss) private var dismiss
	
	private var _steps: Int
	private var _continueButtonText: String
	private var _backButtonText: String
	private var _gradient: (primary: Color, secondary: Color)
	private var _content: Content
	private let _action: () -> Void
	
	@Binding private var currentStep: Int
	
	public init(
		currentStep: Binding<Int>,
		amountOfSteps: Int,
		continueButtonText: String,
		backButtonText: String,
		backgroundGradient: (primary: Color, secondary: Color),
		@ViewBuilder content: () -> Content,
		dismissAction: @escaping () -> Void
	) {
		self._currentStep = currentStep
		self._steps = amountOfSteps
		self._continueButtonText = continueButtonText
		self._backButtonText = backButtonText
		self._gradient = backgroundGradient
		self._content = content()
		self._action = dismissAction
	}
	
	public var body: some View {
		ZStack {
			ZStack {
				LinearGradient(
					gradient: Gradient(colors: [_gradient.primary, _gradient.secondary]),
					startPoint: .top,
					endPoint: .bottom
				)
				.opacity(currentStep != 0 ? 0.2337 : 1.0)
			}
			.animation(.easeInOut(duration: 0.3), value: currentStep)
			.transition(.opacity)
			.ignoresSafeArea()
			
			VStack {
				Spacer()
				Group {
					_content
				}
				.compatTransition()
				Spacer()
				_buttonRow()
			}
			.padding(30)
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
			.animation(.default, value: currentStep.description)
		}
		.interactiveDismissDisabled()
	}
	
	private func _next() {
		guard currentStep < _steps else { _done(); return }
		_sendImpact()
		currentStep += 1
	}
	
	private func _back() {
		guard currentStep > 0 else { return }
		_sendImpact()
		currentStep -= 1
	}
	
	private func _done() {
		_action()
		dismiss()
	}
	
	private func _sendImpact() {
		let generator = UIImpactFeedbackGenerator(style: .soft)
		generator.impactOccurred()
	}
}

extension OKOnboardingView {
	@ViewBuilder
	private func _buttonRow() -> some View {
		HStack(spacing: 10) {
			Group {
				if currentStep != 0 {
					Button(action: _back) {
						_button(text: _backButtonText)
					}
					Button(action: _next) {
						_button(text: _continueButtonText)
					}
				} else {
					Button(action: _next) {
						_button(text: _continueButtonText)
					}
				}
			}
			.compatTransition()
		}
	}
	
	@ViewBuilder
	private func _button(text: String) -> some View {
		Text(text)
			.foregroundColor(_gradient.secondary)
			.fontWeight(.semibold)
			.padding()
			.frame(maxWidth: .infinity)
			.background(
				LinearGradient(
					gradient: Gradient(colors: [
						.white,
						.white.opacity(0.5)
					]),
					startPoint: .top,
					endPoint: .bottom
				)
			)
			.cornerRadius(12)
			.shadow(color: .black.opacity(0.4), radius: 20, y: 40)
	}
}
