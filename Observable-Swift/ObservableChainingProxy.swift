//
//  Chaining.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 23/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

public class ObservableChainingProxy<O1: AnyObservable, O2: AnyObservable>: OwnableObservable {
    
    public typealias ValueType = O2.ValueType?
    
    public var value : ValueType { return nil }
    
    internal weak var _beforeChange : EventReference<ValueChange<ValueType>>? = nil
    internal weak var _afterChange : EventReference<ValueChange<ValueType>>? = nil
    
    public var beforeChange : EventReference<ValueChange<ValueType>> {
        if let event = _beforeChange {
            return event
        } else {
            let event = OwningEventReference<ValueChange<ValueType>>()
            event.owned = self
            _beforeChange = event
            return event
        }
    }
    
    public var afterChange : EventReference<ValueChange<ValueType>> {
        if let event = _afterChange {
            return event
        } else {
            let event = OwningEventReference<ValueChange<ValueType>>()
            event.owned = self
            _afterChange = event
            return event
        }
    }
    
    internal let base: O1
    internal let path: O1.ValueType -> O2?
    
    private func targetChangeToValueChange(vc: ValueChange<O2.ValueType>) -> ValueChange<ValueType> {
        let oldValue = Optional.Some(vc.oldValue)
        let newValue = Optional.Some(vc.newValue)
        return ValueChange(oldValue, newValue)
    }
        
    private func objectChangeToValueChange(oc: ValueChange<O1.ValueType>) -> ValueChange<ValueType> {
        let oldValue = path(oc.oldValue)?.value
        let newValue = path(oc.newValue)?.value
        return ValueChange(oldValue, newValue)
    }
    
    init(base: O1, path: O1.ValueType -> O2?) {
        self.base = base
        self.path = path

        let beforeSubscription = EventSubscription(owner: self) { [weak self] in
            self!.beforeChange.notify(self!.targetChangeToValueChange($0))
        }
        
        let afterSubscription = EventSubscription(owner: self) { [weak self] in
            self!.afterChange.notify(self!.targetChangeToValueChange($0))
        }
        
        base.beforeChange.add(owner: self) { [weak self] oc in
            let oldTarget = path(oc.oldValue)
            oldTarget?.beforeChange.remove(beforeSubscription)
            oldTarget?.afterChange.remove(afterSubscription)
            self!.beforeChange.notify(self!.objectChangeToValueChange(oc))
        }
        
        base.afterChange.add(owner: self) { [weak self] oc in
            self!.afterChange.notify(self!.objectChangeToValueChange(oc))
            let newTarget = path(oc.newValue)
            newTarget?.beforeChange.add(beforeSubscription)
            newTarget?.afterChange.add(afterSubscription)
        }
    }
    
    public func to<O3: AnyObservable>(path f: O2.ValueType -> O3?) -> ObservableChainingProxy<ObservableChainingProxy<O1, O2>, O3> {
        func cascadeNil(oOrNil: ValueType) -> O3? {
            if let o = oOrNil {
                return f(o)
            } else {
                return nil
            }
        }
        return ObservableChainingProxy<ObservableChainingProxy<O1, O2>, O3>(base: self, path: cascadeNil)
    }
    
    public func to<O3: AnyObservable>(path f: O2.ValueType -> O3) -> ObservableChainingProxy<ObservableChainingProxy<O1, O2>, O3> {
        func cascadeNil(oOrNil: ValueType) -> O3? {
            if let o = oOrNil {
                return f(o)
            } else {
                return nil
            }
        }
        return ObservableChainingProxy<ObservableChainingProxy<O1, O2>, O3>(base: self, path: cascadeNil)
    }
    
}

public struct ObservableChainingBase<O1: AnyObservable> {
    internal let base: O1
    public func to<O2: AnyObservable>(path: O1.ValueType -> O2?) -> ObservableChainingProxy<O1, O2> {
        return ObservableChainingProxy(base: base, path: path)
    }
    public func to<O2: AnyObservable>(path: O1.ValueType -> O2) -> ObservableChainingProxy<O1, O2> {
        return ObservableChainingProxy(base: base, path: { .Some(path($0)) })
    }
}

public func chain<O: AnyObservable>(o: O) -> ObservableChainingBase<O> {
    return ObservableChainingBase(base: o)
}

public func / <O1: AnyObservable, O2: AnyObservable, O3: AnyObservable> (o: ObservableChainingProxy<O1, O2>, f: O2.ValueType -> O3?) -> ObservableChainingProxy<ObservableChainingProxy<O1, O2>, O3> {
    return o.to(path: f)
}

public func / <O1: AnyObservable, O2: AnyObservable> (o: O1, f: O1.ValueType -> O2?) -> ObservableChainingProxy<O1, O2> {
    return ObservableChainingProxy(base: o, path: f)
}
