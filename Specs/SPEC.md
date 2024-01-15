# Specifications for the Caraml Language
#### By: Chubak Bidpaa

## Summary

Caraml is a functional language in the ML family, drawing inspiration from languages like Standard ML and OCaml in terms of syntax and semantics. Unlike lazy languages, Caraml can be compiled into machine code using its optimizing compiler or interpreted using a VMGEN-generated Stack VM.

## Syntax 

See Caraml.ebnf for the lexical and syntactic grammar of Caraml.

## Semantics

Any Caraml program may optionally begin with a Shebang line. Following that, modules play a crucial role. In contrast to other ML-driven languages where modules serve as an application of a signature, in Caraml, modules are more akin to units of execution.

Every module has its lexical scope, accessible using the 'Self' keyword inside the module and `<ModuleName>` outside the module itself.

By utilizing `let` bindings, a new scope can be created within the module's scope. These `let` bindings are recursive, allowing the creation of a new `let` binding inside another, each having its own lexical scope.

Functions in Caraml are first-class citizens, as every `let` binding can be invoked as a function. Additionally, closures are supported through the `fun` binding, enabling the creation of lambda functions.

Caraml boasts powerful pattern matching capabilities, allowing developers to concisely express complex conditional and structural logic in their code. This feature enhances the expressiveness and readability of Caraml programs.

The language also supports algebraic data types through the 'datatype' declaration, allowing developers to model complex data structures with ease. Pattern matching and algebraic data types work together seamlessly to provide a flexible and expressive way to handle data in Caraml.

## Module Scope and Binding

Modules in Caraml define their own lexical scope, facilitating encapsulation and modular programming. The `Self` keyword is used to refer to the current module's scope, providing a concise way to access its internal elements.

```caraml
module MyModule where
  let x = 42;
  let doubleX = Self.x * 2;
end
```

Outside the module, you can reference its elements using the `<ModuleName>` syntax:

```caraml
MyModule.doubleX;  ;; Accessing doubleX from outside the module
```

`let` bindings within modules are recursive, allowing for the creation of mutually dependent functions or values:

```caraml
module RecursiveExample where
  let rec factorial n =
    if n <= 1 then 1 else n * Self.factorial (n - 1);
end
```

## First-Class Functions and Closures

Functions in Caraml are first-class citizens, meaning they can be passed as arguments to other functions, returned from functions, and assigned to variables. This enables a functional programming style and enhances the language's expressiveness.

```caraml
module FunctionExample where
  let add x y = x + y;
  let multiplyByTwo = Self.add 2;  // Using partial application
  let result = Self.multiplyByTwo 3;  // Result is 6
end
```

Closures, created with the `fun` binding, allow the definition of lambda functions capturing variables from their lexical environment:

```caraml
module ClosureExample where
  let makeAdder x = fun y => x + y;
  let addFive = Self.makeAdder 5;
  let result = Self.addFive 3;  // Result is 8
end
```

## Pattern Matching

Pattern matching is a powerful feature in Caraml that enables concise and expressive handling of data structures. It is commonly used with `match` expressions to destructure and match values against different patterns.

```caraml
module PatternMatchingExample where
  let rec factorial n =
    match n with
    | 0 => 1
    | _ => n * Self.factorial (n - 1);
end
```

In the example above, the `match` expression checks the value of `n` against different patterns. If `n` is 0, it returns 1; otherwise, it recursively calls the `factorial` function.

## Algebraic Data Types

Caraml supports algebraic data types through the `datatype` declaration, allowing developers to define structured types with named constructors. This feature is particularly useful for modeling complex data structures.

```caraml
module TreeExample where
  datatype Tree =
    | Leaf
    | Node of int * Self.Tree * Self.Tree;

  let rec sumTree tree =
    match tree with
    | Leaf => 0
    | Node(value, left, right) => value + Self.sumTree left + Self.sumTree right;
end
```

