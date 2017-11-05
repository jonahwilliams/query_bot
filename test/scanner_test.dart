import 'package:query_bot/src/parser.dart';
import 'package:test/test.dart';

void main() {
  group('Scanner', () {
    group('scans operators', () {
      var table = [
        '+',
        '-',
        '*',
        '/',
        '<=',
        '>=',
        '<',
        '>',
        '!=',
        '==',
        '&',
        '|'
      ];

      for (var op in table) {
        test(op, () {
          expect(scanner(op), [op]);
        });
      }
    });

    test('scans numbers and dice', () {
      expect(scanner('1232'), ['1232']);
    });
  });
}
