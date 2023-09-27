import 'package:ini_parser/ini_parser.dart';
import 'package:spec/spec.dart';

void main() {
  group('FrontPage', () {
    group('success', () {
      const raw = '''
[FrontPage]
   gauge1 = tachometer
   gauge2 = throttleGauge
   gauge3 = pulseWidthGauge
   gauge4 = dutyCycleGauge
   gauge5 = mapGauge
   gauge6 = iatGauge
   gauge7 = cltGauge
   gauge8 = gammaEnrichGauge

   indicator = { running            }, "Not Running",   "Running",       white, black, green,    black
   indicator = { (tps > tpsflood) && (rpm < crankRPM) }, "FLOOD OFF", "FLOOD CLEAR"
''';

      test('gauges and indicators', () async {
        final result = await INIParser(raw).parse();
        final frontPage = result.frontPage;

        expect(frontPage.gauges).toEqual([
          'tachometer',
          'throttleGauge',
          'pulseWidthGauge',
          'dutyCycleGauge',
          'mapGauge',
          'iatGauge',
          'cltGauge',
          'gammaEnrichGauge',
        ]);

        final indicator1 = frontPage.indicators[0];

        expect(indicator1.expression).toEqual('{ running }');
        expect(indicator1.labelOff).toEqual('Not Running');
        expect(indicator1.labelOn).toEqual('Running');
        expect(indicator1.colors!.offBackground).toEqual('white');
        expect(indicator1.colors!.offForeground).toEqual('black');
        expect(indicator1.colors!.onBackground).toEqual('green');
        expect(indicator1.colors!.onForeground).toEqual('black');

        final indicator2 = frontPage.indicators[1];

        expect(indicator2.expression).toEqual(
          '{ (tps > tpsflood) && (rpm < crankRPM) }',
        );
        expect(indicator2.labelOff).toEqual('FLOOD OFF');
        expect(indicator2.labelOn).toEqual('FLOOD CLEAR');
        expect(indicator2.colors).toBeNull();
      });
    });

    group('failure', () {
      const raw = '''
[FrontPage]
  gauge0 =
''';
      test('ParserException', () async {
        expect(() => INIParser(raw).parse()).throws.isException();
      });
    });
  });
}
