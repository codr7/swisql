public protocol Source {
    var sourceSql: String {get}
    var sourceParams: [any Encodable] {get}
}

extension Source {
    public var sourceParams: [any Encodable] {
        []
    }
}

extension [any Source] {
    var sql: String {
        self.map({$0.sourceSql}).joined(separator: ", ")
    }
}
