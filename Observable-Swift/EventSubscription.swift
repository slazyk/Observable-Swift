//
//  EventSubscription.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 21/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

// Implemented as a class, so it can be compared using === and !==.

// There is no way for event to get notified when the owner was deallocated,
// therefore it will be invalidated only upon next attempt to trigger.

// Event subscriptions are neither freed nor removed from events upon invalidation.
// Events remove invalidated subscriptions themselves when firing.

// Invalidation immediately frees handler and owned objects.

/// A class representing a subscription for `Event<T>`.
class EventSubscription<T> {
    
    typealias HandlerType = T -> ()
    
    var _valid : () -> Bool
    
    /// Handler to be caled when value changes.
    var handler : HandlerType
    
    /// @protected array of owned objects
    var _owned = [AnyObject]()
    
    /// When invalid subscription is to be notified, it is removed instead.
    func valid() -> Bool {
        if !_valid() {
            invalidate()
            return false
        } else {
            return true
        }
    }
    
    /// Marks the event for removal, frees the handler and owned objects
    func invalidate() {
        _valid = { false }
        handler = { _ in () }
        _owned = []
    }
    
    /// Init with a handler and an optional owner.
    /// If owner is present, valid() is tied to its lifetime.
    init(owner o: AnyObject?, handler h: HandlerType) {
        if !o {
            _valid = { true }
        } else {
            _valid = { [weak o] in o.getLogicValue() }
        }
        handler = h
    }
    
    /// Add an object to be owned while the event is not invalidated
    func addOwnedObject(o: AnyObject) {
        _owned += o
    }
    
    /// Remove object from owned objects
    func removeOwnedObject(o: AnyObject) {
        _owned = _owned.filter{ $0 !== o }
    }
}