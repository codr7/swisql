public protocol Definition {
    var createSql: String {get}
    var definitionType: String {get}
    var dropSql: String {get}
    var name: String {get}
    var schema: Schema {get}
    var nameSql: String {get}
    
    func create(_ tx: Tx) async throws
    func drop(_ tx: Tx) async throws
    func sync(_ tx: Tx) async throws
    func exists(_ tx: Tx) async throws -> Bool
}

public extension Definition {
    func create(_ tx: Tx) async throws {
        try await tx.exec(self.createSql)
    }

    func drop(_ tx: Tx) async throws {
        try await tx.exec(self.dropSql)
    }

    func sync(_ tx: Tx) async throws {
        if !(try await exists(tx)) {
            try await create(tx)
        }
    }
}

public class BasicDefinition {
    public let name: String
    public let schema: Schema
    
    public init(_ schema: Schema, _ name: String) {
        self.schema = schema
        self.name = name
    }

    public var nameSql: String {
        "\"\(name)\""
    }
}

public func createSql(_ d: Definition) -> String {
    "CREATE \(d.definitionType) \(d.nameSql)"
}

public func dropSql(_ d: Definition) -> String {
    "DROP \(d.definitionType) \(d.nameSql)"
}
