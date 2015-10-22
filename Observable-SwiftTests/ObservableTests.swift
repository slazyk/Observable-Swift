//
//  ObservableTests.swift
//  Observable-SwiftTests
//
//  Created by Leszek Ślażyński on 20/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

import XCTest

import Observable

class ObservableTests: XCTestCase {
    
    // copying an observable is exposed here as a function in case it changes
    // e.g. if Observables become classes instead of structs
    func makeCopy<T>(x: Observable<T>) -> Observable<T> {
        var copy = Observable(x^)
        copy.unshare(removeSubscriptions: true)
        return copy
    }
    
    // handler can take one argument of ValueChange struct
    func testFullHandler() {
        var x = Observable(0)
        var t : (Int, Int) = (-1, -1)
        x.afterChange += { c in t = (c.oldValue, c.newValue) }
        
        x <- 1
        XCTAssertEqual(t.0, 0, "Should receive correct old value")
        XCTAssertEqual(t.1, 1, "Should receive correct new value")
        
        x <- 2
        XCTAssertEqual(t.0, 1, "Should receive correct old value")
        XCTAssertEqual(t.1, 2, "Should receive correct new value")
    }
    
    // if handler takes 2 arguments it should be (oldValue, newValue)
    func testPairHandler() {
        var x = Observable(0)
        var t : (Int, Int) = (-1, -1)
        x.afterChange += { (x, y) in t = (x, y) }
        
        x <- 1
        XCTAssertEqual(t.0, 0, "Should receive correct old value")
        XCTAssertEqual(t.1, 1, "Should receive correct new value")
        
        x <- 2
        XCTAssertEqual(t.0, 1, "Should receive correct old value")
        XCTAssertEqual(t.1, 2, "Should receive correct new value")
    }
    
    // if handler takes 1 argument it should be newValue
    func testSimpleHandler() {
        var x = Observable(0)
        var t = -1
        x.afterChange += { t = $0 }
        
        x <- 1
        XCTAssertEqual(t, 1, "Should receive correct new value")
        
        x <- 2
        XCTAssertEqual(t, 2, "Should receive correct new value")
    }
    
    func testMultipleHandlers() {
        var x = Observable(0)
        var a = -1
        var b = -1
        x.afterChange += { a = $0 }
        x.afterChange += { b = $0 }
        
        x <- 42
        XCTAssertEqual(a, 42, "Should fire first handler")
        XCTAssertEqual(b, 42, "Should fire second handler")
    }
    
    func testBeforeAfter() {
        var x = Observable(0)
        var y = -1
        
        x.beforeChange += { y = $0 }
        x.afterChange += { (v: Int) in XCTAssertEqual(y, v, "Should be set in before"); y = 2 * v }
    
        x <- 21
    
        XCTAssertEqual(y, 42, "Should be set in after")
    }
    
    // should be able to add afterChange handlers directly to observable
    func testShorthand() {
        var x = Observable(0)
        var y = -1
        let s = x += { y = $0 }
        x <- 124
        XCTAssertEqual(y, x^, "Should add observer with shorthand")
        
        x.beforeChange += { (_,_) in y = -1 }
        
        x <- 42
        XCTAssertEqual(y, x^, "Should add to afterChange")
        
        x -= s
        x <- 18
        
        XCTAssertEqual(y, -1, "Should remove from afterChange")
    }
    
    func testAddHandlerToOptional() {
        var original = Observable(0)
        let optional = Optional.Some(original)
        
        var calledTimes = 0
        optional!.afterChange.add({ _ in calledTimes += 1 })
        
        original <- 42
        XCTAssertEqual(1, calledTimes, "Should be able to add handler to optional")
    }
    
    func testRemove() {
        var x = Observable(0)
        var y = 0
        
        let observer = x.afterChange += { (_,_) in y += 1 }
        
        for i in 0..<5 { x <- i }
        
        x.afterChange -= observer
        
        for i in 0..<5 { x <- i }
        XCTAssertEqual(y, 5, "Should not update after removed")
    }
    
    func testValueAfterCopy() {
        let original = Observable(0)
        var copy = makeCopy(original)
        
        XCTAssertEqual(0, original^)
        XCTAssertEqual(0, copy^)
        
        copy <- 42
        
        XCTAssertEqual(0, original^, "Original should stay the same")
        XCTAssertEqual(42, copy^, "Copy should change")
    }
    
