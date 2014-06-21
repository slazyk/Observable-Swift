//
//  ObservableReference.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 21/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

class ObservableReference<O: AnyObservable> : OwnableObservable {
    
    typealias ValueType = O.ValueType
    typealias ObserverCollectionType = ObserverCollection<ValueType>
    typealias ObserverType = ObserverCollectionType.ObserverType
    typealias HandlerType = ObserverCollectionType.HandlerType
    typealias SimpleHandlerType = ObserverCollectionType.SimpleHandlerType
    
    var beforeChange = ObserverCollectionType()
    var afterChange = ObserverCollectionType()
    
    var value : ValueType {
    get { return _value() }
    }
    
    var _value : () -> ValueType
    
    @conversion func __conversion () -> ValueType {
        return value
    }
    
    init(inout _ o : O) {
        _value = { o.value }
        o.beforeChange.add(owner: self) { [weak self] (oV, nV) in
            self!.beforeChange.notify(oldValue: oV, newValue: nV)
        }
        // why do I have to annotate types here?
        o.afterChange.add(owner: self) { [weak self] (oV: ValueType, nV: ValueType) in
            self!._value = { nV }
            self!.afterChange.notify(oldValue: oV, newValue: nV)
        }
    }
    
    func ownableSelf() -> AnyObject {
        return self
    }
    
}

func reference <O: AnyObservable> (inout o: O) -> ObservableReference<O> {
    return ObservableReference(&o)
}
