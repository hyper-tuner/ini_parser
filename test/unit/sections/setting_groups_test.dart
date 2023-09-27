import 'package:ini_parser/ini_parser.dart';
import 'package:spec/spec.dart';

void main() {
  group('SettingGroups', () {
    group('success', () {
      const raw = '''
[SettingGroups]
    settingGroup = pressure_units, "Pressure Display"
      settingOption = DEFAULT, "PSI"
      settingOption = pressure_bar, "BAR"

    settingGroup = NEW_COMMS, "Use new comms protocol"
''';

      test('settingGroups', () async {
        final result = await INIParser(raw).parse();
        final settingGroups = result.settingGroups;

        expect(settingGroups.length).toEqual(2);
      });

      test('settingGroups with options', () async {
        final result = await INIParser(raw).parse();
        final settingGroup = result.settingGroups[0];

        expect(settingGroup.name).toEqual('pressure_units');
        expect(settingGroup.label).toEqual('Pressure Display');
        expect(settingGroup.options.length).toEqual(2);

        expect(settingGroup.options).toEqual({
          'DEFAULT': 'PSI',
          'pressure_bar': 'BAR',
        });
      });

      test('settingGroups without any options', () async {
        final result = await INIParser(raw).parse();
        final settingGroup = result.settingGroups[1];

        expect(settingGroup.name).toEqual('NEW_COMMS');
        expect(settingGroup.label).toEqual('Use new comms protocol');
        expect(settingGroup.options.length).toEqual(0);
      });
    });

    group('failure', () {
      const raw = '''
[SettingGroups]
    settingGroup = test
''';
      test('ParserException', () async {
        expect(() => INIParser(raw).parse()).throws.isException();
      });
    });
  });
}
