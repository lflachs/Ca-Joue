/// Base exception for all CaJoue application errors.
class CaJoueException implements Exception {
  /// Creates a [CaJoueException] with the given [message].
  const CaJoueException(this.message);

  /// A human-readable description of the error.
  final String message;

  @override
  String toString() => 'CaJoueException: $message';
}

/// Exception thrown when a database operation fails.
class DatabaseException extends CaJoueException {
  /// Creates a [DatabaseException] with the given [message].
  const DatabaseException(super.message);

  @override
  String toString() => 'DatabaseException: $message';
}

/// Exception thrown when validation fails.
class ValidationException extends CaJoueException {
  /// Creates a [ValidationException] with the given [message].
  const ValidationException(super.message);

  @override
  String toString() => 'ValidationException: $message';
}
