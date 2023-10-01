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

    public override func create(in tx: Tx) throws {
        try definitions.forEach {try $0.create(in: tx)}
    }
}
