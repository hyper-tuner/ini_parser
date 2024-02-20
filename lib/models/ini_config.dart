// ignore_for_file: one_member_abstracts

enum ConstantType {
  scalar('scalar'),
  bits('bits'),
  array('array'),
  string('string');

  const ConstantType(this.type);

  final String type;
}

enum ConstantSize {
  u08('U08'),
  s08('S08'),
  u16('U16'),
  s16('S16'),
  u32('U32'),
  s32('S32'),
  s64('S64'),
  f32('F32'),
  ascii('ASCII');

  const ConstantSize(this.size);

  final String size;
}

class Header {
  String? signature;
  double? mTVersion;
  String? queryCommand;
  String? versionInfo;
  bool? enable2ndByteCanID;
  bool? useLegacyFTempUnits;
  bool? ignoreMissingBitOptions;
  bool? noCommReadDelay;
  int? defaultRuntimeRecordPerSec;
  int? maxUnusedRuntimeRange;
  String? defaultIpAddress;
  int? defaultIpPort;
  String? iniSpecVersion;
  String? hyperTunerCloudUrl;

  Map<String, dynamic> toJson() {
    return {
      'signature': signature,
      'mTVersion': mTVersion,
      'queryCommand': queryCommand,
      'versionInfo': versionInfo,
      'enable2ndByteCanID': enable2ndByteCanID,
      'useLegacyFTempUnits': useLegacyFTempUnits,
      'ignoreMissingBitOptions': ignoreMissingBitOptions,
      'noCommReadDelay': noCommReadDelay,
      'defaultRuntimeRecordPerSec': defaultRuntimeRecordPerSec,
      'maxUnusedRuntimeRange': maxUnusedRuntimeRange,
      'defaultIpAddress': defaultIpAddress,
      'iniSpecVersion': iniSpecVersion,
      'hyperTunerCloudUrl': hyperTunerCloudUrl,
    };
  }
}

abstract class OutputChannel {
  late final String name;

  Map<String, dynamic> toJson();
}

class OutputChannelScalar implements OutputChannel {
  OutputChannelScalar({
    required this.name,
    required this.size,
    required this.offset,
    required this.units,
    required this.scale,
    required this.transform,
  });
  @override
  late final String name;
  final ConstantType type = ConstantType.scalar;
  final ConstantSize size;
  final int offset;
  final String? units;
  final String? scale;
  final String? transform;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.type,
      'size': size.size,
      'offset': offset,
      'units': units,
      'scale': scale,
      'transform': transform,
    };
  }
}

class BitsShape {
  BitsShape({
    required this.low,
    required this.high,
  });
  final int low;
  final int high;

  Map<String, dynamic> toJson() {
    return {
      'low': low,
      'high': high,
    };
  }
}

class OutputChannelBits implements OutputChannel {
  OutputChannelBits({
    required this.name,
    required this.size,
    required this.offset,
    required this.bits,
  });
  @override
  late final String name;
  final ConstantType type = ConstantType.bits;
  final ConstantSize size;
  final int offset;
  final BitsShape bits;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.type,
      'size': size.size,
      'offset': offset,
      'bits': bits.toJson(),
    };
  }
}

class OutputChannelDynamic implements OutputChannel {
  OutputChannelDynamic({
    required this.name,
    required this.expression,
  });
  @override
  late final String name;
  final String expression;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'expression': expression,
    };
  }
}

class OutputChannelsConfig {
  String? ochGetCommand = '';
  int? ochBlockSize = 0;

  Map<String, dynamic> toJson() {
    return {
      'ochGetCommand': ochGetCommand,
      'ochBlockSize': ochBlockSize,
    };
  }
}

class OutputChannels {
  OutputChannelsConfig config = OutputChannelsConfig();
  List<OutputChannel> channels = [];

  Map<String, dynamic> toJson() {
    return {
      'config': config.toJson(),
      'channels': channels.map((c) => c.toJson()).toList(),
    };
  }
}

