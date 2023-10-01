public class Key: Constraint {
    public override var constraintType: String {
        get {
            if ObjectIdentifier(self) == ObjectIdentifier(table.primaryKey) {
                "PRIMARY KEY"
            } else {
                "UNIQUE"
            }
        }
    }
}
