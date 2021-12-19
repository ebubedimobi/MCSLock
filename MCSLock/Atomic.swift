//
//  Atomic.swift
//  MCSLocck
//
//  Created by Ebubechukwu Dimobi on 19.12.2021.
//

import Foundation

// Since swift doesn't support atomicity from the box
// i have to create my own implementation

struct Atomic<Value: Equatable> {

    private var value: Value?
    private let lock = NSRecursiveLock()

    init(value: Value?) {
        self.value = value
    }

    func get() -> Value? {
        lock.lock()
        defer { lock.unlock() }
        return value
    }

    mutating func set(_ newValue: Value) {
        lock.lock()
        defer { lock.unlock() }
        value = newValue
    }
    
    mutating func getAndSet(_ newValue: Value) -> Value? {
        lock.lock()
        defer { lock.unlock() }
        let oldValue = value
        value = newValue
        return oldValue
    }
    
    mutating func compareAndSet(
        valueToCompare: Value,
        newValue: Value?
    ) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let isSame = value == valueToCompare
        if isSame {
            value = newValue
        }
        return isSame
    }
}

