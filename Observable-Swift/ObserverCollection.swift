//
//  ObserverCollection.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 20/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

// Implemented as a struct to have desired value and mutability sementics.

/// A struct representing a collection os observers with means to add, remove and notify them.
struct ObserverCollection<T> {
    
    typealias ObserverType = Observer<T>
    
    typealias HandlerType = ObserverType.HandlerType
    
    typealias SimpleHandlerType = ObserverType.SimpleHandlerType
    
    /// @protected array of observers
    var _observers = ObserverType[]()
    
    /// Notify all valid observers of the change. Remove invalid ones.
    mutating func notify(#oldValue : T, newValue : T) {
        _observers = _observers.filter { $0.valid() }
        for observer in _observers {
            observer.handler(oldValue: oldValue, newValue: newValue)
        }
    }
    
    /// Add an Observer object. NOTE: You can add one observer multiple times.
    mutating func add(observer: ObserverType) -> ObserverType {
        _observers += observer
        return observer
    }
    
    /// Create, add and return an Observer with given handler and no owner.
    mutating func add(handler : HandlerType) -> ObserverType {
        return add(Observer(nil, handler))
    }
    
    /// Create, add and return an Observer with given simple handler and no owner.
    mutating func add(handler : SimpleHandlerType) -> ObserverType {
        return add({ (_, x) in handler(newValue: x) })
    }
    
    /// Remove given Observer, if present.
    mutating func remove(observer : ObserverType) {
        var newObservers = ObserverType[]()
        var first = true
        for existing in _observers {
            if first && existing === observer {
                first = false
            } else {
                newObservers += existing
            }
        }
        _observers = newObservers
    }
    
    /// Create, add and return an Observer with given handler and owner.
    mutating func add(#owner : AnyObject, _ handler : HandlerType) -> ObserverType {
        return add(Observer(owner, handler))
    }
    
    /// Create, add and return an Observer with given simple handler and owner.
    mutating func add(#owner : AnyObject, _ handler : SimpleHandlerType) -> ObserverType {
        return add(owner: owner, { (_, x) in handler(newValue: x) })
    }
    
}

@assignment func += <T> (inout collection: ObserverCollection<T>, handler: ObserverCollection<T>.HandlerType) -> ObserverCollection<T>.ObserverType {
    return collection.add(handler)
}

@assignment func += <T> (inout collection: ObserverCollection<T>, handler: ObserverCollection<T>.SimpleHandlerType) -> ObserverCollection<T>.ObserverType {
    return collection.add(handler)
}

@assignment func -= <T> (inout collection: ObserverCollection<T>, observer: ObserverCollection<T>.ObserverType) {
    return collection.remove(observer)
}
