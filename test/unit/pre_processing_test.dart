import 'package:ini_parser/ini_parser.dart';
import 'package:spec/spec.dart';

void main() {
  group('pre-processing', () {
    const raw = r'''
#unset CAN_COMMANDS
#set NEW_COMMS

  [SomeSection]

#if CUSTOM_SETTING

    someVar = "A";inline comment
    ; comment here
#else
    someVar = "B"
#endif
    anotherVar = "C"
    test = "test"

#if NEW_COMMS
  differentVar = "default"
#else
  differentVar = "shouldn't be here"
#endif

#define invalid_x16 = "TEST", $invalid_x8
#define fullStatus_def  = $fullStatus_def_1, $fullStatus_def_2
#define loadSourceUnits = "kPa",           "% TPS",   "%",         "INVALID"
#define trigger_missingTooth        = 0
''';

    final parser = INIParser(raw);

    test('#if evaluates to true', () async {
      await parser.parse(
        profileSettings: [
          'CUSTOM_SETTING',
          'CAN_COMMANDS',
        ],
      );

      expect(parser.lines.length).toEqual(5);
      expect(parser.lines[0]).toEqual('[SomeSection]');
      expect(parser.lines[1]).toEqual('someVar = "A"');
      expect(parser.lines[2]).toEqual('anotherVar = "C"');
      expect(parser.lines[3]).toEqual('test = "test"');
      expect(parser.lines[4]).toEqual('differentVar = "default"');
      expect(parser.settings).toEqual(
        [
          'CUSTOM_SETTING',
          'NEW_COMMS',
        ],
      );
    });

    test('#if does not evaluate to true', () async {
      await parser.parse(profileSettings: []);

      expect(parser.lines.length).toEqual(5);
      expect(parser.lines[0]).toEqual('[SomeSection]');
      expect(parser.lines[1]).toEqual('someVar = "B"');
      expect(parser.lines[2]).toEqual('anotherVar = "C"');
      expect(parser.lines[3]).toEqual('test = "test"');
      expect(parser.lines[4]).toEqual('differentVar = "default"');
      expect(parser.settings).toEqual(
        [
          'NEW_COMMS',
        ],
      );
    });

    test('#define', () async {
      await parser.parse();

      expect(parser.defines).toEqual(
        {
          'invalid_x16': ['"TEST"', r'$invalid_x8'],
          'fullStatus_def': [r'$fullStatus_def_1', r'$fullStatus_def_2'],
          'loadSourceUnits': ['"kPa"', '"% TPS"', '"%"', '"INVALID"'],
          'trigger_missingTooth': ['0'],
        },
      );
    });
  });
}
