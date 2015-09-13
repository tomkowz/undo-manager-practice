//
//  ChangesRecorder.swift
//  UndoAppExample
//
//  Created by Tomasz Szulc on 13/09/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

class ChangesRecorder {
    typealias Key = String
    typealias Value = AnyObject
    
    var dictionary = Dictionary<Key, Value>()
    
    func setValueForKey(key: Key, value: Value?) {
        dictionary[key] = value
    }
    
    func valueForKey(key: Key) -> Value? {
        return dictionary[key]
    }
    
    func reset() {
        dictionary.removeAll()
    }
}