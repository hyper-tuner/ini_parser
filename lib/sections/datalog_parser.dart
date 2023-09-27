import 'package:ini_parser/extensions.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:ini_parser/parsing_exception.dart';
import 'package:ini_parser/patterns.dart';
import 'package:ini_parser/section.dart';
import 'package:text_parser/text_parser.dart';

class DatalogParser {
  final List<Datalog> _logs = [];

  final _parser = TextParser(
    matchers: [
      const PatternMatcher(namePattern),
      const PatternMatcher(textPattern),
    ],
  );

  Future<List<Datalog>> parse(List<String> lines) async {
    for (final line in lines) {
      try {
        await _parseLine(line);
      } catch (e) {
        throw ParsingException(section: Section.datalog, line: line);
      }
    }

    return _logs;
  }

  Future<void> _parseLine(String line) async {
    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    if (result.isEmpty || result[0] != 'entry') {
      return;
    }

    _logs.add(
      Datalog(
        channel: result[1],
        label: result[2],
        // type: result[3], // no longer used
        format: result[4],
        enabled: result.length > 5 ? result[5] : null,
      ),
    );
  }
}
