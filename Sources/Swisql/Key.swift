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

    public func create(inTx tx: Tx) async throws {
        try await tx.exec(createSql(self))
    }
    
    public func drop(inTx tx: Tx) async throws {
        try await tx.exec(dropSql(self))
    }   
}
