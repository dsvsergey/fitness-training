class ApplicationException implements Exception {
  final String massage;

  ApplicationException({
    required this.massage,
  });
}
