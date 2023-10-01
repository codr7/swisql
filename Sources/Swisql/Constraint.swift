public class Constraint: TableDefinition {
    let columns: [Column]

    public init(_ table: Table, _ name: String, _ columns: [Column]) {
        self.columns = columns
        super.init(table, name)
    }
}
