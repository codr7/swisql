public class Enum<T: RawRepresentable>: BasicDefinition, Definition where T.RawValue == String {
    public init() {
        super.init(String(describing: T.self))
    }
    
    public var definitionType: String {
            "TYPE"
    }

    public func create(inTx tx: Tx) throws {
        try tx.exec(sql: createSql(self))
    }
    
    public func drop(inTx tx: Tx) throws {
        try tx.exec(sql: dropSql(self))
    }   
}

public func createSql<T>(_ e: Enum<T>) -> String {
    "\(createSql(e as Definition)) AS ENUM"
}
