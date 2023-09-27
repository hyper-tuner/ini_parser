// ignore_for_file: lines_longer_than_80_chars

import 'package:ini_parser/ini_parser.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:spec/spec.dart';

void main() {
  group('OutputChannels', () {
    group('success', () {
      const raw = '''
[OutputChannels]
  ochGetCommand    = "r\$tsCanId\x30%2o%2c"
  ochBlockSize     =  122

  flexIgnCor = scalar,   S08,    36, "deg",    1.000, 0.000
  iatRaw     = scalar,   U08,    6, "°C",     1.000, 0.000
  TPSdot     = scalar,   U08,    22, "%/s",    10.00, 0.000
  rpmDOT     = scalar,   S16,    32, "rpm/s",  1.000, 0.000
  tps        = scalar,   U08,    24, "%",      0.500, 0.000

  idleLoad  = scalar,   U08,    37, { bitStringValue( idleUnits , iacAlgorithm  ) },    { (iacAlgorithm == 2 || iacAlgorithm == 3 || iacAlgorithm == 6 || iacMaxSteps <= 255) ? 1.000 : 2.000 }, 0.000
  test = bits,    U08,    38, [ 0:7 ]
  coolant  = { (coolantRaw - 40) * 1.8 + 32 }
  tpsFrom = scalar, F32, 1024
#endif
''';
      final parser = INIParser(raw);

      test('config', () async {
        final result = await parser.parse();

        expect(result.outputChannels.config.ochGetCommand)
            .toEqual(r'r$tsCanId0%2o%2c');
        expect(result.outputChannels.config.ochBlockSize).toEqual(122);
      });

      test('scalar', () async {
        final result = await parser.parse();

        final flex = result.outputChannels.channels[0] as OutputChannelScalar;
        expect(flex.name).toEqual('flexIgnCor');
        expect(flex.type).toEqual(ConstantType.scalar);
        expect(flex.size).toEqual(ConstantSize.s08);
        expect(flex.offset).toEqual(36);
        expect(flex.units).toEqual('deg');
        expect(flex.scale).toEqual('1.000');
        expect(flex.transform).toEqual('0.000');

        final iat = result.outputChannels.channels[1] as OutputChannelScalar;
        expect(iat.name).toEqual('iatRaw');
        expect(iat.type).toEqual(ConstantType.scalar);
        expect(iat.size).toEqual(ConstantSize.u08);
        expect(iat.offset).toEqual(6);
        expect(iat.units).toEqual('°C');
        expect(iat.scale).toEqual('1.000');
        expect(iat.transform).toEqual('0.000');

        final tpsDot = result.outputChannels.channels[2] as OutputChannelScalar;
        expect(tpsDot.name).toEqual('TPSdot');
        expect(tpsDot.type).toEqual(ConstantType.scalar);
        expect(tpsDot.size).toEqual(ConstantSize.u08);
        expect(tpsDot.offset).toEqual(22);
        expect(tpsDot.units).toEqual('%/s');
        expect(tpsDot.scale).toEqual('10.00');
        expect(tpsDot.transform).toEqual('0.000');

        final rpmDot = result.outputChannels.channels[3] as OutputChannelScalar;
        expect(rpmDot.name).toEqual('rpmDOT');
        expect(rpmDot.type).toEqual(ConstantType.scalar);
        expect(rpmDot.size).toEqual(ConstantSize.s16);
        expect(rpmDot.offset).toEqual(32);
        expect(rpmDot.units).toEqual('rpm/s');
        expect(rpmDot.scale).toEqual('1.000');
        expect(rpmDot.transform).toEqual('0.000');

        final tps = result.outputChannels.channels[4] as OutputChannelScalar;
        expect(tps.name).toEqual('tps');
        expect(tps.type).toEqual(ConstantType.scalar);
        expect(tps.size).toEqual(ConstantSize.u08);
        expect(tps.offset).toEqual(24);
        expect(tps.units).toEqual('%');
        expect(tps.scale).toEqual('0.500');
        expect(tps.transform).toEqual('0.000');
      });

      test('scalar with expressions', () async {
        final result = await parser.parse();
        final channel =
            result.outputChannels.channels[5] as OutputChannelScalar;

        expect(channel.name).toEqual('idleLoad');
        expect(channel.type).toEqual(ConstantType.scalar);
        expect(channel.size).toEqual(ConstantSize.u08);
        expect(channel.offset).toEqual(37);
        expect(channel.units)
            .toEqual('{ bitStringValue( idleUnits , iacAlgorithm ) }');
        expect(channel.scale).toEqual(
          '{ (iacAlgorithm == 2 || iacAlgorithm == 3 || iacAlgorithm == 6 || iacMaxSteps <= 255) ? 1.000 : 2.000 }',
        );
        expect(channel.transform).toEqual('0.000');
      });

      test('bits', () async {
        final result = await parser.parse();
        final channel = result.outputChannels.channels[6] as OutputChannelBits;

        expect(channel.name).toEqual('test');
        expect(channel.type).toEqual(ConstantType.bits);
        expect(channel.size).toEqual(ConstantSize.u08);
        expect(channel.offset).toEqual(38);
        expect(channel.bits.low).toEqual(0);
        expect(channel.bits.high).toEqual(7);
      });

      test('expression', () async {
        final result = await parser.parse();
        final channel =
            result.outputChannels.channels[7] as OutputChannelDynamic;

        expect(channel.name).toEqual('coolant');
        expect(channel.expression).toEqual('{ (coolantRaw - 40) * 1.8 + 32 }');
      });

      test('scalar short version', () async {
        final result = await parser.parse();
        final channel =
            result.outputChannels.channels[8] as OutputChannelScalar;

        expect(channel.name).toEqual('tpsFrom');
        expect(channel.type).toEqual(ConstantType.scalar);
        expect(channel.size).toEqual(ConstantSize.f32);
        expect(channel.offset).toEqual(1024);
      });
    });

    group('failure', () {
      group('invalid definition', () {
        const raw = '''
      [OutputChannels]
        test =
      ''';
        test('ParserException', () async {
          expect(() => INIParser(raw).parse()).throws.isException();
        });
      });

      group('invalid type', () {
        const raw = '''
[OutputChannels]
  invalid = array, S08, 36, "deg", 1.000, 0.000
''';
        test('Unknown ConstantType', () async {
          expect(() => INIParser(raw).parse()).throws.isException();
        });
      });
    });
  });
}
