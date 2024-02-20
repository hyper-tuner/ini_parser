import 'package:ini_parser/extensions.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:ini_parser/parsing_exception.dart';
import 'package:ini_parser/patterns.dart';
import 'package:ini_parser/section.dart';
import 'package:text_parser/text_parser.dart';

class TableEditorParser {
  final List<Table> _tables = [];
  Table? _currentTable;

  final _parser = TextParser(
    matchers: [
      const PatternMatcher(textPattern),
    ],
  );

  Future<List<Table>> parse(List<String> lines) async {
    for (final line in lines) {
      try {
        await _parseLine(line);
      } catch (e) {
        throw ParsingException(section: Section.tableEditor, line: line);
      }
    }

    return _tables;
  }

  Future<void> _parseLine(String line) async {
    if (line.startsWith(RegExp(r'^table\s*='))) {
      await _parseTable(line);
    } else {
      await _parseAttributes(line);
    }
  }

  Future<void> _parseTable(String line) async {
    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    _currentTable = Table(
      name: result[1],
      map: result[2],
      label: result[3],
      page: result.length > 4 ? result[4].parseInt() : 0,
    );
    _tables.add(_currentTable!);
  }

  Future<void> _parseAttributes(String line) async {
    if (_currentTable == null) {
      return;
    }

    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    final name = result.first;

    switch (name) {
      case 'topicHelp':
        _currentTable!.topicHelp = result[1];
      case 'xBins':
        final parts = result.sublist(1);
        _currentTable!.xBins = TableBins(
          constant: parts[0],
          channel: parts.length > 1 ? parts[1] : null,
        );
      case 'yBins':
        final parts = result.sublist(1);
        _currentTable!.yBins = TableBins(
          constant: parts[0],
          channel: parts.length > 1 ? parts[1] : null,
        );
      case 'zBins':
        final parts = result.sublist(1);
        _currentTable!.zBins = TableBins(
          constant: parts[0],
          channel: parts.length > 1 ? parts[1] : null,
        );
      case 'xyLabels':
        _currentTable!.xyLabels = result.sublist(1);
      case 'gridHeight':
        _currentTable!.gridHeight = result[1].parseDouble();
      case 'gridOrient':
        _currentTable!.gridOrient =
            result.sublist(1).map((e) => e.parseDouble()).toList();
      case 'upDownLabel':
        _currentTable!.upDownLabels = result.sublist(1);
      default:
    }
  }
}
