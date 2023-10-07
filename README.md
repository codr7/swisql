## intro
This project aims to simplify working with PostgreSQL in Swift by modelling/integrating relational concepts rather than imposing an object oriented world view onto the database. Many of the ideas have previously been prototyped and verified in several languages before, including [Common Lisp](https://github.com/codr7/cl-redb) and [Go](https://github.com/codr7/gstraps).

## records
Records are ordered sets of `Column`/`Any` tuples (aka. `Field`s).
Subscripting using typed columns accepts and returns the correct type:

```
let scm = Schema()
let tbl = Table(scm, "tbl")
let col = IntColumn("col", tbl, primaryKey: true
let rec = Record()

rec[intCol] = 42
assert(rec[intCol]! == 42)
```

## enums
PostgreSQL enums require `String` raw values and implementing the Enum protocol:

```
enum TestEnum: String, Enum {
    case foo = "foo"
    case bar = "bar"
    case baz = "baz"

}

let scm = Schema()
let tbl = Table(scm, "tbl")
let col = EnumColumn<TestEnum>("col", tbl, primaryKey: true)
let rec = Record()

rec[enumCol] = .foo
```