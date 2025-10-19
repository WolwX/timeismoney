// lib/utils.dart

/// Formate un nombre avec des espaces comme séparateur de milliers
/// Exemple: 100000 -> "100 000", 3030 -> "3 030"
String formatNumberWithSpaces(double number, int decimals) {
  String formatted = number.toStringAsFixed(decimals);

  // Séparer la partie entière et la partie décimale
  List<String> parts = formatted.split('.');
  String integerPart = parts[0];
  String decimalPart = parts.length > 1 ? '.' + parts[1] : '';

  // Ajouter des espaces tous les 3 chiffres dans la partie entière
  String reversed = integerPart.split('').reversed.join('');
  List<String> chunks = [];
  for (int i = 0; i < reversed.length; i += 3) {
    int end = i + 3;
    if (end > reversed.length) end = reversed.length;
    chunks.add(reversed.substring(i, end));
  }
  String formattedInteger = chunks.join(' ').split('').reversed.join('');

  return formattedInteger + decimalPart;
}