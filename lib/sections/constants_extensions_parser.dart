import 'package:ini_parser/extensions.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:ini_parser/parsing_exception.dart';
import 'package:ini_parser/patterns.dart';
import 'package:ini_parser/section.dart';
import 'package:text_parser/text_parser.dart';

class ConstantsExtensionsParser {
  final _extensions = ConstantsExtensions();
  final _parser = TextParser(
    matchers: [
      const PatternMatcher(namePattern),
      const PatternMatcher(textPattern),
    ],
  );

  Future<ConstantsExtensions> parse(List<String> lines) async {
    for (final line in lines) {
      try {
        await _parseLine(line);
      } catch (e) {
        throw ParsingException(
          section: Section.constantsExtensions,
          line: line,
        );
      }
    }

    return _extensions;
  }

  Future<void> _parseLine(String line) async {
    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    final type = result[0];
    final name = result[1];
    final value = result.length > 2 ? result[2] : '';

    switch (type) {
      case 'defaultValue':
        _extensions.defaultValue.addAll({name: value});
      case 'maintainConstantValue':
        _extensions.maintainConstantValue.addAll({name: value});
      case 'controllerPriority':
        _extensions.controllerPriority.add(name);
      case 'requiresPowerCycle':
        _extensions.requiresPowerCycle.add(name);
      default:
    }
  }
}
