public class Enum<T: RawRepresentable>: BasicDefinition, Definition where T.RawValue == String {
    public init() {
        super.init(String(describing: T.self))
    }
    
    public var definitionType: String {
            "TYPE"
    }

    public func create(inTx tx: Tx) async throws {
        try await tx.exec("\(createSql(self as Definition)) AS ENUM ()")
    }
    
    public func drop(inTx tx: Tx) async throws {
        try await tx.exec(dropSql(self))
    }

    public func exists(inTx tx: Tx) async throws -> Bool {
        let rows = try await tx.query("""
                                        SELECT EXISTS (
                                          SELECT FROM pg_type
                                          WHERE typname  = \(sqlName)
                                        )
                                        """)

        for try await (exists) in rows.decode((Bool).self) {
            return exists
        }

        return false
    }    
}
