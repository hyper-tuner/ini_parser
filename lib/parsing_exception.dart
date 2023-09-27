import 'package:ini_parser/section.dart';

class ParsingException implements Exception {
  ParsingException({
    required this.section,
    required this.line,
  });
  final Section section;
  final String line;

  // coverage:ignore-start
  @override
  String toString() =>
      'ParserException: Unable to parse [${section.name}] line: `$line`';
  // coverage:ignore-end
}
