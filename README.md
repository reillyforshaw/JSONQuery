# JSONQuery

JSONQuery is a utility to help query JSON data. Use it to drill into JSON objects and select just the parts you care about.

## Available Components

### Array and Dictionary Access

Arrays can be accessed by index:

```swift
let query = try! Parser(input: "0").parseQuery()

let foo = query.evaluate(on: [
  [ "foo" : "bar" ],
  [ "baz" : "qux" ],
])!
// foo = [ "foo" : "bar" ]
```

Dictionaries can be accessed by key:

```swift
let query = try! Parser(input: "foo").parseQuery()

let foo = query.evaluate(on: [
  "foo" : [ "bar" ],
  "baz" : [ "qux" ],
])!
// foo = [ "bar" ]
```

You can use quoted strings (`"`) if you need to:
- access a dictionary key that starts with a number
- access a dictionary key that starts with `"`
- access a dictionary key that contains a `.`
- access a dictionary key that contains `(` or `)`

You can escape quotes, or the escape character, with the escape character (`\`):

```swift
let query = try! Parser(input: "\"foo.bar\"").parseQuery()

let foo = query.evaluate(on: [
  "foo.bar" : [ "bar" ],
  "baz" : [ "qux" ],
])!
// foo = [ "bar" ]
```

### Functions

Arrays can be flat mapped with a subquery:

```swift
let query = try! Parser(input: "@flatMap(name)").parseQuery()

let foo = query.evaluate(on: [
  [ "id" : 1, "name" : "Alice" ],
  [ "id" : 2, "name" : "Bob" ],
])!
// foo = [ "Alice", "Bob" ]
```

Dictionaries can be queried for their keys:
```swift
let query = try! Parser(input: "@keys()").parseQuery()

let foo = query.evaluate(on: [
  "id" : 1,
  "name" : "Charlie",
])!
// foo = [ "id" : "name" ]
```

Dictionaries can be queried for their values:
```swift
let query = try! Parser(input: "@values()").parseQuery()

let foo = query.evaluate(on: [
  "id" : 1,
  "name" : "Charlie",
])!
// foo = [ 1 : "Charlie" ]
```

### Chaining

Most importantly, you can chain query components to your heart's content:
```swift
let query = try! Parser(input: "foo.bar.0.@keys()").parseQuery()

let foo = query.evaluate(on: [
  "foo" : [
    "bar" : [
      [
        "id" : 1,
        "name" : "Reilly",
      ]
    ]
  ]
])!
// foo = [ "id", "name" ]
```
