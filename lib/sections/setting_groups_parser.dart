import 'package:ini_parser/extensions.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:ini_parser/parsing_exception.dart';
import 'package:ini_parser/patterns.dart';
import 'package:ini_parser/section.dart';
import 'package:text_parser/text_parser.dart';

class SettingGroupsParser {
  final List<SettingGroup> _groups = [];
  SettingGroup? _currentGroup;

  final _parser = TextParser(
    matchers: [
      const PatternMatcher(namePattern),
      const PatternMatcher(textPattern),
    ],
  );

  Future<List<SettingGroup>> parse(List<String> lines) async {
    for (final line in lines) {
      try {
        await _parseLine(line);
      } catch (e) {
        throw ParsingException(section: Section.menu, line: line);
      }
    }

    return _groups;
  }

  Future<void> _parseLine(String line) async {
    if (line.startsWith(RegExp(r'^settingGroup\s*='))) {
      return _parseSettingGroup(line);
    }

    if (_currentGroup == null) {
      return;
    }

    if (line.startsWith(RegExp(r'^settingOption\s*='))) {
      await _parseSettingGroupOption(line);
    }
  }

  Future<void> _parseSettingGroup(String line) async {
    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    _currentGroup = SettingGroup(
      name: result[1],
      label: result[2],
    );
    _groups.add(_currentGroup!);
  }

  Future<void> _parseSettingGroupOption(String line) async {
    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    _currentGroup!.options.addAll({result[1]: result[2]});
  }
}
