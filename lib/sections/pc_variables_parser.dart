import 'package:ini_parser/extensions.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:ini_parser/parsing_exception.dart';
import 'package:ini_parser/patterns.dart';
import 'package:ini_parser/section.dart';
import 'package:text_parser/text_parser.dart';

class PcVariablesParser {
  final List<PcVariable> _pcVariables = [];

  final _parser = TextParser(
    matchers: [
      const PatternMatcher(namePattern),
      const PatternMatcher(bitsListPattern),
      const PatternMatcher(textPattern),
    ],
  );

  Future<List<PcVariable>> parse(List<String> lines) async {
    for (final line in lines) {
      try {
        await _parseLine(line);
      } catch (e) {
        throw ParsingException(section: Section.pcVariables, line: line);
      }
    }

    return _pcVariables;
  }

  Future<void> _parseLine(String line) async {
    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    // special cases - skip for now
    if (result[1] == 'channelValueOnConnect' ||
        result[1] == 'continuousChannelValue') {
      return;
    }

    _parsePcVariable(result);
  }

  void _parsePcVariable(List<String> result) {
    final name = result.first;
    final type = result[1].toConstantType();
    final size = result[2].toConstantSize();
    PcVariable pcVariable;

    switch (type) {
      case ConstantType.scalar:
        pcVariable = PcVariableScalar(
          name: name,
          size: size,
          units: result[3],
          scale: result[4],
          transform: result[5],
          min: result.length > 6 ? result[6] : null,
          max: result.length > 7 ? result[7] : null,
          digits: result.length > 8 ? result[8] : null,
        );
      case ConstantType.bits:
        final optionsRaw = result.sublist(4);

        // convert to Map<int, String>
        var options = <int, String>{};
        if (optionsRaw.isNotEmpty && optionsRaw.first.contains('=')) {
          optionsRaw
              .map((e) => e.split('='))
              .forEach((e) => options.addAll({e.first.parseInt(): e.last}));
        } else {
          options = optionsRaw.asMap();
        }

        final bitsRaw = result[3]
            .replaceAll(RegExp(r'[^\d:]'), '')
            .clearString()
            .split(':');

        pcVariable = PcVariableBits(
          name: name,
          size: size,
          bits: BitsShape(
            low: bitsRaw[0].parseInt(),
            high: bitsRaw[1].parseInt(),
          ),
          options: options,
        );
      case ConstantType.array:
        final shapeRaw = result[3]
            .replaceAll(RegExp(r'[^\dx]'), '')
            .clearString()
            .split('x');

        pcVariable = PcVariableArray(
          name: name,
          size: size,
          shape: ArrayShape(
            columns: shapeRaw[0].parseInt(),
            rows: shapeRaw.length > 1 ? shapeRaw[1].parseInt() : null,
          ),
          units: result[4],
          scale: result[5],
          transform: result[6],
          min: result[7],
          max: result[8],
          digits: result[9],
          noSave: result.length > 10 && result[10] == 'noMsqSave',
        );
      case ConstantType.string:
        pcVariable = PcVariableString(
          name: name,
          size: size,
          length: result[3].parseInt(),
        );
    }

    _pcVariables.add(pcVariable);
  }
}
