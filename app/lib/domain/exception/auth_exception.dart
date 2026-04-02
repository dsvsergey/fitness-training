class AuthException implements Exception {
  final String massage;

  AuthException({
    required this.massage,
  });
}
