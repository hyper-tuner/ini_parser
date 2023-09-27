import 'package:ini_parser/ini_parser.dart';
import 'package:spec/spec.dart';

void main() {
  group('ControllerCommands', () {
    group('success', () {
      const raw = r'''
[ControllerCommands]
  cmd_test_spk1  = "Z\x00\x12\x00\x01"
  cmd_test_spk2  = "Z\x00\x12\x00\x02"
''';

      test('commands', () async {
        final result = await INIParser(raw).parse();
        final command1 = result.controllerCommands;

        expect(command1['cmd_test_spk1']).toEqual(r'Z\x00\x12\x00\x01');
        expect(command1['cmd_test_spk2']).toEqual(r'Z\x00\x12\x00\x02');
      });
    });

    group('failure', () {
      const raw = '''
[ControllerCommands]
  test =
''';
      test('ParserException', () async {
        expect(() => INIParser(raw).parse()).throws.isException();
      });
    });
  });
}
