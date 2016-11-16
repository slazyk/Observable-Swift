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
    
    internal var _subscriptions = [SubscriptionType]()
    
    public mutating func notify(_ value: T) {
        _subscriptions = _subscriptions.filter { $0.valid() }
        for subscription in _subscriptions {
            subscription.handler(value)
        }
    }
    
    public mutating func add(_ subscription: SubscriptionType) -> SubscriptionType {
        _subscriptions.append(subscription)
        return subscription
    }
    
    public mutating func add(_ handler : @escaping HandlerType) -> SubscriptionType {
        return add(SubscriptionType(owner: nil, handler: handler))
    }
    
    public mutating func remove(_ subscription : SubscriptionType) {
        var newsubscriptions = [SubscriptionType]()
        var first = true
        for existing in _subscriptions {
            if first && existing === subscription {
                first = false
            } else {
                newsubscriptions.append(existing)
            }
        }
        _subscriptions = newsubscriptions
    }
    
    public mutating func removeAll() {
        _subscriptions.removeAll()
    }
    
    public mutating func add(owner : AnyObject, _ handler : @escaping HandlerType) -> SubscriptionType {
        return add(SubscriptionType(owner: owner, handler: handler))
    }
    
    public mutating func unshare() {
//        _subscriptions.unshare()
    }
    
}

public func += <T: UnownableEvent> (event: inout T, handler: @escaping (T.ValueType) -> ()) -> EventSubscription<T.ValueType> {
    return event.add(handler)
}

public func += <T: OwnableEvent> (event: T, handler: @escaping (T.ValueType) -> ()) -> EventSubscription<T.ValueType> {
    var event = event
    return event.add(handler)
}

public  func -= <T: UnownableEvent> (event: inout T, subscription: EventSubscription<T.ValueType>) {
    return event.remove(subscription)
}

public func -= <T: OwnableEvent> (event: T, subscription: EventSubscription<T.ValueType>) {
    var event = event
    return event.remove(subscription)
}
