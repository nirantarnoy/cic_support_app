import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PurchaseApproveProvider with ChangeNotifier {
  List<dynamic> _pendingList = [];
  bool _isLoading = false;
  String _errorMessage = '';
  
  Map<String, dynamic>? _currentPrDetail;
  bool _isDetailLoading = false;

  List<dynamic> get pendingList => _pendingList;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Map<String, dynamic>? get currentPrDetail => _currentPrDetail;
  bool get isDetailLoading => _isDetailLoading;

  final List<String> baseUrls = [
    'http://api.cicsupports.com:1223/api/pr-approve',
    'http://172.16.0.231:3000/api/pr-approve',
    'http://192.168.60.195:3000/api/pr-approve'
  ];

  Future<void> fetchPendingList() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? empCode = prefs.getString('emp_code');

      if (token == null || empCode == null) {
        print('====== PurchaseApprove API (fetchPendingList) ======');
        print('Error: token or empCode is null');
        _pendingList = [];
      } else {
        bool success = false;
        for (String baseUrl in baseUrls) {
          try {
            final url = '$baseUrl/pending/$empCode';
            print('====== PurchaseApprove API (fetchPendingList) ======');
            print('URL: $url');
            print('Headers: {Authorization: Bearer ***, Content-Type: application/json}');

            final response = await http.get(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            ).timeout(const Duration(seconds: 4));

            print('Status Code: ${response.statusCode}');
            print('Response Body: ${response.body}');
            print('====================================================');

            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              if (data['status'] == true) {
                _pendingList = data['data'] ?? [];
              } else {
                _pendingList = [];
              }
              success = true;
              break;
            }
          } catch (e) {
            print('Error with $baseUrl: $e');
          }
        }
        if (!success) {
          _pendingList = [];
        }
      }
    } catch (e) {
      // หากเชื่อมต่อไม่ได้หรือ Timeout ให้แสดงเป็นลิสต์ว่างๆ แทนการหมุนค้าง
      _pendingList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPrDetail(int prId) async {
    _isDetailLoading = true;
    _currentPrDetail = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      for (String baseUrl in baseUrls) {
        try {
          final url = '$baseUrl/detail/$prId';
          print('====== PurchaseApprove API (fetchPrDetail) ======');
          print('URL: $url');
          print('Headers: {Authorization: Bearer ***, Content-Type: application/json}');

          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ).timeout(const Duration(seconds: 4));

          print('Status Code: ${response.statusCode}');
          print('Response Body: ${response.body}');
          print('=================================================');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['status'] == true) {
              _currentPrDetail = data['data'];
            }
            break;
          }
        } catch (e) {
          print('Error with $baseUrl: $e');
        }
      }
    } catch (e) {
      print('Error fetching PR detail: $e');
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<bool> actionPr(int prId, String action, String remark) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? empCode = prefs.getString('emp_code');

      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        EasyLoading.showError('ไม่มีสัญญาณอินเทอร์เน็ต กรุณาลองใหม่');
        return false;
      }

      for (String baseUrl in baseUrls) {
        try {
          final url = '$baseUrl/action';
          final bodyData = {
            'pr_id': prId,
            'action': action, // '1' = Approve, '2' = Reject, '3' = Return
            'remark': remark,
            'emp_code': empCode ?? '',
          };

          print('====== PurchaseApprove API (actionPr) ======');
          print('URL: $url');
          print('Headers: {Authorization: Bearer ***, Content-Type: application/json}');
          print('Body: ${json.encode(bodyData)}');

          final response = await http.post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(bodyData),
          ).timeout(const Duration(seconds: 4));

          print('Status Code: ${response.statusCode}');
          print('Response Body: ${response.body}');
          print('============================================');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            return data['status'] == true;
          }
        } catch (e) {
          print('Error with $baseUrl: $e');
        }
      }
      return false;
    } catch (e) {
      print('Error sending action: $e');
      return false;
    }
  }
}
