public protocol Definition {
    var createSql: String {get}
    var definitionType: String {get}
    var dropSql: String {get}
    var name: String {get}
    var schema: Schema {get}
    var nameSql: String {get}
    
    func create(inTx: Tx) async throws
    func drop(inTx: Tx) async throws
    func sync(inTx: Tx) async throws
    func exists(inTx: Tx) async throws -> Bool
}

public extension Definition {
    func create(inTx tx: Tx) async throws {
        try await tx.exec(self.createSql)
    }

    func drop(inTx tx: Tx) async throws {
        try await tx.exec(self.dropSql)
    }

    func sync(inTx tx: Tx) async throws {
        if !(try await exists(inTx: tx)) {
            try await create(inTx: tx)
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
