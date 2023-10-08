public typealias Field = (Column, Any)

public class Record {
    public var fields: [Field] {_fields.items}
    
    var _fields = OrderedSet({(l: Column, r: Field) -> Order in
                                 let t = compare(ObjectIdentifier(l.table),
                                                 ObjectIdentifier(r.0.table))
                                 
                                 return if t == .equal {
                                     compare(l.id, r.0.id)
                                 } else {
                                     t
                                 }   
                             })

    public init() {}

    public var count: Int {
        _fields.count
    }

    public subscript<T, C>(column: C) -> T? where C:BasicColumn<T>, C: Column {
        get {
            if let f = _fields[column] {
                return f.1 as? T
            }

            return nil
        }
        set(value) {
            if value == nil {
                _fields[column] = nil
            } else {
                _fields[column] = (column, value!)
            }
        }
    }

    public subscript(column: Column) -> Any? {
        get {
            if let f = _fields[column] {
                return f.1
            }

            return nil
        }
        set(value) {
            if value == nil {
                _fields[column] = nil
            } else {
                _fields[column] = (column, value!)
            }
        }
    }

    public func modified(_ columns: [Column], inTx tx: Tx) -> Bool {
        for c in columns {
            let l = self[c]
            let r = tx[self, c]
            if l == nil && r == nil  { continue }
            if l == nil || r == nil || !c.equal(l!, r!) { return true }
        }

        return false
    }

    public func stored(_ columns: [Column], inTx tx: Tx) -> Bool {
        for c in columns {
            if tx[self, c] != nil {
                return true
            }
        }

        return false
    }
}
