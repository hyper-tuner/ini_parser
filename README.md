[![codecov](https://codecov.io/github/hyper-tuner/ini_parser/graph/badge.svg?token=XJO6OG177G)](https://codecov.io/github/hyper-tuner/ini_parser)

# HyperTuner INI parser

INI parser for HyperTuner written in Dart.

## Roadmap

Checkout Roadmap issue: <https://github.com/hyper-tuner/ini_parser/issues/2>

## Example usage

from `example/save_as_json.dart`:

```dart
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
    final config = await INIParser(raw).parse();
    final json = const JsonEncoder.withIndent('  ').convert(config);

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
```

Compile and run:

```bash
dart compile exe example/save_as_json.dart

./example/save_as_json
```
