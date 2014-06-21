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
    typealias ObserverCollectionType = ObserverCollection<T>
    typealias ObserverType = ObserverCollectionType.ObserverType
    typealias HandlerType = ObserverCollectionType.HandlerType
    typealias SimpleHandlerType = ObserverCollectionType.SimpleHandlerType

    var beforeChange = ObserverCollectionType()
    var afterChange = ObserverCollectionType()
    
    var value : T {
    get { return _value() }
    set { _value = { newValue } }
    }
    
    var _value : () -> T {
    willSet { beforeChange.notify(oldValue: _value(), newValue: newValue()) }
    didSet { afterChange.notify(oldValue: oldValue(), newValue: _value()) }
    }
    
    @conversion func __conversion () -> T {
        return value
    }
    
    init(_ v : T) {
        _value = { v }
    }
    
}
