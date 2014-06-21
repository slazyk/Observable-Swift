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
    
    var beforeChange = Event<((T1, T2), (T1, T2))>()
    var afterChange = Event<((T1, T2), (T1, T2))>()
    
    var first : () -> T1
    var second : () -> T2
    
    var value : (T1, T2) {
    get { return (first(), second()) }
    }
    
    @conversion func __conversion() -> (T1, T2) {
        return value
    }
    
    var dependent : (AnyObject?, AnyObject?)
    
    init (inout _ o1: O1, inout _ o2: O2, dependent: (AnyObject?, AnyObject?) = (nil, nil)) {
        self.dependent = dependent
        first = { o1.value }
        second = { o2.value }
        o1.beforeChange.add(owner: self) { [weak self] (oV1, nV1) in
            self!.beforeChange.notify((oV1, self!.second()), (nV1, self!.second()))
        }
        o1.afterChange.add(owner: self) { [weak self] (oV1, nV1) in
            self!.first = { nV1 }
            self!.afterChange.notify((oV1, self!.second()), (nV1, self!.second()))
        }
        o2.beforeChange.add(owner: self) { [weak self] (oV2, nV2) in
            self!.beforeChange.notify((self!.first(), oV2), (self!.first(), nV2))
        }
        o2.afterChange.add(owner: self) { [weak self] (oV2, nV2) in
            self!.second = { nV2 }
            self!.afterChange.notify((self!.first(), oV2), (self!.first(), nV2))
        }
    }

    func ownableSelf() -> AnyObject {
        return self
    }
    
}

@infix func & <O1 : UnownableObservable, O2: OwnableObservable> (inout x: O1, var y: O2) -> PairObservable<O1, O2> {
    return PairObservable(&x, &y, dependent: (nil, y.ownableSelf()))
}

@infix func & <O1 : OwnableObservable, O2: UnownableObservable> (var x: O1, inout y: O2) -> PairObservable<O1, O2> {
    return PairObservable(&x, &y, dependent: (x.ownableSelf(), nil))
}

@infix func & <O1 : OwnableObservable, O2: OwnableObservable> (var x: O1, var y: O2) -> PairObservable<O1, O2> {
    return PairObservable(&x, &y, dependent: (x.ownableSelf(), y.ownableSelf()))
}

@infix func & <O1 : UnownableObservable, O2: UnownableObservable> (inout x: O1, inout y: O2) -> PairObservable<O1, O2> {
    return PairObservable(&x, &y)
}
