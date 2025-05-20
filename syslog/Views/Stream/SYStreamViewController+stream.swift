//
//  SYStreamViewController+stream.swift
//  syslog
//
//  Created by samara on 20.05.2025.
//

import Foundation
import UIKit.UIApplication

// MARK: - Class extension
extension SYStreamViewController {
	@objc func stopOrStartStream() {
		let isStreaming = logManager.isStreaming
		playButton.updateImage(systemImageName: !isStreaming ? "pause.circle.fill" : "play.circle.fill", highlighted: !isStreaming)
		
		Task { [weak self] in
			guard let self else { return }
			if self.logManager.isStreaming {
				self.logManager.stop()
			} else {
				try await self.logManager.os_trace_relay()
			}
		}
	}
	
	func dataSourceApply(snapshot: StepDataSourceSnapshot) {
		// https://stackoverflow.com/questions/73242482/uicollectionview-snapshot-takes-too-long-to-re-apply
		// whyyyyy is this so slowwww
		dataSource.applySnapshotUsingReloadData(snapshot) {
			self.subtitleLabel.text = "\(self.numberFormatter.string(from: snapshot.numberOfItems as NSNumber) ?? snapshot.numberOfItems.description) Messages"
		}
	}
	
	func makeTimer(interval: TimeInterval = UserDefaults.standard.double(forKey: "SY.refreshSpeed")) -> Timer {
		return Timer(timeInterval: interval, repeats: true) { [self] _  in
			// if we're paused,
			// or collecting logs in background
			// let's stop here, keep the batch for when we do want
			// to display it
			guard
				logManager.isStreaming == true,
				UIApplication.shared.applicationState != .background
			else {
				return
			}
			
			addBatch()
			
			if #available(iOS 17.0, *) {
				setNeedsUpdateContentUnavailableConfiguration()
			}
			
			if automaticallyScrollToBottom == true {
				scrollAllTheWayDown()
			}
		}
	}
	
	func addBatch() {
		guard !batch.isEmpty else { return }

		var snapshot = dataSource.snapshot()

		snapshot.appendItems(batch)
		batch = []
		dataSourceApply(snapshot: snapshot)
	}
	
	@objc func clearAll() {
		var snapshot: StepDataSourceSnapshot = .init()
		batch = []
		snapshot.appendSections([0])
		dataSourceApply(snapshot: snapshot)
		
		if #available(iOS 17.0, *) {
			setNeedsUpdateContentUnavailableConfiguration()
		}
	}
}
