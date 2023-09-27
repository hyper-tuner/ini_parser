import 'package:ini_parser/ini_parser.dart';
import 'package:spec/spec.dart';

void main() {
  group('success', () {
    group('HyperTuner', () {
      const raw = '''
[HyperTuner]
   hyperTunerCloudUrl = "hypertuner.cloud"
''';
      final parser = INIParser(raw);

      test('section', () async {
        final result = await parser.parse();

        expect(result.header.hyperTunerCloudUrl).toEqual('hypertuner.cloud');
      });
    });

    group('MegaTune', () {
      const raw = '''
[MegaTune]
   MTversion      = 2.25
   queryCommand   = "Q"
   signature      = "speeduino 202207"
   versionInfo    = "S"
''';
      final parser = INIParser(raw);

      test('section', () async {
        final result = await parser.parse();

        expect(result.header.mTVersion).toEqual(2.25);
        expect(result.header.queryCommand).toEqual('Q');
        expect(result.header.signature).toEqual('speeduino 202207');
        expect(result.header.versionInfo).toEqual('S');
        expect(result.header.enable2ndByteCanID).toBeNull();
        expect(result.header.useLegacyFTempUnits).toBeNull();
        expect(result.header.ignoreMissingBitOptions).toBeNull();
        expect(result.header.noCommReadDelay).toBeNull();
        expect(result.header.defaultRuntimeRecordPerSec).toBeNull();
        expect(result.header.maxUnusedRuntimeRange).toBeNull();
        expect(result.header.defaultIpAddress).toBeNull();
        expect(result.header.defaultIpPort).toBeNull();
        expect(result.header.iniSpecVersion).toBeNull();
      });
    });

    group('TunerStudio', () {
      const raw = '''
enable2ndByteCanID = false

[MegaTune]
  signature    = "ignored"
  queryCommand = "ignored"

[TunerStudio]
  signature= "rusEFI (FOME) release_230512.2023.05.16.proteus_f4.3268344553" ; signature is expected to be 7 or more characters.
  queryCommand   = "S"
  versionInfo    = "V"
  useLegacyFTempUnits = false
  ignoreMissingBitOptions = true
  noCommReadDelay = true;
  defaultRuntimeRecordPerSec = 100;
  maxUnusedRuntimeRange = 1000;
  defaultIpAddress = 192.168.10.1;
  defaultIpPort = 29000;
  iniSpecVersion = 3.64
''';
      final parser = INIParser(raw);

      test('section', () async {
        final result = await parser.parse();

        expect(result.header.mTVersion).toBeNull();
        expect(result.header.queryCommand).toEqual('S');
        expect(result.header.signature).toEqual(
          'rusEFI (FOME) release_230512.2023.05.16.proteus_f4.3268344553',
        );
        expect(result.header.versionInfo).toEqual('V');
        expect(result.header.enable2ndByteCanID).toEqual(false);
        expect(result.header.useLegacyFTempUnits).toEqual(false);
        expect(result.header.ignoreMissingBitOptions).toEqual(true);
        expect(result.header.noCommReadDelay).toEqual(true);
        expect(result.header.defaultRuntimeRecordPerSec).toEqual(100);
        expect(result.header.maxUnusedRuntimeRange).toEqual(1000);
        expect(result.header.defaultIpAddress).toEqual('192.168.10.1');
        expect(result.header.defaultIpPort).toEqual(29000);
        expect(result.header.iniSpecVersion).toEqual('3.64');
      });
    });
  });

  group('failure', () {
    const raw = '''
[TunerStudio]
  queryCommand
''';

    test('ParserException', () async {
      expect(() => INIParser(raw).parse()).throws.isException();
    });
  });
}
