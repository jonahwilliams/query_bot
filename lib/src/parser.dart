import 'package:query_bot/src/ast.dart';
import 'package:charcode/charcode.dart';
import 'package:query_bot/src/errors.dart';

const _operatorPrescedence = const {
  '+': 13,
  '-': 13,
  '*': 14,
  '/': 14,
  '<': 8,
  '<=': 8,
  '>': 8,
  '>=': 8,
  '==': 7,
  '!=': 7,
  '&': 6,
  '|': 5,
};

const _operators = const [
  '+',
  '-',
  '*',
  '/',
  '&',
  '|',
  '>',
  '<',
  '>=',
  '<=',
  '==',
  '!=',
];

final _whitespace = new RegExp(r'\s');

/// Scans a source string into a list of String tokens.
///
/// Throws [SyntaxError] if it encounters invalid syntax.
List<String> scanner(String source) {
  var result = <String>[];
  var iterator = new _PeekableIterator(source.codeUnits);

  while (iterator.moveNext()) {
    var char = iterator.current;
    if (char == $space || char == $tab || char == $vt) {
      continue;
    } else if (char == $plus ||
        char == $asterisk ||
        char == $slash ||
        char == $open_paren ||
        char == $close_paren ||
        char == $ampersand ||
        char == $pipe ||
        char == $minus) {
      result.add(new String.fromCharCode(char));
    } else if (char == $lt) {
      if (iterator.peek == $equal) {
        iterator.moveNext();
        result.add('<=');
      } else {
        result.add('<');
      }
    } else if (char == $gt) {
      if (iterator.peek == $equal) {
        iterator.moveNext();
        result.add('>=');
      } else {
        result.add('>');
      }
    } else if (char == $equal) {
      if (iterator.peek == $equal) {
        iterator.moveNext();
        result.add('==');
      } else {
        throw new SyntaxError(source, iterator.offset);
      }
    } else if (char == $exclamation) {
      if (iterator.peek == $equal) {
        iterator.moveNext();
        result.add('!=');
      } else {
        throw new SyntaxError(source, iterator.offset);
      }
    } else {
      var buffer = new StringBuffer()..writeCharCode(char);
      var peek = iterator.peek;
      while ((peek >= $0 && peek <= $9) ||
          peek == $dot ||
          peek == $d ||
          peek == $D) {
        buffer.writeCharCode(peek);
        iterator.moveNext();
        peek = iterator.peek;
      }
      result.add(buffer.toString());
    }
  }
  return result;
}

/// Parses an expression using Dijkstra's shunting yard algorithm.
Node parse(String source) {
  var tokens = scanner(source);
  var output = <Node>[];
  var operators = <String>[];

  for (var token in tokens) {
    if (_operators.contains(token)) {
      while (operators.isNotEmpty) {
        if (operators.last != '(' &&
            _operatorPrescedence[operators.last] >=
                _operatorPrescedence[token]) {
          var node = new BinaryNode(operators.removeLast());
          output.add(node);
        } else {
          break;
        }
      }
      operators.add(token);
    } else if (token == '(') {
      operators.add(token);
    } else if (token == ')') {
      while (operators.isNotEmpty) {
        if (operators.last == '(') {
          operators.removeLast();
          break;
        } else {
          var node = new BinaryNode(operators.removeLast());
          output.add(node);
        }
      }
    } else if (token.contains('d')) {
      var values = token.split('d');
      output.add(new Dice(int.parse(values[0]), int.parse(values[1])));
    } else {
      output.add(new Number(double.parse(token)));
    }
  }

  while (operators.isNotEmpty) {
    var node = new BinaryNode(operators.removeLast());
    output.add(node);
  }

  var stack = <Node>[];
  for (var node in output) {
    if (node is BinaryNode) {
      node
        ..right = stack.removeLast()
        ..left = stack.removeLast();
      stack.add(node);
    } else {
      stack.add(node);
    }
  }

  return stack.single;
}

/// An [Iterator] which allows 1 character lookahead.
class _PeekableIterator implements Iterator<int> {
  final List<int> _source;
  int _index = -1;

  _PeekableIterator(this._source);

  @override
  int get current {
    if (_index < 0 || _index >= _source.length) {
      return null;
    }
    return _source[_index];
  }

  int get peek {
    if (_index + 1 < _source.length) {
      return _source[_index + 1];
    }
    return 0;
  }

  int get offset => _index;

  @override
  bool moveNext() {
    if (_index + 1 < _source.length) {
      _index++;
      return true;
    }
    return false;
  }
}
