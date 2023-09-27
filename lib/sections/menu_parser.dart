import 'package:ini_parser/extensions.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:ini_parser/parsing_exception.dart';
import 'package:ini_parser/patterns.dart';
import 'package:ini_parser/section.dart';
import 'package:text_parser/text_parser.dart';

class MenuParser {
  final List<Menu> _menus = [];
  Menu? _currentMenu;
  GroupMenu? _currentGroupMenu;

  final _parser = TextParser(
    matchers: [
      const PatternMatcher(namePattern),
      const PatternMatcher(textPattern),
    ],
  );

  Future<List<Menu>> parse(List<String> lines) async {
    for (final line in lines) {
      try {
        await _parseLine(line);
      } catch (e) {
        throw ParsingException(section: Section.menu, line: line);
      }
    }

    return _menus;
  }

  Future<void> _parseLine(String line) async {
    if (await _parseMenu(line)) {
      return;
    }

    if (_currentMenu == null) {
      return;
    }

    if (await _parseGroupMenu(line)) {
      return;
    }

    await _parseSubMenu(line);
  }

  Future<bool> _parseMenu(String line) async {
    final parser = TextParser(
      matchers: [
        const PatternMatcher(r'^menu\s*=\s*"(?<label>.+)"'),
      ],
    );
    final result = await parser.parse(line, onlyMatches: true);
    final groups = result.isEmpty ? <String>[] : result.first.groups;

    if (groups.isNotEmpty) {
      final label = groups.first.toString().clearString();

      _currentMenu = Menu(label: label);
      _menus.add(_currentMenu!);

      return true;
    }

    return false;
  }

  Future<bool> _parseGroupMenu(String line) async {
    final parser = TextParser(
      matchers: [
        const PatternMatcher(r'^groupMenu\s*=\s*"(?<label>.+)"'),
      ],
    );
    final result = await parser.parse(line, onlyMatches: true);
    final groups = result.isEmpty ? <String>[] : result.first.groups;

    if (groups.isNotEmpty && _currentMenu != null) {
      final label = groups.first.toString().clearString();

      _currentGroupMenu = GroupMenu(label: label);
      _currentMenu!.children.add(_currentGroupMenu!);

      return true;
    }

    return false;
  }

  bool _addSubMenu(List<String> result) {
    final dialog = result[1];

    if (result.length == 2 && dialog == 'std_separator') {
      _currentMenu!.children.add(
        SubMenu(
          dialog: dialog,
          label: dialog,
          enabled: null,
          visible: null,
        ),
      );

      return true;
    }

    _currentMenu!.children.add(
      SubMenu(
        dialog: dialog,
        label: result[2],
        enabled: result.length > 3 ? result[3] : null,
        visible: result.length > 4 ? result[4] : null,
      ),
    );

    return true;
  }

  bool _addGroupChildMenu(List<String> result) {
    final dialog = result[1];

    if (result.length == 2 && dialog == 'std_separator') {
      _currentGroupMenu?.children.add(
        GroupChildMenu(
          dialog: dialog,
          label: dialog,
          enabled: null,
          visible: null,
        ),
      );

      return true;
    }

    _currentGroupMenu?.children.add(
      GroupChildMenu(
        dialog: dialog,
        label: result[2],
        enabled: result.length > 3 ? result[3] : null,
        visible: result.length > 4 ? result[4] : null,
      ),
    );

    return true;
  }

  Future<bool> _parseSubMenu(String line) async {
    var isSubMenu = false;

    if (line.startsWith(RegExp(r'^subMenu\s*='))) {
      // clear current groupMenu since we encountered a new subMenu
      _currentGroupMenu = null;
      isSubMenu = true;
    } else if (line.startsWith(RegExp(r'^groupChildMenu\s*='))) {
      isSubMenu = false;
    } else {
      return false;
    }

    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    if (isSubMenu) {
      return _addSubMenu(result);
    } else {
      return _addGroupChildMenu(result);
    }
  }
}
