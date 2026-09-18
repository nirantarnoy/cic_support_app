import 'dart:convert';

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
          "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDNOkgMF6gxXXN8\nqyMIBAfvE3U7ds9FeeC4JKHNL8TjwQFHwR+gsfVBp4vpMzI2iU/1npfZeAZoBswc\nFv2E+dTQKc9QVP4saPCypTihqF1rM9NOwZEyMNR89EoVCjNPTqA9KNEs6T/Oqaej\nYv8/6OoUpRkgffOqVr4QVXahIINDM4pnTBS2LypkjuaJ0ua3w+we+5OdXtJWsA1O\n80vtxFkvlkEYxSCld7ZM/npuQOz1EH+WHd4j3m/A1dIxPCvWYhhsmpCcgksBqJcs\nITmXzxCXh+2+F5su/HzMKQyRIwOIOjQUxiFueBEvT+0idkrJTrJrmRpK37L+bETa\n1ydHlNPxAgMBAAECggEAILC2LcDt8HEVlofvJFV6Cw3TKHXwJb24ezSQlm3Tw8Co\naszbNB5stfjRi0O1raS5OSN6RjB9esAMbrQFzZL7IG5sgLwNIbdUkexKBUwbl1ox\nwFOKhI9tJXtHOqs9iZY5ZYyVJz1/RbTWCGtaQ8yezsuOoVOWxu0ayODILPnQFtm7\nOSfVtvFnFhELjLMdZUiZjuNFgsarbp6ilhYvDEeNiniEW7wALGR//UyNcbx+lGTB\nImltiXUJAJ4j+Rpg91O3Aa5m4SqTnOFH4bMVbUYufUGslYuBw5WS3uua2z89svNP\niwnTXDxs4lrJAVWyHoNy9tJrzfySqNKriTESIZR9zQKBgQDOmSJrjBkaAdRFrMPg\nQzMOD6Z3m7Mb7yu2OYbJWMAvLsnc/bPVCchVqUhibVnJhsmRIj+ItE/5IJb6pp/S\noGg5Ye1H5pgOe4VmJqulN5IOnxq40NuPITO5HfXghK7zrZwOPE67GIU+LB6fwYB3\ny+koBC+PfCUnXp5/q5WjWwkDZQKBgQD+TUA7KqKUQglvj3uZBL99POf8OtqD73a5\nliM59vn0aGsQaMWIyHDtRtkyyBEL2tTbTvdaurktUTxLpRx9qLOixGJqEO0qiy30\n7CcPfXw6LBFS1tSp2yYILdRfTILAn0Qhe/UNFVedxc04zRhKyn9xhNYbmtj2X+t7\nrkgV7eRTnQKBgQCeX3eqWBBaBnLyInlZbkoyCj9DS2EnFdY9b6XqrZVN1iE6vmVf\n94rSV928TjVZLnFQR5/KrObthFUYuiikbwDWlEIwLw37dCcT4qsMEShu+vqiGMFm\n3D3pN5Vn0m7HMBwEMajs9eQWf/3N26kerHsEiQjohnN41ajNF/yy6DNlnQKBgQCr\nzJ6vGh+Zz382ahXTC50eS65h/ZSwe2+W83I677pvvrdN76o7vUZlVm7X2seBXcZd\nntyG5AzEK9RzOkmkLvuk482k4GiJTFuw0nWVBm6NkkXl1BL56X6pGeUWuMbAwRgz\nEt47h4aYpQ/+5rgZlvJAS8CmB5e54pVhCh3TCtMtFQKBgQCcWKIgv/DYItf7ITP5\nTKijqyVKzDJZV0+SpU/bZOBfnAqd41aSpAVc2ktkfSRLD39xYhqsz2xNCKAn9HMH\n0GQeUWSsfZ4mASqm1CK2YCpd9beeQgSDtKvo4rdDxHz1+Iy69S5Cl29MMgRLyIZ/\niz6/AFtevXYRnNFULyLILI9IZw==\n-----END PRIVATE KEY-----\n",
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
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
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

  static sendNotificationToSelectedPerson(
      String deviceToken, BuildContext context, String tripID) async {
    final String serverAcessTokenKey = await getAccessToken();
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/fcmflutter-ed115/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': "TEST",
          'body': "Pickup",
        },
        'data': {
          'tripID': 'xxx',
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAcessTokenKey'
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print("send success");
    } else {
      print("send error");
    }
  }
}
