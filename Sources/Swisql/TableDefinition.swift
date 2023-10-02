public protocol TableDefinition: Definition {
    var table: Table {get}
}

public class BasicTableDefinition: BasicDefinition {
    public let table: Table

    public init(_ name: String, _ table: Table) {
        self.table = table
        super.init(name)
    }
}

public func createSql(_ d: TableDefinition) -> String {
    "ALTER TABLE \(d.table.sqlName) ADD \(d.definitionType) \(d.sqlName)"
}

public func dropSql(_ d: TableDefinition) -> String {
    "ALTER TABLE \(d.table.sqlName) DROP \(d.definitionType) \(d.sqlName)"
}
