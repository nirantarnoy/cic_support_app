import 'package:flutter/foundation.dart';
import 'package:flutter_cic_support/models/person.dart';
import 'package:flutter_cic_support/models/storeissue.dart';
import 'package:flutter_cic_support/models/storeissueline.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreissueData extends ChangeNotifier {
  final String url_issue_list =
      "https://api.cicsupports.com/api/storeissue/listbyemp";
  final String url_issue_list_detail =
      "https://api.cicsupports.com/api/storeissue/fetchissuedetail";
  final String url_issue_approve =
      "https://api.cicsupports.com/api/storeissue/approveissue";

  late List<Storeissue> _issue = [];
  List<Storeissue> get listIssue => _issue;

  late List<Storeissueline> _issueline = [];
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

    String targetEmp = (emp_code != null && emp_code.isNotEmpty) ? emp_code : (user_id ?? '');

    List<String> listUrls = [
      url_issue_list + "/" + targetEmp,
      "https://api.cicsupports.com/api/findjournalbyemp",
      "https://api.cicsupports.com/ptbmprod/api_get_pending_approvals.php",
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
            body: json.encode({
              'emp_code': targetEmp,
              'empid': targetEmp,
              'approver_emp_code': targetEmp,
              'approver_id': targetEmp
            }),
          ).timeout(const Duration(seconds: 4));
        } else if (url.contains('/findjournalbyemp')) {
          response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              if (token.isNotEmpty && token != 'null') 'Authorization': 'Bearer $token'
            },
            body: json.encode({
              'empid': targetEmp,
              'emp_code': targetEmp,
              'approver_emp_code': targetEmp,
              'approver_id': targetEmp
            }),
          ).timeout(const Duration(seconds: 4));
        } else {
          response = await http.get(
            Uri.parse(url),
            headers: {if (token.isNotEmpty && token != 'null') 'Authorization': token},
          ).timeout(const Duration(seconds: 4));
        }

        if (response.statusCode == 200) {
          var decoded = json.decode(utf8.decode(response.bodyBytes));
          List<dynamic> res = [];
          if (decoded is List) {
            res = decoded;
          } else if (decoded is Map && decoded['data'] is List) {
            res = decoded['data'];
          }

          if (res.isNotEmpty) {
            for (var i = 0; i < res.length; i++) {
              var r = res[i];
              String sId = (r['ID'] ?? r['id'] ?? r['journal_no'] ?? r['JOURNAL_NO'] ?? '').toString();
              String sNo = (r['JOURNAL_NO'] ?? r['journal_no'] ?? '').toString();
              String key = sId + '_' + sNo;
              
              String parsedStatus = (r['STATUS'] ?? r['status'] ?? r['approve_status'] ?? r['status_id'] ?? '0').toString();
              if (parsedStatus.isEmpty || parsedStatus == 'null') {
                parsedStatus = '0';
              }
              
              if (seenKeys.contains(key)) {
                // If we already saw this item, but the new one has a non-zero status (like '1' or '3'),
                // we should update it so that 'listbyemp' returning '0' doesn't override actual status.
                if (parsedStatus != '0') {
                  int idx = data.indexWhere((element) => element.id == sId);
                  if (idx >= 0 && data[idx].status == '0') {
                    Storeissue old = data[idx];
                    data[idx] = Storeissue(
                      id: old.id,
                      journal_no: old.journal_no,
                      trans_date: old.trans_date,
                      created_by: old.created_by,
                      created_name: old.created_name,
                      status: parsedStatus,
                      emp_full_name: old.emp_full_name,
                    );
                  }
                }
                continue;
              }
              seenKeys.add(key);

              String reqName = (r['EMP_FULL_NAME'] ?? r['created_name'] ?? r['REQUEST_BY'] ?? r['created_by'] ?? '').toString();
              if (reqName.isEmpty) reqName = (r['REQUEST_BY'] ?? r['created_by'] ?? '').toString();

              final Storeissue personRes = Storeissue(
                id: sId,
                journal_no: sNo,
                trans_date: (r['TRANS_DATE'] ?? r['trans_date'] ?? '').toString(),
                created_by: (r['REQUEST_BY'] ?? r['created_by'] ?? '').toString(),
                created_name: reqName,
                status: parsedStatus,
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

    List<String> detailUrls = [
      url_issue_list_detail + "/" + _issueid,
      "https://api.cicsupports.com/api/findjournaldetail",
      "https://api.cicsupports.com/ptbmprod/api_find_journal_detail.php",
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
          var decoded = json.decode(utf8.decode(response.bodyBytes));
          List<dynamic> res = [];
          if (decoded is List) {
            res = decoded;
          } else if (decoded is Map && decoded['data'] is List) {
            res = decoded['data'];
          }

          if (res.isNotEmpty) {
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
            notifyListeners();
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

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      EasyLoading.showError('ไม่มีสัญญาณอินเทอร์เน็ต กรุณาลองใหม่');
      return false;
    }

    List<String> approveUrls = [
      url_issue_approve,
      "https://api.cicsupports.com/api/approve_issue",
      "https://api.cicsupports.com/api/force_approve_issue",
      "https://api.cicsupports.com/ptbmprod/api_approve_journal.php",
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
        if (err is Exception && err.toString().contains('เกิดข้อผิดพลาดในการอนุมัติ')) {
          rethrow;
        }
      }
    }
    return false;
  }

  Future<bool> checkWorkOrderExist(String jobNo) async {
    final pref = await SharedPreferences.getInstance();
    final String? token = pref.getString('token');
    final String cleanJobNo = jobNo.trim();

    if (cleanJobNo.isEmpty) return false;

    final Map<String, dynamic> filterData = {
      'wo_number': cleanJobNo,
      'job_no': cleanJobNo,
      'job_ref_no': cleanJobNo
    };

    List<String> phpEndpoints = [
      "https://api.cicsupports.com/ptbmprod/api_check_work_order.php",
      "http://192.168.60.231/ptbmprod/api_check_work_order.php",
    ];

    for (String endpoint in phpEndpoints) {
      try {
        http.Response response = await http.post(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'
          },
          body: json.encode(filterData),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          var res = json.decode(response.body);
          if (res != null && res is Map) {
            if (res.containsKey('exists')) {
              bool isExist = (res['exists'] == true || res['exists'] == 1 || res['exists'].toString() == 'true');
              if (isExist) return true;
            }
            int cnt = int.tryParse(res['count']?.toString() ?? '0') ?? 0;
            if (cnt > 0) return true;
          }
        }
      } catch (e) {
        print('error checkWorkOrderExist PHP API ($endpoint): $e');
      }
    }

    try {
      http.Response response = await http.post(
        Uri.parse("https://api.cicsupports.com/api/checkworkorder"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}'
        },
        body: json.encode(filterData),
      );

      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        if (res != null) {
          if (res is Map) {
            if (res.containsKey('exists')) {
              return (res['exists'] == true || res['exists'] == 1 || res['exists'].toString() == 'true');
            } else if (res.containsKey('count')) {
              int cnt = int.tryParse(res['count'].toString()) ?? 0;
              if (cnt > 0) return true;
            }
          } else if (res is List && res.isNotEmpty) {
            return true;
          }
        }
      }
    } catch (e) {
      print('error checkWorkOrderExist Node API: $e');
    }

    return false;
  }

  Future<int> checkJobNoCount(String jobNo) async {
    final pref = await SharedPreferences.getInstance();
    final String? token = pref.getString('token');
    final String cleanJobNo = jobNo.trim();

    if (cleanJobNo.isEmpty) return 0;

    final Map<String, dynamic> filterData = {
      'job_no': cleanJobNo,
      'job_ref_no': cleanJobNo
    };
    try {
      http.Response response = await http.post(
        Uri.parse("https://api.cicsupports.com/api/checkjobcount"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}'
        },
        body: json.encode(filterData),
      );

      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        if (res != null) {
          if (res is Map && res.containsKey('count')) {
            return int.tryParse(res['count'].toString()) ?? 0;
          } else if (res is List) {
            return res.length;
          }
        }
      }
    } catch (e) {
      print('error checkJobNoCount API: $e');
    }

    return 0;
  }

  Future<Map<String, dynamic>> checkDuplicateIssueAlert(String jobNo, String itemId, String itemName, String empCode) async {
    List<String> checkUrls = [
      'https://api.cicsupports.com/ptbmprod/api_check_duplicate_issue_alert.php',
      'http://192.168.60.231/ptbmprod/api_check_duplicate_issue_alert.php'
    ];

    Map<String, dynamic> reqData = {
      'job_ref_no': jobNo,
      'item_id': itemId,
      'item_name': itemName,
      'emp_code': empCode,
      'trigger_notify': 1
    };

    for (String url in checkUrls) {
      try {
        final http.Response res = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(reqData),
        ).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          var body = json.decode(res.body);
          if (body != null) {
            return body; 
          }
        }
      } catch (e) {
        print('Error checkDuplicateIssueAlert at $url: $e');
      }
    }
    return {};
  }

  Future<bool> addJournal(List<dynamic> listdata, String job_no, {bool forcePending = false, String? approverEmpCode, String? approverName, String? idempotencyKey}) async {
    String _user_id = "";
    String _dept_code = "";

    bool _iscomplated = false;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _user_id = prefs.getString('emp_code') ?? "";
    _dept_code = prefs.getString('department_code') ?? prefs.getString('department_id') ?? prefs.getString('dept_name') ?? "";
    final String? token = prefs.getString('token');
    final String? level_type_id = prefs.getString('level_type_id');
    
    var jsonx = listdata
        .map((e) {
          int parsedQty = (double.tryParse(e.qty.toString().replaceAll(',', '')) ?? 1).round();
          if (parsedQty <= 0) parsedQty = 1;
          return {
            'itemid': e.id?.toString() ?? '',
            'itemname': e.name?.toString() ?? '',
            'qty': parsedQty,
            'unit_name': e.unit_name?.toString() ?? '',
            'remark': e.remark,
          };
        })
        .toList();

    String? final_level_type_id = level_type_id;
    if (forcePending) {
      final_level_type_id = '1';
    }

    final Map<String, dynamic> orderData = {
      'user_id': _user_id,
      'job_no': job_no.trim(),
      'data': jsonx,
      'level_type_id': final_level_type_id,
      'dept_code': _dept_code,
      if (approverEmpCode != null && approverEmpCode.isNotEmpty) 'approver_emp_code': approverEmpCode,
      if (approverName != null && approverName.isNotEmpty) 'approver_name': approverName,
      if (idempotencyKey != null && idempotencyKey.isNotEmpty) 'idempotency_key': idempotencyKey,
    };
    print('data will save journal to https://api.cicsupports.com/api/addjournal: ${orderData}');

    List<String> addJournalUrls = [
      "https://api.cicsupports.com/api/addjournal",
    ];

    for (String url in addJournalUrls) {
      try {
        http.Response response;
        if (url.contains('.php')) {
          response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {
              'user_id': _user_id,
              'job_no': job_no,
              'data': json.encode(jsonx),
              'items': json.encode(jsonx),
              'lines': json.encode(jsonx),
              if (idempotencyKey != null && idempotencyKey.isNotEmpty) 'idempotency_key': idempotencyKey,
            },
          ).timeout(const Duration(seconds: 90));

          if (response.statusCode != 200) {
            response = await http.post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'
              },
              body: json.encode(orderData),
            ).timeout(const Duration(seconds: 90));
          }
        } else {
          response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'
            },
            body: json.encode(orderData),
          ).timeout(const Duration(seconds: 90));
        }

        if (response.statusCode == 200) {
          print('data added journal response from $url: ${response.body}');
          _iscomplated = true;
          return _iscomplated;
        } else {
          print('Failed to add journal at $url, status: ${response.statusCode}, body: ${response.body}');
        }
      } catch (err) {
        print('cannot create journal at $url: $err');
      }
    }

    return _iscomplated;
  }
}
