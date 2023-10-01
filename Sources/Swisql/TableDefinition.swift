public class TableDefinition: Definition {
    public let table: Table

    public init(_ table: Table, _ name: String) {
        self.table = table
        super.init(name)
        table.definitions.append(self)
    }
}
