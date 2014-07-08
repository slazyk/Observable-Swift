//
//  TupleObservable.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 20/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

class PairObservable<O1: AnyObservable, O2: AnyObservable> : OwnableObservable {
    
    typealias T1 = O1.ValueType
    typealias T2 = O2.ValueType
    
    typealias ValueType = (T1, T2)
    
    var beforeChange = EventReference<ValueChange<(T1, T2)>>()
    var afterChange = EventReference<ValueChange<(T1, T2)>>()
    
    var first : T1
    var second : T2
    
    var value : (T1, T2) {
    get { return (first, second) }
    }
    
    @conversion func __conversion() -> (T1, T2) {
        return value
    }
    
    var dependent : (AnyObject?, AnyObject?)
    
    init (_ o1: O1, _ o2: O2, dependent: (AnyObject?, AnyObject?) = (nil, nil)) {
        self.dependent = dependent
        first = o1.value
        second = o2.value
        o1.beforeChange.add(owner: self) { [weak self] c1 in
            let oldV = (c1.oldValue, self!.second)
            let newV = (c1.newValue, self!.second)
            let change = ValueChange(oldV, newV)
            self!.beforeChange.notify(change)
        }
        o1.afterChange.add(owner: self) { [weak self] c1 in
            let nV1 = c1.newValue
            self!.first = nV1
            let oldV = (c1.oldValue, self!.second)
            let newV = (c1.newValue, self!.second)
            let change = ValueChange(oldV, newV)
            self!.afterChange.notify(change)
        }
        o2.beforeChange.add(owner: self) { [weak self] c2 in
            let oldV = (self!.first, c2.oldValue)
            let newV = (self!.first, c2.newValue)
            let change = ValueChange(oldV, newV)
            self!.beforeChange.notify(change)
        }
        o2.afterChange.add(owner: self) { [weak self] c2 in
            let nV2 = c2.newValue
            self!.second = nV2
            let oldV = (self!.first, c2.oldValue)
            let newV = (self!.first, c2.newValue)
            let change = ValueChange(oldV, newV)
            self!.afterChange.notify(change)
        }
    }

    func ownableSelf() -> AnyObject {
        return self
    }
    
}

@infix func & <O1 : UnownableObservable, O2: OwnableObservable> (x: O1, y: O2) -> PairObservable<O1, O2> {
    return PairObservable(x, y, dependent: (nil, y.ownableSelf()))
}

@infix func & <O1 : OwnableObservable, O2: UnownableObservable> (x: O1, y: O2) -> PairObservable<O1, O2> {
    return PairObservable(x, y, dependent: (x.ownableSelf(), nil))
}

@infix func & <O1 : OwnableObservable, O2: OwnableObservable> (x: O1, y: O2) -> PairObservable<O1, O2> {
    return PairObservable(x, y, dependent: (x.ownableSelf(), y.ownableSelf()))
}

@infix func & <O1 : UnownableObservable, O2: UnownableObservable> (x: O1, y: O2) -> PairObservable<O1, O2> {
    return PairObservable(x, y)
}
