import 'package:ini_parser/extensions.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:ini_parser/parsing_exception.dart';
import 'package:ini_parser/patterns.dart';
import 'package:ini_parser/section.dart';
import 'package:text_parser/text_parser.dart';

class CurveEditorParser {
  final List<Curve> _curves = [];
  Curve? _currentCurve;

  final _parser = TextParser(
    matchers: [
      const PatternMatcher(namePattern),
      const PatternMatcher(textPattern),
    ],
  );

  Future<List<Curve>> parse(List<String> lines) async {
    for (final line in lines) {
      try {
        await _parseLine(line);
      } catch (e) {
        throw ParsingException(section: Section.curveEditor, line: line);
      }
    }

    return _curves;
  }

  Future<void> _parseLine(String line) async {
    if (line.startsWith(RegExp(r'^curve\s*='))) {
      await _parseTable(line);
    } else {
      await _parseAttributes(line);
    }
  }

  Future<void> _parseTable(String line) async {
    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    _currentCurve = Curve(
      name: result[1],
      label: result[2],
    );
    _curves.add(_currentCurve!);
  }

  Future<void> _parseAttributes(String line) async {
    if (_currentCurve == null) {
      return;
    }

    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    final name = result.first;

    switch (name) {
      case 'columnLabel':
        _currentCurve!.columnLabels = result.sublist(1);
      case 'xAxis':
        _currentCurve!.xAxis = result.sublist(1);
      case 'yAxis':
        _currentCurve!.yAxis = result.sublist(1);
      case 'xBins':
        _currentCurve!.xBins = result.sublist(1);
      case 'yBins':
        _currentCurve!.yBins = result.sublist(1);
      case 'topicHelp':
        _currentCurve!.topicHelp = result[1];
      case 'showTextValues':
        _currentCurve!.showTextValues = result[1].parseBool() ?? false;
      case 'lineLabel':
        _currentCurve!.lineLabel = result[1];
      case 'size':
        _currentCurve!.size = result.sublist(1);
      case 'gauge':
        _currentCurve!.gauge = result[1];
      default:
    }
  }
}
