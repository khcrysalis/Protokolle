//
//  SYPipViewController.swift
//  Protokolle
//
//  Created by samara on 23.05.2025.
//

/*
import UIKit
import UIPiPView

class SYPipViewController: UIViewController {
	var messages: [String] = ["Le stream"]
	private var batchedMessages: [String] = []
	private let batchQueue = DispatchQueue(label: "log.batch.queue", qos: .userInitiated)
	
	private let pipView = UIPiPView()
	private var timer: Timer?
	
	lazy var logManager: SystemLogManager = {
		let stream = SystemLogManager()
		stream.delegate = self
		return stream
	}()
	
	private let textView: UITextView = {
		let textView = UITextView()
		textView.isEditable = false
		textView.isSelectable = false
		textView.font = UIFont.monospacedSystemFont(ofSize: 7, weight: .regular)
		textView.backgroundColor = .black
		textView.textColor = .white
		textView.translatesAutoresizingMaskIntoConstraints = false
		return textView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		setupTextView()
		startTimer()
		updateMessages()
	}
	
	private func setupTextView() {
		let width: CGFloat = 240
		let height: CGFloat = 120
		let margin = ((view.bounds.width - width) / 2)
		
		pipView.frame = CGRect(x: margin, y: 160, width: width, height: height)
		pipView.backgroundColor = .black
		view.addSubview(pipView)
		
		textView.frame = pipView.bounds
		textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		pipView.addSubview(textView)
	}
	
	@objc func toggle() {
		Task { [weak self] in
			guard let self else { return }
			
			await MainActor.run {
				if self.pipView.isPictureInPictureActive() {
					self.pipView.stopPictureInPicture()
				} else {
					self.pipView.startPictureInPicture(withRefreshInterval: 1.0 / 60.0)
					
					Task {
						try? await self.logManager.syslog_relay()
					}
				}
			}
		}
	}
	
	private func startTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			self?.flushBatchedMessages()
		}
	}
	
	private func flushBatchedMessages() {
		batchQueue.async { [weak self] in
			guard let self else { return }
			guard !self.batchedMessages.isEmpty else { return }
			
			let newMessages = self.batchedMessages
			self.batchedMessages.removeAll()
			
			DispatchQueue.main.async {
				self.messages.append(contentsOf: newMessages)
				self.updateMessages()
			}
		}
	}
	
	private func updateMessages() {
		textView.text = messages.suffix(500).joined(separator: "\n")
		scrollToBottom()
	}
	
	private func scrollToBottom() {
		guard textView.text.count > 0 else { return }
		let range = NSMakeRange(textView.text.count - 1, 1)
		textView.scrollRangeToVisible(range)
		
		textView.setContentOffset(
			CGPoint(x: 0, y: max(0, textView.contentSize.height - textView.bounds.height)),
			animated: false
		)
	}

	
	deinit {
		timer?.invalidate()
	}
}

// MARK: - Delegate

extension SYPipViewController: SystemLogManagerDelegate {
	func activityStream(didRecieveEntry entry: LogEntryModel) {}
	
	func activityStream(didRecieveString entryString: String) {
		batchQueue.async { [weak self] in
			self?.batchedMessages.append(entryString)
		}
	}
}
 */
