struct Field {
    let column: Column
    var value: Any
}

public class Record {
    var fields: OrderedSet<Column, Field>

    public init() {
        fields = OrderedSet({(l: Column, r: Field) -> Order in
                                let t = compare(ObjectIdentifier(l.table), ObjectIdentifier(r.column.table))
                                
                                return if t == .equal {
                                    compare(ObjectIdentifier(l), ObjectIdentifier(r.column))
                                } else {
                                    t
                                }   
                            })
    }

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

    public func store(in tx: Tx) throws {
        fields.items.forEach {tx[self, $0.column] = $0.value}
    }
}
