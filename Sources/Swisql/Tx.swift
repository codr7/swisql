import PostgresNIO

enum DatabaseError: Error {
    case noRows
}

public class Tx: ValueStore {
    let cx: Cx

    public init(_ cx: Cx) {
        self.cx = cx
    }

    public func exec(_ sql: String, _ params: [PostgresDynamicTypeEncodable] = []) async throws {
        let psql = convertParams(sql)
        print("\(psql)\n")
        var bs = PostgresBindings()
        for p in params { bs.append(p) }
        try await cx.connection!.query(PostgresQuery(unsafeSQL: psql, binds: bs), logger: cx.log)
    }

    public func query(_ query: PostgresQuery) async throws -> PostgresRowSequence {
        print("\(query.sql)\n")
        return try await cx.connection!.query(query, logger: cx.log)
    }

    public func queryValue<T: PostgresDecodable>(_ query: PostgresQuery) async throws -> T {
        print("\(query.sql)\n")
        let rows = try await cx.connection!.query(query, logger: cx.log)

        for try await (value) in rows.decode((T).self) {
            return value
        }

        throw DatabaseError.noRows
    }
    
    public func commit() async throws {
        try await exec("COMMIT")
        
        for (f, v) in self.storedValues {
            cx[f.record, f.column] = v
        }
    }
    
    public func rollback() async throws {
        try await exec("ROLLBACK") 
    }
}

public func convertParams(_ sql: String) -> String {
    let ss = sql.components(separatedBy: "?")
    var result = ss[0]
    var n = 1
    
    for s in ss[1...] {
        result = result + "$\(n)" + s
        n += 1
    }

    return result
}
