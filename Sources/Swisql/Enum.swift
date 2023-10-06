public class Enum<T: RawRepresentable>: BasicDefinition, Definition where T.RawValue == String {
    public init() {
        super.init(String(describing: T.self))
    }
    
    public var definitionType: String {
            "TYPE"
    }

    public func create(inTx tx: Tx) async throws {
        try await tx.exec(createSql(self))
    }
    
    public func drop(inTx tx: Tx) async throws {
        try await tx.exec(dropSql(self))
    }   
}

public func createSql<T>(_ e: Enum<T>) -> String {
    "\(createSql(e as Definition)) AS ENUM"
}
