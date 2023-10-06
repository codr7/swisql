public protocol Constraint: TableDefinition {
    var columns: [any Column] {get}
    var constraintType: String {get}
}

public class BasicConstraint: BasicTableDefinition {
    public let columns: [any Column]

    public init(_ name: String, _ columns: [any Column]) {
        let table = columns[0].table

        for c in columns[1...] {
            if c.table !== table {
                fatalError("Table mismatch: \(table)/\(c.table)")
            }
        }
        
        self.columns = columns
        super.init(name, table)
    }
    
    public var definitionType: String {
        "CONSTRAINT"
    }

    public func exists(inTx tx: Tx) async throws -> Bool {
        let rows = try await tx.query("""
                                        SELECT EXISTS (
                                          SELECT constraint_name 
                                          FROM information_schema.constraint_column_usage 
                                          WHERE table_name = \(table.sqlName)  and constraint_name = \(sqlName)
                                        )
                                        """)

        for try await (exists) in rows.decode((Bool).self) {
            return exists
        }

        return false
    }
}

public func createSql(_ c: Constraint) -> String {
    "\(createSql(c as TableDefinition)) \(c.constraintType) (\(c.columns.sql))"
}
