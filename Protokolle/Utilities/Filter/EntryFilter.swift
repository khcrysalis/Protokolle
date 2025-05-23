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
	
	private var _acceptedTypesInternal: [UInt8] = LogMessageEventModel.allCases.map(\.rawValue)
	
	var acceptedTypes: Set<LogMessageEventModel> {
		didSet {
			_acceptedTypesInternal = acceptedTypes.map(\.rawValue)
		}
	}
	
	init(customFilters: [CustomFilter] = []) {
		self.customFilters = customFilters
		self.acceptedTypes = Set(_acceptedTypesInternal.compactMap(LogMessageEventModel.init))
	}
	
	func entryPassesFilter(_ entry: LogEntryModel) -> Bool {
		if !isEnabled { return true }
		
		let textChecks = customFilters.map { filter in
			if filter.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				return true
			}
			
			if filter.type == .any {
				let fieldsToCheck: [String?] = [
					entry.message,
					entry.processName,
					entry.label?.subsystem,
					entry.label?.category,
					entry.pid.description
				]
				
				return fieldsToCheck.contains {
					TextFilter(text: filter.value, mode: filter.mode).matches($0)
				}
			} else {
				let valueToMatch: String? = {
					switch filter.type {
					case .message: return entry.message
					case .process: return entry.processName
					case .subsystem: return entry.label?.subsystem
					case .category: return entry.label?.category
					case .pid: return entry.pid.description
					default: return nil
					}
				}()
				return TextFilter(text: filter.value, mode: filter.mode).matches(valueToMatch)
			}
		}
		
		let typeCheck = _acceptedTypesInternal.contains(entry.level)
		
		let allChecks = textChecks + [typeCheck]
		return allChecks.allSatisfy { $0 }
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
