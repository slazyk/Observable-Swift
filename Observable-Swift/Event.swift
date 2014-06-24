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
struct Event<T>: UnownableEvent {
    typealias ValueType = T
    typealias SubscriptionType = EventSubscription<T>
    typealias HandlerType = SubscriptionType.HandlerType
    
    var _subscriptions = SubscriptionType[]()
    
    mutating func notify(value: T) {
        _subscriptions = _subscriptions.filter { $0.valid() }
        for subscription in _subscriptions {
            subscription.handler(value)
        }
    }
    
    mutating func add(subscription: SubscriptionType) -> SubscriptionType {
        _subscriptions += subscription
        return subscription
    }
    
    mutating func add(handler : HandlerType) -> SubscriptionType {
        return add(SubscriptionType(nil, handler))
    }
    
    mutating func remove(subscription : SubscriptionType) {
        var newsubscriptions = SubscriptionType[]()
        var first = true
        for existing in _subscriptions {
            if first && existing === subscription {
                first = false
            } else {
                newsubscriptions += existing
            }
        }
        _subscriptions = newsubscriptions
    }
    
    mutating func removeAll() {
        _subscriptions.removeAll()
    }
    
    mutating func add(#owner : AnyObject, _ handler : HandlerType) -> SubscriptionType {
        return add(SubscriptionType(owner, handler))
    }
    
    mutating func unshare() {
        _subscriptions.unshare()
    }
    
}

@assignment func += <T: UnownableEvent> (inout event: T, handler: T.ValueType -> ()) -> EventSubscription<T.ValueType> {
    return event.add(handler)
}

@infix func += <T: OwnableEvent> (var event: T, handler: T.ValueType -> ()) -> EventSubscription<T.ValueType> {
    return event.add(handler)
}

@assignment func -= <T: UnownableEvent> (inout event: T, subscription: EventSubscription<T.ValueType>) {
    return event.remove(subscription)
}

@infix func -= <T: OwnableEvent> (var event: T, subscription: EventSubscription<T.ValueType>) {
    return event.remove(subscription)
}
