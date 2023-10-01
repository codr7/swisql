public class Table: Definition {
    var definitions: [TableDefinition] = []
    var columns: [Column] = []
    var _primaryKey: Key?

    public override var createSql: String {
        get {"\(super.createSql) ()"}
    }

    public override var definitionType: String {
        get {"TABLE"}
    }

    public var primaryKey: Key {
        get {
            if _primaryKey == nil {
                _primaryKey = Key(self, "\(name)PrimaryKey",
                                  columns.filter {$0.primaryKey})
            }

            return _primaryKey!
        }
    }

    public override func create(inTx tx: Tx) throws {
        try super.create(inTx: tx)
        for d in definitions {try d.create(inTx: tx)}
        if _primaryKey == nil {try primaryKey.create(inTx: tx)}
    }
}
