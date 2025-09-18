
String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

bool isValidEmail(String email) {
  final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  return emailRegex.hasMatch(email);
}