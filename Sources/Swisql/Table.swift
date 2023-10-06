public class Table: BasicDefinition, Definition {
    var definitions: [any TableDefinition] = []
    var columns: [any Column] = []
    var foreignKeys: [ForeignKey] = []
    lazy var primaryKey: Key = Key("\(name)PrimaryKey", columns.filter {$0.primaryKey})

     public var definitionType: String {
        "TABLE"
    }

    public func create(inTx tx: Tx) async throws {
        try await tx.exec(createSql(self))
        _ = primaryKey
        for d in definitions {try await d.create(inTx: tx)}
    }

    public func drop(inTx tx: Tx) async throws {
        try await tx.exec(dropSql(self))
    }

    public func exists(inTx tx: Tx) async throws -> Bool {
        let rows = try await tx.query("""
                                        SELECT EXISTS (
                                          SELECT FROM pg_tables
                                          WHERE tablename  = \(sqlName)
                                        )
                                        """)

        for try await (exists) in rows.decode((Bool).self) {
            return exists
        }

        return false
    }
}

public func createSql(_ t: Table) -> String {
    "\(createSql(t as Definition)) ()"
}
