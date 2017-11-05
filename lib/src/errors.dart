/// Thrown when a node which evaluates to type A is evaluated to type B.
class QueryTypeError {
  final String expected;
  final String actual;

  const QueryTypeError(this.expected, this.actual);

  @override
  String toString() {
    return 'I exprected an expression of type $expected, '
        'instead I found type $actual';
  }
}

/// Thrown if the number of dice exceeds 50.
class ExcessiveDiceError {
  final int count;

  const ExcessiveDiceError(this.count);

  @override
  String toString() {
    return '$count dice is too many';
  }
}

/// Thrown if there is invalid syntax when parsing a Dart expression.
class SyntaxError {
  final String message;
  final int offset;

  const SyntaxError(this.message, this.offset);

  @override
  String toString() {
    var first = message.substring(0, offset);
    var last = message.substring(offset + 1);

    return 'Syntax Error: $first **${message[offset]}** $last';
  }
}