abstract class Constant {
  late final String name;
  late final ConstantType type;
  late final ConstantSize size;
  late final int offset;

  Map<String, dynamic> toJson();
}

class ConstantScalar implements Constant {
  ConstantScalar({
    required this.name,
    required this.size,
    required this.offset,
    required this.units,
    required this.scale,
    required this.transform,
    required this.min,
    required this.max,
    required this.digits,
  }) : type = ConstantType.scalar;
  @override
  late final String name;
  @override
  late final ConstantType type;
  @override
  late final ConstantSize size;
  @override
  late final int offset;
  final String units;
  final String scale;
  final String transform;
  final String? min;
  final String? max;
  final String? digits;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.type,
      'size': size.size,
      'offset': offset,
      'units': units,
      'scale': scale,
      'transform': transform,
      'min': min,
      'max': max,
      'digits': digits,
    };
  }
}

class ArrayShape {
  ArrayShape({
    required this.columns,
    required this.rows,
  });
  final int columns;
  final int? rows;

  Map<String, dynamic> toJson() {
    return {
      'columns': columns,
      'rows': rows,
    };
  }
}

class ConstantArray implements Constant {
  ConstantArray({
    required this.name,
    required this.size,
    required this.offset,
    required this.shape,
    required this.units,
    required this.scale,
    required this.transform,
    required this.min,
    required this.max,
    required this.digits,
  }) : type = ConstantType.array;
  @override
  late final String name;
  @override
  late final ConstantType type;
  @override
  late final ConstantSize size;
  @override
  late final int offset;
  final ArrayShape shape;
  final String units;
  final String scale;
  final String transform;
  final String min;
  final String max;
  final String digits;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.type,
      'size': size.size,
      'offset': offset,
      'shape': shape.toJson(),
      'units': units,
      'scale': scale,
      'transform': transform,
      'min': min,
      'max': max,
      'digits': digits,
    };
  }
}

class ConstantBits implements Constant {
  ConstantBits({
    required this.name,
    required this.size,
    required this.offset,
    required this.bits,
    required this.options,
  }) : type = ConstantType.bits;
  @override
  late final String name;
  @override
  late final ConstantType type;
  @override
  late final ConstantSize size;
  @override
  late final int offset;
  final BitsShape bits;
  final Map<int, String> options;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.type,
      'size': size.size,
      'offset': offset,
      'bits': bits.toJson(),
      'options': options.map((key, value) => MapEntry(key.toString(), value)),
    };
  }
}

class ConstantString implements Constant {
  ConstantString({
    required this.name,
    required this.size,
    required this.offset,
    required this.length,
  }) : type = ConstantType.string;
  @override
  late final String name;
  @override
  late final ConstantType type;
  @override
  late final ConstantSize size;
  @override
  late final int offset;
  final int length;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.type,
      'size': size.size,
      'offset': offset,
      'length': length,
    };
  }
}

class ConstantsPage {
  ConstantsPage({
    required this.number,
  });
  int number = 0;
  List<Constant> constants = [];

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'constants': constants.map((c) => c.toJson()).toList(),
    };
  }
}

class ConstantsConfig {
  String endianness = 'little';
  int nPages = 0;
  List<int> pageSizes = [];
  List<String> pageIdentifiers = [];

  Map<String, dynamic> toJson() {
    return {
      'endianness': endianness,
      'nPages': nPages,
      'pageSizes': pageSizes,
      'pageIdentifiers': pageIdentifiers,
    };
  }
}

class Constants {
  ConstantsConfig config = ConstantsConfig();
  List<ConstantsPage> pages = [];

  Map<String, dynamic> toJson() {
    return {
      'config': config.toJson(),
      'pages': pages.map((c) => c.toJson()).toList(),
    };
  }
}

abstract class PcVariable {
  late final String name;
  late final ConstantType type;
  late final ConstantSize size;

