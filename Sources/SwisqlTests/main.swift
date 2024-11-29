import Foundation
import PostgresNIO
import Swisql

func conditionTests() {
    let scm = Schema()
    let tbl = Table(scm, "tbl")
    let col = StringColumn("col", tbl)

    let c = (col == "foo") || (col == 42)
    assert(c.conditionSql == "(\(col.valueSql) = ?) OR (\(col.valueSql) = ?)")
}

func foreignKeyTests() async {
    let scm = Schema()
    let tbl1 = Table(scm, "tbl1")
    let col1 = IntColumn("col", tbl1, primaryKey: true)
    
    let tbl2 = Table(scm, "tbl2")
    _ = ForeignKey("fkey", tbl2, [col1], primaryKey: true)
    
    let cx = Cx(database: "swisql", user: "swisql", password: "swisql")
    try! await cx.connect()

    var tx = try! await cx.startTx()
    try! await scm.create(tx)
    try! await tx.rollback()

    tx = try! await cx.startTx()
    try! await scm.sync(tx)
    try! await tx.rollback()
    
    try! await cx.disconnect()
}

func orderedSetTests() {
    func compareInts(l: Int, r: Int) -> Order {
        return
          if l < r { .less }
          else if l > r { .greater }
          else { .equal }
    }

    var s = OrderedSet<Int, Int>(compare)
    
    assert(s.index(of: 42) == (0, nil))
    
    assert(s.add(1))
    assert(!s.add(1))
    assert(s.add(3))
    assert(s.add(2))
    assert(s.count == 3)

    assert(s.remove(2) == 2)
    assert(s.count == 2)

    assert(s[1] == 1)
    assert(s[2] == nil)
    assert(s[3] == 3)
}

func queryTests() async {
    let scm = Schema()
    let tbl = Table(scm, "tbl")
    let col1 = StringColumn("col1", tbl, primaryKey: true)
    let col2 = StringColumn("col2", tbl)

    let q = Query()
    q.select(col1, col2)
    q.from(tbl)
    q.filter(col1 == "foo")
    let cx = Cx(database: "swisql", user: "swisql", password: "swisql")
    try! await cx.connect()
    let tx = try! await cx.startTx()
    try! await scm.sync(tx)
    try! await q.exec(tx)
    try! await cx.disconnect()
}

enum TestEnum: String, Enum {
    case foo = "foo"
    case bar = "bar"
    case baz = "baz"
}

func recordTests() async {
    let scm = Schema()
    let tbl = Table(scm, "tbl")
    let boolCol = BoolColumn("bool", tbl)
    let dateCol = DateColumn("date", tbl)
    let decimalCol = DecimalColumn("decimal", tbl)
    let enumCol = EnumColumn<TestEnum>("enum", tbl)
    let intCol = IntColumn("int", tbl, primaryKey: true)
    let stringCol = StringColumn("string", tbl)
    let rec = Record()
    
    rec[boolCol] = true
    assert(rec[boolCol]! == true)

    let now = Date.now
    rec[dateCol] = now
    assert(rec[dateCol]! == now)

    let d = Decimal(4.2)
    rec[decimalCol] = d 
    assert(rec[decimalCol] == d)
             
    rec[enumCol] = .foo
    assert(rec[enumCol]! == .foo)

    rec[intCol] = 1
    assert(rec[intCol]! == 1)

    rec[stringCol] = "foo"
    assert(rec[stringCol]! == "foo")
    
    assert(rec.count == 6)
    
    let cx = Cx(database: "swisql", user: "swisql", password: "swisql")
    try! await cx.connect()
    var tx = try! await cx.startTx()
    try! await scm.sync(tx)
    try! await tx.commit()
    tx = try! await cx.startTx()

    assert(!rec.stored(tbl.columns, tx))
    assert(rec.modified(tbl.columns, tx))
    try! await tbl.upsert(rec, tx)
    assert(rec.stored(tbl.columns, tx))
    assert(!rec.modified(tbl.columns, tx))

    rec[intCol] = 2
    assert(rec[intCol]! == 2)
    assert(rec.modified(tbl.columns, tx))
    try! await tbl.upsert(rec, tx)
    assert(rec.stored(tbl.columns, tx))
    assert(!rec.modified(tbl.columns, tx))

    try! await scm.drop(tx)
    try! await tx.commit()
    try! await cx.disconnect()
}

conditionTests()
await foreignKeyTests()
orderedSetTests()
await queryTests()
await recordTests()
