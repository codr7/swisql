import PostgresNIO

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
