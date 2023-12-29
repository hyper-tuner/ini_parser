import 'package:ini_parser/models/ini_config.dart';
import 'package:ini_parser/pre_processor.dart';
import 'package:ini_parser/sections/constants_extensions_parser.dart';
import 'package:ini_parser/sections/constants_parser.dart';
import 'package:ini_parser/sections/context_help_parser.dart';
import 'package:ini_parser/sections/controller_commands_parser.dart';
import 'package:ini_parser/sections/curve_editor_parser.dart';
import 'package:ini_parser/sections/datalog_parser.dart';
import 'package:ini_parser/sections/front_page_parser.dart';
import 'package:ini_parser/sections/gauge_configurations_parser.dart';
import 'package:ini_parser/sections/header_parser.dart';
import 'package:ini_parser/sections/menu_parser.dart';
import 'package:ini_parser/sections/output_channels_parser.dart';
import 'package:ini_parser/sections/pc_variables_parser.dart';
import 'package:ini_parser/sections/setting_groups_parser.dart';
import 'package:ini_parser/sections/table_editor_parser.dart';
import 'package:ini_parser/sections/ui_dialogs_parser.dart';

class INIParser {
  INIParser(this.raw);

  final String raw;
  final List<String> lines = [];
  final List<String> settings = [];
  final PreProcessorDefines defines = {};

  // assume that top level definitions are in the TunerStudio section (see FOME)
  String _currentSection = 'TunerStudio';

  final Map<String, List<String>> _sections = {};
  INIConfig _config = INIConfig();

  Future<INIConfig> parse({List<String>? profileSettings}) async {
    _config = INIConfig();
    lines.clear();
    settings.clear();

    final preProcessor = PreProcessor(raw: raw, settings: profileSettings ?? [])
      ..process();
    lines.addAll(preProcessor.lines);
    settings.addAll(preProcessor.settings);
    defines.addAll(preProcessor.defines);

    for (final line in lines) {
      _parseSections(line);
    }

    await Future.wait(
      [
        _parseHeader(),
        _parseSettingGroups(),
        _parsePcVariables(),
        _parseConstants(),
        _parseOutputChannels(),
        _parseConstantsExtensions(),
        _parseTableEditor(),
        _parseGaugeConfigurations(),
        _parseControllerCommands(),
        _parseCurveEditor(),
        _parseUiDialogs(),
        _parseMenu(),
        // _parseKeyActions(),
        _parseDatalog(),
        _parseFrontPage(),
        // _parseEventTriggers(),
        // _parseVeAnalyze(),
        // _parseWueAnalyze(),
        // _parseTuning(),
        // _parseReferenceTables(),
        // _parseTools(),
        // _parseLoggerDefinition(),
        _parseContextHelp(),
      ],
      eagerError: true,
    );

    return _config;
  }

  void _parseSections(String line) {
    if (line.startsWith('[') && line.endsWith(']')) {
      _currentSection = line.substring(1, line.length - 1);

      return;
    }

    _sections.containsKey(_currentSection)
        ? _sections[_currentSection]!.add(line)
        : _sections[_currentSection] = [line];
  }

  Future<void> _parseHeader() async {
    final lines = (_sections['MegaTune'] ?? []) +
        (_sections['TunerStudio'] ?? []) +
        (_sections['HyperTuner'] ?? []);

    _config.header = await HeaderParser().parse(lines);
  }

  Future<void> _parseSettingGroups() async {
    _config.settingGroups =
        await SettingGroupsParser().parse(_sections['SettingGroups'] ?? []);
  }

  Future<void> _parsePcVariables() async {
    _config.pcVariables = await PcVariablesParser(defines: defines)
        .parse(_sections['PcVariables'] ?? []);
  }

  Future<void> _parseConstants() async {
    _config.constants = await ConstantsParser(defines: defines)
        .parse(_sections['Constants'] ?? []);
  }

  Future<void> _parseOutputChannels() async {
    _config.outputChannels =
        await OutputChannelsParser().parse(_sections['OutputChannels'] ?? []);
  }

  Future<void> _parseConstantsExtensions() async {
    _config.constantsExtensions = await ConstantsExtensionsParser()
        .parse(_sections['ConstantsExtensions'] ?? []);
  }

  Future<void> _parseTableEditor() async {
    _config.tables =
        await TableEditorParser().parse(_sections['TableEditor'] ?? []);
  }

  Future<void> _parseGaugeConfigurations() async {
    _config.gauges = await GaugeConfigurationsParser()
        .parse(_sections['GaugeConfigurations'] ?? []);
  }

  Future<void> _parseControllerCommands() async {
    _config.controllerCommands = await ControllerCommandsParser()
        .parse(_sections['ControllerCommands'] ?? []);
  }

  Future<void> _parseCurveEditor() async {
    _config.curves =
        await CurveEditorParser().parse(_sections['CurveEditor'] ?? []);
  }

  Future<void> _parseUiDialogs() async {
    final lines =
        (_sections['UserDefined'] ?? []) + (_sections['UiDialogs'] ?? []);

    _config.ui = await UiDialogsParser().parse(lines);
  }

  Future<void> _parseMenu() async {
    _config.menus = await MenuParser().parse(_sections['Menu'] ?? []);
  }

  Future<void> _parseDatalog() async {
    _config.logs = await DatalogParser().parse(_sections['Datalog'] ?? []);
  }

  Future<void> _parseFrontPage() async {
    _config.frontPage =
        await FrontPageParser().parse(_sections['FrontPage'] ?? []);
  }

  Future<void> _parseContextHelp() async {
    _config.contextHelp =
        await ContextHelpParser().parse(_sections['SettingContextHelp'] ?? []);
  }
}
