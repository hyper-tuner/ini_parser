// ignore_for_file: lines_longer_than_80_chars

import 'package:ini_parser/ini_parser.dart';
import 'package:spec/spec.dart';

void main() {
  group('success', () {
    group('ConstantsExtensions', () {
      const raw = '''
[ConstantsExtensions]
  defaultValue = wueAfrTargetOffset, -1.5 -1.4 -1.15
  maintainConstantValue = tpsMax, { (calibrationMode == 1 ) ? calibrationValue : tpsMax }
  defaultValue = gearCountArray, -1 0 1 2 3 4 5 6 7 8
  controllerPriority = vssRatio2
  maintainConstantValue = throttlePedalSecondaryWOTVoltage, { (calibrationMode == 13 ) ? calibrationValue2 : throttlePedalSecondaryWOTVoltage }
  requiresPowerCycle= vssRatio6
  controllerPriority = bootloaderCaps
  requiresPowerCycle = tunerStudioSerialSpeed
''';
      final parser = INIParser(raw);

      test('section', () async {
        final result = await parser.parse();
        final extensions = result.constantsExtensions;

        expect(extensions.defaultValue).toEqual({
          'wueAfrTargetOffset': '-1.5 -1.4 -1.15',
          'gearCountArray': '-1 0 1 2 3 4 5 6 7 8',
        });

        expect(extensions.maintainConstantValue).toEqual({
          'tpsMax': '{ (calibrationMode == 1 ) ? calibrationValue : tpsMax }',
          'throttlePedalSecondaryWOTVoltage':
              '{ (calibrationMode == 13 ) ? calibrationValue2 : throttlePedalSecondaryWOTVoltage }',
        });

        expect(extensions.controllerPriority)
            .toEqual(['vssRatio2', 'bootloaderCaps']);

        expect(extensions.requiresPowerCycle).toEqual([
          'vssRatio6',
          'tunerStudioSerialSpeed',
        ]);
      });
    });
  });

  group('failure', () {
    const raw = '''
[ConstantsExtensions]
  test =
''';

    test('ParserException', () async {
      expect(() => INIParser(raw).parse()).throws.isException();
    });
  });
}
