import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "fcmflutter-ed115",
      "private_key_id": "b3f5c8c75fcb93bb0caf939655874849a56ccffa",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCWx9EQuiWDrbaT\nGYWf4rF2vnRfYxb5c9Sz0Hl6O8qGYHuViJfYoFGubJ2B4VqhhMax+b4l8wo7ugP0\naPl/EeT1XylMPbFaCYJw68zjSF8sLJQYRW9u0axRqpNYeoAdD1qu9DLkYmDbTztm\nX5RREDOm8cMQwydKt0gt/To4kTydTw/+R5bAJ79OQaS+zhTOcNvSA38WaH4DZ7na\ndjQ+GaowQBW6An2dWYKE2BJrw0/EaamzdGgiqtsQqyMBzF6POaIBwW/hZsrF4+Aq\nmnNAXQpO5Fbi3ebm2L+6cJbqErzAbkJJjqF/otxJFzceBxA+PQ9dn/knqVVcUfYV\nsQcxJRI/AgMBAAECggEABq2B0lpUKAFNCTXDp8Gb93TW5ZSXY2PgYzhT8Pht70ad\nopFCnFr5Ux7HWQW4hFfDjwVPCRI6/UsvOqddiWWq/L0CsLg4vxKVvteKovRFFslA\no9SLa16I4bMKxIvkWaUg8IerK1c6D+xx5oZMJMzxZK7nYzopZtM4NKU262NvSk4x\nJRh0nx5nA7HPxBaN8/n4KxDTzEXms8zlddtam9HfLqPzHTa0rjzuPLaejIG6zBhC\nZlM9yWLhjwmAxgfEVPGgvdRBLOFqKH/xZFq73LxfTQUg8A/mg9AEvEEElLKdp4qK\nrD5Ep4jjehiDszv5ot5jndkqkRx1r+dVbMeythLNlQKBgQDTulDZ922JkIndmLqK\nCqtI9FjRmI36KN5qUQ09Z9MjwbpB/P6xMLVzTymHXapy9+drFDZDmp/GpEF0fHqM\nHT7TCfnXeTgUM9TfXHGhDaZAmkfW9S08zvukZ2/xuj1v3BhuL0Dfz+LVgaP4LpGG\n7v8TerMUcm4y4L1VQYsIr+SchQKBgQC2TwYnPBc0dCFmlCph1lg8vFPbZAmdra2U\n+MdXT/LpWMUWiQlz4G/6x1tCaVC11HxhO6cXM7WedqN4JIRI1by+WJROhxas4Ehu\nR3ebyA9LD2AK3te666wyGY/ldytlfF/dS2RjjPOUCFJozvEo68Afw0fhBe52dgWr\n40OKt/qA8wKBgGM5KJTNcMcMNp/j6F+y2kypPkqTfM3kgz891r+VPYy/SEOOhemS\nEycDzUmD6tJQPWKgKUILX59e8NHfWCr7tap/PVfulgpZtAQtNY8tb2FNLCef5OBf\ne+yzEPIuvoYClmxktrlsmjhGtgokAM1EicOeN/h4HA655eDjg33BuJhlAoGAZoh9\nYnWma2bhHis4xvvhdo9I7nwN+HOky8M7gfzCFsFJX4pFGbnh4P5ccjZ/ITTXm2wM\nZr07aVs6RyjqiXhEhh2Vk7DgbOxbcEKbn67eAw4rqxF37XX8y9SanKjwbEyOMgzj\n8iVlHR2tE6tH8QbecD7JX2KRomhweiMAarVcm0cCgYEAhxVa3K7Ox2A4DL5beXen\n8oN18Mm0WshnUb/+W6gam6fdsxgEevi3Ma8HlPWxDBFpiBW6ZoXExECu7GH9upvz\n9NkpZoE8E6YaKsGzMr0P2f3CYvMHE6GOHJk93zX1EmXKOzBZ378DoH64qahUTrQd\nbvnRLV8kbSiEIwQ9voBLUKA=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-2is1t@fcmflutter-ed115.iam.gserviceaccount.com",
      "client_id": "103677406355625078371",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-2is1t%40fcmflutter-ed115.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.gogleapis.com/auth/userinfo.email",
      "https://www.gogleapis.com/auth/firebase.database",
      "https://www.gogleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    // get the access token

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);
    client.close();
    return credentials.accessToken.data;
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
