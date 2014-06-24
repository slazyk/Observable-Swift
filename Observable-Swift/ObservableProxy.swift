//
//  ObservableProxy.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 24/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

// two generic parameters are needed to be able to override `value` in `ObservableReference<T>`

class ObservableProxy<T, O: AnyObservable where O.ValueType == T> : OwnableObservable {
    
    typealias ValueType = T
    
    var beforeChange = EventReference<ValueChange<T>>()
    var afterChange = EventReference<ValueChange<T>>()
    
    var value : ValueType {
    get { return _value() }
    }
    
    var _value : () -> T
    
    @conversion func __conversion () -> T {
        return value
    }
    
    init (_ o : O) {
        self._value = { o.value }
        o.beforeChange.add(owner: self) { [weak self] change in
            self!.beforeChange.notify(change)
        }
        o.afterChange.add(owner: self) { [weak self] change in
            let nV = change.newValue
            self!._value = { nV }
            self!.afterChange.notify(change)
        }
    }
    
    func ownableSelf() -> AnyObject {
        return self
    }
    
}

func proxy <O: AnyObservable> (o: O) -> ObservableProxy<O.ValueType, O> {
    return ObservableProxy(o)
}
