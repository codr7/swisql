public class Enum<T>: BasicDefinition, Definition where T: CaseIterable, T: RawRepresentable, T.RawValue == String {
    public init() {
        super.init(String(describing: T.self))
    }
    
    public var createSql: String {
        "\(Swisql.createSql(self as Definition)) AS ENUM ()"
    }

    public var definitionType: String {
            "TYPE"
    }

    public var dropSql: String {
        Swisql.dropSql(self)
    }

    public func create(inTx tx: Tx) async throws {
        try await tx.exec(self.createSql)

        for m in T.allCases {
            try await EnumMember(self, m.rawValue).create(inTx: tx)
        }
    }

    public func exists(inTx tx: Tx) async throws -> Bool {
        try await tx.queryValue("""
                                  SELECT EXISTS (
                                    SELECT FROM pg_type
                                    WHERE typname  = \(sqlName)
                                  )
                                  """)
    }    

    public func sync(inTx tx: Tx) async throws {
        if (try await exists(inTx: tx)) {
            for m in T.allCases {
                try await EnumMember(self, m.rawValue).sync(inTx: tx)
            }
        } else {
            try await create(inTx: tx)
        }
    }
}

public class EnumMember<T>: BasicDefinition, Definition where T: CaseIterable, T: RawRepresentable, T.RawValue == String {
    let type: Enum<T>
    
    public init(_ type: Enum<T>, _ name: String) {
        self.type = type
        super.init(name)
    }

    public var definitionType: String {
        "VALUE"
    }
          
    public var createSql: String {
        "ALTER TYPE \(type.sqlName) ADD VALUE '\(name)'"
    }
    
    public var dropSql: String {
        "ALTER TYPE \(type.sqlName) DROP VALUE '\(name)'"
    }

    public func exists(inTx tx: Tx) async throws -> Bool {
        try await tx.queryValue("""
                                  SELECT EXISTS (
                                    SELECT
                                    FROM pg_type t 
                                    JOIN pg_enum e on e.enumtypid = t.oid  
                                    JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
                                    WHERE t.typname = \(type.sqlName) AND e.enumlabel = \(sqlName)
                                  )
                                  """)
    }
}

