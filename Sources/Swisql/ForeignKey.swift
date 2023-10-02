public class ForeignKey: Constraint {
    let foreignTable: Table
    let foreignColumns: [Column]

    public init(_ name: String, _ table: Table, _ foreignColumns: [Column]) {
        foreignTable = foreignColumns[0].table
        self.foreignColumns = foreignColumns
        var columns: [Column] = []
        
        for fc in foreignColumns[1...] {
            if fc.table !== table {
                fatalError("Table mismatch: \(table)/\(fc.table)")
            }

            columns.append(fc.clone("\(name)\(fc.name)", table))
        }

        super.init(name, columns)
        table.foreignKeys.append(self)
    }
    
    public override var constraintType: String {
        "FOREIGN KEY"
    }
}
