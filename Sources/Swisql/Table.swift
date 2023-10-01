public class Table: Definition {
    var definitions: [TableDefinition] = []
    var columns: [Column] = []
    lazy var primaryKey: Key = initPrimaryKey()

    func initPrimaryKey() -> Key {
        Key(self, "\(name)PrimaryKey", columns.filter {$0.primaryKey})
    }

    public override var createSql: String {
        get {"\(super.createSql) ()"}
    }

    public override var definitionType: String {
        get {"TABLE"}
    }

    public override func create(inTx tx: Tx) throws {
        try super.create(inTx: tx)
        _ = primaryKey
        for d in definitions {try d.create(inTx: tx)}
    }
}
