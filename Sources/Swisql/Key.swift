public class Key: Constraint {
    public override var constraintType: String {
        if self === table.primaryKey {
            "PRIMARY KEY"
        } else {
            "UNIQUE"
        }
    }
}
