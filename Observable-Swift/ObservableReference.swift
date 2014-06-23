//
//  ObservableReference.swift
//  Observable-Swift
//
//  Created by Leszek Ślażyński on 21/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

class ObservableReference<T> : ObservableProxy<T, Observable<T>>, WritableObservable {
    
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
