import PostgresNIO

public class Cx: ValueStore {
    let host: String
    let port: Int
    let database: String
    let user: String
    let password: String
    
    let log: Logger
    var connection: PostgresConnection?
    
    public init(host: String = "localhost", port: Int = 5432,
                database: String,
                user: String, password: String) {
        self.host = host
        self.port = port
        self.database = database
        self.user = user
        self.password = password
        log = Logger(label: "postgres")
    }

    public func connect() async throws {
        let config = PostgresConnection.Configuration(
          host: host,
          port: port,
          username: user,
          password: password,
          database: database,
          tls: .disable
        )

        connection = try await PostgresConnection.connect(
          configuration: config,
          id: 1,
          logger: log
        )
    }
    
    public func disconnect() async throws {
        try await connection!.close()
        connection = nil
    }
    
    public func startTx() async throws -> Tx {
        let tx = Tx(self)
        try await tx.exec("BEGIN") 
        return tx
    }
}
