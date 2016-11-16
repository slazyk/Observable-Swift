//
//  ObservableTranformProxy.swift
//  Skyway
//
//  Created by Adam Ritenauer on 22.08.15.
//  Copyright (c) 2015 Rhapsody International. All rights reserved.
//

import Foundation

//TODO: Move this to Observable-Swift framework, and submit PR to original Repo
open class ObservableTransformProxy<TransformType, ObservableType:AnyObservable> : OwnableObservable {
    
    open /*internal(set)*/ var beforeChange = EventReference<ValueChange<TransformType>>()
    open /*internal(set)*/ var afterChange = EventReference<ValueChange<TransformType>>()
    
    // private storage in case subclasses override value with a setter
    fileprivate var _value : TransformType
    
    open var value : TransformType {
        return _value
    }
    
    public init(_ o: ObservableType, transform:@escaping (ObservableType.ValueType)->TransformType) {
        
        self._value = transform(o.value)
        o.beforeChange.add(owner: self) { [weak self] change in
            
            let transformChange = ValueChange(transform(change.oldValue), transform(change.newValue))
            self!.beforeChange.notify(transformChange)
        }
        o.afterChange.add(owner: self) { [weak self] change in
            let nV = change.newValue
            self!._value = transform(nV)
            let transformChange = ValueChange(transform(change.oldValue), transform(change.newValue))
            self!.afterChange.notify(transformChange)
        }
    }
}
