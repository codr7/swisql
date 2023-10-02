public typealias Field = (Column, Any)

public class Record {
    var fields = OrderedSet({(l: Column, r: Field) -> Order in
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
        fields.count
    }

    public subscript<T, C>(column: C) -> T? where C:BasicColumn<T>, C: Column {
        get {
            if let f = fields[column] {
                return f.1 as? T
            }

            return nil
        }
        set(value) {
            if value == nil {
                fields[column] = nil
            } else {
                fields[column] = Field(column, value!)
            }
        }
    }

    public func store(inTx tx: Tx) throws {
        for f in fields.items {tx[self, f.0] = f.1}
    }
}
