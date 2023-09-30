public class Column {
    let name: String

    public init(name: String) {
        self.name = name
    }
}

public class TypedColumn<T>: Column {
}
