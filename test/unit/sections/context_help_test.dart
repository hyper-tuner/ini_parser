import 'package:ini_parser/ini_parser.dart';
import 'package:spec/spec.dart';

void main() {
  group('ContextHelp', () {
    group('success', () {
      const raw = r'''
[SettingContextHelp]
  engineType = "http://rusefi.com/wiki/index.php?title=Manual:Engine_Type"
  sensorSnifferRpmThreshold = "Disable sensor sniffer above this rpm"
  TrigEdgeSec       = "The Trigger edge of the secondary (Cam) sensor.\nLeading.\nTrailing."
  tpsSecondaryMaximum = "For Ford TPS, use 53%. For Toyota ETCS-i, use ~65%"
  invalid
''';

      test('logs', () async {
        final result = await INIParser(raw).parse();
        final help = result.contextHelp;

        expect(help).toEqual(
          {
            'engineType':
                'http://rusefi.com/wiki/index.php?title=Manual:Engine_Type',
            'sensorSnifferRpmThreshold':
                'Disable sensor sniffer above this rpm',
            'TrigEdgeSec':
                r'The Trigger edge of the secondary (Cam) sensor.\nLeading.\nTrailing.',
            'tpsSecondaryMaximum':
                'For Ford TPS, use 53%. For Toyota ETCS-i, use ~65%',
          },
        );
      });
    });
  });
}
