import 'package:flutter/foundation.dart';
import 'package:flutter_cic_support/models/person.dart';
import 'package:flutter_cic_support/models/storeissue.dart';
import 'package:flutter_cic_support/models/storeissueline.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StoreissueData extends ChangeNotifier {
  final String url_issue_list =
<<<<<<< HEAD
      "http://172.16.0.231:3000/api/storeissue/listbyemp";
  // final String url_issue_list =
  //     "http://192.168.60.197:1223/api/storeissue/listbyemp";
  final String url_issue_list_detail =
      "http://172.16.0.231:3000/api/storeissue/fetchissuedetail";

=======
      "https://api.cicsupports.com/api/storeissue/listbyemp";
  final String url_issue_list_detail =
      "https://api.cicsupports.com/api/storeissue/fetchissuedetail";
>>>>>>> e22eb7c6d1c95d0455da2e90fabde345106aff56
  final String url_issue_approve =
      "http://172.16.0.231:3000/api/storeissue/approveissue";

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

<<<<<<< HEAD
    String targetEmp = (emp_code != null && emp_code.isNotEmpty) ? emp_code : (user_id ?? '');

    List<String> listUrls = [
      url_issue_list + "/" + targetEmp,
      "http://172.16.0.231:3000/api/findjournalbyemp",
      "http://172.16.0.231/ptbmprod/api_get_pending_approvals.php",
      "http://192.168.60.195/ptbmprod/api_get_pending_approvals.php",
    ];

    Set<String> seenKeys = {};
    List<Storeissue> data = [];

    for (String url in listUrls) {
      try {
        http.Response response;
        if (url.contains('.php')) {
          response = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'emp_code': targetEmp, 'empid': targetEmp}),
          ).timeout(const Duration(seconds: 4));
        } else if (url.contains('/findjournalbyemp')) {
          response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              if (token.isNotEmpty && token != 'null') 'Authorization': 'Bearer $token'
            },
            body: json.encode({'empid': targetEmp, 'emp_code': targetEmp}),
          ).timeout(const Duration(seconds: 4));
        } else {
          response = await http.get(
            Uri.parse(url),
            headers: {if (token.isNotEmpty && token != 'null') 'Authorization': token},
          ).timeout(const Duration(seconds: 4));
        }

        if (response.statusCode == 200) {
          var decoded = json.decode(response.body);
          List<dynamic> res = [];
          if (decoded is List) {
            res = decoded;
          } else if (decoded is Map && decoded['data'] is List) {
            res = decoded['data'];
=======
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
>>>>>>> e22eb7c6d1c95d0455da2e90fabde345106aff56
          }

          if (res != null && res.isNotEmpty) {
            for (var i = 0; i < res.length; i++) {
              var r = res[i];
              String sId = (r['ID'] ?? r['id'] ?? r['journal_no'] ?? r['JOURNAL_NO'] ?? '').toString();
              String sNo = (r['JOURNAL_NO'] ?? r['journal_no'] ?? '').toString();
              String key = sId + '_' + sNo;
              if (seenKeys.contains(key)) continue;
              seenKeys.add(key);

              String reqName = (r['EMP_FULL_NAME'] ?? r['created_name'] ?? r['REQUEST_BY'] ?? r['created_by'] ?? '').toString();
              if (reqName.isEmpty) reqName = (r['REQUEST_BY'] ?? r['created_by'] ?? '').toString();

              final Storeissue personRes = Storeissue(
                id: sId,
                journal_no: sNo,
                trans_date: (r['TRANS_DATE'] ?? r['trans_date'] ?? '').toString(),
                created_by: (r['REQUEST_BY'] ?? r['created_by'] ?? '').toString(),
                created_name: reqName,
                status: (r['STATUS'] ?? r['status'] ?? '0').toString(),
                emp_full_name: reqName,
              );
              data.add(personRes);
            }
          }
        }
      } catch (err) {
        print("Error fetching issue list at $url: $err");
      }
    }

    listIssue = data;
    notifyListeners();
    return listIssue;
  }

  Future<dynamic> fetchIssueline(String _issueid) async {
    listIssueLine = [];
    notifyListeners();

    final pref = await SharedPreferences.getInstance();
    final String token = pref.getString("token").toString();

<<<<<<< HEAD
    List<String> detailUrls = [
      url_issue_list_detail + "/" + _issueid,
      "http://172.16.0.231:3000/api/findjournaldetail",
      "http://172.16.0.231/ptbmprod/api_find_journal_detail.php",
    ];

    for (String url in detailUrls) {
      try {
        http.Response response;
        if (url.contains('.php')) {
          response = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {'issue_id': _issueid, 'id': _issueid},
          ).timeout(const Duration(seconds: 4));
        } else if (url.contains('/findjournaldetail')) {
          response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              if (token.isNotEmpty && token != 'null') 'Authorization': 'Bearer $token'
            },
            body: json.encode({'issue_id': _issueid, 'id': _issueid}),
          ).timeout(const Duration(seconds: 4));
        } else {
          response = await http.get(
            Uri.parse(url),
            headers: {if (token.isNotEmpty && token != 'null') 'Authorization': token},
          ).timeout(const Duration(seconds: 4));
        }

        if (response.statusCode == 200) {
          var decoded = json.decode(response.body);
          List<dynamic> res = [];
          if (decoded is List) {
            res = decoded;
          } else if (decoded is Map && decoded['data'] is List) {
            res = decoded['data'];
=======
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
>>>>>>> e22eb7c6d1c95d0455da2e90fabde345106aff56
          }

          if (res != null && res.isNotEmpty) {
            List<Storeissueline> data = [];
            for (var i = 0; i < res.length; i++) {
              var r = res[i];
              final Storeissueline personRes = Storeissueline(
                id: (r['ID'] ?? r['id'] ?? r['line_id'] ?? '').toString(),
                issue_id: (r['ISSUE_ID'] ?? r['issue_id'] ?? _issueid).toString(),
                product_id: (r['ITEM_ID'] ?? r['item_id'] ?? r['product_id'] ?? '').toString(),
                product_name: (r['ITEM_NAME'] ?? r['item_name'] ?? r['product_name'] ?? '').toString(),
                qty: (r['QTY'] ?? r['qty'] ?? '0').toString(),
                remark: (r['REMARK'] ?? r['remark'] ?? '').toString(),
                unit_name: (r['UNIT_NAME'] ?? r['unit_name'] ?? '').toString(),
                price: (r['PRICE'] ?? r['price'] ?? '0').toString(),
              );
              data.add(personRes);
            }
            listIssueLine = data;
            return listIssueLine;
          }
        }
      } catch (err) {
        print("Error fetching issue line at $url: $err");
      }
    }

    return listIssueLine;
  }

  Future<bool> approveissue(int approve_type, String issue_id) async {
    notifyListeners();

    final pref = await SharedPreferences.getInstance();
    final String? user_id = pref.getString('user_id');
    final String? emp_code = pref.getString('emp_code');
    final String token = pref.getString("token").toString();

    String approverCode = (emp_code != null && emp_code.isNotEmpty) ? emp_code : (user_id ?? '');

    final Map<String, dynamic> approveData = {
      'user_id': approverCode,
      'emp_code': approverCode,
      'approve_by': approverCode,
      'approve_status': approve_type,
      'status': approve_type,
      'issue_id': issue_id,
      'id': issue_id
    };
    print("data approve is ${approveData}");
<<<<<<< HEAD

    List<String> approveUrls = [
      url_issue_approve,
      "http://172.16.0.231:3000/api/approve_issue",
      "http://172.16.0.231:3000/api/force_approve_issue",
      "http://172.16.0.231/ptbmprod/api_approve_journal.php",
    ];

    for (String url in approveUrls) {
      try {
        http.Response response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            if (token.isNotEmpty && token != 'null') 'Authorization': token,
          },
          body: json.encode(approveData),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 400) {
          var body = json.decode(response.body);
          if (response.statusCode == 400) {
            String errorMsg = body['error'] ?? 'เกิดข้อผิดพลาดในการอนุมัติ';
            throw Exception(errorMsg);
          }
          if (body != null && (body['success'] == true || body['status'] == 'success' || body['status'] == 200)) {
            await fetchIssuelist();
            return true;
          }
        }
      } catch (err) {
        print("Error approving issue at $url: $err");
        throw err; // Re-throw to show in UI
=======
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
>>>>>>> e22eb7c6d1c95d0455da2e90fabde345106aff56
      }
    }
    return false;
  }
}