  Map<String, dynamic> toJson();
}

class PcVariableScalar implements PcVariable {
  PcVariableScalar({
    required this.name,
    required this.size,
    required this.units,
    required this.scale,
    required this.transform,
    required this.min,
    required this.max,
    required this.digits,
  }) : type = ConstantType.scalar;
  @override
  late final String name;
  @override
  late final ConstantType type;
  @override
  late final ConstantSize size;
  final String units;
  final String scale;
  final String transform;
  final String? min;
  final String? max;
  final String? digits;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.type,
      'size': size.size,
      'units': units,
      'scale': scale,
      'transform': transform,
      'min': min,
      'max': max,
      'digits': digits,
    };
  }
}

class PcVariableArray implements PcVariable {
  PcVariableArray({
    required this.name,
    required this.size,
    required this.shape,
    required this.units,
    required this.scale,
    required this.transform,
    required this.min,
    required this.max,
    required this.digits,
    required this.noSave,
  }) : type = ConstantType.array;
  @override
  late final String name;
  @override
  late final ConstantType type;
  @override
  late final ConstantSize size;
  final ArrayShape shape;
  final String units;
  final String scale;
  final String transform;
  final String min;
  final String max;
  final String digits;
  final bool noSave;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.type,
      'size': size.size,
      'shape': shape.toJson(),
      'units': units,
      'scale': scale,
      'transform': transform,
      'min': min,
      'max': max,
      'digits': digits,
      'noSave': noSave,
    };
  }
}

class PcVariableBits implements PcVariable {
  PcVariableBits({
    required this.name,
    required this.size,
    required this.bits,
    required this.options,
  }) : type = ConstantType.bits;
  @override
  late final String name;
  @override
  late final ConstantType type;
  @override
  late final ConstantSize size;
  final BitsShape bits;
  final Map<int, String> options;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.type,
      'size': size.size,
      'bits': bits.toJson(),
      'options': options.map((key, value) => MapEntry(key.toString(), value)),
    };
  }
}

class PcVariableString implements PcVariable {
  PcVariableString({
    required this.name,
    required this.size,
    required this.length,
  }) : type = ConstantType.string;
  @override
  late final String name;
  @override
  late final ConstantType type;
  @override
  late final ConstantSize size;
  final int length;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.type,
      'size': size.size,
      'length': length,
    };
  }
}

abstract class MenuChild {
  late final String label;

  Map<String, dynamic> toJson();
}

class SubMenu implements MenuChild {
  SubMenu({
    required this.dialog,
    required this.label,
    required this.enabled,
    required this.visible,
  });
  @override
  late final String label;
  final String dialog;
  final String? enabled;
  final String? visible;

  @override
  Map<String, dynamic> toJson() {
    return {
      'dialog': dialog,
      'label': label,
      'enabled': enabled,
      'visible': visible,
    };
  }
}

class GroupChildMenu {
  GroupChildMenu({
    required this.dialog,
    required this.label,
    required this.enabled,
    required this.visible,
  });
  final String dialog;
  final String label;
  final String? enabled;
  final String? visible;

  Map<String, dynamic> toJson() {
    return {
      'dialog': dialog,
      'label': label,
      'enabled': enabled,
      'visible': visible,
    };
  }
}

class GroupMenu implements MenuChild {
  GroupMenu({
    required this.label,
  });
  @override
  late final String label;
  final List<GroupChildMenu> children = [];

  @override
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }
}

class Menu {
  Menu({
    required this.label,
  });
  final String label;
  final List<MenuChild> children = [];

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }
}

class SettingGroup {
  SettingGroup({
    required this.name,
    required this.label,
  });
  final String name;
  final String label;
  final Map<String, String> options = {};

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'options': options,
    };
  }
}

class ConstantsExtensions {
  /// Structure: { 'name': 'value' }
  final Map<String, String> defaultValue = {};

