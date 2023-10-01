struct ValueKey: Hashable {
    let record: Record
    let column: Column
      
    init(_ record: Record, _ column: Column) {
        self.record = record
        self.column = column
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(record))
        hasher.combine(ObjectIdentifier(column))
    }
}

func ==(l: ValueKey, r: ValueKey) -> Bool {
    return
      ObjectIdentifier(l.record) == ObjectIdentifier(r.record) &&
      ObjectIdentifier(l.column) == ObjectIdentifier(r.column)
}

public class ValueStore {
    var storedValues: [ValueKey: Any] = [:]

    public subscript(record: Record, column: Column) -> Any? {
        get { storedValues[ValueKey(record, column)] }
        set(value) { storedValues[ValueKey(record, column)] = value }
    }
}
