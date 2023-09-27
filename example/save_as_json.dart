import 'dart:convert';
import 'dart:io';

import 'package:ini_parser/ini_parser.dart';
import 'package:path/path.dart' as p;

void main() async {
  final timer = Stopwatch()..start();
  const fileNames = [
    {
      'ecosystem': 'speeduino',
      'name': '202207',
    },
    {
      'ecosystem': 'fome',
      'name': 'fome_proteus_f4',
    },
  ];

  for (final fileName in fileNames) {
    final raw = File(
      p.join(
        Directory.current.path,
        'test/data/${fileName['ecosystem']}/ini/${fileName['name']}.ini',
      ),
    ).readAsStringSync();
    final parser = INIParser(raw);

    final config = await parser.parse();

    const encoder = JsonEncoder.withIndent('  ');
    final json = encoder.convert(config);

    File(
      p.join(
        Directory.current.path,
        'test/data/${fileName['ecosystem']}/json/${fileName['name']}.json',
      ),
    ).writeAsStringSync(json);
  }

  // ignore: avoid_print
  print('Done in ${timer.elapsedMilliseconds}ms');
}
