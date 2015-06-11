//
//  Protocols.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 21/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

/// Arbitrary Event.
public protocol AnyEvent {
    
    typealias ValueType
    
    /// Notify all valid subscriptions of the change. Remove invalid ones.
    mutating func notify(value: ValueType)
    
    /// Add an existing subscription.
    mutating func add(subscription: EventSubscription<ValueType>) -> EventSubscription<ValueType>
    
    /// Create, add and return a subscription for given handler.
    mutating func add(handler : ValueType -> ()) -> EventSubscription<ValueType>
    
    /// Remove given subscription, if present.
    mutating func remove(subscription : EventSubscription<ValueType>)
    
    /// Remove all subscriptions.
    mutating func removeAll()
    
    /// Create, add and return a subscription with given handler and owner.
    mutating func add(owner owner : AnyObject, _ handler : ValueType -> ()) -> EventSubscription<ValueType>

}

/// Event which is a value type.
public protocol UnownableEvent: AnyEvent {

}

/// Event which is a reference type
public protocol OwnableEvent: AnyEvent {

}

/// Arbitrary observable.
public protocol AnyObservable {
    
    typealias ValueType
    
    /// Value of the observable.
    var value : ValueType { get }
    
    /// Event fired before value is changed
    var beforeChange : EventReference<ValueChange<ValueType>> { get }
    
    /// Event fired after value is changed
    var afterChange : EventReference<ValueChange<ValueType>> { get }
}

/// Observable which can be written to
public protocol WritableObservable : AnyObservable {
    var value : ValueType { get set }
}

/// Observable which is a value type. Elementary observables are value types.
public protocol UnownableObservable : WritableObservable {
    /// Unshares events
    mutating func unshare(removeSubscriptions removeSubscriptions: Bool)
}

/// Observable which is a reference type. Compound observables are reference types.
public protocol OwnableObservable : AnyObservable {

}

// observable <- value
infix operator <- { }

// value = observable^
postfix operator ^ { }

// observable ^= value
public func ^= <T : WritableObservable> (inout x: T, y: T.ValueType) {
    x.value = y
}

// observable += { valuechange in ... }
public func += <T : AnyObservable> (inout x: T, y: ValueChange<T.ValueType> -> ()) -> EventSubscription<ValueChange<T.ValueType>> {
    return x.afterChange += y
}

// observable += { (old, new) in ... }
public func += <T : AnyObservable> (inout x: T, y: (T.ValueType, T.ValueType) -> ()) -> EventSubscription<ValueChange<T.ValueType>> {
    return x.afterChange += y
}

// observable += { new in ... }
public func += <T : AnyObservable> (inout x: T, y: T.ValueType -> ()) -> EventSubscription<ValueChange<T.ValueType>> {
    return x.afterChange += y
}

// observable -= subscription
public func -= <T : AnyObservable> (inout x: T, s: EventSubscription<ValueChange<T.ValueType>>) {
    x.afterChange.remove(s)
}

// event += { (old, new) in ... }
public func += <T> (event: EventReference<ValueChange<T>>, handler: (T, T) -> ()) -> EventSubscription<ValueChange<T>> {
    return event.add({ handler($0.oldValue, $0.newValue) })
}

// event += { new in ... }
public func += <T> (event: EventReference<ValueChange<T>>, handler: T -> ()) -> EventSubscription<ValueChange<T>> {
    return event.add({ handler($0.newValue) })
}

// for observable values on variables
public func <- <T : protocol<WritableObservable, UnownableObservable>> (inout x: T, y: T.ValueType) {
    x.value = y
}

// for observable references on variables or constants
public func <- <T : protocol<WritableObservable, OwnableObservable>> (var x: T, y: T.ValueType) {
    x.value = y
}

public postfix func ^ <T : AnyObservable> (x: T) -> T.ValueType {
    return x.value
}
