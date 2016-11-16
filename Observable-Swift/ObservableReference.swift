//
//  ObservableReference.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 21/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

open class ObservableReference<T> : ObservableProxy<T, Observable<T>>, WritableObservable {
    
    public typealias ValueType = T
    
    internal var storage : Observable<T>
    
    open override var value: T {
    get { return storage.value }
    set { storage.value = newValue }
    }
    
    public init (_ v : T) {
        storage = Observable(v)
        super.init(storage)
    }
    
}
