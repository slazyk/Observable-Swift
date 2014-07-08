//
//  Observable.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 20/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

/// A struct representing information associated with value change event.
struct ValueChange<T> {
    let oldValue: T
    let newValue: T
    init(_ o: T, _ n: T) {
        oldValue = o
        newValue = n
    }
}

// Implemented as a struct in order to have desired value and mutability sementics.

/// A struct representing an observable value.
struct Observable<T> : UnownableObservable {
    
    typealias ValueType = T

    var beforeChange = EventReference<ValueChange<T>>()
    var afterChange = EventReference<ValueChange<T>>()
    
    var value : T {
    willSet { beforeChange.notify(ValueChange(value, newValue)) }
    didSet { afterChange.notify(ValueChange(oldValue, value)) }
    }
    
    @conversion func __conversion () -> T {
        return value
    }
    
    mutating func unshare(#removeSubscriptions: Bool) {
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

    init(_ v : T) {
        value = v
    }
}
