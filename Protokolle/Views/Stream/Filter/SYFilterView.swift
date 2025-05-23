//
//  SYFilterView.swift
//  syslog
//
//  Created by samara on 22.05.2025.
//

import SwiftUI

// MARK: - View
struct SYFilterView: View {
	@Environment(\.dismiss) private var dismiss

	@State var entryFilter = Preferences.entryFilter ?? EntryFilter() {
		didSet {
			dump(entryFilter)
		}
	}
	
	// MARK: Body
	
	var body: some View {
		SYNavigationView("Filter", displayMode: .inline) {
			Form {
				Section { Toggle("Enabled", isOn: $entryFilter.isEnabled) }
				
				Group {
					_add()
					_allowed()
				}
				.disabled(!entryFilter.isEnabled)
			}
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						Preferences.entryFilter = entryFilter
						dismiss()
					}
				}
			}
		}
	}
	
	func binding(for model: LogMessageEventModel) -> Binding<Bool> {
		Binding<Bool>(
			get: {
				entryFilter.acceptedTypes.contains(model)
			},
			set: { isOn in
				if isOn {
					entryFilter.acceptedTypes.insert(model)
				} else {
					entryFilter.acceptedTypes.remove(model)
				}
			}
		)
	}
}

// MARK: - View extension
extension SYFilterView {
	@ViewBuilder
	private func _add() -> some View {
		Section("Filters") {
			Button("New Filter") {
				let blankFilter = EntryFilter.CustomFilter(type: .any, mode: .contains)
				entryFilter.customFilters.append(blankFilter)
			}
			
			ForEach($entryFilter.customFilters, id: \.id) { $filter in
				HStack {
					TextField("Value", text: $filter.value)
						.frame(maxWidth: .infinity, alignment: .leading)
					
					Group {
						Picker("Field", selection: $filter.type) {
							ForEach(EntryFilter.AdditionalFilterType.allCases, id: \.self) { type in
								Text(type.rawValue.capitalized)
							}
						}
						
						Picker("Mode", selection: $filter.mode) {
							ForEach(TextFilter.Mode.allCases, id: \.self) { mode in
								Text(mode.description)
							}
						}
					}
					.labelsHidden()
				}
			}
			.onDelete { indexSet in
				entryFilter.customFilters.remove(atOffsets: indexSet)
			}
		}
	}
	
	@ViewBuilder
	private func _allowed() -> some View {
		Section("Allowed Types") {
			ForEach(LogMessageEventModel.allCases, id: \.rawValue) { model in
				Toggle(model.displayText, isOn: binding(for: model))
			}
		}
	}
}
