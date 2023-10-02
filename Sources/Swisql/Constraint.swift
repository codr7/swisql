public class Constraint: TableDefinition {
    let columns: [Column]

    public init(_ name: String, _ columns: [Column]) {
        let table = columns[0].table

        for c in columns[1...] {
            if c.table !== table {
                fatalError("Table mismatch: \(table)/\(c.table)")
            }
        }
        
        self.columns = columns
        super.init(name, table)
    }

    public var constraintType: String {
        fatalError("Not implemented")
    }

    public override var createSql: String {
        "\(super.createSql) \(constraintType) (\(columns.sql))"
    }

    public override var definitionType: String {
        "CONSTRAINT"
    }
}
