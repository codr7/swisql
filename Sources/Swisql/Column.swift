import Foundation
import PostgresNIO

public protocol Column: SqlValue, TableDefinition {
    var columnType: String {get}
    var id: ObjectIdentifier {get}
    var nullable: Bool {get}
    var primaryKey: Bool {get}
    
    func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool) -> Column
    func equal(_ left: Any, _ right: Any) -> Bool
}

public class BasicColumn<T: Equatable>: BasicTableDefinition {
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

    public var paramSql: String {
        "?"
    }

    public func encode(_ value: Any) -> any Encodable {
        value as! any Encodable
    }

    public func equal(_ left: Any, _ right: Any) -> Bool {
        return left as! T == right as! T
    }
    
    public func exists(inTx tx: Tx) async throws -> Bool {
        try await tx.queryValue("""
                                  SELECT EXISTS (
                                    SELECT
                                    FROM pg_attribute 
                                    WHERE attrelid = \(table.name)::regclass
                                    AND attname = \(name)
                                    AND NOT attisdropped
                                  )
                                  """)
    }
}

public extension Column {
    var createSql: String {
        var sql = "\(Swisql.createSql(self as TableDefinition)) \(columnType)"
        if primaryKey || !nullable { sql += " NOT NULL" }
        return sql
    }

    var dropSql: String {
        Swisql.dropSql(self)
    }

    var valueSql: String {
        "\(table.nameSql).\(nameSql)"
    }
    
    var valueParams: [any Encodable] {
        []
    }
}

extension Bool: Encodable {
}

public class BoolColumn: BasicColumn<Bool>, Column {
    public override init(_ name: String, _ table: Table, nullable: Bool = false, primaryKey: Bool = false) {
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table._columns.append(self)
    }
    
    public var columnType: String {
        "BOOLEAN"
    }

    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool) -> Column {
        BoolColumn(name, table, nullable: nullable, primaryKey: primaryKey)
    }
}

extension Date: Encodable {
}

public class DateColumn: BasicColumn<Date>, Column {
    public override init(_ name: String, _ table: Table, nullable: Bool = false, primaryKey: Bool = false) {
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table._columns.append(self)
    }

    public var columnType: String {
        "TIMESTAMP"
    }

    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool) -> Column {
        DateColumn(name, table, nullable: nullable, primaryKey: primaryKey)
    }
}

public class EnumColumn<T: Enum>: BasicColumn<T>, Column where T.RawValue == String {
    public let type: EnumType<T>

    public override init(_ name: String, _ table: Table, nullable: Bool = false, primaryKey: Bool = false) {
        type = EnumType<T>(table.schema)
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table._columns.append(self)
    }

    public var columnType: String {
        "\"\(String(describing: T.self))\""
    }

    public override var paramSql: String {
        "?::\(type.nameSql)"
    }
    
    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool ) -> Column {
        EnumColumn<T>(name, table, nullable: nullable, primaryKey: primaryKey)
    }

    public func create(inTx tx: Tx) async throws {
        if !(try await type.exists(inTx: tx)) {
            try await type.create(inTx: tx)
        }
        
        try await tx.exec(self.createSql)
    }

    public override func encode(_ value: Any) -> any Encodable {
        (value as! T).rawValue
    }

    public func sync(inTx tx: Tx) async throws {
        try await type.sync(inTx: tx)

        if !(try await exists(inTx: tx)) {
            try await create(inTx: tx)
        }
    }
}

extension Int: Encodable {
}

public class IntColumn: BasicColumn<Int>, Column {
    public override init(_ name: String, _ table: Table, nullable: Bool = false, primaryKey: Bool = false) {
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table._columns.append(self)
    }

    public var columnType: String {
        "INTEGER"
    }

    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool) -> Column {
        IntColumn(name, table, nullable: nullable, primaryKey: primaryKey)
    }
}

extension String: Encodable {
}

public class StringColumn: BasicColumn<String>, Column {
    public override init(_ name: String, _ table: Table, nullable: Bool = false, primaryKey: Bool = false) {
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table._columns.append(self)
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
        self.map({$0.nameSql}).joined(separator: ", ")
    }
}
