public class Schema {
    var definitions: [Definition] = []

    public init() {
    }
    
    public func create(inTx tx: Tx) async throws {
        for d in definitions {
            try await d.create(inTx: tx)
        }
    }
    
    public func drop(inTx tx: Tx) async throws {
        for d in definitions {
            try await d.drop(inTx: tx)
        }
    }
    
    public func sync(inTx tx: Tx) async throws {
        for d in definitions {
            try await d.sync(inTx: tx)
        }
    }
}
