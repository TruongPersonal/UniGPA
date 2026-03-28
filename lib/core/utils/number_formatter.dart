class NumberFormatter {

  static String format(double v, {int decimal = 1}) {
    if (v == v.truncateToDouble()) {
      return v.toInt().toString();
    }
    return v.toStringAsFixed(decimal);
  }

  static double? tryParseDouble(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    return double.tryParse(text.replaceAll(',', '.'));
  }
}