  /// Structure: { 'name': '{ expression }' }
  final Map<String, String> maintainConstantValue = {};

  final List<String> controllerPriority = [];

  final List<String> requiresPowerCycle = [];

  Map<String, dynamic> toJson() {
    return {
      'defaultValue': defaultValue,
      'maintainConstantValue': maintainConstantValue,
      'controllerPriority': controllerPriority,
      'requiresPowerCycle': requiresPowerCycle,
    };
  }
}

class Table {
  Table({
    required this.name,
    required this.map,
    required this.label,
    required this.page,
  });
  final String name;
  final String map;
  final String label;
  final int page;
  String? topicHelp;
  List<String> xBins = [];
  List<String> yBins = [];
  List<String> zBins = [];
  List<String> xyLabels = [];
  double? gridHeight;
  List<double> gridOrient = [];
  List<String> upDownLabels = [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'map': map,
      'label': label,
      'page': page,
      'topicHelp': topicHelp,
      'xBins': xBins,
      'yBins': yBins,
      'zBins': zBins,
      'xyLabels': xyLabels,
      'gridHeight': gridHeight,
      'gridOrient': gridOrient,
      'upDownLabels': upDownLabels,
    };
  }
}

class Gauge {
  Gauge({
    required this.name,
    required this.channel,
    required this.label,
    required this.units,
    required this.low,
    required this.high,
    required this.lowDanger,
    required this.lowWarning,
    required this.highWarning,
    required this.highDanger,
    required this.digitsValue,
    required this.digitsLowHigh,
    required this.enabled,
  });
  final String name;
  final String channel;
  final String label;
  final String units;
  final String low;
  final String high;
  final String lowDanger;
  final String lowWarning;
  final String highWarning;
  final String highDanger;
  final String digitsValue;
  final String digitsLowHigh;
  final String? enabled;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'channel': channel,
      'label': label,
      'units': units,
      'low': low,
      'high': high,
      'lowDanger': lowDanger,
      'lowWarning': lowWarning,
      'highWarning': highWarning,
      'highDanger': highDanger,
      'digitsValue': digitsValue,
      'digitsLowHigh': digitsLowHigh,
      'enabled': enabled,
    };
  }
}

class GaugeConfig {
  GaugeConfig({
    required this.category,
  });
  late String category;
  List<Gauge> gauges = [];

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'gauges': gauges.map((c) => c.toJson()).toList(),
    };
  }
}

class TableBins {
  TableBins({
    required this.constant,
    this.channel,
  });

  final String constant;
  final String? channel;

  Map<String, dynamic> toJson() {
    return {
      'constant': constant,
      'channel': channel,
    };
  }
}

class CurveAxis {
  CurveAxis({
    required this.min,
    required this.max,
    this.numDivisions,
  });

  final String min;
  final String max;
  final int? numDivisions;

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'numDivisions': numDivisions,
    };
  }
}

class Curve {
  Curve({
    required this.name,
    required this.label,
  });
  final String name;
  final String label;
  List<String> columnLabels = [];
  CurveAxis xAxis = CurveAxis(min: '0', max: '0');
  CurveAxis yAxis = CurveAxis(min: '0', max: '0');
  TableBins xBins = TableBins(constant: '');
  TableBins yBins = TableBins(constant: '');
  String? topicHelp;
  bool showTextValues = false;
  String? lineLabel;
  List<String>? size;
  String? gauge;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'columnLabels': columnLabels,
      'xAxis': xAxis,
      'yAxis': yAxis,
      'xBins': xBins,
      'yBins': yBins,
      'topicHelp': topicHelp,
      'showTextValues': showTextValues,
      'lineLabel': lineLabel,
      'size': size,
      'gauge': gauge,
    };
  }
}

enum UIPlacement {
  north('North'),
  south('South'),
  east('East'),
  west('West'),
  center('Center');

  const UIPlacement(this.name);

