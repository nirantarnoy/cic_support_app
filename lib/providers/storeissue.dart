import 'package:flutter/foundation.dart';
import 'package:flutter_cic_support/models/person.dart';
import 'package:flutter_cic_support/models/storeissue.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StoreissueData extends ChangeNotifier {
  final String url_issue_list = "http://172.16.0.231:3000/api/findissueapprove";

  late List<Storeissue> _issue;
  List<Storeissue> get listIssue => _issue;

  set listIssue(List<Storeissue> val) {
    _issue = val;
  }

  Future<dynamic> fetchIssuelist() async {
    notifyListeners();

    final pref = await SharedPreferences.getInstance();
    final String? user_id = pref.getString('user_id');

    final Map<String, dynamic> fileterData = {'empid': user_id};
    try {
      http.Response response;
      response = await http.post(
        Uri.parse(url_issue_list),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(fileterData),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> res = json.decode(response.body);
        List<Storeissue> data = [];
        if (res == null) {
          print('no data');
        } else {
          // print("ok");
          for (var i = 0; i < res['data'].length; i++) {
            final Storeissue personRes = Storeissue(
              id: res['data'][i]['id'].toString(),
              journal_no: '',
              trans_date: '',
              created_by: '',
              created_name: '',
              status: '',
            );
            data.add(personRes);
          }

          listIssue = data;
          return listIssue;
        }
      } else {
        print('error');
      }
    } catch (err) {
      print("error naja is ${err}");
    }
  }
}
