import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/teamnotify.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TeamnotifyData extends ChangeNotifier {
  final String url_to_get_notify =
      "http://172.16.0.231:1223/api/teamnotify/findempnotify";
  final String url_to_get_team_notify =
      "http://172.16.0.231:1223/api/teamnotify/findteamnotify";

  List<Teamnotify> _teamnotify = [];
  List<Teamnotify> get listteamnotify => _teamnotify;

  set listteamnotify(List<Teamnotify> val) {
    _teamnotify = val;
  }

  Future<dynamic> teamnotifyFetch() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("user_id").toString();
    final String token = prefs.getString("token").toString();

    try {
      http.Response response;
      response = await http.get(Uri.parse(url_to_get_notify + "/" + user_id),
          headers: {"Authorization": token});

      if (response.statusCode == 200) {
        print("has data");
        List<dynamic> res = json.decode(response.body);
        List<Teamnotify> data = [];

        if (res == null) {
          notifyListeners();
          listteamnotify = data;
          print("data is null");
          return false;
        }

        print("noti is ${res[0]["id"]}");

        for (var i = 0; i <= res.length - 1; i++) {
          Teamnotify item = Teamnotify(
            id: res[i]['id'].toString(),
            trans_ref_id: res[i]['trans_ref_id'].toString(),
            module_type_id: res[i]['module_type_id'].toString(),
            emp_id: res[i]['emp_id'].toString(),
            title: res[i]['title'].toString(),
            detail: res[i]['detail'].toString(),
            read_status: res[i]['read_status'].toString(),
            notify_date: res[i]['notify_date'].toString(),
          );
          data.add(item);
        }
        listteamnotify = data;
        notifyListeners();
        return listteamnotify;
      } else {
        print("no dta");
        return false;
      }
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<dynamic> teamnotifyAllFetch() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String team_id = prefs.getString("team_id").toString();
    final String token = prefs.getString("token").toString();

    try {
      http.Response response;
      response = await http.get(
          Uri.parse(url_to_get_team_notify + "/" + team_id),
          headers: {"Authorization": token});

      if (response.statusCode == 200) {
        print("has data");
        List<dynamic> res = json.decode(response.body);
        List<Teamnotify> data = [];

        if (res == null) {
          notifyListeners();
          print("data is null");
          return false;
        }

        print("noti is ${res[0]["id"]}");

        for (var i = 0; i <= res.length - 1; i++) {
          Teamnotify item = Teamnotify(
            id: res[i]['id'].toString(),
            trans_ref_id: res[i]['trans_ref_id'].toString(),
            module_type_id: res[i]['module_type_id'].toString(),
            emp_id: res[i]['emp_id'].toString(),
            title: res[i]['title'].toString(),
            detail: res[i]['detail'].toString(),
            read_status: res[i]['read_status'].toString(),
            notify_date: res[i]['notify_date'].toString(),
          );
          data.add(item);
        }
        listteamnotify = data;
        notifyListeners();
        return listteamnotify;
      } else {
        print("no dta");
        return false;
      }
    } catch (err) {
      print(err);
      return false;
    }
  }
}
