//
//  EventSubscription.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 21/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

// Implemented as a class, so it can be compared using === and !==.

/// A class representing a subsription for `Event<T>`.
class EventSubscription<T> {
    
    typealias HandlerType = T -> ()
    
    /// When invalid subscription is to be notified, it is removed instead.
    var valid : () -> Bool
    
    /// Handler to be caled when value changes.
    var handler : HandlerType
    
    func invalidate() {
        valid = { false }
    }
    
    /// Init with a handler and an optional owner.
    /// If owner is present, valid() is tied to its lifetime.
    init(owner o: AnyObject?, handler h: HandlerType) {
        if o == nil {
            valid = { true }
        } else {
            valid = { [weak o] in o != nil }
        }
        handler = h
    }
}