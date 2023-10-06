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
        try await tx.queryValue("""
                                  SELECT EXISTS (
                                    SELECT FROM pg_type
                                    WHERE typname  = \(sqlName)
                                  )
                                  """)
    }    
}
