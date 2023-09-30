import Swisql

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

    var s = OrderedSet<Int, Int>(compare: compareInts)
    
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
    let col = TypedColumn<Int>(name: "foo")
    var rec = Record()

    rec[col] = 42
    assert(rec[col]! == 42)
    assert(rec.count == 1)

    rec[col] = nil
    assert(rec.count == 0)
}

orderedSetTests()
recordTests()
