struct Field {
    let column: Column
    var value: Any
}

public class Record {
    var fields: OrderedSet<Column, Field>

    public init() {
        fields = OrderedSet({(l: Column, r: Field) -> Order in
                                let t = compare(l.table.name, r.column.table.name)
                                
                                return if t == .equal {
                                    compare(l.name, r.column.name)
                                } else {
                                    t
                                }   
                            })
    }

    public var count: Int {
        get {
            return fields.count
        }
    }

    public subscript<T>(column: TypedColumn<T>) -> T? {
        get {
            if let f = self.fields[column] {
                return f.value as? T
            }

            return nil
        }
        set(value) {
            if value == nil {
                self.fields[column] = nil
            } else {
                self.fields[column] = Field(column: column, value: value!)
            }
        }
    }
}
