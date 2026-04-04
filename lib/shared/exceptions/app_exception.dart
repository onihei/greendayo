enum ErrorKind {
  notFound,
  unauthorized,
  network,
  server,
  unknown,
}

class AppException implements Exception {
  final ErrorKind kind;
  final String message;
  final Object? cause;

  AppException(this.kind, this.message, [this.cause]);

  @override
  String toString() => 'AppException($kind): $message';
}
