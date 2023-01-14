import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:flutter_cic_support/models/person.dart';
import 'package:flutter_cic_support/models/teammerber.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserData with ChangeNotifier {
  final String url_to_login = "http://192.168.60.58:1223/api/auth/login";
  final String url_to_profile = "http://192.168.60.58:1223/api/user/profile";
  final String url_to_teammember =
      "http://192.168.60.58:1223/api/user/teammember";

  late List<TeamMember> _memberTeam = [];
  List<TeamMember> get listmemberteam => _memberTeam;

  set listmemberteam(List<TeamMember> val) {
    _memberTeam = val;
  }

  Future<dynamic> login(String username, String pwd) async {
    final Map<String, dynamic> loginData = {
      'username': username,
      'password': pwd,
    };

    print("data login is ${loginData}");

    try {
      http.Response response;
      response = await http.post(Uri.parse(url_to_login),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(loginData));

      if (response.statusCode == 200) {
        Map<String, dynamic> res = json.decode(response.body);
        List<Person> data = [];

        if (res == null) {
          notifyListeners();
          return false;
        }

        final Person user = Person(
          id: res['data']['id'].toString(),
          person_name: res['data']['dns_user'].toString(),
          team_id: res['data']['current_team_id'].toString(),
        );

        data.add(user);

        final SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString('token', res['data']['token'].toString());
        prefs.setString('user_id', res['data']['id'].toString());
        prefs.setString('user_name', res['data']['dns_user'].toString());
        prefs.setString('team_id', res['data']['current_team_id'].toString());

        print("res data is ${res['data']}");
        print("token is ${res['data']['token']}");
        return true;
      } else {
        print(response.body);
        return false;
      }
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<dynamic> fetchProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token").toString();
    final String user_ad = prefs.getString("user_name").toString();

    try {
      http.Response response;
      response = await http.get(
        Uri.parse(url_to_profile + "/" + user_ad),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res = json.decode(response.body);
        List<TeamMember> data = [];

        if (res == null) {
          notifyListeners();
          return false;
        }

        print("profile team data is ${res['data']}");

        prefs.setString('team_id', res['data']['current_team_id'].toString());
        notifyListeners();
        return true;
      } else {
        print(response.body);
      }
    } catch (err) {
      print('error is ${err}');
    }
  }

  Future<dynamic> findTeamMember() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token").toString();
    final String team_id = prefs.getString("team_id").toString();

    try {
      http.Response response;
      response = await http.get(
        Uri.parse(url_to_teammember + "/" + team_id),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        List<dynamic> res = json.decode(response.body);
        List<TeamMember> data = [];

        if (res == null) {
          notifyListeners();
          return false;
        }
        // print("member team data is ${res[0]['fname']}");

        for (var i = 0; i <= res.length - 1; i++) {
          TeamMember _item = TeamMember(
            current_team_id: res[i]['current_team_id'].toString(),
            fname: res[i]['fname'].toString(),
            lname: res[i]['lname'].toString(),
          );
          data.add(_item);
        }
        listmemberteam = data;
        notifyListeners();
        print("data is ${data[0].fname}");
        return listmemberteam;
      } else {
        print(response.body);
      }
    } catch (err) {
      print(err);
    }
  }
}
