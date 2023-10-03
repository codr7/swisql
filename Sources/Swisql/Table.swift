public class Table: BasicDefinition, Definition {
    var definitions: [any TableDefinition] = []
    var columns: [any Column] = []
    var foreignKeys: [ForeignKey] = []
    lazy var primaryKey: Key = Key("\(name)PrimaryKey", columns.filter {$0.primaryKey})

     public var definitionType: String {
        "TABLE"
    }

    public func create(inTx tx: Tx) throws {
        try tx.exec(sql: createSql(self))
        _ = primaryKey
        for d in definitions {try d.create(inTx: tx)}
    }

    public func drop(inTx tx: Tx) throws {
        try tx.exec(sql: dropSql(self))
    }
}

public func createSql(_ t: Table) -> String {
    "\(createSql(t as Definition)) ()"
}
