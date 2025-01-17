import Foundation
import PostgresNIO

public protocol Column: Value, TableDefinition {
    var columnType: String {get}
    var id: ObjectIdentifier {get}
    var nullable: Bool {get}
    var primaryKey: Bool {get}
    
    func clone(_ name: String, _ table: Table,
               nullable: Bool, primaryKey: Bool) -> Column
    func equal(_ left: Any, _ right: Any) -> Bool
}

public class BasicColumn<T: Equatable>: BasicTableDefinition {
    public let nullable: Bool
    public let primaryKey: Bool
    
    public init(_ name: String, _ table: Table,
                nullable: Bool = false, primaryKey: Bool = false) {
        self.nullable = nullable
        self.primaryKey = primaryKey
        super.init(name, table)
    }
    
    public var definitionType = "COLUMN"
    
    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }

    public var paramSql: String { "?" }

    public func encode(_ value: Any) -> any Encodable {
        value as! any Encodable
    }

    public func equal(_ left: Any, _ right: Any) -> Bool {
        return left as! T == right as! T
    }
    
    public func exists(_ tx: Tx) async throws -> Bool {
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

    var dropSql: String { Swisql.dropSql(self) }
    var valueSql: String { "\(table.nameSql).\(nameSql)" }
    var valueParams: [any Encodable] { [] }
}

public class BoolColumn: BasicColumn<Bool>, Column {
    public override init(_ name: String, _ table: Table,
                         nullable: Bool = false, primaryKey: Bool = false) {
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table._columns.append(self)
    }
    
    public var columnType = "BOOLEAN"

    public func clone(_ name: String, _ table: Table,
                      nullable: Bool, primaryKey: Bool) -> Column {
        BoolColumn(name, table, nullable: nullable, primaryKey: primaryKey)
    }
}

public class DateColumn: BasicColumn<Date>, Column {
    public override init(_ name: String, _ table: Table,
                         nullable: Bool = false, primaryKey: Bool = false) {
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table._columns.append(self)
    }

    public var columnType = "TIMESTAMPTZ"

    public func clone(_ name: String, _ table: Table,
                      nullable: Bool, primaryKey: Bool) -> Column {
        DateColumn(name, table, nullable: nullable, primaryKey: primaryKey)
    }
}

extension Decimal: @retroactive PostgresDynamicTypeEncodable {}

public class DecimalColumn: BasicColumn<Decimal>, Column {
    let precision: Int
    
    public init(_ name: String, _ table: Table,
                nullable: Bool = false,
                primaryKey: Bool = false,
                precision: Int = 38) {
        self.precision = precision
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table._columns.append(self)
    }

    public var columnType: String { "DECIMAL(\(precision))" }

    public func clone(_ name: String, _ table: Table,
                      nullable: Bool, primaryKey: Bool) -> Column {
        DecimalColumn(name, table,
                      nullable: nullable,
                      primaryKey: primaryKey,
                      precision: precision)
    }
}

public class EnumColumn<T: Enum>: BasicColumn<T>, Column where T.RawValue == String {
    public let type: EnumType<T>

    public override init(_ name: String, _ table: Table,
                         nullable: Bool = false, primaryKey: Bool = false) {
        type = EnumType<T>(table.schema)
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table._columns.append(self)
    }

    public var columnType: String { "\"\(String(describing: T.self))\"" }

    public override var paramSql: String { "?::\(type.nameSql)" }
    
    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool ) -> Column {
        EnumColumn<T>(name, table, nullable: nullable, primaryKey: primaryKey)
    }

    public func create(_ tx: Tx) async throws {
        if !(try await type.exists(tx)) {
            try await type.create(tx)
        }
        
        try await tx.exec(self.createSql)
    }

    public override func encode(_ value: Any) -> any Encodable {
        (value as! T).rawValue
    }

    public func sync(_ tx: Tx) async throws {
        try await type.sync(tx)
        if !(try await exists(tx)) { try await create(tx) }
    }
}

public class IntColumn: BasicColumn<Int>, Column {
    public override init(_ name: String, _ table: Table, nullable: Bool = false, primaryKey: Bool = false) {
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table._columns.append(self)
    }

    public var columnType = "INTEGER"

    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool) -> Column {
        IntColumn(name, table, nullable: nullable, primaryKey: primaryKey)
    }
}

public class StringColumn: BasicColumn<String>, Column {
    public override init(_ name: String, _ table: Table, nullable: Bool = false, primaryKey: Bool = false) {
        super.init(name, table, nullable: nullable, primaryKey: primaryKey)
        table.definitions.append(self)
        table._columns.append(self)
    }

    public var columnType = "TEXT"

    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool ) -> Column {
        StringColumn(name, table, nullable: nullable, primaryKey: primaryKey)
    }
}

extension [any Column] {
    var sql: String {
        self.map({$0.nameSql}).joined(separator: ", ")
    }
}
