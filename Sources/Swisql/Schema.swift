public class Schema {
    var definitions: [Definition] = []

    public init() {
    }
    
    public func create(_ tx: Tx) async throws {
        for d in definitions {
            try await d.create(tx)
        }
    }
    
    public func drop(_ tx: Tx) async throws {
        for d in definitions {
            try await d.drop(tx)
        }
    }
    
    public func sync(_ tx: Tx) async throws {
        for d in definitions {
            try await d.sync(tx)
        }
    }
}