  final String name;

  String toJson() => name;
}

enum UIDialogLayout {
  yAxis('yAxis'),
  xAxis('xAxis'),
  border('border'),
  card('card'),
  indexCard('indexCard');

  const UIDialogLayout(this.name);

  final String name;

  String toJson() => name;
}

enum UIOrientation {
  horizontal,
  vertical;

  String toJson() => name;
}

abstract class UIDialogItem {
  Map<String, dynamic> toJson();
}

class UIGauge implements UIDialogItem {
  UIGauge({
    required this.name,
    this.placement,
  });
  final String name;
  UIPlacement? placement;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'placement': placement,
    };
  }
}

class UIPanel implements UIDialogItem {
  UIPanel({
    required this.name,
    this.placement,
    this.enabled,
  });
  final String name;
  UIPlacement? placement;
  String? enabled;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'placement': placement,
      'enabled': enabled,
    };
  }
}

class UILiveGraphLine {
  UILiveGraphLine({
    required this.channel,
    required this.units,
    required this.min,
    required this.max,
    required this.autoMin,
    required this.autoMax,
  });
  final String channel;
  final String? units;
  final double? min;
  final double? max;
  final bool autoMin;
  final bool autoMax;

  Map<String, dynamic> toJson() {
    return {
      'channel': channel,
      'units': units,
      'min': min,
      'max': max,
      'autoMin': autoMin,
      'autoMax': autoMax,
    };
  }
}

class UILiveGraph implements UIDialogItem {
  UILiveGraph({
    required this.name,
    required this.label,
    required this.placement,
  });
  final String name;
  final String label;
  final UIPlacement? placement;
  final List<UILiveGraphLine> lines = [];

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'placement': placement,
      'lines': lines.map((l) => l.toJson()).toList(),
    };
  }
}

class UISettingSelectorOption {
  UISettingSelectorOption({
    required this.label,
    required this.options,
  });
  final String label;
  final Map<String, double> options;

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'values': options,
    };
  }
}

class UISettingSelector implements UIDialogItem {
  UISettingSelector({
    required this.label,
    required this.enabled,
  });
  final String label;
  final String? enabled;
  final List<UISettingSelectorOption> options = [];

  @override
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'enabled': enabled,
      'options': options.map((o) => o.toJson()).toList(),
    };
  }
}

class UIField implements UIDialogItem {
  UIField({
    required this.label,
    this.constant,
    this.enabled,
  });
  final String label;
  final String? constant;
  final String? enabled;

  @override
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'constant': constant,
      'enabled': enabled,
    };
  }
}

class UICommandButton implements UIDialogItem {
  UICommandButton({
    required this.label,
    required this.command,
    required this.enabled,
  });
  final String label;
  final String command;
  final String? enabled;

  @override
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'command': command,
      'enabled': enabled,
    };
  }
}

class UISlider implements UIDialogItem {
  UISlider({
    required this.label,
    required this.constant,
    required this.orientation,
    required this.enabled,
  });
  final String label;
  final String constant;
  final UIOrientation orientation;
  final String? enabled;

  @override
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'constant': constant,
      'orientation': orientation,
      'enabled': enabled,
    };
  }
}

class UIRadio implements UIDialogItem {
  UIRadio({
    required this.orientation,
    required this.label,
    required this.constant,
    required this.enabled,
    required this.visible,
  });
  final UIOrientation orientation;
  final String label;
  final String constant;
  final String? enabled;
  final String? visible;

  @override
  Map<String, dynamic> toJson() {
    return {
      'orientation': orientation,
      'label': label,
      'constant': constant,
      'enabled': enabled,
      'visible': visible,
    };
  }
}

