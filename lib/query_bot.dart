// Copyright (c) 2017, Jonah Williams. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'src/commands.dart';
import 'src/errors.dart';
export 'src/commands.dart';

class Client {
  final _prefix = <String, Command>{};

  void registerCommand(Command command) {
    for (var word in command.commands) {
      _prefix[word] = command;
    }
  }

  String execute(String message) {
    var trimmed = message.trimLeft();
    if (trimmed[0] != '/') {
      return null;
    }

    var commad = new StringBuffer();
    var i = 1;
    for (; i < trimmed.length; i++) {
      var char = trimmed[i];
      if (char == ' ' || char == '\t' || char == '\n') break;
      commad.write(char);
    }

    var cmd = _prefix[commad.toString()];
    if (cmd != null) {
      String result;
      try {
        result = cmd.execute(message.substring(i).trim());
      } on SyntaxError catch (err) {
        result = err.toString();
      } on ExcessiveDiceError catch (err) {
        result = err.toString();
      } on QueryTypeError catch (err) {
        result = err.toString();
      } catch (err) {
        result = 'Shoot, I couldn\'t parse that';
      }
      return result;
    }
    return null;
  }
}
