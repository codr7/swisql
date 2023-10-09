public protocol TableDefinition: Definition {
    var table: Table {get}
}

public class BasicTableDefinition: BasicDefinition {
    public let table: Table

    public init(_ name: String, _ table: Table) {
        self.table = table
        super.init(table.schema, name)
    }
}

public func createSql(_ d: TableDefinition) -> String {
    "ALTER TABLE \(d.table.nameSql) ADD \(d.definitionType) \(d.nameSql)"
}

public func dropSql(_ d: TableDefinition) -> String {
    "ALTER TABLE \(d.table.nameSql) DROP \(d.definitionType) \(d.nameSql)"
}
