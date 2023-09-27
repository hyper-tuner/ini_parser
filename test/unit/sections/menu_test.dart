import 'package:ini_parser/ini_parser.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:spec/spec.dart';

void main() {
  group('Menu', () {
    group('success', () {
      const raw = '''
[Menu]
menuDialog = main

   menu = "&Tuning"
      subMenu = std_realtime,       "Realtime Display"
      subMenu = egoControl,         "AFR/O2", 3, { exp }
      subMenu = accelEnrichments,   "Acceleration Enrichment", 2
      subMenu = std_separator
      subMenu = cylinderBankSelect,		"Cylinder bank selection", 0, {isInjectionEnabled == 1}
      groupMenu = "Engine Protection"
        groupChildMenu = engineProtection,          "Common Engine Protection"
        groupChildMenu = std_separator
        groupChildMenu = revLimiterDialog,          "Rev Limiters",             { engineProtectType }
      subMenu = flexFuel,           "Flex Fuel",        2
''';

      test('menu', () async {
        final result = await INIParser(raw).parse();
        final menu = result.menus[0];

        expect(menu.label).toEqual('&Tuning');
        expect(menu.children.length).toEqual(7);
      });

      test('subMenu', () async {
        final result = await INIParser(raw).parse();
        final menu = result.menus[0];
        final subMenu = menu.children[0] as SubMenu;

        expect(subMenu.dialog).toEqual('std_realtime');
        expect(subMenu.label).toEqual('Realtime Display');
        expect(subMenu.enabled).toBeNull();
        expect(subMenu.visible).toBeNull();
      });

      test('subMenu with enabled as int', () async {
        final result = await INIParser(raw).parse();
        final menu = result.menus[0];
        final subMenu = menu.children[1] as SubMenu;

        expect(subMenu.dialog).toEqual('egoControl');
        expect(subMenu.label).toEqual('AFR/O2');
        expect(subMenu.enabled).toEqual('3');
        expect(subMenu.visible).toEqual('{ exp }');
      });

      test('subMenu with enabled as int and visible as expression', () async {
        final result = await INIParser(raw).parse();
        final menu = result.menus[0];
        final subMenu = menu.children[2] as SubMenu;

        expect(subMenu.dialog).toEqual('accelEnrichments');
        expect(subMenu.label).toEqual('Acceleration Enrichment');
        expect(subMenu.enabled).toEqual('2');
        expect(subMenu.visible).toBeNull();
      });

      test('subMenu separator', () async {
        final result = await INIParser(raw).parse();
        final menu = result.menus[0];
        final subMenu = menu.children[3] as SubMenu;

        expect(subMenu.dialog).toEqual('std_separator');
        expect(subMenu.label).toEqual('std_separator');
        expect(subMenu.enabled).toBeNull();
        expect(subMenu.visible).toBeNull();
      });

      test('subMenu with expression', () async {
        final result = await INIParser(raw).parse();
        final menu = result.menus[0];
        final subMenu = menu.children[4] as SubMenu;

        expect(subMenu.dialog).toEqual('cylinderBankSelect');
        expect(subMenu.label).toEqual('Cylinder bank selection');
        expect(subMenu.enabled).toEqual('0');
        expect(subMenu.visible).toEqual('{isInjectionEnabled == 1}');
      });

      test('groupMenu', () async {
        final result = await INIParser(raw).parse();
        final menu = result.menus[0];
        final groupMenu = menu.children[5] as GroupMenu;

        expect(groupMenu.label).toEqual('Engine Protection');
        expect(groupMenu.children.length).toEqual(3);
      });

      test('groupChildMenu without expression', () async {
        final result = await INIParser(raw).parse();
        final menu = result.menus[0];
        final groupMenu = menu.children[5] as GroupMenu;
        final groupChildMenu = groupMenu.children[0];

        expect(groupChildMenu.dialog).toEqual('engineProtection');
        expect(groupChildMenu.label).toEqual('Common Engine Protection');
        expect(groupChildMenu.enabled).toBeNull();
        expect(groupChildMenu.visible).toBeNull();
      });

      test('groupChildMenu separator', () async {
        final result = await INIParser(raw).parse();
        final menu = result.menus[0];
        final groupMenu = menu.children[5] as GroupMenu;
        final groupChildMenu = groupMenu.children[1];

        expect(groupChildMenu.dialog).toEqual('std_separator');
        expect(groupChildMenu.label).toEqual('std_separator');
        expect(groupChildMenu.enabled).toBeNull();
        expect(groupChildMenu.visible).toBeNull();
      });

      test('groupChildMenu with expression', () async {
        final result = await INIParser(raw).parse();
        final menu = result.menus[0];
        final groupMenu = menu.children[5] as GroupMenu;
        final groupChildMenu = groupMenu.children[2];

        expect(groupChildMenu.dialog).toEqual('revLimiterDialog');
        expect(groupChildMenu.label).toEqual('Rev Limiters');
        expect(groupChildMenu.enabled).toEqual('{ engineProtectType }');
        expect(groupChildMenu.visible).toBeNull();
      });

      test('subMenu after groupChildMenu', () async {
        final result = await INIParser(raw).parse();
        final menu = result.menus[0];
        final subMenu = menu.children[6] as SubMenu;

        expect(subMenu.dialog).toEqual('flexFuel');
        expect(subMenu.label).toEqual('Flex Fuel');
        expect(subMenu.enabled).toEqual('2');
        expect(subMenu.visible).toBeNull();
      });
    });

    group('failure', () {
      const raw = '''
[Menu]
  menu = "&Tuning"
    subMenu =
''';
      test('ParserException', () async {
        expect(() => INIParser(raw).parse()).throws.isException();
      });
    });
  });
}
