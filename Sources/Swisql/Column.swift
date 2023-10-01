public class Column: TableDefinition {
    public let nullable: Bool
    public let primaryKey: Bool
    
    public init(_ table: Table, _ name: String, nullable: Bool = false, primaryKey: Bool = false) {
        self.nullable = nullable
        self.primaryKey = primaryKey
        super.init(table, name)
        table.columns.append(self)
    }

    public var columnType: String {
        get { fatalError("Not implemented") }
    }

    public override var createSql: String {
        get {
            var sql = "\(super.createSql) \(columnType)"
            if !nullable { sql += " NOT NULL" }
            if primaryKey { sql += " PRIMARY KEY" }
            return sql
        }
    }

    public override var definitionType: String {
        get {"COLUMN"}
    }    
}

public class TypedColumn<T>: Column {
}

public class IntColumn: TypedColumn<Int> {
    public override var columnType: String {
        get { "INTEGER" }
    }
}