    func testHandlerAfterCopy() {
        var original = Observable(0)
        var copy = makeCopy(original)
        
        var calledTimes = 0
        
        copy += { (_,_) in calledTimes += 1 }
        
        original <- 42
        XCTAssertEqual(0, calledTimes, "Only changes to copy should fire")
        
        copy <- 42
        XCTAssertEqual(1, calledTimes, "Only changes to copy should fire")
    }
    
    func testHandlerBeforeCopy() {
        var original = Observable(0)
        
        var calledTimes = 0
        original += { (_,_) in calledTimes += 1 }
        
        var copy = makeCopy(original)
        
        copy <- 42
        XCTAssertEqual(0, calledTimes, "Only changes to original should fire")
        
        original <- 42
        XCTAssertEqual(1, calledTimes, "Only changes to original should fire")
    }
    
    func testPairObservable() {
        var (first, last) = (Observable("John"), Observable("Smith"))
        
        let either = first & last
        
        let getFull = { "\($0 as String) \($1 as String)" }
        var full = getFull(first^, last^)
        
        either.afterChange += { full = getFull($0, $1) }
        
        last <- "Snow"
        XCTAssertEqual(full, "John Snow", "Should update when first element changes")
        
        first <- "Ramsay"
        XCTAssertEqual(full, "Ramsay Snow", "Should update when second element changes")
        
        last <- "Bolton"
        XCTAssertEqual(full, "Ramsay Bolton", "Should update when first element changes again")

    }
    
    func testTripleObserver() {
        var (title, first, last) = (Observable("Mr."), Observable("John"), Observable("Smith"))
        let either3 = title & first & last
        
        let getFull = { "\($0 as String) \($1 as String) \($2 as String)" }
        var full = getFull(title^, first^, last^)

        either3.afterChange += { full = getFull($0.0, $0.1, $1) }
        
        last <- "Snow"
        title <- "Bastard"
        XCTAssertEqual(full, "Bastard John Snow", "Should update when first element changes")
    }
    
    func testObservablePair() {
        var both = Observable(("John", "Smith"))
        
        let getFull = { (x : (String, String)) in "\(x.0 as String) \(x.1 as String)" }
        var full = getFull(both^)

        both.afterChange += { full = getFull($0) }
        
        // fortunately this calls a setter (as a tuples are value types)
        both.value.1 = "Snow"
        XCTAssertEqual(full, getFull(both^), "Should update when one element changes")

        both <- ("Ramsay", "Bolton")
        XCTAssertEqual(full, "Ramsay Bolton", "Should update when whole tuple changes")
    }
    
    func testObservableTriple() {
        var either3 = Observable(("Mr.", "John", "Smith"))
        
        let getFull = { (x: (String, String, String)) in "\(x.0) \(x.1) \(x.2)" }
        var full = getFull(either3^)
        
        either3.afterChange += { full = getFull($0) }
        
        either3.value.2 = "Snow"
        either3.value.0 = "Bastard"
        XCTAssertEqual(full, "Bastard John Snow", "Should update when first element changes")
    }
    
    func testObservableStruct() {
        struct Person {
            var first: String
            var last: String
        }
        
        var person = Observable(Person(first: "John", last: "Smith"))
        let getFull = { (x: Person) in "\(x.first) \(x.last)" }
        var full = getFull(person^)
        
        person.afterChange += { full = getFull($0) }
        
        // fortunately this calls a setter (as a structs are value types)
        person.value.last = "Snow"
        
        XCTAssertEqual(full, "John Snow", "Should update when field changes")
    }
    
    func testStructModifiedWhenPropertyModified() {
        struct Person {
            var first: String
            var last: Observable<String>
        }
        
        var person = Observable(Person(first: "John", last: Observable("Doe")))
        
        var personChangedTimes = 0
        var lastChangedTimes = 0
        
        person.value.last += { (_,_) in lastChangedTimes += 1 }
        person += { (_,_) in personChangedTimes += 1 }
        
        person.value.last <- "Snow"
        person.value.first = "John"
        person <- Person(first: "Ramsay", last: Observable("Bolton"))
        
        XCTAssertEqual(1, lastChangedTimes)
        XCTAssertEqual(3, personChangedTimes)
        
        // unfortunately `+=` means mutation
        person.value.last += { (_,_) in () }
        XCTAssertEqual(4, personChangedTimes)
        
        // but _not_ on reference type `EventReference<T>`
        person.value.last.afterChange += { (_,_) in () }
        XCTAssertEqual(4, personChangedTimes)
        
        // ... and when calling the add method ...
        person.value.last.afterChange.add({ _ in () })
        XCTAssertEqual(4, personChangedTimes)
        
        XCTAssertEqual(1, lastChangedTimes)
    }
    
