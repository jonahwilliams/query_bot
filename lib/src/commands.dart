import 'dart:math' as math;

import 'package:query_bot/src/ast.dart';
import 'package:query_bot/src/parser.dart';

math.Random _rand = new math.Random();

abstract class Command {
  List<String> get commands;

  String execute(String message);
}

const _maxIter = 1000;

class ProbabilityCommand extends Command {
  @override
  final List<String> commands = const ['p', 'prob', 'probability'];

  @override
  String execute(String message) {
    return _probability(message, _rand);
  }

  String _probability(String source, math.Random random) {
    var tree = simplify(parse(source));
    var sum = 0.0;

    for (var i = 0; i < _maxIter; i++) {
      sum += tree.evalBool(random) ? 1.0 : 0.0;
    }

    return '${(sum / _maxIter * 100).toStringAsFixed(0)}%';
  }
}

class AverageCommand extends Command {
  @override
  final List<String> commands = const ['a', 'avg', 'average'];

  @override
  String execute(String message) {
    return _average(message, _rand);
  }

  String _average(String source, math.Random random) {
    var tree = simplify(parse(source));
    var sum = 0.0;

    for (var i = 0; i < _maxIter; i++) {
      sum += tree.evalDouble(random);
    }

    return '${(sum / _maxIter).toStringAsFixed(0)}';
  }
}
