# query_bot

A Discord bot which answers basic dice-based statistical queries. To run,
just provide with a Discord bot API token.

```
  dart -DDISCORD_API_TOKEN=MYTOKEN bin/main.dart
```

NB: the extra D isn't a typo.

### Supports
  - basic arithmetic operators: +, -, *, /
  - numbers: 1.23, 2
  - comparison operations: <, >, <=, >=, ==, !=
  - dice: 1d20, 2d6
  - logical and/or: &, |
  - parens ( )

Operator precedence is the same as in the Dart language.

### Commands
  - /p /prob: estimates the probability the provided expression is true.
  - /a /avg: estimates the average value of an expression.

### Examples
  `/p 1d20 + 4 > 13`
  `[QUERY] 56%`

  `/avg 2d6 + 2d3`
  `[QUERY] 11`

  `/p 1d20` <- ERROR, can't evaluate a number to a boolean.
  `/avg 1d6 > 5` <- ERROR, can't evaluate a boolean to a number.

This bot uses sampling techniques to compute probabilities, so complicated expressions may have slight errors.
