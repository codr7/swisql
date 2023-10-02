public class Constraint: TableDefinition {
    let columns: [Column]

    public init(_ table: Table, _ name: String, _ columns: [Column]) {
        self.columns = columns
        super.init(table, name)
    }

    public var constraintType: String {
        fatalError("Not implemented")
    }

    public override var createSql: String {
        "\(super.createSql) \(constraintType)"
    }

    public override var definitionType: String {
        "CONSTRAINT"
    }
}
