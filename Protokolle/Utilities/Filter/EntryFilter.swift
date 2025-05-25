//
//  EntryFilter.swift
//  Antoine
//
//  Created by Serena on 09/12/2022
//

import Foundation

/// A Structure defining the filters that can be used to filter out unwanted entries by the user
struct EntryFilter: Codable, Hashable {
	/// If the entry filter is actually enabled. If
	/// its not enabled, nothing will be filtered
	var isEnabled: Bool = false
	/// Array containing our custom-made filters
	var customFilters: [CustomFilter] = []
	/// Set containing our accepted types, i.e. `.debug`
	var acceptedTypes: Set<LogMessageEventModel> = Set(LogMessageEventModel.allCases)
	
	init(customFilters: [CustomFilter] = []) {
		self.customFilters = customFilters
	}
	
	/// Determines whether a LogEntryModel is accepted
	/// - Parameter entry: Entry model
	/// - Returns: Bool if the entry is considered a 'pass'
	func entryPassesFilter(_ entry: LogEntryModel) -> Bool {
		if !isEnabled { return true }
		
		// if the entry contains an accepted type, it is considered a "pass", at least here
		let typeCheck: Bool
		if let level = LogMessageEventModel(entry.level) {
			typeCheck = acceptedTypes.contains(level)
		} else {
			typeCheck = false
		}
		
		// only type check if theres no filters
		guard !customFilters.isEmpty else { return typeCheck }
		
		
		let filterGroups = Dictionary(grouping: customFilters) { filter in
			filter.type
		}
		
		// all filter groups must pass (AND logic between groups)
		// we also got positive and negative filters, contains will
		// override doesntcontain, etc....
		
		let allGroupsPass = filterGroups.allSatisfy { (fieldType, filters) in
			let positiveFilters = filters.filter { filter in
				switch filter.mode {
				case .equalTo, .contains, .startsWith, .endsWith:
					return true
				case .notEqualTo, .doesntContain:
					return false
				}
			}

			let negativeFilters = filters.filter { filter in
				switch filter.mode {
				case .notEqualTo, .doesntContain:
					return true
				case .equalTo, .contains, .startsWith, .endsWith:
					return false
				}
			}
			
			let valueToMatch: String? = {
				switch fieldType {
				case .message: return entry.message
				case .process: return entry.processName
				case .subsystem: return entry.label?.subsystem
				case .category: return entry.label?.category
				case .pid: return entry.pid.description
				case .any: return nil
				}
			}()
			
			// .any is a special edge case
			if fieldType == .any {
				let fieldsToCheck: [String?] = [
					entry.message,
					entry.processName,
					entry.label?.subsystem,
					entry.label?.category,
					entry.pid.description
				]
				
				// for positive filters: at least one must match (OR)
				let positivePass = positiveFilters.isEmpty || positiveFilters.contains { filter in
					let trimmed = filter.value.trimmingCharacters(in: .whitespacesAndNewlines)
					guard !trimmed.isEmpty else { return false }
					let matcher = TextFilter(text: trimmed, mode: filter.mode)
					return fieldsToCheck.contains { matcher.matches($0) }
				}
				
				// for negative filters: all must pass (AND)
				let negativePass = negativeFilters.allSatisfy { filter in
					let trimmed = filter.value.trimmingCharacters(in: .whitespacesAndNewlines)
					guard !trimmed.isEmpty else { return true }
					let matcher = TextFilter(text: trimmed, mode: filter.mode)
					return fieldsToCheck.allSatisfy { matcher.matches($0) }
				}
				
				return positivePass && negativePass
			}
			
			// for positive filters: at least one must match (OR)
			let positivePass = positiveFilters.isEmpty || positiveFilters.contains { filter in
				let trimmed = filter.value.trimmingCharacters(in: .whitespacesAndNewlines)
				guard !trimmed.isEmpty else { return false }
				let matcher = TextFilter(text: trimmed, mode: filter.mode)
				return matcher.matches(valueToMatch)
			}
			
			// for negative filters: all must pass (AND)
			let negativePass = negativeFilters.allSatisfy { filter in
				let trimmed = filter.value.trimmingCharacters(in: .whitespacesAndNewlines)
				guard !trimmed.isEmpty else { return true }
				let matcher = TextFilter(text: trimmed, mode: filter.mode)
				return matcher.matches(valueToMatch)
			}
			
			return positivePass && negativePass
		}
		
		return typeCheck && allGroupsPass
	}

}

extension EntryFilter {
	enum AdditionalFilterType: String, Codable, CaseIterable {
		case any
		case message
		case process
		case subsystem
		case category
		case pid
	}
	
	struct CustomFilter: Codable, Hashable, Identifiable {
		var id: UUID = UUID()
		/// Filter type
		var type: AdditionalFilterType = .any
		/// Filter value
		var value: String = ""
		/// Filter mode
		var mode: TextFilter.Mode = .contains
	}
}
