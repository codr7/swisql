import PostgresNIO

enum DatabaseError: Error {
    case noRows
}

public class Tx: ValueStore {
    let cx: Cx

    public init(_ cx: Cx) {
        self.cx = cx
    }

    public func exec(_ sql: String) async throws {
        print("\(sql)\n")
        try await cx.connection!.query(PostgresQuery(unsafeSQL: sql, binds: PostgresBindings()),
                                       logger: cx.log)
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
