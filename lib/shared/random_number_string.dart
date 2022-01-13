import 'dart:math';

/// Generate n-length random numerical string.
String generateRandomNumericalString(int length) {
  const numbers = "0123456789";
  final random = Random();

  return List.generate(length, (_) => numbers[random.nextInt(numbers.length)])
    .join();
}