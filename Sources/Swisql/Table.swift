public class Table: Definition {
    var definitions: [TableDefinition] = []
    var columns: [Column] = []
    var _primaryKey: Key?

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
        try tx.exec(sql: "CREATE TABLE \(sqlName) ()")
        for d in definitions {try d.create(inTx: tx)}
    }
}
