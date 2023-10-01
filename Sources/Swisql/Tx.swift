public class Tx: ValueStore {
    let cx: Cx

    public init(_ cx: Cx) {
        self.cx = cx
    }

    public func exec(sql: String, _ params: Any...) throws {
        print("\(sql)\n")
    }
    
    public func rollback() throws {
    }
}
