public class TableDefinition: Definition {
    public let table: Table

    public init(_ table: Table, _ name: String) {
        self.table = table
        super.init(name)
        table.definitions.append(self)
    }

    public override var createSql: String {
        "ALTER TABLE \(table.sqlName) ADD \(definitionType) \(sqlName)"
    }

    public override var dropSql: String {
        "ALTER TABLE \(table.sqlName) DROP \(definitionType) \(sqlName)"
    }
}
