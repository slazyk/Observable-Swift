//
//  ObservableTranformProxy.swift
//  Skyway
//
//  Created by Adam Ritenauer on 22.08.15.
//  Copyright (c) 2015 Rhapsody International. All rights reserved.
//

import Foundation

//TODO: Move this to Observable-Swift framework, and submit PR to original Repo
public class ObservableTransformProxy<TransformType, ObservableType:AnyObservable> : OwnableObservable {
    
    public /*internal(set)*/ var beforeChange = EventReference<ValueChange<TransformType>>()
    public /*internal(set)*/ var afterChange = EventReference<ValueChange<TransformType>>()
    
    // private storage in case subclasses override value with a setter
    private var _value : TransformType
    
    public var value : TransformType {
        return _value
    }
    
    public init(_ o: ObservableType, transform:ObservableType.ValueType->TransformType) {
        
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