import Foundation
import Swisql

func foreignKeyTests() async {
    let tbl1 = Table("tbl1")
    let col1 = IntColumn("col", tbl1, primaryKey: true)
    
    let tbl2 = Table("tbl2")
    _ = ForeignKey("fkey", tbl2, [col1], primaryKey: true)
    
    let cx = Cx(database: "swisql", user: "swisql", password: "swisql")
    try! await cx.connect()

    var tx = try! await cx.startTx()
    try! await tbl1.create(inTx: tx)
    try! await tbl2.create(inTx: tx)
    try! await tx.rollback()

    tx = try! await cx.startTx()
    try! await tbl1.sync(inTx: tx)
    try! await tbl2.sync(inTx: tx)
    try! await tx.rollback()
    
    try! await cx.disconnect()
}

func orderedSetTests() {
    func compareInts(l: Int, r: Int) -> Order {
        if l < r {
            return .less
        }

        if l > r {
            return .greater
        }

        return .equal
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

enum TestEnum: String, CaseIterable {
    case foo = "foo"
    case bar = "bar"
    case baz = "baz"
}

func recordTests() async {
    let tbl = Table("tbl")
    let boolCol = BoolColumn("bool", tbl)
    let dateCol = DateColumn("date", tbl)
    let enumCol = EnumColumn<TestEnum>("enum", tbl)
    let intCol = IntColumn("int", tbl, primaryKey: true)
    let stringCol = StringColumn("string", tbl)
    let rec = Record()
    
    rec[boolCol] = true
    assert(rec[boolCol]! == true)

    let now = Date.now
    rec[dateCol] = now
    assert(rec[dateCol]! == now)

    rec[enumCol] = .foo
    assert(rec[enumCol]! == .foo)

    rec[intCol] = 42
    assert(rec[intCol]! == 42)

    rec[stringCol] = "foo"
    assert(rec[stringCol]! == "foo")
    
    assert(rec.count == 5)

    rec[intCol] = nil
    assert(rec.count == 4)

    let cx = Cx(database: "swisql", user: "swisql", password: "swisql")
    try! await cx.connect()
    let tx = try! await cx.startTx()
    try! await tbl.create(inTx: tx)
    try! await tx.rollback()
    try! await cx.disconnect()
}

await foreignKeyTests()
orderedSetTests()
await recordTests()
