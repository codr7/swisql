public class Constraint: TableDefinition {
    let columns: [Column]

    public init(_ table: Table, _ name: String, _ columns: [Column]) {
        self.columns = columns
        super.init(table, name)
    }

    public var constraintType: String {
        get {fatalError("Not implemented")}
    }

    public override var createSql: String {
        get {"\(super.createSql) \(constraintType)"}
    }

    public override var definitionType: String {
        get {"CONSTRAINT"}
    }
}
