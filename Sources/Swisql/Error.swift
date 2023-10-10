public enum DatabaseError: Error {
    case noRows
    case missingKey(Column)
}
