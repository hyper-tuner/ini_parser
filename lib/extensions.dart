import 'package:ini_parser/models/ini_config.dart';

extension Parsing on String {
  int parseInt() {
    return int.parse(this);
  }

  double parseDouble() {
    return double.parse(this);
  }

  bool? parseBool() {
    switch (sanitize()) {
      case 'true':
        return true;
      case 'false':
        return false;
      default:
        return null;
    }
  }

  String clearString() {
    return replaceAll('"', '').sanitize();
  }

  String sanitize() {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool isExpression() {
    return startsWith('{') && endsWith('}');
  }

  ConstantType toConstantType() {
    switch (this) {
      case 'scalar':
        return ConstantType.scalar;
      case 'bits':
        return ConstantType.bits;
      case 'array':
        return ConstantType.array;
      case 'string':
        return ConstantType.string;
      default:
        throw Exception('Unknown ConstantType: $this');
    }
  }

  ConstantSize toConstantSize() {
    switch (this) {
      case 'U08':
        return ConstantSize.u08;
      case 'S08':
        return ConstantSize.s08;
      case 'U16':
        return ConstantSize.u16;
      case 'S16':
        return ConstantSize.s16;
      case 'U32':
        return ConstantSize.u32;
      case 'S32':
        return ConstantSize.s32;
      case 'S64':
        return ConstantSize.s64;
      case 'F32':
        return ConstantSize.f32;
      case 'ASCII':
        return ConstantSize.ascii;
      default:
        throw Exception('Unknown ConstantSize: $this');
    }
  }
}
