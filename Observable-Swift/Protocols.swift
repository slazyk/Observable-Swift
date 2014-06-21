//
//  Protocols.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 21/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

/// Arbitrary observable.
protocol AnyObservable {
    typealias ValueType
    
    var value : ValueType { get }
    
    var beforeChange : Event<(ValueType, ValueType)> { get set }
    var afterChange : Event<(ValueType, ValueType)> { get set }
    
    func __conversion () -> ValueType
}

/// Observable which can be written to
protocol WritableObservable : AnyObservable {
    var value : ValueType { get set }
}

/// Observable which is a value type. Elementary observables are value types.
protocol UnownableObservable : WritableObservable {

}

/// Observable which is a reference type. Compound observables are reference types.
protocol OwnableObservable : AnyObservable {
    func ownableSelf() -> AnyObject
}

// observable <- value
operator infix <- { }

// value = observable^
operator postfix ^ { }

// observable ^= value
@assignment func ^= <T : WritableObservable> (inout x: T, y: T.ValueType) {
    x.value = y
}

// observable += { (old, new) in ... }
@assignment func += <T : WritableObservable> (inout x: T, y: (T.ValueType, T.ValueType) -> ()) -> EventSubscription<(T.ValueType, T.ValueType)> {
    return x.afterChange += y
}

// observable += { new in ... }
@assignment func += <T : WritableObservable> (inout x: T, y: T.ValueType -> ()) -> EventSubscription<(T.ValueType, T.ValueType)> {
    return x.afterChange += y
}

// observable.{before,after}Change += { (old, new) in ... }
@assignment func += <T> (inout event: Event<(T, T)>, handler: T -> ()) -> Event<(T, T)>.SubscriptionType {
    return event.add({ (_,x) in handler(x) })
}

// for observable values on variables
func <- <T : protocol<WritableObservable, UnownableObservable>> (inout x: T, y: T.ValueType) {
    x.value = y
}

// for observable references on variables or constants
func <- <T : protocol<WritableObservable, OwnableObservable>> (var x: T, y: T.ValueType) {
    x.value = y
}

@postfix func ^ <T : AnyObservable> (x: T) -> T.ValueType {
    return x.value
}
