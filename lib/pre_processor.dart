import 'package:ini_parser/extensions.dart';
import 'package:ini_parser/parsing_exception.dart';
import 'package:ini_parser/section.dart';
import 'package:text_parser/text_parser.dart';

typedef PreProcessorDefines = Map<String, List<String>>;

class PreProcessor {
  PreProcessor({
    required this.raw,
    required this.settings,
  });

  late final String raw;
  late final List<String> settings;
  final List<String> lines = [];
  final PreProcessorDefines defines = {};

  final _parser = TextParser(
    matchers: [
      const PatternMatcher(r'^(?<key>\w+)\s*=\s*(?<value>.+)'),
    ],
  );

  /// Pre-process INI:
  /// - remove comments
  /// - remove empty lines
  /// - handle #if, #else, #endif, #set, #unset
  /// - handle #define
  Future<void> process() async {
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
        final trimmed = line.substring(7).trim();
        final result = await _parser.parse(trimmed, onlyMatches: true);
        final groups = (result.isEmpty ? <String>[] : result.first.groups)
            .whereType<String>()
            .toList();

        if (groups.length < 2) {
          return;
        }

        final key = groups.first.clearString();
        final elements = groups
            .sublist(1)
            .join()
            .split(',')
            .map((e) {
              final stripped = e.clearString();
              if (stripped.startsWith(r'$')) {
                final define = defines[stripped.substring(1)];
                if (define == null) {
                  throw ParsingException(
                    section: Section.defines,
                    line: line,
                  );
                }

                return define;
              }

              return [stripped];
            })
            .expand((element) => element)
            .toList();

        defines.addAll({
          key: elements,
        });

        continue;
      }

      lines.add(line);
    }
  }
}
