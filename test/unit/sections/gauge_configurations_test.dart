import 'package:ini_parser/ini_parser.dart';
import 'package:spec/spec.dart';

void main() {
  group('GaugeConfigurations', () {
    group('success', () {
      const raw = '''
[GaugeConfigurations]

gaugeCategory = Sensors - Basic
  RPMGauge  = RPMValue,  "RPM - engine speed",  "RPM",  0, {rpmHardLimit + 2000},  200, {cranking_rpm}, {rpmHardLimit - 500},  {rpmHardLimit},  0,  0
  CLTGauge  = coolant,  "Coolant temp",  "C",  -40.0,  140,  -15,  1,  95,  110,  1,  1
  IATGauge  = intake,  "Intake air temp",  "C",  -40,  140,  -15,  1,  95,  110,  1,  1
  afr1Gauge  = AFRValue, "Air/Fuel Ratio",  "",  10,  19.4,  12,  13,  15,  16,  2,  2
  afr2Gauge  = AFRValue2, "Air/Fuel Ratio 2",  "",  10,  19.4,  12,  13,  15,  16,  2,  2

gaugeCategory = Debug
  debugF1Gauge = debugFloatField1, {bitStringValue( debugFieldF1List, debugMode )}, "",  0,  100,  0,  0,  100,  100,  4,  4, { false }
  egt1Gauge  = egt1, "EGT#1", "C", 0, 2000
''';

      test('gauge category 1', () async {
        final result = await INIParser(raw).parse();
        final gauge = result.gauges[0];

        expect(gauge.category).toEqual('Sensors - Basic');

        final gauges = gauge.gauges;

        expect(gauges[0].name).toEqual('RPMGauge');
        expect(gauges[0].channel).toEqual('RPMValue');
        expect(gauges[0].label).toEqual('RPM - engine speed');
        expect(gauges[0].units).toEqual('RPM');
        expect(gauges[0].low).toEqual('0');
        expect(gauges[0].high).toEqual('{rpmHardLimit + 2000}');
        expect(gauges[0].lowDanger).toEqual('200');
        expect(gauges[0].lowWarning).toEqual('{cranking_rpm}');
        expect(gauges[0].highWarning).toEqual('{rpmHardLimit - 500}');
        expect(gauges[0].highDanger).toEqual('{rpmHardLimit}');
        expect(gauges[0].digitsValue).toEqual('0');
        expect(gauges[0].digitsLowHigh).toEqual('0');
        expect(gauges[0].enabled).toBeNull();

        expect(gauges[1].name).toEqual('CLTGauge');
        expect(gauges[1].channel).toEqual('coolant');
        expect(gauges[1].label).toEqual('Coolant temp');
        expect(gauges[1].units).toEqual('C');
        expect(gauges[1].low).toEqual('-40.0');
        expect(gauges[1].high).toEqual('140');
        expect(gauges[1].lowDanger).toEqual('-15');
        expect(gauges[1].lowWarning).toEqual('1');
        expect(gauges[1].highWarning).toEqual('95');
        expect(gauges[1].highDanger).toEqual('110');
        expect(gauges[1].digitsValue).toEqual('1');
        expect(gauges[1].digitsLowHigh).toEqual('1');
        expect(gauges[1].enabled).toBeNull();
      });

      test('gauge category 2', () async {
        final result = await INIParser(raw).parse();
        final gauge = result.gauges[1];

        expect(gauge.category).toEqual('Debug');

        final gauges = gauge.gauges;

        expect(gauges[0].name).toEqual('debugF1Gauge');
        expect(gauges[0].channel).toEqual('debugFloatField1');
        expect(gauges[0].label)
            .toEqual('{bitStringValue( debugFieldF1List, debugMode )}');
        expect(gauges[0].units).toEqual('');
        expect(gauges[0].low).toEqual('0');
        expect(gauges[0].high).toEqual('100');
        expect(gauges[0].lowDanger).toEqual('0');
        expect(gauges[0].lowWarning).toEqual('0');
        expect(gauges[0].highWarning).toEqual('100');
        expect(gauges[0].highDanger).toEqual('100');
        expect(gauges[0].digitsValue).toEqual('4');
        expect(gauges[0].digitsLowHigh).toEqual('4');
        expect(gauges[0].enabled).toEqual('{ false }');
      });
    });

    group('failure', () {
      const raw = '''
[GaugeConfigurations]
  gaugeCategory =
''';
      test('ParserException', () async {
        expect(() => INIParser(raw).parse()).throws.isException();
      });
    });
  });
}