class UIDialog {
  UIDialog({
    required this.name,
    required this.label,
    this.layout,
  });
  final String name;
  final String label;
  UIDialogLayout? layout;
  String? topicHelp;
  List<UIDialogItem> items = [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'layout': layout,
      'topicHelp': topicHelp,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class UIIndicatorColors {
  UIIndicatorColors({
    required this.offBackground,
    required this.offForeground,
    required this.onBackground,
    required this.onForeground,
  });
  final String offBackground;
  final String offForeground;
  final String onBackground;
  final String onForeground;

  Map<String, dynamic> toJson() {
    return {
      'offBackground': offBackground,
      'offForeground': offForeground,
      'onBackground': onBackground,
      'onForeground': onForeground,
    };
  }
}

class UIIndicator {
  UIIndicator({
    required this.expression,
    required this.labelOff,
    required this.labelOn,
    required this.colors,
  });
  final String expression;
  final String labelOff;
  final String labelOn;
  final UIIndicatorColors? colors;

  Map<String, dynamic> toJson() {
    return {
      'expression': expression,
      'labelOff': labelOff,
      'labelOn': labelOn,
      'colors': colors?.toJson(),
    };
  }
}

class UIIndicatorPanel {
  UIIndicatorPanel({
    required this.name,
    required this.columns,
    required this.enabled,
  });
  final String name;
  late int columns;
  final String? enabled;
  final List<UIIndicator> indicators = [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'columns': columns,
      'enabled': enabled,
      'indicators': indicators.map((i) => i.toJson()).toList(),
    };
  }
}

class UI {
  List<UIDialog> dialogs = [];
  List<UIIndicatorPanel> indicatorPanels = [];

  Map<String, dynamic> toJson() {
    return {
      'dialogs': dialogs.map((c) => c.toJson()).toList(),
      'indicatorPanels': indicatorPanels.map((c) => c.toJson()).toList(),
    };
  }
}

class Datalog {
  Datalog({
    required this.channel,
    required this.label,
    required this.format,
    required this.enabled,
  });
  final String channel;
  final String label;
  final String format;
  final String? enabled;

  Map<String, dynamic> toJson() {
    return {
      'channel': channel,
      'label': label,
      'format': format,
      'enabled': enabled,
    };
  }
}

class FrontPage {
  final List<String> gauges = [];
  final List<UIIndicator> indicators = [];

  Map<String, dynamic> toJson() {
    return {
      'gauges': gauges,
      'indicators': indicators.map((i) => i.toJson()).toList(),
    };
  }
}

class INIConfig {
  Header header = Header();
  List<SettingGroup> settingGroups = [];
  List<PcVariable> pcVariables = [];
  Constants constants = Constants();
  OutputChannels outputChannels = OutputChannels();
  ConstantsExtensions constantsExtensions = ConstantsExtensions();
  List<Table> tables = [];
  Map<String, String> controllerCommands = {};
  List<GaugeConfig> gauges = [];
  List<Curve> curves = [];
  UI ui = UI();
  List<Menu> menus = [];
  List<Datalog> logs = [];
  FrontPage frontPage = FrontPage();
  Map<String, String> contextHelp = {}; // { 'constantOrPcVariable: 'help' }

  Map<String, dynamic> toJson() {
    return {
      'header': header.toJson(),
      'settingGroups': settingGroups.map((c) => c.toJson()).toList(),
      'pcVariables': pcVariables.map((c) => c.toJson()).toList(),
      'constants': constants.toJson(),
      'outputChannels': outputChannels.toJson(),
      'constantsExtensions': constantsExtensions.toJson(),
      'tables': tables.map((c) => c.toJson()).toList(),
      'controllerCommands': controllerCommands,
      'gauges': gauges.map((c) => c.toJson()).toList(),
      'curves': curves.map((c) => c.toJson()).toList(),
      'ui': ui.toJson(),
      'menus': menus.map((c) => c.toJson()).toList(),
      'logs': logs.map((c) => c.toJson()).toList(),
      'frontPage': frontPage.toJson(),
      'contextHelp': contextHelp,
    };
  }
}
