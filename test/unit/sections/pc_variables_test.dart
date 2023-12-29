import 'package:ini_parser/ini_parser.dart';
import 'package:ini_parser/models/ini_config.dart';
import 'package:spec/spec.dart';

void main() {
  group('PcVariables', () {
    group('success', () {
      const raw = r'''
[PcVariables]
    tuneCrcPcVariable = continuousChannelValue, tuneCrc16

    bathigh     = scalar,   U08,    "Volts",  .1, 0, 0, 25.5,   1
    fuelLoadMax = scalar, U08, "", 1, 0, 0, 511, 0
    debugFieldF4List = bits,   U08,   [0:7], "Current TPS<>TPS", "Alt: I Gain",             "Extra Fuel",         "",          "Idle: I Gain",                   "Idle df4",            "        ",                  "",           "VVT1: I Gain",            "",                  "",                       "Ign PID Adj"
    gearCountArray = array, S08, [10], "Gear", 1, 0, -1, { 10 - 2 }, 0, noMsqSave
    wueAFR         = array, S16,  [10], "AFR", 0.1,   0.0, -4.0, 4.0, 1
    AUXin00Alias    = string, ASCII, 20
    iat_adcChannel = bits, U08, [0:5], 0="NONE", 1="18 - AN temp 1",13="19 - AN volt 4",5="28 - AN volt 10, Aux Reuse"

#define loadSourceNames = "MAP", "TPS", "IMAP/EMAP", "INVALID",   "INVALID", "INVALID", "INVALID", "INVALID"

    algorithmNames = bits,    U08,   [0:2], $loadSourceNames
''';

      test('scalar long', () async {
        final result = await INIParser(raw).parse();
        final variable = result.pcVariables[0] as PcVariableScalar;

        expect(variable.name).toEqual('bathigh');
        expect(variable.type).toEqual(ConstantType.scalar);
        expect(variable.size).toEqual(ConstantSize.u08);
        expect(variable.units).toEqual('Volts');
        expect(variable.scale).toEqual('.1');
        expect(variable.transform).toEqual('0');
        expect(variable.min).toEqual('0');
        expect(variable.max).toEqual('25.5');
        expect(variable.digits).toEqual('1');
      });

      test('scalar short', () async {
        final result = await INIParser(raw).parse();
        final variable = result.pcVariables[1] as PcVariableScalar;

        expect(variable.name).toEqual('fuelLoadMax');
        expect(variable.type).toEqual(ConstantType.scalar);
        expect(variable.size).toEqual(ConstantSize.u08);
        expect(variable.units).toEqual('');
        expect(variable.scale).toEqual('1');
        expect(variable.transform).toEqual('0');
        expect(variable.min).toEqual('0');
        expect(variable.max).toEqual('511');
        expect(variable.digits).toEqual('0');
      });

      test('bits - regular list', () async {
        final result = await INIParser(raw).parse();
        final variable = result.pcVariables[2] as PcVariableBits;

        expect(variable.name).toEqual('debugFieldF4List');
        expect(variable.type).toEqual(ConstantType.bits);
        expect(variable.size).toEqual(ConstantSize.u08);
        expect(variable.bits.low).toEqual(0);
        expect(variable.bits.high).toEqual(7);
        expect(variable.options).toEqual(
          {
            0: 'Current TPS<>TPS',
            1: 'Alt: I Gain',
            2: 'Extra Fuel',
            3: '',
            4: 'Idle: I Gain',
            5: 'Idle df4',
            6: '',
            7: '',
            8: 'VVT1: I Gain',
            9: '',
            10: '',
            11: 'Ign PID Adj',
          },
        );
      });

      test('array', () async {
        final result = await INIParser(raw).parse();
        final variable = result.pcVariables[3] as PcVariableArray;

        expect(variable.name).toEqual('gearCountArray');
        expect(variable.type).toEqual(ConstantType.array);
        expect(variable.size).toEqual(ConstantSize.s08);
        expect(variable.shape.columns).toEqual(10);
        expect(variable.shape.rows).toBeNull();
        expect(variable.units).toEqual('Gear');
        expect(variable.scale).toEqual('1');
        expect(variable.transform).toEqual('0');
        expect(variable.min).toEqual('-1');
        expect(variable.max).toEqual('{ 10 - 2 }');
        expect(variable.digits).toEqual('0');
        expect(variable.noSave).toEqual(true);
      });

      test('array with save flag and expression', () async {
        final result = await INIParser(raw).parse();
        final variable = result.pcVariables[3] as PcVariableArray;

        expect(variable.name).toEqual('gearCountArray');
        expect(variable.type).toEqual(ConstantType.array);
        expect(variable.size).toEqual(ConstantSize.s08);
        expect(variable.shape.columns).toEqual(10);
        expect(variable.shape.rows).toBeNull();
        expect(variable.units).toEqual('Gear');
        expect(variable.scale).toEqual('1');
        expect(variable.transform).toEqual('0');
        expect(variable.min).toEqual('-1');
        expect(variable.max).toEqual('{ 10 - 2 }');
        expect(variable.digits).toEqual('0');
        expect(variable.noSave).toEqual(true);
      });

      test('array w/o save flag', () async {
        final result = await INIParser(raw).parse();
        final variable = result.pcVariables[4] as PcVariableArray;

        expect(variable.name).toEqual('wueAFR');
        expect(variable.type).toEqual(ConstantType.array);
        expect(variable.size).toEqual(ConstantSize.s16);
        expect(variable.shape.columns).toEqual(10);
        expect(variable.shape.rows).toBeNull();
        expect(variable.units).toEqual('AFR');
        expect(variable.scale).toEqual('0.1');
        expect(variable.transform).toEqual('0.0');
        expect(variable.min).toEqual('-4.0');
        expect(variable.max).toEqual('4.0');
        expect(variable.digits).toEqual('1');
        expect(variable.noSave).toEqual(false);
      });

      test('string', () async {
        final result = await INIParser(raw).parse();
        final variable = result.pcVariables[5] as PcVariableString;

        expect(variable.name).toEqual('AUXin00Alias');
        expect(variable.type).toEqual(ConstantType.string);
        expect(variable.size).toEqual(ConstantSize.ascii);
        expect(variable.length).toEqual(20);
      });

      test('bits - list with keys', () async {
        final result = await INIParser(raw).parse();
        final variable = result.pcVariables[6] as PcVariableBits;

        expect(variable.name).toEqual('iat_adcChannel');
        expect(variable.type).toEqual(ConstantType.bits);
        expect(variable.size).toEqual(ConstantSize.u08);
        expect(variable.bits.low).toEqual(0);
        expect(variable.bits.high).toEqual(5);
        expect(variable.options).toEqual({
          0: 'NONE',
          1: '18 - AN temp 1',
          13: '19 - AN volt 4',
          5: '28 - AN volt 10, Aux Reuse',
        });
      });

      test('bits - with defined options', () async {
        final result = await INIParser(raw).parse();
        final variable = result.pcVariables[7] as PcVariableBits;

        expect(variable.name).toEqual('algorithmNames');
        expect(variable.type).toEqual(ConstantType.bits);
        expect(variable.size).toEqual(ConstantSize.u08);
        expect(variable.bits.low).toEqual(0);
        expect(variable.bits.high).toEqual(2);
        expect(variable.options).toEqual(
          {
            0: 'MAP',
            1: 'TPS',
            2: 'IMAP/EMAP',
            3: 'INVALID',
            4: 'INVALID',
            5: 'INVALID',
            6: 'INVALID',
            7: 'INVALID'
          },
        );
      });
    });

    group('failure', () {
      group('invalid definition', () {
        const raw = '''
      [PcVariables]
        test =
      ''';
        test('ParserException', () async {
          expect(() => INIParser(raw).parse()).throws.isException();
        });
      });

      group('invalid type', () {
        const raw = '''
[PcVariables]
  invalid = bats, S08, 36, "deg", 1.000, 0.000
''';
        test('Unknown ConstantType', () async {
          expect(() => INIParser(raw).parse()).throws.isException();
        });
      });
    });
  });
}
