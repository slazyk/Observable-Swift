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
public class EventSubscription<T> {
    
    public typealias HandlerType = (T) -> ()
    
    private var _valid: () -> Bool
    
    /// Handler to be caled when value changes.
    public private(set) var handler: HandlerType
    
    /// array of owned objects
    private var _owned = [AnyObject]()
    
    /// When invalid subscription is to be notified, it is removed instead.
    public func valid() -> Bool {
        if !_valid() {
            invalidate()
            return false
        } else {
            return true
        }
    }
    
    /// Marks the event for removal, frees the handler and owned objects
    public func invalidate() {
        _valid = { false }
        handler = { _ in () }
        _owned = []
    }
    
    /// Init with a handler and an optional owner.
    /// If owner is present, valid() is tied to its lifetime.
    public init(owner o: AnyObject?, handler h: @escaping HandlerType) {
        if o == nil {
            _valid = { true }
        } else {
            _valid = { [weak o] in o != nil }
        }
        handler = h
    }
    
    /// Add an object to be owned while the event is not invalidated
    public func addOwnedObject(_ o: AnyObject) {
        _owned.append(o)
    }
    
    /// Remove object from owned objects
    public func removeOwnedObject(_ o: AnyObject) {
        _owned = _owned.filter{ $0 !== o }
    }
}
