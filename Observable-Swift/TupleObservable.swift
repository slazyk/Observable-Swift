//
//  TupleObservable.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 20/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

public class PairObservable<O1: AnyObservable, O2: AnyObservable> : OwnableObservable {
    
    internal typealias T1 = O1.ValueType
    internal typealias T2 = O2.ValueType
    
    public typealias ValueType = (T1, T2)
    
    public private(set) var beforeChange = EventReference<ValueChange<(T1, T2)>>()
    public private(set) var afterChange = EventReference<ValueChange<(T1, T2)>>()
    
    internal var first : T1
    internal var second : T2
    
    public var value : (T1, T2) { return (first, second) }
    
    private let _base1 : O1
    private let _base2 : O2
    
    public init (_ o1: O1, _ o2: O2) {
        _base1 = o1
        _base2 = o2
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

}

public func & <O1 : AnyObservable, O2: AnyObservable> (x: O1, y: O2) -> PairObservable<O1, O2> {
    return PairObservable(x, y)
}
