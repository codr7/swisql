import Foundation
import Swisql

func foreignKeyTests() {
    let tbl1 = Table("tbl1")
    let col1 = IntColumn("col", tbl1, primaryKey: true)

    let tbl2 = Table("tbl2")
    _ = ForeignKey("fkey", tbl2, [col1], primaryKey: true)
    
    let cx = Cx()
    let tx = try! cx.startTx()
    try! tbl1.create(inTx: tx)
    try! tbl2.create(inTx: tx)
    try! tx.rollback()
    try! cx.close()
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

func recordTests() {
    let tbl = Table("tbl")
    let boolCol = BoolColumn("bool", tbl)
    let dateCol = DateColumn("date", tbl)
    let intCol = IntColumn("int", tbl, primaryKey: true)
    let stringCol = StringColumn("string", tbl)
    let rec = Record()
    
    rec[boolCol] = true
    assert(rec[boolCol]! == true)

    let now = Date.now
    rec[dateCol] = now
    assert(rec[dateCol]! == now)

    rec[intCol] = 42
    assert(rec[intCol]! == 42)

    rec[stringCol] = "foo"
    assert(rec[stringCol]! == "foo")
    
    assert(rec.count == 4)

    rec[intCol] = nil
    assert(rec.count == 3)

    let cx = Cx()
    let tx = try! cx.startTx()
    try! tbl.create(inTx: tx)
    try! tx.rollback()
    try! cx.close()
}

foreignKeyTests()
orderedSetTests()
recordTests()
