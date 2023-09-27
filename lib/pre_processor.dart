import 'package:ini_parser/extensions.dart';

class PreProcessor {
  PreProcessor({
    required this.raw,
    required this.settings,
  });
  late final String raw;
  late final List<String> settings;
  final List<String> lines = [];
  final Map<String, String> defines = {};

  /// Pre-process INI:
  /// - remove comments
  /// - remove empty lines
  /// - handle #if, #else, #endif, #set, #unset
  /// - handle #define
  void process() {
    lines.clear();
    var ifClauseOpen = false;
    var elseClauseOpen = false;
    var ifConditionTrue = false;

    for (var line in raw.split('\n')) {
      line = line.trim();

      // ignore comments and empty lines
      if (line.startsWith(';') || line.isEmpty) {
        continue;
      }

      // remove inline comments
      if (line.contains(';')) {
        line = line.substring(0, line.indexOf(';'));
      }

      if (line.startsWith('#if')) {
        ifClauseOpen = true;
        ifConditionTrue = settings.contains(line.substring(3).trim());

        continue;
      }

      if (line.startsWith('#else')) {
        elseClauseOpen = true;
        ifClauseOpen = false;

        continue;
      }

      if (line.startsWith('#endif')) {
        ifClauseOpen = false;
        elseClauseOpen = false;

        continue;
      }

      if (ifClauseOpen == true) {
        if (ifConditionTrue == true) {
          lines.add(line);
        }

        continue;
      }

      if (elseClauseOpen == true) {
        if (ifConditionTrue == false) {
          lines.add(line);
        }

        continue;
      }

      // add new Settings entry
      if (line.startsWith('#set')) {
        settings.add(line.substring(4).trim());

        continue;
      }

      // unset/remove Settings entry
      if (line.startsWith('#unset')) {
        settings.remove(line.substring(6).trim());

        continue;
      }

      if (line.startsWith('#define')) {
        final parts = line.substring(7).trim().split('=');
        final key = parts[0].sanitize();
        final value = parts[1].sanitize();

        defines.addAll({key: value});

        continue;
      }

      lines.add(line);
    }
  }
}
