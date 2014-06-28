//
//  EventReference.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 23/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

/// A class enclosing an Event struct. Thus exposing it as a reference type.
class EventReference<T>: OwnableEvent {
    typealias ValueType = T
    typealias SubscriptionType = EventSubscription<T>
    typealias HandlerType = EventSubscription<T>.HandlerType
    
    var event: Event<T>
    
    var owned: () -> AnyObject? = { nil }
    
    func notify(value: T) {
        event.notify(value)
    }
    
    func add(subscription: SubscriptionType) -> SubscriptionType {
        let subscr = event.add(subscription)
        if owned() {
            subscr._owned = { self }
        }
        return subscr
    }
    
    func add(handler : T -> ()) -> EventSubscription<T> {
        let subscr = event.add(handler)
        if owned() {
            subscr._owned = { self }
        }
        return subscr
    }
    
    func remove(subscription : SubscriptionType) {
        return event.remove(subscription)
    }
    
    func removeAll() {
        event.removeAll()
    }
    
    func add(#owner : AnyObject, _ handler : HandlerType) -> SubscriptionType {
        let subscr = event.add(owner: owner, handler)
        if owned() {
            subscr._owned = { self }
        }
        return subscr
    }
    
    convenience init() {
        self.init(event: Event<T>())
    }
    
    init(event: Event<T>) {
        self.event = event
    }
    
}