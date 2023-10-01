struct Field {
    let column: Column
    var value: Any
}

public class Record {
    var fields = OrderedSet({(l: Column, r: Field) -> Order in
                                let t = compare(ObjectIdentifier(l.table),
                                                ObjectIdentifier(r.column.table))
                                
                                return if t == .equal {
                                    compare(ObjectIdentifier(l),
                                            ObjectIdentifier(r.column))
                                } else {
                                    t
                                }   
                            })

    public init() {}

    public var count: Int {
        get { fields.count }
    }

    public subscript<T>(column: TypedColumn<T>) -> T? {
        get {
            if let f = fields[column] {
                return f.value as? T
            }

            return nil
        }
        set(value) {
            if value == nil {
                fields[column] = nil
            } else {
                fields[column] = Field(column: column, value: value!)
            }
        }
    }

    public func store(inTx tx: Tx) throws {
        for f in fields.items {tx[self, f.column] = f.value}
    }
}
