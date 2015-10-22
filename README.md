# Value Observing and Events for Swift

Swift lacks the powerful Key Value Observing (KVO) from Objective-C. But thanks to closures, generics and property observers, in some cases it allows for far more elegant observing. You have to be explicit about what can be observed, though.

## Overview

Observable-Swift is a Swift library for value observing (via explicit usage of `Observable<T>`) and subscribable events (also explicit, using `Event<T>`). While it is not exactly "KVO for Swift" (it is explicit, there are no "Keys", ...) it is a catchy name so you can call it that if you want. The library is still under development, just as Swift is. Any contributions, both in terms of suggestions/ideas or actual code are welcome.

Observable-Swift is brought to you by Leszek Ślażyński (slazyk), you can follow me on [twitter](https://twitter.com/slazyk) and [github](https://github.com/slazyk). 
Also check out [SINQ](https://github.com/slazyk/SINQ) my other Swift library that makes working with collections a breeze.

### Observables

Using `Observable<T>` and related classes you can implement wide range of patterns using value observing. Some of the features: 

- observable variables and properties
- chaining of observables (a.k.a. key path observing)
- short readable syntax using `+=`, `-=`, `<-`/`^=`, `^`
- alternative syntax for those who dislike custom operators
- handlers for _before_ or _after_ the change
- handlers for `{ oldValue:, newValue: }` `(oldValue, newValue)` or `(newValue)`
- adding multiple handlers per observable
- removing / invalidating handlers
- handlers tied to observer lifetime
- observable mutations of value types (structs, tuples, ...)
- ~~conversions from observables to underlying type~~ (not available since Swift Beta 6)
- observables combining other observables
- observables as value types or reference types
- ...

### Events

Sometimes, you don’t want to observe for value change, but other significant events.
Under the hood `Observable<T>` uses `beforeChange` and `afterChange` of `EventReference<ValueChange<T>>`. You can, however, use `Event<T>` or `EventReference<T>` directly and implement other events too.

## Installation

You can use either [CocoaPods](https://cocoapods.org/) or [Carthage](https://github.com/Carthage/Carthage) to install Observable-Swift.

Otherwise, the easiest option to use Observable-Swift in your project is to clone this repo and add Observable-Swift.xcodeproj to your project/workspace and then add Observable.framework to frameworks for your target.

After that you just `import Observable`.

## Examples
`Observable<T>` is a simple `struct` allowing you to have observable variables.

```swift
// create a Observable<Int> variable
var x = Observable(0)

// add a handler
x.afterChange += { println("Changed x from \($0) to \($1)") }
// without operators: x.afterChange.add { ... }

// change the value, prints "Changed x from 0 to 42"
x <- 42
// alternativelyL x ^= 42, without operators: x.value = 42
```

You can, of course, have observable properties in a `class` or a `struct`:

```swift
struct Person {
    let first: String
    var last: Observable<String>
    
    init(first: String, last: String) {
        self.first = first
        self.last = Observable(last)
    }
}
    
var ramsay = Person(first: "Ramsay", last: "Snow")
ramsay.last.afterChange += { println("Ramsay \($0) is now Ramsay \($1)") }        
ramsay.last <- "Bolton"
```
Up to Swift Beta 5 you could implicitly convert `Observable<T>` to `T`, and use it in places where `T` is expected. Unfortunately Beta 6 forbids defining implicit conversions:
```swift
let x = Observable(20)
// You can use the value property ...
let y1 = x.value + 22
// ... or a postfix operator ...
let  y2 = x^ + 22
/// ... which has the advantage of easy chaining
let y3 = obj.property^.whatever^.sthElse^
/// ... you can also use ^= instead of <- for consistency with the postfix ^
```

For value types (such as `structs` or `tuples`) you can also observe their mutations:  
*Since `Observable` is a `struct`, ramsay in example above gets mutated too. This means, you could observe ramsay as well.*

```swift
struct Person {
    let first: String
    var last: String
    var full: String { get { return "\(first) \(last)" } }
}

var ramsay = Observable(Person(first: "Ramsay", last: "Snow"))
// x += { ... } is the same as x.afterChange += { ... }
ramsay += { println("\($0.full) is now \($1.full)") }
ramsay.value.last = "Bolton"
```

You can remove observers by keeping the subscription object:

```swift
var x = Observable(0)    
let subscr = x.afterChange += { (_,_) in println("changed") }
// ...
x.afterChange -= subscr
// without operators: x.afterChange.remove(subscr)
```

Invalidating it:

```swift
var x = Observable(0)    
let subscr = x.afterChange += { (_,_) in println("changed") }
// ...
subscr.invalidate() // will be removed next time event fires
```

Or tie the subscription to object lifetime:

```swift
var x = Observable(0)        
for _ in 0..1 {
    let o = NSObject() // in real-world this would probably be self
    x.afterChange.add(owner: o) { (oV, nV) in println("\(oV) -> \(nV)") }
    x <- 42 // handler called
} // o deallocated, handler invalidated
x <- -1 // handler not called
```

You can also chain observables (observe "key paths"):
```swift
class Person {
    let firstName: String
    var lastName: Observable<String>
    var friend: Observable<Person?> = Observable(nil)
	// init(...) { ... }
}

let me = Person()
var myFriendsName : String? = nil

// we want to observe my current friend last name
// and get notified with name when the friend or the name changes
chain(me.friend).to{$0?.lastName}.afterChange += { (_, newName) in
	myFriendsName = newName
}

// alternatively, we can do the same with '/' operator
(me.friend / {$0?.lastName}).afterChange += { (_, newName) in
	myFriendsName = newName
}
```

`Event<T>` is a simple `struct` allowing you to define subscribable events. `Observable<T>` uses `EventReference<ValueChange<T>>` for `afterChange` and `beforeChange`.

```swift
class SomeClass {
 	// defining an event someone might be interested in
 	var somethingChanged = Event<String>()
 
 	// ...
 
 	func doSomething() {
 		// ...
 		// fire the event and notify all observers
 		somethingChanged.notify("Hello!")
 		// ...
 	}
}

var obj = SomeClass()

// subscribe to an event
obj.somethingChanged += { println($0) }

obj.doSomething()
```

More examples can be found in tests in `ObservableTests.swift`

## Advanced

If you require observables as reference types, you can use either `ObservableProxy` which is a reference type in between your code and the real `Observable` value type. You can also use `ObservableReference` which is a `ObservableProxy` to an `Observable` that it holds on a property.

Same is true for `Event`, there is `EventReference` as well. Actually, `Observable` uses `EventReference` instead of `Event`, otherwise some use cases would be difficult to implement. This means, that if you want to unshare events and subscriptions you need to call `observable.unshare(removeSubscriptions:)`.
