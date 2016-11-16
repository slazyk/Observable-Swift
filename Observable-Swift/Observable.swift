//
//  Observable.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 20/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

/// A struct representing information associated with value change event.
public struct ValueChange<T> {
    public let oldValue: T
    public let newValue: T
    public init(_ o: T, _ n: T) {
        oldValue = o
        newValue = n
    }
}

// Implemented as a struct in order to have desired value and mutability sementics.

/// A struct representing an observable value.
public struct Observable<T> : UnownableObservable {
    
    public typealias ValueType = T

    public /*internal(set)*/ var beforeChange = EventReference<ValueChange<T>>()
    public /*internal(set)*/ var afterChange = EventReference<ValueChange<T>>()
    
    public var value : T {
    willSet { beforeChange.notify(ValueChange(value, newValue)) }
    didSet { afterChange.notify(ValueChange(oldValue, value)) }
    }
    
    public mutating func unshare(removeSubscriptions: Bool) {
        if removeSubscriptions {
            beforeChange = EventReference<ValueChange<T>>()
            afterChange = EventReference<ValueChange<T>>()
        } else {
            beforeChange = EventReference<ValueChange<T>>(event: beforeChange.event)
            beforeChange.event.unshare()
            afterChange = EventReference<ValueChange<T>>(event: afterChange.event)
            afterChange.event.unshare()
        }
    }

    public init(_ v : T) {
        value = v
    }
}
