public class Table: BasicDefinition, Definition, Source {
    var definitions: [any TableDefinition] = []
    var _columns: [any Column] = []
    public var columns: [Column] { _columns }
    var foreignKeys: [ForeignKey] = []
    lazy var primaryKey: Key = Key("\(name)PrimaryKey", _columns.filter {$0.primaryKey})
    public var sourceSql: String { nameSql }

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

    public func create(_ tx: Tx) async throws {
        try await tx.exec(createSql)
        _ = primaryKey
        for d in definitions {try await d.create(tx)}
    }

    public func exists(_ tx: Tx) async throws -> Bool {
        try await tx.queryValue("""
                                  SELECT EXISTS (
                                    SELECT FROM pg_tables
                                    WHERE tablename  = \(name)
                                  )
                                  """)
    }

    public func insert(_ rec: Record, _ tx: Tx) async throws {
        let cvs = _columns.map({($0, rec[$0])}).filter({$0.1 != nil})

        let sql = """
          INSERT INTO \(nameSql) (\(cvs.map({$0.0}).sql))
          VALUES (\(cvs.map({$0.0.paramSql}).joined(separator: ", ")))
          """

        try await tx.exec(sql, cvs.map {$0.0.encode($0.1!)})
        for cv in cvs {tx[rec, cv.0] = cv.1}
    }

    public func update(_ rec: Record, _ tx: Tx) async throws {
        let cvs = _columns.map({($0, rec[$0])}).filter({$0.1 != nil})
        var wcs: [Condition] = []

        for c in primaryKey.columns {
            let v = tx[rec, c] ?? rec[c]
            if v == nil { throw DatabaseError.missingKey(c) }
            wcs.append(c == v!)
        }
        
        let w = foldAnd(wcs)
        
        let sql = """
          UPDATE \(nameSql)
          SET \(cvs.map({"\($0.0.nameSql) = \($0.0.paramSql)"}).joined(separator: ", "))
          WHERE \(w.conditionSql)
          """

        try await tx.exec(sql, cvs.map({$0.0.encode($0.1!)}) + w.conditionParams)
        for cv in cvs {tx[rec, cv.0] = cv.1}
    }

    public func upsert(_ rec: Record, _ tx: Tx) async throws {
        if rec.stored(_columns, tx) { try await update(rec, tx) }
        else { try await insert(rec, tx) }
    }

    public func sync(_ tx: Tx) async throws {
        if (try await exists(tx)) {
            for d in definitions { try await d.sync(tx) }
        } else {
            try await create(tx)
        }
    }
}
