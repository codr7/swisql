public class Table: BasicDefinition, Definition {
    var definitions: [any TableDefinition] = []
    var columns: [any Column] = []
    var foreignKeys: [ForeignKey] = []
    lazy var primaryKey: Key = Key("\(name)PrimaryKey", columns.filter {$0.primaryKey})

    public override init(_ schema: Schema, _ name: String) {
        super.init(schema, name)
        schema.definitions.append(self)
    }
    
     public var definitionType: String {
        "TABLE"
    }

     public var createSql: String {
         "\(Swisql.createSql(self)) ()"
     }

     public var dropSql: String {
         Swisql.dropSql(self)
     }

    public func create(inTx tx: Tx) async throws {
        try await tx.exec(createSql)
        _ = primaryKey
        for d in definitions {try await d.create(inTx: tx)}
    }

    public func exists(inTx tx: Tx) async throws -> Bool {
        try await tx.queryValue("""
                                  SELECT EXISTS (
                                    SELECT FROM pg_tables
                                    WHERE tablename  = \(sqlName)
                                  )
                                  """)
    }

    public func sync(inTx tx: Tx) async throws {
        if (try await exists(inTx: tx)) {
            for d in definitions {
                try await d.sync(inTx: tx)
            }
        } else {
            try await create(inTx: tx)
        }
    }
}
