//
//  EventReference.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 23/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

/// A class enclosing an Event struct. Thus exposing it as a reference type.
class EventReference<T>: AnyEvent {
    typealias ValueType = T
    typealias SubscriptionType = EventSubscription<T>
    typealias HandlerType = EventSubscription<T>.HandlerType
    
    var event: Event<T>
    
    func notify(value: T) {
        event.notify(value)
    }
    
    func add(subscription: SubscriptionType) -> SubscriptionType {
        return event.add(subscription)
    }
    
    func add(handler : T -> ()) -> EventSubscription<T> {
        return event.add(handler)
    }
    
    func remove(subscription : SubscriptionType) {
        return event.remove(subscription)
    }
    
    func removeAll() {
        event.removeAll()
    }
    
    func add(#owner : AnyObject, _ handler : HandlerType) -> SubscriptionType {
        return event.add(owner: owner, handler)
    }
    
    convenience init() {
        self.init(event: Event<T>())
    }
    
    init(event: Event<T>) {
        self.event = event
    }
    
}