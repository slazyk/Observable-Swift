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
    
    var beforeChange : ObserverCollection<ValueType> { get set }
    var afterChange : ObserverCollection<ValueType> { get set }
    
    func __conversion () -> ValueType
}

/// Observable which is a value type. Elementary observables are value types.
protocol UnownableObservable : AnyObservable {
    var value : ValueType { get set }
}

/// Observable which is a reference type. Compound observables are reference types.
protocol OwnableObservable : AnyObservable {
    func ownableSelf() -> AnyObject
}

operator infix <- { }
operator postfix ^ { }

@assignment func ^= <T : UnownableObservable> (inout x: T, y: T.ValueType) {
    x.value = y
}

func <- <T : UnownableObservable> (inout x: T, y: T.ValueType) {
    x.value = y
}

@postfix func ^ <T : AnyObservable> (x: T) -> T.ValueType {
    return x.value
}
