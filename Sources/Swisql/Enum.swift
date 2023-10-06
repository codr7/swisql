public class Enum<T: RawRepresentable>: BasicDefinition, Definition where T.RawValue == String {
    public init() {
        super.init(String(describing: T.self))
    }
    
    public var definitionType: String {
            "TYPE"
    }

    public var createSql: String {
        "\(Swisql.createSql(self as Definition)) AS ENUM ()"
    }
    
    public var dropSql: String {
        Swisql.dropSql(self)
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
