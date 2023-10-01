public class Column: TableDefinition {
    public let nullable: Bool
    public let primaryKey: Bool
    
    public init(_ table: Table, _ name: String, nullable: Bool = false, primaryKey: Bool = false) {
        self.nullable = nullable
        self.primaryKey = primaryKey
        super.init(table, name)
        table.columns.append(self)
    }
}

public class TypedColumn<T>: Column {
}

public class IntColumn: TypedColumn<Int> {
    public var sqlType: String {
        get { return "INTEGER" }
    }
}
