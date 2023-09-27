import 'package:ini_parser/extensions.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:ini_parser/parsing_exception.dart';
import 'package:ini_parser/patterns.dart';
import 'package:ini_parser/section.dart';
import 'package:ini_parser/utils.dart';
import 'package:text_parser/text_parser.dart';

class OutputChannelsParser {
  final _outputChannels = OutputChannels();
  final _parser = TextParser(
    matchers: [
      const PatternMatcher(bitsPattern),
      const PatternMatcher(textPatternNoSpace),
      const PatternMatcher(expPattern),
    ],
  );

  Future<OutputChannels> parse(List<String> lines) async {
    for (final line in lines) {
      try {
        await _parseLine(line);
      } catch (e) {
        throw ParsingException(section: Section.outputChannels, line: line);
      }
    }

    return _outputChannels;
  }

  Future<void> _parseLine(String line) async {
    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    // coolant = { (coolantRaw - 40) * 1.8 + 32 }
    if (Utils.isExpression(result[1])) {
      _outputChannels.channels.add(
        OutputChannelDynamic(
          name: result[0],
          expression: result[1],
        ),
      );

      return;
    }

    // ochBlockSize = 122
    if (result.length == 2) {
      _parseConfig(result);

      return;
    }

    _parseChannel(result);
  }

  void _parseChannel(List<String> result) {
    final name = result[0];
    final type = Utils.toConstantType(result[1]);
    final size = Utils.toConstantSize(result[2]);
    final offset = result[3].parseInt();
    OutputChannel channel;

    switch (type) {
      case ConstantType.scalar:
        channel = OutputChannelScalar(
          name: name,
          size: size,
          offset: offset,
          units: result.length > 4 ? result[4] : null,
          scale: result.length > 5 ? result[5] : null,
          transform: result.length > 6 ? result[6] : null,
        );
      case ConstantType.bits:
        final bitsRaw = result[4]
            .replaceAll(RegExp(r'[^\d:]'), '')
            .clearString()
            .split(':');

        channel = OutputChannelBits(
          name: name,
          size: size,
          offset: offset,
          bits: BitsShape(
            low: bitsRaw[0].parseInt(),
            high: bitsRaw[1].parseInt(),
          ),
        );
      // ignore: no_default_cases
      default:
        throw ParsingException(
          section: Section.constants,
          line: 'Unsupported constant type: $type',
        );
    }

    _outputChannels.channels.add(channel);
  }

  void _parseConfig(List<String> result) {
    final name = result.first;
    final value = result[1];

    switch (name) {
      case 'ochGetCommand':
        _outputChannels.config.ochGetCommand = value;
      case 'ochBlockSize':
        _outputChannels.config.ochBlockSize = value.parseInt();
      default:
    }
  }
}
