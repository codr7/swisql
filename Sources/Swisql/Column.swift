public class Column: TableDefinition {
    public let nullable: Bool
    public let primaryKey: Bool
    
    public init(_ name: String, _ table: Table, nullable: Bool = false, primaryKey: Bool = false) {
        self.nullable = nullable
        self.primaryKey = primaryKey
        super.init(name, table)
        table.columns.append(self)
    }

    public var columnType: String {
        fatalError("Not implemented")
    }

    public override var createSql: String {
        var sql = "\(super.createSql) \(columnType)"
        if !nullable { sql += " NOT NULL" }
        if primaryKey { sql += " PRIMARY KEY" }
        return sql
    }

    public override var definitionType: String {
       "COLUMN"
    }

    public func clone(_ name: String, _ table: Table) -> Column {
        fatalError("Not implemented")
    }
}

public class TypedColumn<T>: Column {
}

public class BoolColumn: TypedColumn<Bool> {
    public override var columnType: String {
        "BOOLEAN"
    }

    public override func clone(_ name: String, _ table: Table) -> Column {
        BoolColumn(name, table)
    }
}

public class IntColumn: TypedColumn<Int> {
    public override var columnType: String {
        "INTEGER"
    }

    public override func clone(_ name: String, _ table: Table) -> Column {
        IntColumn(name, table)
    }
}

public class StringColumn: TypedColumn<String> {
    public override var columnType: String {
        "TEXT"
    }

    public override func clone(_ name: String, _ table: Table) -> Column {
        StringColumn(name, table)
    }
}
