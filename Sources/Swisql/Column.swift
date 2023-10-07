import Foundation
import PostgresNIO

public protocol Column: TableDefinition {
    var columnType: String {get}
    var id: ObjectIdentifier {get}
    var nullable: Bool {get}
    var primaryKey: Bool {get}
    func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool) -> Column
    func encode(_ value: Any) -> PostgresDynamicTypeEncodable
}

public class BasicColumn<T>: BasicTableDefinition {
    public let nullable: Bool
    public let primaryKey: Bool
    
    public init(_ name: String, _ table: Table, nullable: Bool = false, primaryKey: Bool = false) {
        self.nullable = nullable
        self.primaryKey = primaryKey
        super.init(name, table)
    }
    
    public var definitionType: String {
       "COLUMN"
    }
    
    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }

    public func encode(_ value: Any) -> PostgresDynamicTypeEncodable {
        value as! PostgresDynamicTypeEncodable
    }
    
    public func exists(inTx tx: Tx) async throws -> Bool {
        try await tx.queryValue("""
                                  SELECT EXISTS (
                                    SELECT
                                    FROM pg_attribute 
                                    WHERE attrelid = \(table.sqlName)
                                    AND attname = \(sqlName)
                                    AND NOT attisdropped
                                  )
                                  """)
    }
}

public extension Column {
    var createSql: String {
        Swisql.createSql(self)
    }

    var dropSql: String {
        Swisql.dropSql(self)
    }
}

public func createSql(_ c: any Column) -> String {
    var sql = "\(createSql(c as TableDefinition)) \(c.columnType)"
    if !c.nullable { sql += " NOT NULL" }
    return sql
}

public class BoolColumn: BasicColumn<Bool>, Column {
    public override init(_ name: String, _ table: Table, nullable: Bool = false, primaryKey: Bool = false) {
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table.columns.append(self)
    }
    
    public var columnType: String {
        "BOOLEAN"
    }

    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool) -> Column {
        BoolColumn(name, table, nullable: nullable, primaryKey: primaryKey)
    }
}

public class DateColumn: BasicColumn<Date>, Column {
    public override init(_ name: String, _ table: Table, nullable: Bool = false, primaryKey: Bool = false) {
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table.columns.append(self)
    }

    public var columnType: String {
        "TIMESTAMP"
    }

    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool) -> Column {
        DateColumn(name, table, nullable: nullable, primaryKey: primaryKey)
    }
}

public class EnumColumn<T>: BasicColumn<T>, Column where T: CaseIterable, T: RawRepresentable, T.RawValue == String {
    public override init(_ name: String, _ table: Table, nullable: Bool = false, primaryKey: Bool = false) {
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table.columns.append(self)
    }

    public var columnType: String {
        "\"\(String(describing: T.self))\""
    }

    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool ) -> Column {
        EnumColumn<T>(name, table, nullable: nullable, primaryKey: primaryKey)
    }

    public func create(inTx tx: Tx) async throws {
        let type = Enum<T>(schema)
        
        if !(try await type.exists(inTx: tx)) {
            try await type.create(inTx: tx)
        }
        
        try await tx.exec(self.createSql)
    }

    public override func encode(_ value: Any) -> PostgresDynamicTypeEncodable {
        (value as! T).rawValue
    }
}

public class IntColumn: BasicColumn<Int>, Column {
    public override init(_ name: String, _ table: Table, nullable: Bool = false, primaryKey: Bool = false) {
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table.columns.append(self)
    }

    public var columnType: String {
        "INTEGER"
    }

    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool) -> Column {
        IntColumn(name, table, nullable: nullable, primaryKey: primaryKey)
    }
}

public class StringColumn: BasicColumn<String>, Column {
    public override init(_ name: String, _ table: Table, nullable: Bool = false, primaryKey: Bool = false) {
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table.columns.append(self)
    }

    public var columnType: String {
        "TEXT"
    }

    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool ) -> Column {
        StringColumn(name, table, nullable: nullable, primaryKey: primaryKey)
    }
}

extension [any Column] {
    var sql: String {
        self.map({$0.sqlName}).joined(separator: ", ")
    }
}
