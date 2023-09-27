import 'package:ini_parser/ini_parser.dart';
import 'package:spec/spec.dart';

void main() {
  group('TableEditor', () {
    group('success', () {
      const raw = '''
[TableEditor]
table = throttle2TrimTbl, throttle2TrimMap,  "ETB #2 Trim",     1
  topicHelp = "http://speeduino.com/wiki/index.php/Tuning"
  xBins       = alsIgnRetardrpmBins,  RPMValue
  yBins       = alsIgnRetardLoadBins,  TPSValue
  zBins       = ALSTimingRetardTable
  xyLabels    = "RPM", "Fuel Load: "
  gridHeight  = 4.0
  gridOrient  = 250,   0, 340 ; Space 123 rotation of grid in degrees.
  upDownLabel = "(RICHER)", "(LEANER)"

table = idleVeTableTbl, idleVeTable, "Idle VE"
  xBins  = idleVeRpmBins,  RPMValue
  yBins  = idleVeLoadBins, veTableYAxis
  zBins  = idleVeTable
  gridOrient  = 250,  0, 340 ; Space 123 rotation of grid in degrees.
  upDownLabel = "(RICHER)", "(LEANER)"
''';

      test('table with all attributes', () async {
        final result = await INIParser(raw).parse();
        final table = result.tables[0];

        expect(table.name).toEqual('throttle2TrimTbl');
        expect(table.map).toEqual('throttle2TrimMap');
        expect(table.label).toEqual('ETB #2 Trim');
        expect(table.page).toEqual(1);
        expect(table.topicHelp)
            .toEqual('http://speeduino.com/wiki/index.php/Tuning');
        expect(table.xBins).toEqual(['alsIgnRetardrpmBins', 'RPMValue']);
        expect(table.yBins).toEqual(['alsIgnRetardLoadBins', 'TPSValue']);
        expect(table.zBins).toEqual(['ALSTimingRetardTable']);
        expect(table.xyLabels).toEqual(['RPM', 'Fuel Load:']);
        expect(table.gridHeight).toEqual(4);
        expect(table.gridOrient).toEqual([250, 0, 340]);
        expect(table.upDownLabels).toEqual(['(RICHER)', '(LEANER)']);
      });

      test('table without a page', () async {
        final result = await INIParser(raw).parse();
        final table = result.tables[1];

        expect(table.name).toEqual('idleVeTableTbl');
        expect(table.map).toEqual('idleVeTable');
        expect(table.label).toEqual('Idle VE');
        expect(table.page).toEqual(0);
      });
    });

    group('failure', () {
      const raw = '''
[TableEditor]
  table =
''';
      test('ParserException', () async {
        expect(() => INIParser(raw).parse()).throws.isException();
      });
    });
  });
}
