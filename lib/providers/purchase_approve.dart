import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  final String baseUrl = 'http://api.cicsupports.com:1223/api/pr-approve'; // Update with your actual production/dev API

  Future<void> fetchPendingList() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? empCode = prefs.getString('emp_code');

      if (token == null || empCode == null) {
        throw Exception('User not logged in');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/pending/$empCode'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _pendingList = data['data'] ?? [];
        } else {
          _errorMessage = data['message'] ?? 'Failed to load data';
        }
      } else {
        _errorMessage = 'Error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error connecting to server: $e';
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

      final response = await http.get(
        Uri.parse('$baseUrl/detail/$prId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _currentPrDetail = data['data'];
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

      final response = await http.post(
        Uri.parse('$baseUrl/action'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'pr_id': prId,
          'action': action, // '1' = Approve, '2' = Reject, '3' = Return
          'remark': remark,
          'emp_code': empCode ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == true;
      }
      return false;
    } catch (e) {
      print('Error sending action: $e');
      return false;
    }
  }
}
