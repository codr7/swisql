## intro
This project aims to simplify working with PostgreSQL in Swift by modelling/integrating relational concepts rather than imposing an object oriented world view on the database. The core concepts have previously been prototyped and verified in several other languages, including [Common Lisp](https://github.com/codr7/cl-redb) and [Go](https://github.com/codr7/gstraps).

## schemas
Schemas keep track of standalone definitions such as tables, indexes, sequences and enum types.

```
let scm = Schema()
let tbl = Table(scm, "tbl")

var tx = try! await cx.startTx()
try! await scm.create(inTx: tx)
try! await tx.commit()
```

## tables
Tables keep track of their columns, keys and indexes.

```
let scm = Schema()
let tbl = Table(scm, "tbl1")
let col = IntColumn("col", tbl, primaryKey: true)

var tx = try! await cx.startTx()
try! await tbl.create(inTx: tx)
try! await tx.commit()
```

## foreign keys
Foreign keys create the required columns in their tables automatically by default.

```
let scm = Schema()
let tbl1 = Table(scm, "tbl1")
let col = IntColumn("col", tbl1, primaryKey: true)

let tbl2 = Table(scm, "tbl2")
_ = ForeignKey("fkey", tbl2, [col], primaryKey: true)
```

## records
Records are ordered sets of `Column`/`Any` tuples.
Subscripting using typed columns accepts and returns the correct type.

```
let scm = Schema()
let tbl = Table(scm, "tbl")
let col = StringColumn("col", tbl, primaryKey: true)
let rec = Record()

rec[col] = "foo"
assert(rec[col]! == "foo")
```

The status of each field is tracked in the current context/transaction.

```
tx = try! await cx.startTx()
assert(!rec.stored([col], inTx: tx))
assert(rec.modified([col], inTx: tx))
try! await tbl.upsert(rec, inTx: tx)
assert(rec.stored([col], inTx: tx))
assert(!rec.modified([col], inTx: tx))
```

## enums
PostgreSQL enums require `String` raw values and implementing the `Enum` protocol.

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