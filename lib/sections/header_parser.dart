import 'package:ini_parser/extensions.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:ini_parser/parsing_exception.dart';
import 'package:ini_parser/patterns.dart';
import 'package:ini_parser/section.dart';
import 'package:text_parser/text_parser.dart';

class HeaderParser {
  final _header = Header();
  final _parser = TextParser(
    matchers: [
      const PatternMatcher(textPattern),
    ],
  );

  Future<Header> parse(List<String> lines) async {
    for (final line in lines) {
      try {
        await _parseLine(line);
      } catch (e) {
        throw ParsingException(section: Section.header, line: line);
      }
    }

    return _header;
  }

  Future<void> _parseLine(String line) async {
    final result = (await _parser.parse(line, onlyMatches: true))
        .map((e) => e.text.clearString())
        .toList();

    if (result.length < 2) {
      throw ParsingException(section: Section.header, line: line);
    }

    final name = result.first;
    final value = result.last;

    switch (name) {
      case 'MTversion':
        _header.mTVersion = value.parseDouble();
      case 'signature':
        _header.signature = value;
      case 'queryCommand':
        _header.queryCommand = value;
      case 'versionInfo':
        _header.versionInfo = value;
      case 'enable2ndByteCanID':
        _header.enable2ndByteCanID = value.parseBool();
      case 'useLegacyFTempUnits':
        _header.useLegacyFTempUnits = value.parseBool();
      case 'ignoreMissingBitOptions':
        _header.ignoreMissingBitOptions = value.parseBool();
      case 'noCommReadDelay':
        _header.noCommReadDelay = value.parseBool();
      case 'defaultRuntimeRecordPerSec':
        _header.defaultRuntimeRecordPerSec = value.parseInt();
      case 'maxUnusedRuntimeRange':
        _header.maxUnusedRuntimeRange = value.parseInt();
      case 'defaultIpAddress':
        _header.defaultIpAddress = value;
      case 'defaultIpPort':
        _header.defaultIpPort = value.parseInt();
      case 'iniSpecVersion':
        _header.iniSpecVersion = value;
      case 'hyperTunerCloudUrl':
        _header.hyperTunerCloudUrl = value;
      default:
    }
  }
}
