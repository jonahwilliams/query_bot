import 'package:query_bot/src/ast.dart';
import 'package:query_bot/src/parser.dart';
import 'package:test/test.dart';

void main() {
  group('Simplifier', () {
    test('simplifies expressions', () {
      var source = parse('1 + 2 + 3 + 4');
      expect(simplify(source).compareTo(new Number(10.0)), 0);
    });
  });
}
