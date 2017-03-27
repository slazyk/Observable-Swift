//
//  EventReference.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 23/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

/// A class enclosing an Event struct. Thus exposing it as a reference type.
open class EventReference<T>: OwnableEvent {
    public typealias ValueType = T
    public typealias SubscriptionType = EventSubscription<T>
    public typealias HandlerType = EventSubscription<T>.HandlerType
    
    public private(set) var event: Event<T>
    
    open func notify(_ value: T) {
        event.notify(value)
    }
    
    @discardableResult
    open func add(_ subscription: SubscriptionType) -> SubscriptionType {
        return event.add(subscription)
    }
    
    @discardableResult
    open func add(_ handler: @escaping (T) -> ()) -> EventSubscription<T> {
        return event.add(handler)
    }
    
    open func remove(_ subscription: SubscriptionType) {
        return event.remove(subscription)
    }
    
    open func removeAll() {
        event.removeAll()
    }
    
    @discardableResult
    open func add(owner: AnyObject, _ handler: @escaping HandlerType) -> SubscriptionType {
        return event.add(owner: owner, handler)
    }
    
    public convenience init() {
        self.init(event: Event<T>())
    }
    
    public init(event: Event<T>) {
        self.event = event
    }
    
}
