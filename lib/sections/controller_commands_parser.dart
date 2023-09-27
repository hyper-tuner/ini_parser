import 'package:ini_parser/extensions.dart';
import 'package:ini_parser/parsing_exception.dart';
import 'package:ini_parser/patterns.dart';
import 'package:ini_parser/section.dart';
import 'package:text_parser/text_parser.dart';

class ControllerCommandsParser {
  final Map<String, String> _commands = {};

  final _parser = TextParser(
    matchers: [
      const PatternMatcher(textPatternNoSpace),
    ],
  );

  Future<Map<String, String>> parse(List<String> lines) async {
    for (final line in lines) {
      try {
        await _parseLine(line);
      } catch (e) {
        throw ParsingException(section: Section.controllerCommands, line: line);
      }
    }

    return _commands;
  }

  Future<void> _parseLine(String line) async {
    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    _commands.addAll({result[0]: result[1]});
  }
}
