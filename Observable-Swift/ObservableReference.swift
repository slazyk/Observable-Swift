//
//  ObservableReference.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 21/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

// two generic parameters are needed to be able to override `value` in `WritableObservableReference<T>`

class ObservableReference<T, O: AnyObservable where O.ValueType == T> : OwnableObservable {
    
    typealias ValueType = T
    
    var beforeChange = Event<(T, T)>()
    var afterChange = Event<(T, T)>()
    
    var value : ValueType {
    get { return _value() }
    }
    
    var _value : () -> T
    
    @conversion func __conversion () -> T {
        return value
    }
    
    init (inout _ o : O) {
        self._value = { o.value }
        o.beforeChange.add(owner: self) { [weak self] (oV, nV) in
            self!.beforeChange.notify(oV, nV)
        }
        o.afterChange.add(owner: self) { [weak self] (oV, nV) in
            self!._value = { nV }
            self!.afterChange.notify(oV, nV)
        }
    }
    
    func ownableSelf() -> AnyObject {
        return self
    }
    
}

class WritableObservableReference<T> : ObservableReference<T, Observable<T>>, WritableObservable {
    
    typealias ValueType = T
    
    var storage : Observable<T>
    
    override var value: T {
    get { return storage.value }
    set { storage.value = newValue }
    }
    
    init (_ v : T) {
        storage = Observable(v)
        super.init(&storage)
    }
    
}

func reference <O: AnyObservable> (inout o: O) -> ObservableReference<O.ValueType, O> {
    return ObservableReference(&o)
}
