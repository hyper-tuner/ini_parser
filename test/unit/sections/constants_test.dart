import 'package:ini_parser/ini_parser.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:spec/spec.dart';

void main() {
  group('Constants', () {
    group('success', () {
      const raw = r'''
[Constants]
  endianness = little
  nPages = 15
  pageSize = 128,   288,     288,    128,     288,    128,    240,     384,    192,    192,    288,    192,    128,    288,    256
  pageIdentifier = "$tsCanId\x01   ", "$tsCanId\x02", "$tsCanId\x03", "$tsCanId\x04", "$tsCanId\x05", "$tsCanId\x06", "$tsCanId\x07", "$tsCanId\x08", "$tsCanId\x09", "$tsCanId\x0A", "$tsCanId\x0B", "$tsCanId\x0C", "$tsCanId\x0D", "$tsCanId\x0E", "$tsCanId\x0F"

page = 1
  aseTaperTime  = scalar, U08,       0,         "S",        0.1,       0.0,   0.0,    25.5,      1
  divider       = scalar, U08,      25,        "",          1.0,       0.0
  aeMode        = bits,   U08,       3, [0:1],  "TPS", "MAP", "INVALID", "INVALID"
  iat_adcChannel = bits, U08, 348, [0:5], 0="NONE", 1="18 - AN temp 1",13="19 - AN volt 4",5="28 - AN volt 10, Aux Reuse"
  cltAdvValues  = array,  S08,     77, [ 6x6],   "deg",    1.0,     -15,  -15,   15,      0

page = 2
  fuelLoadBins = array,  U08,   272, [  16], { bitStringValue(algorithmUnits ,  algorithm) },       fuelLoadRes,      0.0,   0.0,   {fuelLoadMax},      fuelDecimalRes
  engineMake = string, ASCII, 1092, 32
  unusedBits4_123 = bits,   U08,      123, [3:7]
  rtc_trim        = scalar,  S08,    123,               "ppm",      1, 0, -127, +127, 0
  inj4CylPairing  = bits,   U08,      123, [1:2],  "1+3 & 2+4", "1+4 & 2+3", "INVALID", "INVALID"
''';

      test('config', () async {
        final result = await INIParser(raw).parse();

        expect(result.constants.config.endianness).toEqual('little');
        expect(result.constants.config.nPages).toEqual(15);
        expect(result.constants.config.pageSizes).toEqual([
          128,
          288,
          288,
          128,
          288,
          128,
          240,
          384,
          192,
          192,
          288,
          192,
          128,
          288,
          256,
        ]);
        expect(result.constants.config.pageIdentifiers).toEqual([
          r'$tsCanId\x01',
          r'$tsCanId\x02',
          r'$tsCanId\x03',
          r'$tsCanId\x04',
          r'$tsCanId\x05',
          r'$tsCanId\x06',
          r'$tsCanId\x07',
          r'$tsCanId\x08',
          r'$tsCanId\x09',
          r'$tsCanId\x0A',
          r'$tsCanId\x0B',
          r'$tsCanId\x0C',
          r'$tsCanId\x0D',
          r'$tsCanId\x0E',
          r'$tsCanId\x0F',
        ]);
      });

      test('scalar long', () async {
        final result = await INIParser(raw).parse();
        final constant =
            result.constants.pages[0].constants[0] as ConstantScalar;

        expect(result.constants.pages.length).toEqual(2);
        expect(result.constants.pages[0].number).toEqual(1);
        expect(constant.name).toEqual('aseTaperTime');
        expect(constant.type).toEqual(ConstantType.scalar);
        expect(constant.size).toEqual(ConstantSize.u08);
        expect(constant.offset).toEqual(0);
        expect(constant.units).toEqual('S');
        expect(constant.scale).toEqual('0.1');
        expect(constant.transform).toEqual('0.0');
        expect(constant.min).toEqual('0.0');
        expect(constant.max).toEqual('25.5');
        expect(constant.digits).toEqual('1');
      });

      test('scalar short', () async {
        final result = await INIParser(raw).parse();
        final constant =
            result.constants.pages[0].constants[1] as ConstantScalar;

        expect(result.constants.pages.length).toEqual(2);
        expect(constant.name).toEqual('divider');
        expect(constant.type).toEqual(ConstantType.scalar);
        expect(constant.size).toEqual(ConstantSize.u08);
        expect(constant.offset).toEqual(25);
        expect(constant.units).toEqual('');
        expect(constant.scale).toEqual('1.0');
        expect(constant.transform).toEqual('0.0');
        expect(constant.min).toBeNull();
        expect(constant.max).toBeNull();
        expect(constant.digits).toBeNull();
      });

      test('bits - regular list', () async {
        final result = await INIParser(raw).parse();
        final constant = result.constants.pages[0].constants[2] as ConstantBits;

        expect(result.constants.pages.length).toEqual(2);
        expect(constant.name).toEqual('aeMode');
        expect(constant.type).toEqual(ConstantType.bits);
        expect(constant.size).toEqual(ConstantSize.u08);
        expect(constant.offset).toEqual(3);
        expect(constant.bits.low).toEqual(0);
        expect(constant.bits.high).toEqual(1);
        expect(constant.options).toEqual({
          0: 'TPS',
          1: 'MAP',
          2: 'INVALID',
          3: 'INVALID',
        });
      });

      test('bits - list with keys', () async {
        final result = await INIParser(raw).parse();
        final constant = result.constants.pages[0].constants[3] as ConstantBits;

        expect(result.constants.pages.length).toEqual(2);
        expect(constant.name).toEqual('iat_adcChannel');
        expect(constant.type).toEqual(ConstantType.bits);
        expect(constant.size).toEqual(ConstantSize.u08);
        expect(constant.offset).toEqual(348);
        expect(constant.bits.low).toEqual(0);
        expect(constant.bits.high).toEqual(5);
        expect(constant.options).toEqual({
          0: 'NONE',
          1: '18 - AN temp 1',
          13: '19 - AN volt 4',
          5: '28 - AN volt 10, Aux Reuse',
        });
      });

      test('array', () async {
        final result = await INIParser(raw).parse();
        final constant =
            result.constants.pages[0].constants[4] as ConstantArray;

        expect(result.constants.pages.length).toEqual(2);
        expect(constant.name).toEqual('cltAdvValues');
        expect(constant.type).toEqual(ConstantType.array);
        expect(constant.size).toEqual(ConstantSize.s08);
        expect(constant.offset).toEqual(77);
        expect(constant.shape.columns).toEqual(6);
        expect(constant.shape.rows).toEqual(6);
        expect(constant.units).toEqual('deg');
        expect(constant.scale).toEqual('1.0');
        expect(constant.transform).toEqual('-15');
        expect(constant.min).toEqual('-15');
        expect(constant.max).toEqual('15');
        expect(constant.digits).toEqual('0');
      });

      test('array with expressions', () async {
        final result = await INIParser(raw).parse();
        final constant =
            result.constants.pages[1].constants[0] as ConstantArray;

        expect(result.constants.pages[1].number).toEqual(2);
        expect(result.constants.pages.length).toEqual(2);
        expect(constant.name).toEqual('fuelLoadBins');
        expect(constant.type).toEqual(ConstantType.array);
        expect(constant.size).toEqual(ConstantSize.u08);
        expect(constant.offset).toEqual(272);
        expect(constant.shape.columns).toEqual(16);
        expect(constant.shape.rows).toBeNull();
        expect(constant.units)
            .toEqual('{ bitStringValue(algorithmUnits , algorithm) }');
        expect(constant.scale).toEqual('fuelLoadRes');
        expect(constant.transform).toEqual('0.0');
        expect(constant.min).toEqual('0.0');
        expect(constant.max).toEqual('{fuelLoadMax}');
        expect(constant.digits).toEqual('fuelDecimalRes');
      });

      test('string', () async {
        final result = await INIParser(raw).parse();
        final constant =
            result.constants.pages[1].constants[1] as ConstantString;

        expect(result.constants.pages[1].number).toEqual(2);
        expect(result.constants.pages.length).toEqual(2);
        expect(constant.name).toEqual('engineMake');
        expect(constant.type).toEqual(ConstantType.string);
        expect(constant.size).toEqual(ConstantSize.ascii);
        expect(constant.offset).toEqual(1092);
        expect(constant.length).toEqual(32);
      });

      test('bits with no options', () async {
        final result = await INIParser(raw).parse();
        final constant = result.constants.pages[1].constants[2] as ConstantBits;

        expect(constant.name).toEqual('unusedBits4_123');
        expect(constant.type).toEqual(ConstantType.bits);
        expect(constant.size).toEqual(ConstantSize.u08);
        expect(constant.offset).toEqual(123);
        expect(constant.bits.low).toEqual(3);
        expect(constant.bits.high).toEqual(7);
        expect(constant.options).toEqual({});
      });

      test('edge cases', () async {
        final result = await INIParser(raw).parse();
        final constant1 =
            result.constants.pages[1].constants[3] as ConstantScalar;

        expect(constant1.name).toEqual('rtc_trim');
        expect(constant1.type).toEqual(ConstantType.scalar);
        expect(constant1.size).toEqual(ConstantSize.s08);
        expect(constant1.offset).toEqual(123);
        expect(constant1.units).toEqual('ppm');
        expect(constant1.scale).toEqual('1');
        expect(constant1.transform).toEqual('0');
        expect(constant1.min).toEqual('-127');
        expect(constant1.max).toEqual('+127');
        expect(constant1.digits).toEqual('0');

        final constant2 =
            result.constants.pages[1].constants[4] as ConstantBits;

        expect(constant2.name).toEqual('inj4CylPairing');
        expect(constant2.type).toEqual(ConstantType.bits);
        expect(constant2.size).toEqual(ConstantSize.u08);
        expect(constant2.offset).toEqual(123);
        expect(constant2.bits.low).toEqual(1);
        expect(constant2.bits.high).toEqual(2);
        expect(constant2.options).toEqual({
          0: '1+3 & 2+4',
          1: '1+4 & 2+3',
          2: 'INVALID',
          3: 'INVALID',
        });
      });
    });

    group('failure', () {
      group('invalid definition', () {
        const raw = '''
[Constants]
  test =
''';
        test('ParserException', () async {
          expect(() => INIParser(raw).parse()).throws.isException();
        });
      });

      group('invalid type', () {
        const raw = '''
[Constants]
page = 1
  invalid = bats, U08, 3, [0:1], "TPS", "MAP", "INVALID", "INVALID"
''';
        test('Unknown ConstantType', () async {
          expect(() => INIParser(raw).parse()).throws.isException();
        });
      });

      group('invalid size', () {
        const raw = '''
[Constants]
page = 1
  invalid = bits, X08, 3, [0:1], "TPS", "MAP", "INVALID", "INVALID"
''';
        test('Unknown ConstantSize', () async {
          expect(() => INIParser(raw).parse()).throws.isException();
        });
      });
    });
  });
}
