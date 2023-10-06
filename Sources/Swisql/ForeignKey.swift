public class ForeignKey: BasicConstraint, Constraint {
    public enum Action: String {
        case cascade = "CASCADE"
        case restrict = "RESTRICT"
    }
    
    let foreignTable: Table
    let foreignColumns: [any Column]
    let onUpdate: Action
    let onDelete: Action
    
    public init(_ name: String, _ table: Table, _ foreignColumns: [any Column],
                nullable: Bool = false, primaryKey: Bool = false,
                onUpdate: Action = .cascade, onDelete: Action = .restrict) {
        self.onUpdate = onUpdate
        self.onDelete = onDelete
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
        "\(Swisql.createSql(self)) REFERENCES \(foreignTable.sqlName) (\(foreignColumns.sql)) " +
          "ON UPDATE \(onUpdate.rawValue) ON DELETE \(onDelete.rawValue)"
    }

    public var dropSql: String {
        Swisql.dropSql(self)
    }
}
