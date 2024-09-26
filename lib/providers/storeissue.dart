import 'package:flutter/foundation.dart';
import 'package:flutter_cic_support/models/person.dart';
import 'package:flutter_cic_support/models/storeissue.dart';
import 'package:flutter_cic_support/models/storeissueline.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StoreissueData extends ChangeNotifier {
  final String url_issue_list =
      "http://172.16.100.50:1223/api/storeissue/listbyemp";
  final String url_issue_list_detail =
      "http://172.16.100.50:1223/api/storeissue/fetchissuedetail";

  final String url_issue_approve =
      "http://172.16.100.50:1223/api/storeissue/approveissue";

  late List<Storeissue> _issue;
  List<Storeissue> get listIssue => _issue;

  late List<Storeissueline> _issueline;
  List<Storeissueline> get listIssueLine => _issueline;

  set listIssue(List<Storeissue> val) {
    _issue = val;
  }

  set listIssueLine(List<Storeissueline> val) {
    _issueline = val;
  }

  Future<dynamic> fetchIssuelist() async {
    notifyListeners();

    final pref = await SharedPreferences.getInstance();
    final String? user_id = pref.getString('user_id');
    final String? emp_code = pref.getString('emp_code');
    final String token = pref.getString("token").toString();

    //final Map<String, dynamic> fileterData = {'empid': user_id};
    // print("data for issue is ${user_id}");
    try {
      http.Response response;
      response = await http.get(
        Uri.parse(url_issue_list + "/" + emp_code!),
        headers: {'Authorization': token},
        // body: json.encode(fileterData),
      );
      if (response.statusCode == 200) {
        List<dynamic> res = json.decode(response.body);
        List<Storeissue> data = [];
        if (res == null) {
          print('no data');
        } else {
          print(res);
          // print("ok");
          for (var i = 0; i < res.length; i++) {
            final Storeissue personRes = Storeissue(
                id: res[i]['ID'].toString(),
                journal_no: res[i]['JOURNAL_NO'].toString(),
                trans_date: res[i]['TRANS_DATE'].toString(),
                created_by: res[i]['REQUEST_BY'].toString(),
                created_name: res[i]['REQUEST_BY'].toString(),
                status: res[i]['STATUS'].toString(),
                emp_full_name: res[i]['EMP_FULL_NAME']);
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

  Future<dynamic> fetchIssueline(String _issueid) async {
    notifyListeners();

    final pref = await SharedPreferences.getInstance();
    final String token = pref.getString("token").toString();

    //final Map<String, dynamic> fileterData = {'empid': user_id};
    // print("data for issue is ${user_id}");
    try {
      http.Response response;
      response = await http.get(
        Uri.parse(url_issue_list_detail + "/" + _issueid),
        headers: {'Authorization': token},
        // body: json.encode(fileterData),
      );
      if (response.statusCode == 200) {
        List<dynamic> res = json.decode(response.body);
        List<Storeissueline> data = [];
        if (res == null) {
          print('no data');
        } else {
          print(res);
          // print("ok");
          for (var i = 0; i < res.length; i++) {
            final Storeissueline personRes = Storeissueline(
              id: res[i]['ID'].toString(),
              issue_id: res[i]['ISSUE_ID'].toString(),
              product_id: res[i]['ITEM_ID'].toString(),
              product_name: res[i]['ITEM_NAME'].toString(),
              qty: res[i]['QTY'].toString(),
              remark: res[i]['REMARK'].toString(),
              unit_name: res[i]['UNIT_NAME'].toString(),
            );
            data.add(personRes);
          }

          listIssueLine = data;
          return listIssueLine;
        }
      } else {
        print('error');
      }
    } catch (err) {
      print("error naja is ${err}");
    }
  }

  Future<bool> approveissue(int approve_type, String issue_id) async {
    notifyListeners();

    final pref = await SharedPreferences.getInstance();
    final String? user_id = pref.getString('user_id');
    final String token = pref.getString("token").toString();
    final Map<String, dynamic> approveData = {
      'user_id': user_id,
      'approve_status': approve_type,
      'issue_id': issue_id
    };
    print("data approve is ${approveData}");
    try {
      http.Response response;
      response = await http.post(
        Uri.parse(url_issue_approve),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: json.encode(approveData),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (err) {
      print("error naja is ${err}");
      return false;
    }
  }
}