In this example, the `Tree` type is defined with two constructors: `Leaf` and `Node`. The `sumTree` function recursively calculates the sum of values in the tree.

These features collectively contribute to the expressive power of Caraml, providing developers with a versatile set of tools for building modular, functional, and readable programs.

## Records

Caraml introduces the concept of records, allowing developers to define structured data types with named fields. Records in Caraml serve as a collection of types, providing a mechanism similar to classes or objects in object-oriented languages.

### Record Definition

To define a record, use the `record` declaration followed by the field names and their corresponding types:

```caraml
module RecordExample where
  record Point = {
    x: int;
    y: int;
  };
end
```

In this example, a record named `Point` is defined with two fields, `x` and `y`, both of type `int`.

### Record Instantiation

To create an instance of a record, use the record's name and provide values for its fields:

```caraml
module RecordUsageExample where
  let myPoint = RecordExample.Point { x = 10; y = 20 };
end
```

Here, an instance of the `Point` record is created with values 10 for `x` and 20 for `y`.

### Record Pattern Matching

Records can be deconstructed using pattern matching, allowing developers to access individual fields:

```caraml
module RecordPatternMatchingExample where
  let printPoint point =
    match point with
    | RecordExample.Point { x = px; y = py } =>
      print("x: " + px + ", y: " + py);
  end
```

In this example, the `printPoint` function uses pattern matching to extract values from the `Point` record and print them.

### Update Syntax

Caraml provides a concise syntax for updating records, creating a new record with modified fields:

```caraml
module RecordUpdateExample where
  let originalPoint = RecordExample.Point { x = 5; y = 10 };
  let updatedPoint = originalPoint { y = 20 };
end
```

Here, `updatedPoint` is a new record based on `originalPoint` with the `y` field modified to 20.

Records in Caraml enhance the language's expressiveness, allowing developers to model complex data structures with named fields and providing convenient syntax for instantiation, pattern matching, and updates.

## Syntax for Records

The syntax for defining, instantiating, and using records in Caraml is as follows:

### Record Definition

```caraml
module RecordExample where
  type Point = {
    x: int;
    y: int;
  };
end
```

The `record-type` non-terminal is used to define a new record type with a given name. It consists of the keyword 'record,' followed by the record's name (`alnum-identifier`), an equals sign '=', and the list of fields enclosed in curly braces '{' and '}'. Each field is specified with an `alnum-identifier` representing the field name, a colon ':', and the `type-exp` representing the field's type.

### Record Instantiation

```caraml
module RecordUsageExample where
  let myPoint = RecordExample.Point { x = 10; y = 20 };
end
```

The `record-literal` non-terminal represents the instantiation of a record. It starts with the record's name (`alnum-identifier`), followed by an opening brace '{,' a list of `field-bindings` specifying values for the record's fields, and a closing brace '}'.

### Record Pattern Matching

```caraml
module RecordPatternMatchingExample where
  let printPoint point =
    match point with
    | RecordExample.Point { x = px; y = py } =>
      print("x: " + px + ", y: " + py);
  end
```

To perform pattern matching on records, the `pattern` non-terminal includes the `record-pattern` non-terminal. A record pattern starts with the record's name (`alnum-identifier`), followed by an opening brace '{,' a list of `field-patterns` specifying patterns for the record's fields, and a closing brace '}'.

### Update Syntax

```caraml
module RecordUpdateExample where
  let originalPoint = RecordExample.Point { x = 5; y = 10 };
  let updatedPoint = RecordExample.Point { originalPoint | y = 20 };
end
```

The `record-update` non-terminal represents updating a record. It starts with the record's name (`alnum-identifier`), followed by an opening brace '{,' a list of `field-updates` specifying new values for the record's fields, and a closing brace '}'.

These syntactic rules provide a clear and concise way to work with records in Caraml, allowing developers to define, instantiate, pattern match, and update records seamlessly within the language's expressive and modular framework.
