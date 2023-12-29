import 'package:ini_parser/extensions.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:ini_parser/parsing_exception.dart';
import 'package:ini_parser/patterns.dart';
import 'package:ini_parser/pre_processor.dart';
import 'package:ini_parser/section.dart';
import 'package:text_parser/text_parser.dart';

class ConstantsParser {
  ConstantsParser({required this.defines});

  late final PreProcessorDefines defines;
  final _constants = Constants();

  int _currentPage = 0;

  final _parser = TextParser(
    matchers: [
      const PatternMatcher(namePattern),
      const PatternMatcher(bitsListPattern),
      const PatternMatcher(textPattern),
    ],
  );

  Future<Constants> parse(List<String> lines) async {
    for (final line in lines) {
      try {
        await _parseLine(line);
      } catch (e) {
        throw ParsingException(section: Section.constants, line: line);
      }
    }

    return _constants;
  }

  Future<void> _parseLine(String line) async {
    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    if (result.length == 2) {
      final pageParser = TextParser(
        matchers: [
          const PatternMatcher(r'^page\s*=\s*(?<number>\d+)'),
        ],
      );
      final pageResult = await pageParser.parse(line, onlyMatches: true);

      final groups = pageResult.isEmpty ? <String>[] : pageResult.first.groups;

      if (groups.isNotEmpty) {
        _currentPage = groups.first.toString().parseInt();
        _constants.pages.add(ConstantsPage(number: _currentPage));

        return;
      }
    }

    if (_currentPage > 0) {
      _parseConstant(result);
    }

    if (_currentPage == 0) {
      _parseConfig(result);

      return;
    }
  }

  void _parseConstant(List<String> result) {
    final name = result.first;
    final type = result[1].toConstantType();
    final size = result[2].toConstantSize();
    final offset = result[3].parseInt();
    Constant constant;

    switch (type) {
      case ConstantType.scalar:
        constant = ConstantScalar(
          name: name,
          size: size,
          offset: offset,
          units: result[4],
          scale: result[5],
          transform: result[6],
          min: result.length > 7 ? result[7] : null,
          max: result.length > 8 ? result[8] : null,
          digits: result.length > 9 ? result[9] : null,
        );
      case ConstantType.bits:
        final optionsRaw = result.sublist(5);

        // convert to Map<int, String>
        var options = <int, String>{};
        if (optionsRaw.isNotEmpty && optionsRaw.first.contains('=')) {
          optionsRaw
              .map((e) => e.split('='))
              .forEach((e) => options.addAll({e.first.parseInt(): e.last}));
        } else {
          options = optionsRaw.asMap();
        }

        // resolve defines (ex. $loadSourceNames)
        if (options[0] != null && options[0]!.startsWith(r'$')) {
          final foundDefines = defines[options[0]!.substring(1)];
          if (foundDefines != null) {
            options = foundDefines.asMap();
          }
        }

        final bitsRaw = result[4]
            .replaceAll(RegExp(r'[^\d:]'), '')
            .clearString()
            .split(':');

        constant = ConstantBits(
          name: name,
          size: size,
          offset: offset,
          bits: BitsShape(
            low: bitsRaw[0].parseInt(),
            high: bitsRaw[1].parseInt(),
          ),
          options: options,
        );
      case ConstantType.array:
        final shapeRaw = result[4]
            .replaceAll(RegExp(r'[^\dx]'), '')
            .clearString()
            .split('x');

        constant = ConstantArray(
          name: name,
          size: size,
          offset: offset,
          shape: ArrayShape(
            columns: shapeRaw[0].parseInt(),
            rows: shapeRaw.length > 1 ? shapeRaw[1].parseInt() : null,
          ),
          units: result[5],
          scale: result[6],
          transform: result[7],
          min: result[8],
          max: result[9],
          digits: result[10],
        );
      case ConstantType.string:
        constant = ConstantString(
          name: name,
          size: size,
          offset: offset,
          length: result[4].parseInt(),
        );
    }

    _constants.pages[_currentPage - 1].constants.add(constant);
  }

  void _parseConfig(List<String> result) {
    final name = result.first;
    final value = result[1];

    switch (name) {
      case 'endianness':
        _constants.config.endianness = value;
      case 'nPages':
        _constants.config.nPages = value.parseInt();
      case 'pageSize':
        _constants.config.pageSizes =
            result.sublist(1).map((e) => e.parseInt()).toList();
      case 'pageIdentifier':
        _constants.config.pageIdentifiers = result.sublist(1);
      default:
    }
  }
}
