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

    public var createSql: String {
        Swisql.createSql(self)
    }
    
    public var dropSql: String {
        Swisql.dropSql(self)
    }   
}
