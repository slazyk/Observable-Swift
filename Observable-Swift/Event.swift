//
//  Event.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 21/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

// Implemented as a struct to have desired value and mutability sementics.

/// A struct representing a collection of subscriptions with means to add, remove and notify them.
struct Event<T> {
    
    typealias SubscriptionType = EventSubscription<T>
    typealias HandlerType = SubscriptionType.HandlerType
    
    /// @protected array of subscriptions
    var _subscriptions = SubscriptionType[]()
    
    /// Notify all valid subscriptions of the change. Remove invalid ones.
    mutating func notify(value: T) {
        _subscriptions = _subscriptions.filter { $0.valid() }
        for subscription in _subscriptions {
            subscription.handler(value)
        }
    }
    
    /// Add a Subscription object. NOTE: You can add one subscription multiple times.
    mutating func add(subscription: SubscriptionType) -> SubscriptionType {
        _subscriptions += subscription
        return subscription
    }
    
    /// Create, add and return an subscription with given handler and no owner.
    mutating func add(handler : HandlerType) -> SubscriptionType {
        return add(SubscriptionType(nil, handler))
    }
    
    /// Remove given subscription, if present.
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
    
    /// Create, add and return an subscription with given handler and owner.
    mutating func add(#owner : AnyObject, _ handler : HandlerType) -> SubscriptionType {
        return add(SubscriptionType(owner, handler))
    }
}

@assignment func += <T> (inout event: Event<T>, handler: Event<T>.HandlerType) -> Event<T>.SubscriptionType {
    return event.add(handler)
}

@assignment func -= <T> (inout event: Event<T>, subscription: Event<T>.SubscriptionType) {
    return event.remove(subscription)
}
