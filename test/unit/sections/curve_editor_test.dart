import 'package:ini_parser/ini_parser.dart';
import 'package:spec/spec.dart';

void main() {
  group('CurveEditor', () {
    group('success', () {
      const raw = '''
[CurveEditor]
curve = knockThresholdCurve, "Engine knock threshold RPM based"
  columnLabel = "RPM", "Threshold"
  xAxis  =  0, { some }, 9
  yAxis  =  0,  8, 10
  xBins  = knockNoiseRpmBins, RPMValue
  yBins  = knockBaseNoise
  topicHelp = "Knock threshold RPM based"
  showTextValues = true
  lineLabel = "Knock threshold"
  size  = 450, 200
  gauge  = RPMGauge

curve = scriptCurve1, "Script Curve #1"
  columnLabel = "X", "Y"
  xAxis  =  0, 128, 10
  yAxis  = -155,  150, 10
  xBins  = scriptCurve1Bins
  yBins  = scriptCurve1
  showTextValues = true
''';

      test('curve with all attributes', () async {
        final result = await INIParser(raw).parse();
        final curve = result.curves[0];

        expect(curve.name).toEqual('knockThresholdCurve');
        expect(curve.label).toEqual('Engine knock threshold RPM based');
        expect(curve.columnLabels).toEqual(['RPM', 'Threshold']);
        expect(curve.xAxis).toEqual(['0', '{ some }', '9']);
        expect(curve.yAxis).toEqual(['0', '8', '10']);
        expect(curve.xBins).toEqual(['knockNoiseRpmBins', 'RPMValue']);
        expect(curve.yBins).toEqual(['knockBaseNoise']);
        expect(curve.topicHelp).toEqual('Knock threshold RPM based');
        expect(curve.showTextValues).toEqual(true);
        expect(curve.lineLabel).toEqual('Knock threshold');
        expect(curve.size).toEqual(['450', '200']);
        expect(curve.gauge).toEqual('RPMGauge');
      });

      test('second curve', () async {
        final result = await INIParser(raw).parse();
        final curve = result.curves[1];

        expect(curve.name).toEqual('scriptCurve1');
        expect(curve.label).toEqual('Script Curve #1');
        expect(curve.columnLabels).toEqual(['X', 'Y']);
        expect(curve.xAxis).toEqual(['0', '128', '10']);
        expect(curve.yAxis).toEqual(['-155', '150', '10']);
        expect(curve.xBins).toEqual(['scriptCurve1Bins']);
        expect(curve.yBins).toEqual(['scriptCurve1']);
        expect(curve.topicHelp).toBeNull();
        expect(curve.showTextValues).toEqual(true);
        expect(curve.lineLabel).toBeNull();
        expect(curve.size).toBeNull();
        expect(curve.gauge).toBeNull();
      });
    });

    group('failure', () {
      const raw = '''
[CurveEditor]
  curve =
''';
      test('ParserException', () async {
        expect(() => INIParser(raw).parse()).throws.isException();
      });
    });
  });
}
