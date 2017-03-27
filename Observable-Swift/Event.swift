//
//  Event.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 21/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

// Events are implemented as structs, what has both advantages and disadvantages
// Notably they are copied when inside other value types, and mutated on add/remove/notify
// If you require a reference type for Event, use EventReference<T> instead

/// A struct representing a collection of subscriptions with means to add, remove and notify them.
public struct Event<T>: UnownableEvent {
    public typealias ValueType = T
    public typealias SubscriptionType = EventSubscription<T>
    public typealias HandlerType = SubscriptionType.HandlerType
    
    public private(set) var subscriptions = [SubscriptionType]()
    
    public init() { }
    
    public mutating func notify(_ value: T) {
        subscriptions = subscriptions.filter { $0.valid() }
        for subscription in subscriptions {
            subscription.handler(value)
        }
    }
    
    @discardableResult
    public mutating func add(_ subscription: SubscriptionType) -> SubscriptionType {
        subscriptions.append(subscription)
        return subscription
    }
    
    @discardableResult
    public mutating func add(_ handler: @escaping HandlerType) -> SubscriptionType {
        return add(SubscriptionType(owner: nil, handler: handler))
    }
    
    public mutating func remove(_ subscription: SubscriptionType) {
        var newsubscriptions = [SubscriptionType]()
        var first = true
        for existing in subscriptions {
            if first && existing === subscription {
                first = false
            } else {
                newsubscriptions.append(existing)
            }
        }
        subscriptions = newsubscriptions
    }
    
    public mutating func removeAll() {
        subscriptions.removeAll()
    }
    
    @discardableResult
    public mutating func add(owner: AnyObject, _ handler: @escaping HandlerType) -> SubscriptionType {
        return add(SubscriptionType(owner: owner, handler: handler))
    }
    
    public mutating func unshare() {
//        _subscriptions.unshare()
    }
    
}

@discardableResult
public func += <T: UnownableEvent> (event: inout T, handler: @escaping (T.ValueType) -> ()) -> EventSubscription<T.ValueType> {
    return event.add(handler)
}

@discardableResult
public func += <T: OwnableEvent> (event: T, handler: @escaping (T.ValueType) -> ()) -> EventSubscription<T.ValueType> {
    var e = event
    return e.add(handler)
}

public func -= <T: UnownableEvent> (event: inout T, subscription: EventSubscription<T.ValueType>) {
    return event.remove(subscription)
}

public func -= <T: OwnableEvent> (event: T, subscription: EventSubscription<T.ValueType>) {
    var e = event
    return e.remove(subscription)
}