    func testMultipleTimes() {
        var x = Observable(0)
        var y = 0
        x.afterChange.add(x.afterChange += { (_,_) in y += 1 })
        
        for i in 0..<10 { x <- i }
        
        XCTAssertEqual(y, 20, "Should be called twice every update")
    }
    
    func testRemoveMultiple() {
        var x = Observable(0)
        var y = 0
        let obs = x.afterChange.add(x.afterChange += { (_,_) in y += 1 })
        
        for i in 0..<10 { x <- i }
        XCTAssertEqual(y, 20, "Should be called twice every update")

        x.afterChange -= obs // this should remove once only...
        
        for i in 0..<10 { x <- i }
        XCTAssertEqual(y, 30, "Should be called once after removal")
        
        x.afterChange -= obs // this should remove the second ocurrence
        
        for i in 0..<10 { x <- i }
        XCTAssertEqual(y, 30, "Should not be called after removal")
    }
    
    func testOwnership() {
        var x = Observable(0)
        var y = 0
        
        for _ in 0..<1 {
            let owner = NSObject()
            x.afterChange.add(owner: owner) { c in y = c.newValue }
            x <- 12
            x <- 42
        }
        x <- -1
        
        XCTAssertEqual(y, 42, "Should not update after owner is deallocated")
    }
    
    func testProxyOwnership() {
        var x = Observable(0)
        
        var y = 0
        
        for _ in 0..<1 {
            let xr = proxy(x)
            xr.afterChange += { (_,_) in y += 1 }
            for i in 0..<5 { x <- i }
        }
        
        for i in 0..<5 { x <- i }
        
        XCTAssertEqual(y, 5, "Should increment only when proxy is alive")
    }

    func testProxyLifetime() {
        var x = Observable(0)
        var y = 0

        let xr = proxy(x)
        xr.afterChange += { (_,_) in y += 1 }

        for i in 0..<5 { x <- i }
        
        var z = x
        
        x = Observable(0)
        
        for i in 0..<5 { x <- i }

        for i in 0..<2 { z <- i }

        XCTAssertEqual(y, 7, "Should increment for refered object or a value-copy")
    }

    func testValueCopySementics() {
        var x = Observable(0)
        var y = x;
        y <- 1
        XCTAssertEqual(x.value, 0, "Original should stay unchanged")
        XCTAssertEqual(y.value, 1, "Copy should change")
    }
    
    func testCopyObserversSemantics() {
        var x = Observable(0)
        var y = 0
        x.afterChange += { (_,_) in y += 1 }
        var z = x
        
        z <- 10
        x <- 20
        
        XCTAssertEqual(z.value, 10)
        XCTAssertEqual(x.value, 20)
        
        // well... this is kind of unfortunate, but expected since x was copied
        XCTAssertEqual(y, 2, "Should be called for both x and z")

        // this actually makes observers not shared
        z.unshare(removeSubscriptions: false)
        
        z <- 30
        x <- 40
        
        XCTAssertEqual(z.value, 30)
        XCTAssertEqual(x.value, 40)
        
        XCTAssertEqual(y, 4, "Should still be called for both")
     
        x.afterChange += { (_,_) in y += 1 }
        
        z <- 50
        x <- 60

        XCTAssertEqual(y, 7, "Should now be called 3 times")
        
    }

    func testCopyObserversSemanticsWithRemove() {
        var x = Observable(0)
        var y = 0
        x.afterChange += { (_,_) in y += 1 }
        var z = x
        
        z <- 10
        x <- 20
        
        XCTAssertEqual(z.value, 10)
        XCTAssertEqual(x.value, 20)
        
        // well... this is kind of unfortunate, but expected since x was copied
        XCTAssertEqual(y, 2, "Should be called for both x and z")

        // this actually makes observers not shared
        z.unshare(removeSubscriptions: true)
        
        z <- 30
        x <- 40
        
        XCTAssertEqual(z.value, 30)
        XCTAssertEqual(x.value, 40)
        
        XCTAssertEqual(y, 3, "Should be called for x only")
        
    }
    
    func testReferences() {
        let x = ObservableReference(0)
        x <- 1
        XCTAssertEqual(x^, 1, "Should be equal to one")
    }
    
