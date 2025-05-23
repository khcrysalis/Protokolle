//
//  EntryFilter.swift
//  Antoine
//
//  Created by Serena on 09/12/2022
//

import Foundation

/// A Structure defining the filters that can be used to filter out unwanted entries by the user
struct EntryFilter: Codable, Hashable {
	var isEnabled: Bool = false
	var customFilters: [CustomFilter] = []
	
	var acceptedTypes: Set<LogMessageEventModel> = Set(LogMessageEventModel.allCases)
	
	init(customFilters: [CustomFilter] = []) {
		self.customFilters = customFilters
	}
	
	func entryPassesFilter(_ entry: LogEntryModel) -> Bool {
		if !isEnabled { return true }
		
		let typeCheck: Bool
		if let level = LogMessageEventModel(entry.level) {
			typeCheck = acceptedTypes.contains(level)
		} else {
			typeCheck = false
		}

		let hasMatchingCustomFilter = customFilters.allSatisfy { filter in
			let trimmed = filter.value.trimmingCharacters(in: .whitespacesAndNewlines)
			guard !trimmed.isEmpty else { return true }
			
			let matcher = TextFilter(text: trimmed, mode: filter.mode)
			
			if filter.type == .any {
				let fieldsToCheck: [String?] = [
					entry.message,
					entry.processName,
					entry.label?.subsystem,
					entry.label?.category,
					entry.pid.description
				]
				return fieldsToCheck.contains { matcher.matches($0) }
			} else {
				let valueToMatch: String? = {
					switch filter.type {
					case .message: return entry.message
					case .process: return entry.processName
					case .subsystem: return entry.label?.subsystem
					case .category: return entry.label?.category
					case .pid: return entry.pid.description
					case .any: return nil
					}
				}()
				return matcher.matches(valueToMatch)
			}
		}
		
		return typeCheck && hasMatchingCustomFilter
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
		var type: AdditionalFilterType
		var value: String = ""
		var mode: TextFilter.Mode = .contains
	}

}
