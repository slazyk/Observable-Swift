//
//  Observable.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 20/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

// Implemented as a struct in order to have desired value and mutability sementics.

/// A struct representing an observable value.
struct Observable<T> : UnownableObservable {
    
    typealias ValueType = T

    var beforeChange = Event<(T, T)>()
    var afterChange = Event<(T, T)>()
    
    var value : T {
    get { return _value() }
    set { _value = { newValue } }
    }
    
    var _value : () -> T {
    willSet { beforeChange.notify(_value(), newValue()) }
    didSet { afterChange.notify(oldValue(), _value()) }
    }
    
    @conversion func __conversion () -> T {
        return value
    }
    
    init(_ v : T) {
        _value = { v }
    }
}
