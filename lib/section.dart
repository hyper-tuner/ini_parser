enum Section {
  header('Header'),
  defines('Defines'),
  settingGroups('SettingGroups'),
  pcVariables('PcVariables'),
  constants('Constants'),
  outputChannels('OutputChannels'),
  constantsExtensions('ConstantsExtensions'),
  tableEditor('TableEditor'),
  gaugeConfigurations('GaugeConfigurations'),
  controllerCommands('ControllerCommands'),
  curveEditor('CurveEditor'),
  uiDialogs('UiDialogs'),
  menu('Menu'),
  datalog('Datalog'),
  frontPage('FrontPage'),
  contextHelp('ContextHelp');

  const Section(this.name);

  final String name;
}
