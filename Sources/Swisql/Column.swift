public class Column: TableDefinition {
    public let nullable: Bool
    public let primaryKey: Bool
    
    public init(_ table: Table, _ name: String, nullable: Bool = false, primaryKey: Bool = false) {
        self.nullable = nullable
        self.primaryKey = primaryKey
        super.init(table, name)
        table.columns.append(self)
    }

    public var sqlType: String {
        get { fatalError("Not implemented") }
    }
}

public class TypedColumn<T>: Column {
}

public class IntColumn: TypedColumn<Int> {
    public override var sqlType: String {
        get { "INTEGER" }
    }
}
