import 'dart:math' as math;

import 'package:query_bot/src/errors.dart';

/// An ast which describes a basic statistical query.
abstract class Node implements Comparable<Node> {
  const Node();

  /// Evaluate this AST to a double value.
  ///
  /// Throws [QueryTypeError] if the expression is not numeric.
  double evalDouble(math.Random random);

  /// Evaluate this AST to a boolean value.
  ///
  /// Throws [QueryTypeError] if the expression is not boolean.
  bool evalBool(math.Random random);
}

/// An ast [Node] representing a dice random variable.
class Dice extends Node {
  /// The number of dice to roll.
  final int quantity;

  /// The size of the dice, d20 or d6 for example.
  final int size;

  const Dice(this.quantity, this.size);

  @override
  double evalDouble(math.Random random) {
    if (quantity > 50) {
      throw new ExcessiveDiceError(quantity);
    }

    var result = 0.0;
    for (var i = 0; i < quantity; i++) {
      result += (random.nextInt(size) + 1).toDouble();
    }
    return result;
  }

  @override
  bool evalBool(math.Random _) {
    throw const QueryTypeError('bool', 'number');
  }

  @override
  String toString() => 'Dice(${quantity}d${size})';

  @override
  int compareTo(Node other) {
    if (other is Dice && other.size == size && other.quantity == quantity) {
      return 0;
    }
    return -1;
  }
}

/// An ast [Node] representing a numeric value.
class Number extends Node {
  final num value;

  const Number(this.value);

  @override
  double evalDouble(math.Random _) => value;

  @override
  bool evalBool(math.Random _) => throw const QueryTypeError('bool', 'number');

  @override
  String toString() => 'Number($value)';

  @override
  int compareTo(Node other) {
    if (other is Number && other.value == value) {
      return 0;
    }
    return -1;
  }
}

/// An ast [Node] representing a binary operation.
class BinaryNode extends Node {
  final String op;
  Node left;
  Node right;

  BinaryNode(this.op, [this.left = null, this.right = null]);

  @override
  double evalDouble(math.Random random) {
    var leftValue = left.evalDouble(random);
    var rightValue = right.evalDouble(random);
    switch (op) {
      case '+':
        return leftValue + rightValue;
      case '-':
        return leftValue - rightValue;
      case '*':
        return leftValue * rightValue;
      case '/':
        return leftValue / rightValue;
      default:
        throw const QueryTypeError('double', 'bool');
    }
  }

  @override
  bool evalBool(math.Random random) {
    switch (op) {
      case '>':
        return left.evalDouble(random) > right.evalDouble(random);
      case '>=':
        return left.evalDouble(random) >= right.evalDouble(random);
      case '<':
        return left.evalDouble(random) < right.evalDouble(random);
      case '<=':
        return left.evalDouble(random) <= right.evalDouble(random);
      case '==':
        return left.evalDouble(random) == right.evalDouble(random);
      case '!=':
        return left.evalDouble(random) != right.evalDouble(random);
      case '&':
        return left.evalBool(random) && right.evalBool(random);
      case '|':
        return left.evalBool(random) || right.evalBool(random);
      default:
        throw const QueryTypeError('bool', 'double');
    }
  }

  @override
  String toString() => 'BinaryNode($op $left $right)';

  @override
  int compareTo(Node other) {
    if (other is BinaryNode &&
        other.op == op &&
        other.left.compareTo(left) == 0 &&
        other.right.compareTo(right) == 0) {
      return 0;
    }
    return -1;
  }
}

/// Attemps to simplify an AST by constant-folding.
Node simplify(Node root) {
  if (root is BinaryNode) {
    root.left = simplify(root.left);
    root.right = simplify(root.right);

    if (root.left is Number && root.right is Number) {
      return new Number(root.evalDouble(null));
    }
  }
  return root;
}
