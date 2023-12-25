import 'package:ini_parser/extensions.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:ini_parser/parsing_exception.dart';
import 'package:ini_parser/patterns.dart';
import 'package:ini_parser/section.dart';
import 'package:text_parser/text_parser.dart';

class UiDialogsParser {
  final UI _ui = UI();
  UIDialog? _currentDialog;
  UILiveGraph? _currentLiveGraph;
  UISettingSelector? _currentSettingSelector;
  UIIndicatorPanel? _currentIndicatorPanel;

  final _parser = TextParser(
    matchers: [
      const PatternMatcher(namePattern),
      const PatternMatcher(textPattern),
    ],
  );

  Future<UI> parse(List<String> lines) async {
    for (final line in lines) {
      try {
        await _parseLine(line);
      } catch (e) {
        throw ParsingException(section: Section.uiDialogs, line: line);
      }
    }

    return _ui;
  }

  Future<void> _parseLine(String line) async {
    if (line.startsWith(RegExp(r'^dialog\s*='))) {
      await _parseDialog(line);
    } else {
      await _parseAttributes(line);
    }
  }

  Future<void> _parseDialog(String line) async {
    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    UIDialogLayout? layout;
    if (result.length > 3) {
      layout = UIDialogLayout.values.firstWhere(
        (e) => e.name == result[3],
        orElse: () => UIDialogLayout.yAxis,
      );
    }

    _currentDialog = UIDialog(
      name: result[1],
      label: result.length > 2 ? result[2] : '',
      layout: layout,
    );
    _ui.dialogs.add(_currentDialog!);
  }

  Future<void> _parseAttributes(String line) async {
    if (_currentDialog == null) {
      return;
    }

    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    final name = result.first;

    switch (name) {
      case 'topicHelp':
        _parseTopicHelp(result);
      case 'field':
        _parseField(result);
      case 'panel':
        _parsePanel(result);
      case 'gauge':
        _parseGauge(result);
      case 'slider':
        _parseSlider(result);
      case 'liveGraph':
        _parseLiveGraph(result);
      case 'graphLine':
        _parseGraphLine(result);
      case 'commandButton':
        _parseCommandButton(result);
      case 'settingSelector':
        _parseSettingSelector(result);
      case 'settingOption':
        _parseSettingSelectorOption(result);
      case 'radio':
        _parseRadio(result);
      case 'indicatorPanel':
        _parseIndicatorPanel(result);
      case 'indicator':
        _parseIndicator(result);
      default:
    }
  }

  void _parseTopicHelp(List<String> result) {
    _currentDialog!.topicHelp = result[1];
  }

  void _parseField(List<String> result) {
    _currentDialog!.items.add(
      UIField(
        label: result[1],
        constant: result.length > 2 ? result[2] : null,
        enabled: result.length > 3 ? result[3] : null,
      ),
    );
  }

  void _parseGauge(List<String> result) {
    _currentDialog!.items.add(
      UIGauge(
        name: result[1],
        placement: result.length > 2 ? _parsePlacement(result[2]) : null,
      ),
    );
  }

  void _parseSlider(List<String> result) {
    _currentDialog!.items.add(
      UISlider(
        label: result[1],
        constant: result[2],
        orientation: _parseOrientation(result[3]),
        enabled: result.length > 4 ? result[4] : null,
      ),
    );
  }

  void _parsePanel(List<String> result) {
    //  could have layout and enabled or just one of them
    final placementTemp = result.length > 2 ? result[2] : null;
    final enabledTemp = result.length > 3 ? result[3] : null;
    String? placement;
    String? enabled;

    if (placementTemp?.isExpression() ?? true) {
      // if placement (2nd) is expression,
      // it's actually enabled and there is no placement
      // panel = name, { exp }
      enabled = placementTemp;
      placement = null;
    } else if (enabledTemp?.isExpression() ?? true) {
      // if enabled is expression, we have all params
      // panel = name, West, { exp }
      enabled = enabledTemp;
      placement = placementTemp;
    } else {
      // if none is expression, we have only placement
      // panel = name, West
      placement = placementTemp;
      enabled = null;
    }

    final placementEnum = placement == null ? null : _parsePlacement(placement);

    _currentDialog!.items.add(
      UIPanel(
        name: result[1],
        placement: placementEnum,
        enabled: enabled,
      ),
    );
  }

  void _parseLiveGraph(List<String> result) {
    _currentLiveGraph = UILiveGraph(
      name: result[1],
      label: result[2],
      placement: result.length > 3 ? _parsePlacement(result[3]) : null,
    );
    _currentDialog!.items.add(_currentLiveGraph!);
  }

  void _parseGraphLine(List<String> result) {
    if (_currentLiveGraph == null) {
      return;
    }

    _currentLiveGraph!.lines.add(
      UILiveGraphLine(
        channel: result[1],
        units: result.length > 2 ? result[2] : null,
        min: result.length > 3 ? result[3].parseDouble() : null,
        max: result.length > 4 ? result[4].parseDouble() : null,
        autoMin: result.length > 5 && result[5] == 'auto',
        autoMax: result.length > 6 && result[6] == 'auto',
      ),
    );
  }

  void _parseCommandButton(List<String> result) {
    _currentDialog!.items.add(
      UICommandButton(
        label: result[1],
        command: result[2],
        enabled: result.length > 3 ? result[3] : null,
      ),
    );
  }

  void _parseSettingSelector(List<String> result) {
    _currentSettingSelector = UISettingSelector(
      label: result[1],
      enabled: result.length > 2 ? result[2] : null,
    );
    _currentDialog!.items.add(_currentSettingSelector!);
  }

  void _parseSettingSelectorOption(List<String> result) {
    if (_currentSettingSelector == null) {
      return;
    }

    final optionsRaw = result.sublist(2);

    // join pairs of options with `=` sign
    final options = <String, double>{};
    for (var i = 0; i < optionsRaw.length; i += 2) {
      options[optionsRaw[i]] = optionsRaw[i + 1].parseDouble();
    }

    _currentSettingSelector!.options.add(
      UISettingSelectorOption(
        label: result[1],
        options: options,
      ),
    );
  }

  void _parseRadio(List<String> result) {
    _currentDialog!.items.add(
      UIRadio(
        orientation: _parseOrientation(result[1]),
        label: result[2],
        constant: result[3],
        enabled: result.length > 4 ? result[4] : null,
        visible: result.length > 5 ? result[5] : null,
      ),
    );
  }

  void _parseIndicatorPanel(List<String> result) {
    _currentIndicatorPanel = UIIndicatorPanel(
      name: result[1],
      columns: result[2].parseInt(),
      enabled: result.length > 3 ? result[3] : null,
    );
    _ui.indicatorPanels.add(_currentIndicatorPanel!);
  }

  void _parseIndicator(List<String> result) {
    if (_currentIndicatorPanel == null) {
      return;
    }

    _currentIndicatorPanel!.indicators.add(
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

  UIPlacement _parsePlacement(String value) {
    return UIPlacement.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UIPlacement.north,
    );
  }

  UIOrientation _parseOrientation(String value) {
    return UIOrientation.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UIOrientation.horizontal,
    );
  }
}
