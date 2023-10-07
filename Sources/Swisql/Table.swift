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

    public func insert(_ rec: Record, inTx tx: Tx) async throws {
        let cvs = columns.map({($0, rec[$0])}).filter({$0.1 != nil})

        let sql = """
          INSERT INTO \(sqlName) (\(cvs.map({$0.0}).sql))
          VALUES (\([String](repeating: "?", count: cvs.count).joined(separator: ", ")))
          """

        try await tx.exec(sql, cvs.map {$0.0.encode($0.1!)})
        for cv in cvs {tx[rec, cv.0] = cv.1}
    }

    public func exists(_ rec: Record, inTx tx: Tx) -> Bool {
        for c in primaryKey.columns {
            if tx[rec, c] == nil {
                return false
            }
        }

        return true
    }
    
    public func upsert(_ rec: Record, inTx tx: Tx) async throws {
        if exists(rec, inTx: tx) {
            //try await table.update(rec, inTx: tx)
        } else {
            try await insert(rec, inTx: tx)
        }
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
