// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  const threshold = 100.0;
  final file = File('coverage/summary.txt');
  final lines = file.readAsStringSync();
  final match = RegExp(r'([\d.]+)%').firstMatch(lines);

  if (match == null) {
    throw Exception('Could not find coverage percentage');
  }

  final percentage = double.parse(match.group(1)!);

  if (percentage < 99.4) {
    print('❌ Current coverage $percentage% is below threshold of $threshold%');
    exit(1);
  }

  print('✅ Coverage $percentage%');
}
