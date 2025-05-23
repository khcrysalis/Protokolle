//
//  Storage.swift
//  Antoine
//
//  Created by Serena on 10/12/2022
//

import Foundation

@propertyWrapper
struct Storage<Value> {
    typealias Callback = (Value) -> Void
    let key: String
    let defaultValue: Value
    let callback: Callback?
    
    init(key: String, defaultValue: Value, callback: Callback? = nil) {
        self.key = key
        self.defaultValue = defaultValue
        self.callback = callback
    }

    var wrappedValue: Value {
        get {
            return UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            callback?(newValue)
        }
    }
}

@propertyWrapper
struct CodableStorage<Value: Codable> {
    typealias Handler = (String, Value) -> Void
    
    var key: String
    var defaultValue: Value
    var handler: Handler? = nil
    
    var wrappedValue: Value {
        get {
            guard let data = UserDefaults.standard.data(forKey: key),
                  let decoded = try? JSONDecoder().decode(Value.self, from: data) else {
                return defaultValue
            }
            
            return decoded
        }
        
        set {
            guard let newData = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(newData, forKey: key)
            handler?(key, newValue)
        }
    }
}
