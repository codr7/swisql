import PostgresNIO

public protocol Enum: CaseIterable, Equatable, RawRepresentable where RawValue == String {
}

public class EnumType<T: Enum>: BasicDefinition, Definition {
    public init(_ schema: Schema) {
        super.init(schema, String(describing: T.self))
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
    
    public func create(_ tx: Tx) async throws {
        try await tx.exec(self.createSql)

        for m in T.allCases {
            try await EnumMember(self, m.rawValue).create(tx)
        }
    }

    public func exists(_ tx: Tx) async throws -> Bool {
        try await tx.queryValue("""
                                  SELECT EXISTS (
                                    SELECT FROM pg_type
                                    WHERE typname  = \(name)
                                  )
                                  """)
    }    

    public func sync(_ tx: Tx) async throws {        
        if (try await exists(tx)) {
            for m in T.allCases {
                try await EnumMember<T>(self, m.rawValue).sync(tx)
            }
        } else {
            try await create(tx)
        }
    }
}

public class EnumMember<T: Enum>: BasicDefinition, Definition {
    let type: EnumType<T>
    
    public init(_ type: EnumType<T>, _ name: String) {
        self.type = type
        super.init(type.schema, name)
    }

    public var definitionType: String {
        "VALUE"
    }
          
    public var createSql: String {
        "ALTER TYPE \(type.nameSql) ADD VALUE '\(name)'"
    }
    
    public var dropSql: String {
        "ALTER TYPE \(type.nameSql) DROP VALUE '\(name)'"
    }

    public func exists(_ tx: Tx) async throws -> Bool {
        try await tx.queryValue("""
                                  SELECT EXISTS (
                                    SELECT
                                    FROM pg_type t 
                                    JOIN pg_enum e on e.enumtypid = t.oid  
                                    JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
                                    WHERE t.typname = \(type.name) AND e.enumlabel = \(name)
                                  )
                                  """)
    }
}

