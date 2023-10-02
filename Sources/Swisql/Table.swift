public class Table: BasicDefinition, Definition {
    var definitions: [any TableDefinition] = []
    var columns: [any Column] = []
    var foreignKeys: [ForeignKey] = []
    lazy var primaryKey: Key = Key("\(name)PrimaryKey", columns.filter {$0.primaryKey})

    public var createSql: String {
        "\(Swisql.createSql(self)) ()"
    }

    public var definitionType: String {
        "TABLE"
    }

    public var dropSql: String {
        Swisql.dropSql(self)
    }

    public func create(inTx tx: Tx) throws {
        try tx.exec(sql: self.createSql)
        _ = primaryKey
        for d in definitions {try d.create(inTx: tx)}
    }

    public func drop(inTx tx: Tx) throws {
        try tx.exec(sql: self.dropSql)
    }
}
