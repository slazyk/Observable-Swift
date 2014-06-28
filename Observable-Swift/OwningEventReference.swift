//
//  OwningEventReference.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 28/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

/// A subclass of event reference allowing it to own other object[s].
/// Additionally, the reference makes added events own itself.
/// This retain cycle allows owned objects to live as long as valid subscriptions exist.
class OwningEventReference<T>: EventReference<T> {
    
    var owned: () -> AnyObject? = { nil }

    override func add(subscription: SubscriptionType) -> SubscriptionType {
        let subscr = super.add(subscription)
        if owned() {
            subscr.addOwnedObject(self)
        }
        return subscr
    }
    
    override func add(handler : T -> ()) -> EventSubscription<T> {
        let subscr = super.add(handler)
        if owned() {
            subscr.addOwnedObject(self)
        }
        return subscr
    }
    
    override func remove(subscription : SubscriptionType) {
        subscription.removeOwnedObject(self)
        return event.remove(subscription)
    }
    
    override func removeAll() {
        for subscription in event._subscriptions {
            subscription.removeOwnedObject(self)
        }
        event.removeAll()
    }
    
    override func add(#owner : AnyObject, _ handler : HandlerType) -> SubscriptionType {
        let subscr = event.add(owner: owner, handler)
        if owned() {
            subscr.addOwnedObject(self)
        }
        return subscr
    }

    init(event: Event<T>) {
        super.init(event: event)
    }
    
}