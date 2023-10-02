public enum ForeignKeyAction: String {
    case cascade = "CASCADE"
    case restrict = "RESTRICT"
}

public class ForeignKey: BasicConstraint, Constraint {
    let foreignTable: Table
    let foreignColumns: [any Column]

    public init(_ name: String, _ table: Table, _ foreignColumns: [any Column],
                nullable: Bool = false, primaryKey: Bool = false,
                onUpdate: ForeignKeyAction = .cascade, onDelete: ForeignKeyAction = .restrict) {
        foreignTable = foreignColumns[0].table
        self.foreignColumns = foreignColumns
        var columns: [Column] = []

        for fc in foreignColumns {
            if fc.table !== foreignTable {
                fatalError("Table mismatch: \(table)/\(fc.table)")
            }

            columns.append(fc.clone("\(name)\(fc.name)", table, nullable: nullable, primaryKey: primaryKey))
        }

        super.init(name, columns)
        table.definitions.append(self)
        table.foreignKeys.append(self)
    }
    
    public var constraintType: String {
        "FOREIGN KEY"
    }

    public var createSql: String {
        "\(Swisql.createSql(self)) REFERENCES \(foreignTable.sqlName) (\(foreignColumns.sql))"
    }

    public var dropSql: String {
        Swisql.dropSql(self)
    }
    
    public func create(inTx tx: Tx) throws {
        try tx.exec(sql: self.createSql)
    }
    
    public func drop(inTx tx: Tx) throws {
        try tx.exec(sql: self.dropSql)
    }    
}
