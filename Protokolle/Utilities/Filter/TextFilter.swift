//
//  TextComparisonMode.swift
//  Antoine
//
//  Created by Serena on 10/12/2022
//

import Foundation

struct TextFilter: Codable, Hashable {
    static func == (lhs: TextFilter, rhs: TextFilter) -> Bool {
        return lhs.mode == rhs.mode && lhs.text == rhs.text
    }
    
    /// Describes an empty text filter.
    static let empty = TextFilter(text: "")
    
    let mode: Mode
    var text: String
    private var _comparor: (String) -> Bool
    
    func matches(_ str: String) -> Bool {
        _comparor(str)
    }
    
    func matches(_ optionalStr: String?) -> Bool {
        if let optionalStr { return _comparor(optionalStr) }
        return false
    }
    
	init(text: String, mode: Mode = .contains) {
        self.mode = mode
        self.text = text
        
        // NOTE: - DO NOT embed the switch in `comparor = { ... }`
        // that'll cause the switch to activate every time comparor is called,
        // which we want to avoid, for performance reasons
        
        // (not wanting the switch to happen *every time* a entry passes when a filter is active)
        switch mode {
        case .equalTo:
            _comparor = { other in
                return text == other
            }
        case .notEqualTo:
            _comparor = { other in
                return text != other
            }
        case .contains:
            _comparor = { other in
                return other.contains(text)
            }
        case .doesntContain:
            _comparor = { other in
                return !other.contains(text)
            }
        case .startsWith:
            _comparor = { other in
                return other.starts(with: text)
            }
        case .endsWith:
            _comparor = { other in
                return other.hasSuffix(text)
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var keyed = encoder.container(keyedBy: CodingKeys.self)
        try keyed.encode(mode, forKey: .mode)
        try keyed.encode(text, forKey: .text)
    }
    
    init(from decoder: Decoder) throws {
        let keyed = try decoder.container(keyedBy: CodingKeys.self)
        let mode = try keyed.decode(Mode.self, forKey: .mode)
        let text = try keyed.decode(String.self, forKey: .text)
        
        self.init(text: text, mode: mode)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(mode)
        hasher.combine(text)
    }
    
    enum CodingKeys: CodingKey {
        case mode
        case text
    }
    
    /// The text comparison mode used between the text given and the target entry text.
    enum Mode: Codable, Hashable, CustomStringConvertible, CaseIterable {
        // all cases, but the ones that should be together are put in an array.
        static let allCasesSectioned: [[Mode]] = [
            [ .equalTo, .notEqualTo],
            [.contains, .doesntContain],
            [.startsWith, .endsWith]
        ]
        
        case equalTo
        case notEqualTo
        
        case contains
        case doesntContain
        
        case startsWith
        case endsWith
        
        var description: String {
            switch self {
            case .equalTo:
                return "Equal To"
            case .notEqualTo:
                return "Not Equal To"
            case .contains:
                return "Contains"
            case .doesntContain:
                return "Doesn't Contain"
            case .startsWith:
                return "Starts With"
            case .endsWith:
                return "Ends With"
            }
        }
    }
}

