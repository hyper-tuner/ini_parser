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

#define invalid_x8      = "INVALID", "INVALID", "INVALID"
#define invalid_x16 = "TEST", $invalid_x8
#define loadSourceUnits = "kPa",           "% TPS",   "%",         "INVALID"
#define trigger_missingTooth        = 0
#define comparator_def  = "== (equal)",  "!= (different)",  "> (greater)",  ">= (greater/equal)",  "< (smaller)",  "<= (smaller/equal)",  "& (and)",  "^ (xor)"

#define PIN_OUT16inv = "INVALID", "INVALID"
#define CAN_ADDRESS_HEX_inv255 = $PIN_OUT16inv, $PIN_OUT16inv
#define CAN_ADDRESS_HEX_01XX = "0x100", "0x101", "0x102"
#define CAN_ADDRESS_HEX_02XX = "0x200", "0x201", "0x202"
#define CAN_ADDRESS_HEX =  $CAN_ADDRESS_HEX_01XX, $CAN_ADDRESS_HEX_02XX, $CAN_ADDRESS_HEX_inv255
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
          'invalid_x8': [
            'INVALID',
            'INVALID',
            'INVALID',
          ],
          'invalid_x16': [
            'TEST',
            'INVALID',
            'INVALID',
            'INVALID',
          ],
          'loadSourceUnits': ['kPa', '% TPS', '%', 'INVALID'],
          'trigger_missingTooth': ['0'],
          'comparator_def': [
            '== (equal)',
            '!= (different)',
            '> (greater)',
            '>= (greater/equal)',
            '< (smaller)',
            '<= (smaller/equal)',
            '& (and)',
            '^ (xor)',
          ],
          'PIN_OUT16inv': ['INVALID', 'INVALID'],
          'CAN_ADDRESS_HEX_inv255': [
            'INVALID',
            'INVALID',
            'INVALID',
            'INVALID',
          ],
          'CAN_ADDRESS_HEX_01XX': [
            '0x100',
            '0x101',
            '0x102',
          ],
          'CAN_ADDRESS_HEX_02XX': [
            '0x200',
            '0x201',
            '0x202',
          ],
          'CAN_ADDRESS_HEX': [
            '0x100',
            '0x101',
            '0x102',
            '0x200',
            '0x201',
            '0x202',
            'INVALID',
            'INVALID',
            'INVALID',
            'INVALID',
          ],
        },
      );
    });
  });
}
