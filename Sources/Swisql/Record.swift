struct Field {
    let column: Column
    var value: Any
}

public struct Record {
    var fields: OrderedSet<Column, Field>

    public init() {
        fields = OrderedSet(compare: {
                                (l: Column, r: Field) -> Order in
                                return .equal
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
