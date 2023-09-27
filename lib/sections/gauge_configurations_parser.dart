import 'package:ini_parser/extensions.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:ini_parser/parsing_exception.dart';
import 'package:ini_parser/patterns.dart';
import 'package:ini_parser/section.dart';
import 'package:text_parser/text_parser.dart';

class GaugeConfigurationsParser {
  final List<GaugeConfig> _gaugeConfigs = [];
  late GaugeConfig? _currentConfig;

  Future<List<GaugeConfig>> parse(List<String> lines) async {
    for (final line in lines) {
      try {
        await _parseLine(line);
      } catch (e) {
        throw ParsingException(
          section: Section.gaugeConfigurations,
          line: line,
        );
      }
    }

    return _gaugeConfigs;
  }

  Future<void> _parseLine(String line) async {
    if (line.startsWith(RegExp(r'^gaugeCategory\s*='))) {
      await _parseCategory(line);
    } else {
      await _parseGauge(line);
    }
  }

  Future<void> _parseCategory(String line) async {
    final parser = TextParser(
      matchers: [
        const PatternMatcher(textPattern),
      ],
    );
    final result = (await parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    _currentConfig = GaugeConfig(
      category: result[1],
    );
    _gaugeConfigs.add(_currentConfig!);
  }

  Future<void> _parseGauge(String line) async {
    final parser = TextParser(
      matchers: [
        const PatternMatcher(namePattern),
        const PatternMatcher(textPattern),
      ],
    );
    final result = (await parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    _currentConfig!.gauges.add(
      Gauge(
        name: result[0],
        channel: result[1],
        label: result[2],
        units: result[3],
        low: result[4],
        high: result[5],
        lowDanger: result.length > 6 ? result[6] : '0',
        lowWarning: result.length > 7 ? result[7] : '0',
        highWarning: result.length > 8 ? result[8] : '0',
        highDanger: result.length > 9 ? result[9] : '0',
        digitsValue: result.length > 10 ? result[10] : '0',
        digitsLowHigh: result.length > 11 ? result[11] : '0',
        enabled: result.length > 12 ? result[12] : null,
      ),
    );
  }
}
