import 'package:flutter/cupertino.dart';

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {};
    return '';
  }

  static sendNotificationToPerson(
      String deviceToken, BuildContext context, String TripId) async {
    final String serverKey = await getAccessToken();
    String endpointFirebaseCloudMessaging = '';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': "",
          "body": "",
        }
      }
    };
  }
}
