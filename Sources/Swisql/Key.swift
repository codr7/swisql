public class Key: Constraint {
    public override var constraintType: String {
        get {
            if self === table.primaryKey {
                "PRIMARY KEY"
            } else {
                "UNIQUE"
            }
        }
    }
}
