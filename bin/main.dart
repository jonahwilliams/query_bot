import 'dart:async';
import 'dart:io';
import 'package:din/din.dart' as din;
import 'package:query_bot/query_bot.dart' as qb;

var token = new String.fromEnvironment('DISCORD_API_TOKEN');
var client = new qb.Client()
  ..registerCommand(new qb.ProbabilityCommand())
  ..registerCommand(new qb.AverageCommand());

Future<Null> main() async {
  print(token);
  var apiClient = new din.ApiClient(
    rest: new din.RestClient(
      auth: new din.AuthScheme.asBot(token),
    ),
  );
  var gateway = await apiClient.gateway.getGatewayBot();
  var gatewayClient = await apiClient.connect(gateway.url);

  ProcessSignal.SIGTERM.watch().listen((_) {
    gatewayClient.close();
    exitCode = 0;
  });

  var helloTraces = await gatewayClient.onHello;
  var readyMessage = await gatewayClient.events.ready.first;
  print('Authenticated! Connected through $helloTraces.');

  await for (final message in gatewayClient.events.messageCreate) {
    if (message.user.id != readyMessage.user.id) {
      var response = client.execute(message.content);
      if (response == null || response.isEmpty) continue;

      apiClient.channels.createMessage(
        channelId: message.channelId,
        content: '[QUERY] ${response}',
      );
    }
  }
}