    func testChainingWithStructs() {
        struct Test { var test = Observable(0) }
        var test = Observable(Test())
        
        var beforeTimes = 0
        var afterTimes = 0
        var currentValue = -1
        
        chain(test).to{$0.test}.beforeChange += { (_,_) in beforeTimes += 1 }
        chain(test).to{$0.test}.afterChange += { (_,_) in afterTimes += 1 }
        chain(test).to{$0.test}.afterChange += { currentValue = $0.newValue! }
        
        XCTAssertEqual(beforeTimes, 0)
        XCTAssertEqual(afterTimes, 0)
        
        test.value.test <- 1
        XCTAssertEqual(beforeTimes, 1)
        XCTAssertEqual(afterTimes, 1)
        XCTAssertEqual(currentValue, 1)
        
        test <- Test()
        XCTAssertEqual(beforeTimes, 2)
        XCTAssertEqual(afterTimes, 2)
        XCTAssertEqual(currentValue, 0)
    }
    
    func testChainingWithOptionals() {
        class Person {
            let firstName: String
            var lastName: Observable<String>
            var friend: Observable<Person?> = Observable(nil)
            
            init(first: String, last: String) {
                firstName = first
                lastName = Observable(last)
            }
        }
        
        let john = Person(first: "John", last: "Doe")
        let ramsay = Person(first: "Ramsay", last: "Snow")
        
        let me = Person(first: "John", last: "Snow")
        
        var name1 : String? = nil
        var name2 : String? = nil
        
        // you can either chain(x).to{$0.y}.to{...}[...].afterChange
        chain(me.friend).to{$0?.lastName}.afterChange += { (_, newValue) in
            name1 = newValue
        }
        
        // or (x/{$0.y}/{...}/...).afterChange
        (me.friend/{$0?.friend}/{$0?.lastName}).afterChange += { (_, newValue) in
            name2 = newValue
        }
        
        me.friend <- john
        XCTAssertEqual(name1!, john.lastName.value)
        XCTAssertNil(name2)
        
        me.friend <- ramsay
        XCTAssertEqual(name1!, ramsay.lastName.value)
        XCTAssertNil(name2)
        
        john.lastName <- "Stark"
        XCTAssertEqual(name1!, ramsay.lastName.value)
        XCTAssertNil(name2)
        
        ramsay.lastName <- "Bolton"
        XCTAssertEqual(name1!, ramsay.lastName.value)
        XCTAssertNil(name2)
        
        ramsay.friend <- john
        XCTAssertEqual(name1!, ramsay.lastName.value)
        XCTAssertEqual(name2!, john.lastName.value)
        
        john.lastName <- "Doe"
        XCTAssertEqual(name1!, ramsay.lastName.value)
        XCTAssertEqual(name2!, john.lastName.value)
        
        me.friend <- john
        XCTAssertEqual(name1!, john.lastName.value)
        XCTAssertNil(name2)
        
    }
    
    func testChainingWithOwner() {
        struct Test { var test = Observable(0) }
        
        var afterTimes = 0
        var test = Observable(Test())
        
        for _ in 0..<1 {
            let o = NSObject()
            chain(test).to{$0.test}.afterChange.add(owner: o) { _ in afterTimes += 1 }
                        
            test.value.test <- 1
            XCTAssertEqual(afterTimes, 1)
            
            test <- Test()
            XCTAssertEqual(afterTimes, 2)
        }
        
        test.value.test <- 1
        XCTAssertEqual(afterTimes, 2)
        
        test <- Test()
        XCTAssertEqual(afterTimes, 2)
        
    }
    
    func testChainingCleanup() {
        struct Test { var test = Observable(0) }
        
        var afterTimes = 0
        var test = Observable(Test())
        
        weak var proxy : ObservableChainingProxy<Observable<Test>, Observable<Int>>? = nil
        weak var event : EventReference<ValueChange<Int?>>? = nil
        
        for _ in 0..<1 {
            let strongProxy = chain(test).to{$0.test}
            proxy = strongProxy
            
            let subscription = strongProxy.afterChange += { (_,_) in afterTimes += 1 }
            
            event = strongProxy.afterChange
            
            test.value.test <- 1
            XCTAssertEqual(afterTimes, 1)
            
            event! -= subscription
            
            test <- Test()
            XCTAssertEqual(afterTimes, 1)
        }
        
        XCTAssertNil(event)
        XCTAssertNil(proxy)
        
    }
    
    func testObservingAnArray() {
        let ref = [1, 2, 3, 42]
        var comp : [Int] = []
        var vals = Observable<[Int]>([])
        var changes = 0
        vals.afterChange.add {
            comp = [Int]($0.newValue)
            changes += 1
        }
        for x in ref {
            vals.value.append(x)
        }
        XCTAssertTrue(ref == vals^)
        XCTAssertTrue(ref == comp)
        XCTAssertEqual(changes, ref.count)
    }
    
}
