public class Key: BasicConstraint, Constraint {
    public override init(_ name: String, _ columns: [any Column]) {
        super.init(name, columns)
        self.table.definitions.append(self)
    }
    
    public var constraintType: String {
        if self === table.primaryKey {
            "PRIMARY KEY"
        } else {
            "UNIQUE"
        }
    }

    public func create(inTx tx: Tx) throws {
        try tx.exec(sql: createSql(self))
    }
    
    public func drop(inTx tx: Tx) throws {
        try tx.exec(sql: dropSql(self))
    }   
}
