import 'package:flutter/foundation.dart';
import 'package:flutter_cic_support/models/person.dart';
import 'package:flutter_cic_support/models/storeissue.dart';
import 'package:flutter_cic_support/models/storeissueline.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StoreissueData extends ChangeNotifier {
  final String url_issue_list =
      "https://api.cicsupports.com/api/storeissue/listbyemp";
  final String url_issue_list_detail =
      "https://api.cicsupports.com/api/storeissue/fetchissuedetail";
  final String url_issue_approve =
      "https://api.cicsupports.com/api/storeissue/approveissue";

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
    listIssue = [];
    notifyListeners();

    final pref = await SharedPreferences.getInstance();
    final String? user_id = pref.getString('user_id');
    final String? emp_code = pref.getString('emp_code');
    final String token = pref.getString("token").toString();

    //final Map<String, dynamic> fileterData = {'empid': user_id};
    // print("data for issue is ${user_id}");
    try {
      final uri = Uri.parse(url_issue_list + "/" + emp_code!);
      print("DEBUG storeissue GET: $uri");
      http.Response response;
      response = await http.get(
        uri,
        headers: {'Authorization': token},
        // body: json.encode(fileterData),
      );
      print("DEBUG storeissue status: ${response.statusCode}");
      print("DEBUG storeissue body: ${utf8.decode(response.bodyBytes)}");
      if (response.statusCode == 200) {
        List<dynamic> res = json.decode(utf8.decode(response.bodyBytes));
        List<Storeissue> data = [];
        if (res == null) {
          print('no data');
        } else {
          print(res);
          // listIssue.clear();
          // print("ok");
          for (var i = 0; i < res.length; i++) {
            final statusStr = res[i]['STATUS'].toString();
            if (statusStr != "0") continue; // เฉพาะรายการที่รออนุมัติ (STATUS == 0)

            final Storeissue personRes = Storeissue(
                id: res[i]['ID'].toString(),
                journal_no: res[i]['JOURNAL_NO'].toString(),
                trans_date: res[i]['TRANS_DATE'].toString(),
                created_by: res[i]['REQUEST_BY'].toString(),
                created_name: res[i]['REQUEST_BY'].toString(),
                status: statusStr,
                emp_full_name: res[i]['EMP_FULL_NAME']);
            data.add(personRes);
          }

          listIssue = data;
          notifyListeners();
          return listIssue;
        }
      } else {
        print('error');
        listIssue.clear();
        notifyListeners();
        return listIssue;
      }
    } catch (err) {
      print("error naja is ${err}");
    }
  }

  Future<dynamic> fetchIssueline(String _issueid) async {
    listIssueLine = [];
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
        List<dynamic> res = json.decode(utf8.decode(response.bodyBytes));
        List<Storeissueline> data = [];
        if (res == null) {
          print('no data');
        } else {
          print(res);
          if (res.length == 0) {
            listIssue.clear();
            notifyListeners();
            return listIssue;
          }
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
              price: res[i]['PRICE']?.toString() ?? '0',
            );
            data.add(personRes);
          }

          listIssueLine = data;
          return listIssueLine;
        }
      } else {
        listIssue.clear();
        notifyListeners();
        return listIssue;
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
      print("data approve is issue_id=$issue_id, approve_status=$approve_type, user_id=$user_id");
      final Map<String, dynamic> approveData = {
        'user_id': int.tryParse(user_id ?? '0') ?? 0,
        'approve_status': approve_type,
        'issue_id': int.tryParse(issue_id) ?? 0
      };
      
      final uri = Uri.parse(url_issue_approve);
      http.Response response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: json.encode(approveData),
      );
      print("approve response: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
      if (response.statusCode == 200 || response.statusCode == 201) {
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
