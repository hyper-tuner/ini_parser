import 'package:ini_parser/extensions.dart';
import 'package:text_parser/text_parser.dart';

class ContextHelpParser {
  final Map<String, String> _help = {};

  final _parser = TextParser(
    matchers: [
      const PatternMatcher(r'^(?<key>\w+)\s*=\s*"(?<value>.+)"'),
    ],
  );

  Future<Map<String, String>> parse(List<String> lines) async {
    for (final line in lines) {
      await _parseLine(line);
    }

    return _help;
  }

  Future<void> _parseLine(String line) async {
    final result = await _parser.parse(line, onlyMatches: true);
    final groups = result.isEmpty ? <String>[] : result.first.groups;

    if (groups.length < 2) {
      return;
    }

    _help[groups.first.toString().clearString()] =
        groups.last.toString().clearString();
  }
}
