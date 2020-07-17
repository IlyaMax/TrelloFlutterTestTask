class UserFailure {
  final String message;

  UserFailure(this.message);

  @override
  String toString() => message;
}

class TokenExpiredFailure extends UserFailure {
  TokenExpiredFailure() : super("Token expired. User has to enter credentials one more time.");
}

class ConnectionFailure extends UserFailure {
  ConnectionFailure() : super("No internet connection");
}
