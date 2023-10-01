public class Tx: ValueStore {
    let cx: Cx

    public init(_ cx: Cx) {
        self.cx = cx
    }

    public func exec(sql: String, _ params: Any...) throws {
        print("\(sql)\n")
    }

    public func commit() throws {
        for (f, v) in self.storedValues {
            cx[f.record, f.column] = v
        }
    }
    
    public func rollback() throws {
    }
}
