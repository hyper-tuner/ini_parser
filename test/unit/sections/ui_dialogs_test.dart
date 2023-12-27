// ignore_for_file: lines_longer_than_80_chars

import 'package:ini_parser/ini_parser.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:spec/spec.dart';

void main() {
  group('UserDefined/UiDialogs', () {
    group('success', () {
      const raw = '''
[UserDefined]
  dialog = injTest_l, "Output test modes", yAxis
    topicHelp = "baseHelp"

    field = "The values here set the amount of filtering to apply to each analog input"
    field = "#Most setups will NOT require changes to the default filter values"
    field = ""

    slider = "Throttle Position sensor", ADCFILTER_TPS,  vertical
    slider = "Baro sensor",                 ADCFILTER_BARO, horizontal, { useExtBaro > 0 }

    field = "Start/Stop Button input mode", startStopButtonMode
    field = "Starter Control", starterControlPin, { starterControlPin != 0 || startStopButtonPin != 0}
    field = "!This is a critical setting!"
    field = "VVT2 Cam angle @ 0% duty",vvt2CL0DutyAng,    { vvt2Enabled && vvtMode == 2 }
    field = "Real Time Clock Trim +/-", rtc_trim, {rtc_mode}
    field = "#Please ensure you calibrate your O2 sensor in the Tools menu", { egoType }

    gauge = VBattGauge,North
    gauge = pedalPositionGauge

  dialog = acSettings, "", border
    panel = acSettingsWest, West
    panel = ac_controlIndicatorPanel, East
    panel = etbIdleDialog,{ etbFunctions1 == 1 || etbFunctions1 == 2 || etbFunctions2 == 1 || etbFunctions2 == 2 }
    panel = limitsAndFallbackCenter, Center, { (cutFuelOnHardLimit || cutSparkOnHardLimit) && useCltBasedRpmLimit }

    liveGraph = fuel_computer_1_Graph, "Graph", South
      graphLine = totalFuelCorrection
      graphLine = running_postCrankingFuelCorrection

    liveGraph = pump_ae_Graph, "AE Graph"
      graphLine = TPSdot, "%", -2000, 2000, auto, auto

  dialog = fanSettings,"Fan Settings",7
    commandButton = "Enable Test Mode", cmdEnableTestMode,{!testenabled && !testactive }
    commandButton = "Lua Out #1",	cmd_test_lua1

  dialog = idleAdvanceSettings_east
    settingSelector = "Common Pressure Sensors",  { useExtBaro }
        settingOption = "MPX4115/MPXxx6115A/KP234",  baroMin=10,   baroMax=121
        settingOption = "MPX4250A/MPXA4250A",  baroMin=10,   baroMax=260

    settingSelector = "Common CLT Sensors"
			settingOption = "GM CLT", clt_tempC_1=0,clt_resistance_1=9240

    radio = horizontal, "A radio label", map_sample_opt2, { enable }, { visible }
    radio = invalid_orientation, "A radio label 2", map_sample_opt3, { enable }, { visible }

  indicatorPanel = protectIndicatorPanel, 1, { 1 }
    indicator = { engineProtectStatus}, "Engine Protect OFF",   "Engine Protect ON",   green, black, red,      black
    indicator = { engineProtectRPM   }, "Rev Limiter Off",      "Rev Limiter ON"
''';

      test('dialog with fields sliders and gauges', () async {
        final result = await INIParser(raw).parse();
        final dialog = result.ui.dialogs[0];

        expect(dialog.name).toEqual('injTest_l');
        expect(dialog.label).toEqual('Output test modes');
        expect(dialog.layout).toEqual(UIDialogLayout.yAxis);
        expect(dialog.topicHelp).toEqual('baseHelp');

        final items = dialog.items;

        expect((items[0] as UIField).label).toEqual(
          'The values here set the amount of filtering to apply to each analog input',
        );

        expect((items[1] as UIField).label).toEqual(
          '#Most setups will NOT require changes to the default filter values',
        );

        expect((items[2] as UIField).label).toEqual('');

        expect((items[3] as UISlider).label)
            .toEqual('Throttle Position sensor');
        expect((items[3] as UISlider).constant).toEqual('ADCFILTER_TPS');
        expect((items[3] as UISlider).orientation)
            .toEqual(UIOrientation.vertical);
        expect((items[3] as UISlider).enabled).toBeNull();

        expect((items[4] as UISlider).label).toEqual('Baro sensor');
        expect((items[4] as UISlider).constant).toEqual('ADCFILTER_BARO');
        expect((items[4] as UISlider).orientation)
            .toEqual(UIOrientation.horizontal);
        expect((items[4] as UISlider).enabled).toEqual('{ useExtBaro > 0 }');

        expect((items[5] as UIField).label)
            .toEqual('Start/Stop Button input mode');
        expect((items[5] as UIField).constant).toEqual('startStopButtonMode');

        expect((items[6] as UIField).label).toEqual('Starter Control');
        expect((items[6] as UIField).constant).toEqual('starterControlPin');
        expect((items[6] as UIField).enabled).toEqual(
          '{ starterControlPin != 0 || startStopButtonPin != 0}',
        );

        expect((items[7] as UIField).label)
            .toEqual('!This is a critical setting!');
        expect((items[7] as UIField).constant).toBeNull();
        expect((items[7] as UIField).enabled).toBeNull();

        expect((items[8] as UIField).label).toEqual('VVT2 Cam angle @ 0% duty');
        expect((items[8] as UIField).constant).toEqual('vvt2CL0DutyAng');
        expect((items[8] as UIField).enabled).toEqual(
          '{ vvt2Enabled && vvtMode == 2 }',
        );

        expect((items[9] as UIField).label).toEqual('Real Time Clock Trim +/-');
        expect((items[9] as UIField).constant).toEqual('rtc_trim');
        expect((items[9] as UIField).enabled).toEqual('{rtc_mode}');

        expect((items[10] as UIField).label).toEqual(
          '#Please ensure you calibrate your O2 sensor in the Tools menu',
        );
        expect((items[10] as UIField).constant).toBeNull();
        expect((items[10] as UIField).enabled).toEqual('{ egoType }');

        expect((items[11] as UIGauge).name).toEqual('VBattGauge');
        expect((items[11] as UIGauge).placement).toEqual(UIPlacement.north);

        expect((items[12] as UIGauge).name).toEqual('pedalPositionGauge');
        expect((items[12] as UIGauge).placement).toBeNull();
      });

      test('dialog with panels and live graphs', () async {
        final result = await INIParser(raw).parse();
        final dialog = result.ui.dialogs[1];

        expect(dialog.name).toEqual('acSettings');
        expect(dialog.label).toEqual('');
        expect(dialog.layout).toEqual(UIDialogLayout.border);

        final items = dialog.items;

        expect((items[0] as UIPanel).name).toEqual('acSettingsWest');
        expect((items[0] as UIPanel).placement).toEqual(UIPlacement.west);
        expect((items[0] as UIPanel).enabled).toBeNull();

        expect((items[1] as UIPanel).name).toEqual('ac_controlIndicatorPanel');
        expect((items[1] as UIPanel).placement).toEqual(UIPlacement.east);
        expect((items[1] as UIPanel).enabled).toBeNull();

        expect((items[2] as UIPanel).name).toEqual('etbIdleDialog');
        expect((items[2] as UIPanel).placement).toBeNull();
        expect((items[2] as UIPanel).enabled).toEqual(
          '{ etbFunctions1 == 1 || etbFunctions1 == 2 || etbFunctions2 == 1 || etbFunctions2 == 2 }',
        );

        expect((items[3] as UIPanel).name).toEqual('limitsAndFallbackCenter');
        expect((items[3] as UIPanel).placement).toEqual(UIPlacement.center);
        expect((items[3] as UIPanel).enabled).toEqual(
          '{ (cutFuelOnHardLimit || cutSparkOnHardLimit) && useCltBasedRpmLimit }',
        );

        expect((items[4] as UILiveGraph).name).toEqual('fuel_computer_1_Graph');
        expect((items[4] as UILiveGraph).label).toEqual('Graph');
        expect((items[4] as UILiveGraph).placement).toEqual(UIPlacement.south);

        final graphLines = (items[4] as UILiveGraph).lines;

        expect(graphLines[0].channel).toEqual('totalFuelCorrection');
        expect(graphLines[0].units).toBeNull();
        expect(graphLines[0].min).toBeNull();
        expect(graphLines[0].max).toBeNull();
        expect(graphLines[0].autoMin).toEqual(false);
        expect(graphLines[0].autoMax).toEqual(false);

        expect(graphLines[1].channel)
            .toEqual('running_postCrankingFuelCorrection');
        expect(graphLines[1].units).toBeNull();
        expect(graphLines[1].min).toBeNull();
        expect(graphLines[1].max).toBeNull();
        expect(graphLines[1].autoMin).toEqual(false);
        expect(graphLines[1].autoMax).toEqual(false);

        expect((items[5] as UILiveGraph).name).toEqual('pump_ae_Graph');
        expect((items[5] as UILiveGraph).label).toEqual('AE Graph');
        expect((items[5] as UILiveGraph).placement).toBeNull();

        final graphLines2 = (items[5] as UILiveGraph).lines;

        expect(graphLines2[0].channel).toEqual('TPSdot');
        expect(graphLines2[0].units).toEqual('%');
        expect(graphLines2[0].min).toEqual(-2000);
        expect(graphLines2[0].max).toEqual(2000);
        expect(graphLines2[0].autoMin).toEqual(true);
        expect(graphLines2[0].autoMax).toEqual(true);
      });

      test('dialog number as a layout with command buttons', () async {
        final result = await INIParser(raw).parse();
        final dialog = result.ui.dialogs[2];

        expect(dialog.name).toEqual('fanSettings');
        expect(dialog.label).toEqual('Fan Settings');
        expect(dialog.layout).toEqual(UIDialogLayout.yAxis);

        final items = dialog.items;

        expect((items[0] as UICommandButton).label).toEqual('Enable Test Mode');
        expect((items[0] as UICommandButton).command)
            .toEqual('cmdEnableTestMode');
        expect((items[0] as UICommandButton).enabled)
            .toEqual('{!testenabled && !testactive }');

        expect((items[1] as UICommandButton).label).toEqual('Lua Out #1');
        expect((items[1] as UICommandButton).command).toEqual('cmd_test_lua1');
        expect((items[1] as UICommandButton).enabled).toBeNull();
      });

      test('minimal dialog with setting and radio', () async {
        final result = await INIParser(raw).parse();
        final dialog = result.ui.dialogs[3];

        expect(dialog.name).toEqual('idleAdvanceSettings_east');
        expect(dialog.label).toEqual('');
        expect(dialog.layout).toBeNull();

        final settingSelector1 = dialog.items[0] as UISettingSelector;

        expect(settingSelector1.label).toEqual('Common Pressure Sensors');
        expect(settingSelector1.enabled).toEqual('{ useExtBaro }');

        final settingOptions1 = settingSelector1.options;

        expect(settingOptions1[0].label).toEqual('MPX4115/MPXxx6115A/KP234');
        expect(settingOptions1[0].options).toEqual({
          'baroMin': 10,
          'baroMax': 121,
        });

        expect(settingOptions1[1].label).toEqual('MPX4250A/MPXA4250A');
        expect(settingOptions1[1].options).toEqual({
          'baroMin': 10,
          'baroMax': 260,
        });

        final settingSelector2 = dialog.items[1] as UISettingSelector;

        expect(settingSelector2.label).toEqual('Common CLT Sensors');

        final settingOptions2 = settingSelector2.options;

        expect(settingOptions2[0].label).toEqual('GM CLT');
        expect(settingOptions2[0].options).toEqual({
          'clt_tempC_1': 0,
          'clt_resistance_1': 9240,
        });

        final radio1 = dialog.items[2] as UIRadio;

        expect(radio1.orientation).toEqual(UIOrientation.horizontal);
        expect(radio1.label).toEqual('A radio label');
        expect(radio1.constant).toEqual('map_sample_opt2');
        expect(radio1.enabled).toEqual('{ enable }');
        expect(radio1.visible).toEqual('{ visible }');

        final radio2 = dialog.items[3] as UIRadio;

        expect(radio2.orientation).toEqual(UIOrientation.horizontal);
        expect(radio2.label).toEqual('A radio label 2');
        expect(radio2.constant).toEqual('map_sample_opt3');
        expect(radio2.enabled).toEqual('{ enable }');
        expect(radio2.visible).toEqual('{ visible }');
      });

      test('indicator panel', () async {
        final result = await INIParser(raw).parse();
        final panel = result.ui.indicatorPanels[0];

        expect(panel.name).toEqual('protectIndicatorPanel');
        expect(panel.columns).toEqual(1);
        expect(panel.enabled).toEqual('{ 1 }');

        final indicators = panel.indicators;

        expect(indicators[0].expression).toEqual('{ engineProtectStatus}');
        expect(indicators[0].labelOff).toEqual('Engine Protect OFF');
        expect(indicators[0].labelOn).toEqual('Engine Protect ON');
        expect(indicators[0].colors!.offBackground).toEqual('green');
        expect(indicators[0].colors!.offForeground).toEqual('black');
        expect(indicators[0].colors!.onBackground).toEqual('red');
        expect(indicators[0].colors!.onForeground).toEqual('black');

        expect(indicators[1].expression).toEqual('{ engineProtectRPM }');
        expect(indicators[1].labelOff).toEqual('Rev Limiter Off');
        expect(indicators[1].labelOn).toEqual('Rev Limiter ON');
        expect(indicators[1].colors).toBeNull();
      });
    });

    group('failure', () {
      const raw = '''
[UserDefined]
  dialog =
''';
      test('ParserException', () async {
        expect(() => INIParser(raw).parse()).throws.isException();
      });
    });
  });
}
