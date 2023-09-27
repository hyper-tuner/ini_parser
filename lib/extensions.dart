extension Parsing on String {
  int parseInt() {
    return int.parse(this);
  }

  double parseDouble() {
    return double.parse(this);
  }

  bool? parseBool() {
    switch (sanitize()) {
      case 'true':
        return true;
      case 'false':
        return false;
      default:
        return null;
    }
  }

  String clearString() {
    return replaceAll('"', '').sanitize();
  }

  String sanitize() {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool isExpression() {
    return startsWith('{') && endsWith('}');
  }
}
