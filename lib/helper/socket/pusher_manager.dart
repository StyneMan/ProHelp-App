import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherManager {
  static final PusherManager _instance = PusherManager.internal();
  late PusherChannelsFlutter pusher;

  factory PusherManager() {
    return _instance;
  }

  PusherManager.internal({var payload}) {
    _initPusher(payload);
  }

  _initPusher(var payload) async {
    final sockId = await pusher.getSocketId();
    final Map<String, String> _paramsMap = {
      "socket_id": sockId,
      "id": payload['id'],
      "firstname": payload['firstname'],
      "lastname": payload['lastname'],
      "email": payload['email'],
    };

    pusher = PusherChannelsFlutter()
      ..init(
        apiKey: "1c215c902be56f87e08f",
        useTLS: true,
        cluster: "mt1",
        authEndpoint: "/pusher-auth",
        authParams: {
          'params': _paramsMap,
        },
        onError: (message, code, error) {
          print("PUSHER ERROR MSG :: $message");
          print("PUSHER ERROR CODE :: $code");
          print("PUSHER ERROR ERROR :: $error");
        },
      );

    pusher.connect();
  }
}
