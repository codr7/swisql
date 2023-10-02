import Foundation

public protocol Column: TableDefinition {
    var columnType: String {get}
    var id: ObjectIdentifier {get}
    var nullable: Bool {get}
    var primaryKey: Bool {get}
    func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool) -> Column
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
}

public func createSql(_ c: any Column) -> String {
    var sql = "\(createSql(c as TableDefinition)) \(c.columnType)"
    if !c.nullable { sql += " NOT NULL" }
    if c.primaryKey { sql += " PRIMARY KEY" }
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

    public var createSql: String {
        Swisql.createSql(self)
    }

    public var dropSql: String {
        Swisql.dropSql(self)
    }

    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool) -> Column {
        BoolColumn(name, table, nullable: nullable, primaryKey: primaryKey)
    }

    public func create(inTx tx: Tx) throws {
        try tx.exec(sql: self.createSql)
    }

    public func drop(inTx tx: Tx) throws {
        try tx.exec(sql: self.dropSql)
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

    public var createSql: String {
        Swisql.createSql(self)
    }

    public var dropSql: String {
        Swisql.dropSql(self)
    }

    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool) -> Column {
        DateColumn(name, table, nullable: nullable, primaryKey: primaryKey)
    }

    public func create(inTx tx: Tx) throws {
        try tx.exec(sql: self.createSql)
    }

    public func drop(inTx tx: Tx) throws {
        try tx.exec(sql: self.dropSql)
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

    public var createSql: String {
        Swisql.createSql(self)
    }

    public var dropSql: String {
        Swisql.dropSql(self)
    }

    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool) -> Column {
        IntColumn(name, table, nullable: nullable, primaryKey: primaryKey)
    }

    public func create(inTx tx: Tx) throws {
        try tx.exec(sql: self.createSql)
    }

    public func drop(inTx tx: Tx) throws {
        try tx.exec(sql: self.dropSql)
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

    public var createSql: String {
        Swisql.createSql(self)
    }

    public var dropSql: String {
        Swisql.dropSql(self)
    }

    public func clone(_ name: String, _ table: Table, nullable: Bool, primaryKey: Bool ) -> Column {
        StringColumn(name, table, nullable: nullable, primaryKey: primaryKey)
    }

    public func create(inTx tx: Tx) throws {
        try tx.exec(sql: self.createSql)
    }

    public func drop(inTx tx: Tx) throws {
        try tx.exec(sql: self.dropSql)
    }        
}

extension [any Column] {
    var sql: String {
        self.map({$0.sqlName}).joined(separator: ", ")
    }
}
