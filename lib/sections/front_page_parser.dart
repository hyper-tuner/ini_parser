import 'package:ini_parser/extensions.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:ini_parser/parsing_exception.dart';
import 'package:ini_parser/patterns.dart';
import 'package:ini_parser/section.dart';
import 'package:text_parser/text_parser.dart';

class FrontPageParser {
  final FrontPage _frontPage = FrontPage();

  final _parser = TextParser(
    matchers: [
      const PatternMatcher(namePattern),
      const PatternMatcher(textPattern),
    ],
  );

  Future<FrontPage> parse(List<String> lines) async {
    for (final line in lines) {
      try {
        await _parseLine(line);
      } catch (e) {
        throw ParsingException(section: Section.frontPage, line: line);
      }
    }

    return _frontPage;
  }

  Future<void> _parseLine(String line) async {
    if (line.startsWith(RegExp(r'^gauge\d+\s*='))) {
      await _parseGauge(line);
    } else if (line.startsWith(RegExp(r'^indicator\s*='))) {
      await _parseIndicator(line);
    }
  }

  Future<void> _parseGauge(String line) async {
    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    _frontPage.gauges.add(result[1]);
  }

  Future<void> _parseIndicator(String line) async {
    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    _frontPage.indicators.add(
      UIIndicator(
        expression: result[1],
        labelOff: result[2],
        labelOn: result[3],
        colors: result.length > 7 ? _parseColors(result.sublist(4)) : null,
      ),
    );
  }

  UIIndicatorColors _parseColors(List<String> parts) {
    return UIIndicatorColors(
      offBackground: parts[0],
      offForeground: parts[1],
      onBackground: parts[2],
      onForeground: parts[3],
    );
  }
}
