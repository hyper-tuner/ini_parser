// ignore_for_file: lines_longer_than_80_chars

import 'package:ini_parser/ini_parser.dart';
import 'package:spec/spec.dart';

void main() {
  group('Datalog', () {
    group('success', () {
      const raw = '''
[Datalog]
  entry = rpmAcceleration, "dRPM", int,    "%d"
  entry = speedToRpmRatio, "Gearbox Ratio", float,  "%.3f"
  entry = CLIdleTarget,    "Idle Target RPM",  int,    "%%d",     { iacAlgorithm == 3 || iacAlgorithm == 5 || iacAlgorithm == 6 || iacAlgorithm == 7 || idleAdvEnabled >= 1 }
  entry = vvt2Angle,       "VVT2 Angle",       int,    "%.1f",        { vvt2Enabled > 0 }
''';

      test('logs', () async {
        final result = await INIParser(raw).parse();
        final logs = result.logs;

        expect(logs[0].channel).toEqual('rpmAcceleration');
        expect(logs[0].label).toEqual('dRPM');
        expect(logs[0].format).toEqual('%d');
        expect(logs[0].enabled).toEqual(null);

        expect(logs[1].channel).toEqual('speedToRpmRatio');
        expect(logs[1].label).toEqual('Gearbox Ratio');
        expect(logs[1].format).toEqual('%.3f');
        expect(logs[1].enabled).toEqual(null);

        expect(logs[2].channel).toEqual('CLIdleTarget');
        expect(logs[2].label).toEqual('Idle Target RPM');
        expect(logs[2].format).toEqual('%%d');
        expect(logs[2].enabled).toEqual(
          '{ iacAlgorithm == 3 || iacAlgorithm == 5 || iacAlgorithm == 6 || iacAlgorithm == 7 || idleAdvEnabled >= 1 }',
        );

        expect(logs[3].channel).toEqual('vvt2Angle');
        expect(logs[3].label).toEqual('VVT2 Angle');
        expect(logs[3].format).toEqual('%.1f');
        expect(logs[3].enabled).toEqual('{ vvt2Enabled > 0 }');
      });
    });

    group('failure', () {
      const raw = '''
[Datalog]
  entry =
''';
      test('ParserException', () async {
        expect(() => INIParser(raw).parse()).throws.isException();
      });
    });
  });
}
