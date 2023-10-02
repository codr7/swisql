public enum ForeignKeyAction: String {
    case cascade = "CASCADE"
    case restrict = "RESTRICT"
}

public class ForeignKey: Constraint {
    let foreignTable: Table
    let foreignColumns: [Column]

    public init(_ name: String, _ table: Table, _ foreignColumns: [Column],
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
        table.foreignKeys.append(self)
    }
    
    public override var constraintType: String {
        "FOREIGN KEY"
    }

    public override var createSql: String {
        "\(super.createSql) REFERENCES \(foreignTable.sqlName) (\(foreignColumns.sql))"
    }
}
