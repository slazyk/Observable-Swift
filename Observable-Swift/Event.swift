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
    
    public mutating func notify(value: T) {
        _subscriptions = _subscriptions.filter { $0.valid() }
        for subscription in _subscriptions {
            subscription.handler(value)
        }
    }
    
    public mutating func add(subscription: SubscriptionType) -> SubscriptionType {
        _subscriptions.append(subscription)
        return subscription
    }
    
    public mutating func add(handler : HandlerType) -> SubscriptionType {
        return add(SubscriptionType(owner: nil, handler: handler))
    }
    
    public mutating func remove(subscription : SubscriptionType) {
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
    
    public mutating func add(owner owner : AnyObject, _ handler : HandlerType) -> SubscriptionType {
        return add(SubscriptionType(owner: owner, handler: handler))
    }
    
    public mutating func unshare() {
//        _subscriptions.unshare()
    }
    
}

public func += <T: UnownableEvent> (inout event: T, handler: T.ValueType -> ()) -> EventSubscription<T.ValueType> {
    return event.add(handler)
}

public func += <T: OwnableEvent> (var event: T, handler: T.ValueType -> ()) -> EventSubscription<T.ValueType> {
    return event.add(handler)
}

public  func -= <T: UnownableEvent> (inout event: T, subscription: EventSubscription<T.ValueType>) {
    return event.remove(subscription)
}

public func -= <T: OwnableEvent> (var event: T, subscription: EventSubscription<T.ValueType>) {
    return event.remove(subscription)
}
