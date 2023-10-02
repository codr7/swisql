public class ForeignKey: Constraint {
    let foreignTable: Table
    let foreignColumns: [Column]

    public init(_ table: Table, _ name: String, _ foreignColumns: [Column]) {
        foreignTable = foreignColumns[0].table
        self.foreignColumns = foreignColumns
        var columns: [Column] = []
        
        for fc in foreignColumns[1...] {
            if fc.table !== table {
                fatalError("Table mismatch: \(table)/\(fc.table)")
            }

            columns.append(fc.clone(table, "\(name)\(fc.name)"))
        }

        super.init(name, columns)
    }
    
    public override var constraintType: String {
        "FOREIGN KEY"
    }
}
