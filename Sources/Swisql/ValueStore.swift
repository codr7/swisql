struct ValueKey: Hashable {
    let record: Record
    let column: any Column
      
    init(_ record: Record, _ column: any Column) {
        self.record = record
        self.column = column
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(record))
        hasher.combine(column.id)
    }
}

func ==(l: ValueKey, r: ValueKey) -> Bool {
    return l.record === r.record && l.column.id == r.column.id
}

public class ValueStore {
    var storedValues: [ValueKey: Any] = [:]

    public subscript(record: Record, column: any Column) -> Any? {
        get { storedValues[ValueKey(record, column)] }
        set(value) { storedValues[ValueKey(record, column)] = value }
    }
}
