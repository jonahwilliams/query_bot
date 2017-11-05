import 'package:query_bot/src/ast.dart';
import 'package:query_bot/src/parser.dart';
import 'package:test/test.dart';

void main() {
  group('parsing', () {
    group('parses numeric expression', () {
      var table = {
        '1 + 2': new BinaryNode(
          '+',
          new Number(1),
          new Number(2),
        ),
        '4 * 5': new BinaryNode(
          '*',
          new Number(4),
          new Number(5),
        ),
        '2 / 3': new BinaryNode(
          '/',
          new Number(2),
          new Number(3),
        ),
        '9 + (2 - 3) * 4': new BinaryNode(
          '+',
          new Number(9),
          new BinaryNode(
            '*',
            new BinaryNode(
              '-',
              new Number(2),
              new Number(3),
            ),
            new Number(4),
          ),
        ),
      };

      for (var key in table.keys) {
        test(key, () {
          expect(parse(key).compareTo(table[key]), 0);
        });
      }
    });

    group('parses boolean expressions', () {
      var table = {
        '1 + 2 >= 3': new BinaryNode(
          '>=',
          new BinaryNode(
            '+',
            new Number(1),
            new Number(2),
          ),
          new Number(3),
        ),
        '4 * 5 > 2': new BinaryNode(
          '>',
          new BinaryNode(
            '*',
            new Number(4),
            new Number(5),
          ),
          new Number(2),
        ),
        '2 - 100 < 2': new BinaryNode(
          '<',
          new BinaryNode(
            '-',
            new Number(2),
            new Number(100),
          ),
          new Number(2),
        )
      };

      for (var key in table.keys) {
        test(key, () {
          expect(parse(key).compareTo(table[key]), 0);
        });
      }
    });

    group('parses dice', () {
      var table = {
        '1d20': new Dice(1, 20),
        '1d6': new Dice(1, 6),
        '1d100': new Dice(1, 100),
      };

      for (var key in table.keys) {
        test(key, () {
          expect(parse(key).compareTo(table[key]), 0);
        });
      }
    });
  });
}
