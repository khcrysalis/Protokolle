//
//  SYStreamViewController+stream.swift
//  syslog
//
//  Created by samara on 20.05.2025.
//

import Foundation
import UIKit.UIApplication

// MARK: - Class extension: Stream stuff
extension SYStreamViewController {
	@objc func stopOrStartStream() {
		Task { [weak self] in
			guard let self else { return }
			
			if logManager.isStreaming {
				self.logManager.stop()
			} else {
				do {
					try await self.logManager.os_trace_relay()
				} catch {
					await MainActor.run {
						self.playButton.updateImage(
							systemImageName: "play.circle.fill",
							highlighted: false
						)
						
						UIAlertController.showAlertWithOk(
							title: "Stream",
							message: error.localizedDescription,
							action: {
								HeartbeatManager.shared.start(true)
							}
						)
					}
				}
			}
		}
	}
	
	func dataSourceApply(snapshot: StepDataSourceSnapshot) {
		// https://stackoverflow.com/questions/73242482/uicollectionview-snapshot-takes-too-long-to-re-apply
		// whyyyyy is this so slowwww
		// this may crash lol
		dataSource.applySnapshotUsingReloadData(snapshot) {
			let itemCount = snapshot.numberOfItems
			let label =  "\(String(itemCount).formattedAsDecimal() ?? "0") Messages"
			self.subtitleLabel.text = label
			UIApplication.sceneDelegate?.currentScene?.title = label
		}
	}
	
	func makeTimer(interval: TimeInterval = Preferences.refreshSpeed) -> Timer {
		return Timer(timeInterval: interval, repeats: true) { [self] _  in
			// if we're paused,
			// or collecting logs in background
			// let's stop here, keep the batch for when we do want
			// to display it
			guard
				logManager.isStreaming,
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
		let currentCount = snapshot.numberOfItems
		let newTotalCount = currentCount + batch.count
		
		if newTotalCount > buffer {
			
			if !userInformedAboutThreshold {
				UIAlertController.showAlertWithOk(
					title: "You've reached the threshold",
					message: "To save on performance, we've automatically started clearing logs from the start of the session."
				)
				
				logManager.isStreaming = false
				userInformedAboutThreshold = true
			}
			
			let overflowCount = min(batch.count, currentCount)
			
			let itemsToRemove = snapshot.itemIdentifiers.prefix(overflowCount)
			snapshot.deleteItems(Array(itemsToRemove))
		}
		
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
