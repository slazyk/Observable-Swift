//
//  Observer.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 20/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

// Implemented as a class, so it can be compared using === and !==.

/// A class representing an observer watching value of type T.
class Observer<T> {
    
    typealias HandlerType = (oldValue: T, newValue: T) -> ()
    
    typealias SimpleHandlerType = (newValue: T) -> ()
    
    /// When invalid observer is to be notified, it is removed instead.
    var valid : () -> Bool
    
    /// Handler to be caled when value changes.
    var handler : HandlerType
    
    /// Init with a handler and an optional owner.
    /// If owner is present, valid() is tied to its lifetime.
    init(_ o: AnyObject?, _ h : HandlerType) {
        if o == nil {
            valid = { true }
        } else {
            valid = { [weak o] in o != nil }
        }
        handler = h
    }
}