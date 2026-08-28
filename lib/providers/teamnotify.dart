import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/teamnotify.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TeamnotifyData extends ChangeNotifier {
  final String url_to_get_notify =
      "https://api.cicsupports.com/api/notifications";
  final String url_to_read_notify =
      "https://api.cicsupports.com/api/notifications/read";
  final String url_to_get_team_notify =
      "https://api.cicsupports.com/api/teamnotify/findteamnotify";

  List<Teamnotify> _teamnotify = [];
  List<Teamnotify> get listteamnotify => _teamnotify;

  set listteamnotify(List<Teamnotify> val) {
    _teamnotify = val;
  }

  /// Safely extract a [List<dynamic>] from a decoded JSON body
  /// that may be either a plain array or a wrapped object {"data": [...]}.
  List<dynamic>? _safeList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['data'] is List) {
      return decoded['data'] as List<dynamic>;
    }
    return null;
  }

  List<Teamnotify> _mapItems(List<dynamic> res) {
    return res.map((item) {
      return Teamnotify(
        id: item['id']?.toString() ?? '',
        trans_ref_id: item['journal_no']?.toString() ?? item['trans_ref_id']?.toString() ?? '',
        module_type_id: item['module_type_id']?.toString() ?? '',
        emp_id: item['emp_code']?.toString() ?? item['emp_id']?.toString() ?? '',
        title: item['title']?.toString() ?? '',
        detail: item['body']?.toString() ?? item['detail']?.toString() ?? '',
        read_status: item['is_read']?.toString() ?? item['read_status']?.toString() ?? '0',
        notify_date: item['created_at']?.toString() ?? item['notify_date']?.toString() ?? '',
      );
    }).toList();
  }

  Future<dynamic> teamnotifyFetch() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String empCode = prefs.getString("emp_code").toString();
    final String token = prefs.getString("token").toString();

    try {
      final uri = Uri.parse("$url_to_get_notify?emp_code=$empCode");
      print("DEBUG calling GET: $uri");
      final response = await http.get(
        uri,
        headers: {"Authorization": token},
      );

      if (response.statusCode == 200) {
        print("has data notify");
        final res = _safeList(json.decode(response.body));
        if (res == null || res.isEmpty) {
          print("notify: empty or unrecognised format");
          listteamnotify = [];
          notifyListeners();
          return false;
        }
        print("notify id[0]: ${res[0]["id"]}");
        listteamnotify = _mapItems(res);
        notifyListeners();
        return listteamnotify;
      } else {
        print("notify: HTTP ${response.statusCode}");
        return false;
      }
    } catch (err) {
      print("teamnotifyFetch error: $err");
      return false;
    }
  }

  Future<dynamic> teamnotifyAllFetch() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String teamId = prefs.getString("team_id").toString();
    final String token = prefs.getString("token").toString();

    try {
      final response = await http.get(
        Uri.parse("$url_to_get_team_notify/$teamId"),
        headers: {"Authorization": token},
      );

      if (response.statusCode == 200) {
        print("has data (team notify)");
        final res = _safeList(json.decode(response.body));
        if (res == null || res.isEmpty) {
          print("team notify: empty or unrecognised format");
          listteamnotify = [];
          notifyListeners();
          return false;
        }
        print("team notify id[0]: ${res[0]["id"]}");
        listteamnotify = _mapItems(res);
        notifyListeners();
        return listteamnotify;
      } else {
        print("team notify: HTTP ${response.statusCode}");
        return false;
      }
    } catch (err) {
      print("teamnotifyAllFetch error: $err");
      return false;
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token").toString();

    try {
      final response = await http.post(
        Uri.parse(url_to_read_notify),
        headers: {
          "Authorization": token,
          "Content-Type": "application/json",
        },
        body: json.encode({"notification_id": notificationId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final index = _teamnotify.indexWhere((n) => n.id == notificationId.toString());
        if (index != -1) {
          _teamnotify[index].read_status = "1";
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (err) {
      print("markAsRead error: $err");
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String empCode = prefs.getString("emp_code").toString();
    final String token = prefs.getString("token").toString();

    try {
      final response = await http.post(
        Uri.parse(url_to_read_notify),
        headers: {
          "Authorization": token,
          "Content-Type": "application/json",
        },
        body: json.encode({"emp_code": empCode}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        for (var n in _teamnotify) {
          n.read_status = "1";
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (err) {
      print("markAllAsRead error: $err");
      return false;
    }
  }
}
