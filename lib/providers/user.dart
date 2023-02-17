import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:flutter_cic_support/models/person.dart';
import 'package:flutter_cic_support/models/teammerber.dart';
import 'package:flutter_cic_support/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserData with ChangeNotifier {
  final String url_to_login = "http://172.16.0.231:1223/api/auth/login";
  final String url_to_profile = "http://172.16.0.231:1223/api/user/profile";
  final String url_to_update_profile_photo =
      "http://172.16.0.231:1223/api/user/updatephoto";
  final String url_to_teammember =
      "http://172.16.0.231:1223/api/user/teammember";

  late User _authenticatedUser;
  late User _emptyauthenicatedUser;
  late Timer _authTimer;

  // List<User> _user;
  // List<User> _userlogin;
  // List<User> get listuser => _user;
  // List<User> get listuserlogin => _userlogin;
  bool _isLoading = false;
  bool _isauthenuser = false;

  late List<TeamMember> _memberTeam = [];
  List<TeamMember> get listmemberteam => _memberTeam;

  late String _username_display = '';
  String get username_display => _username_display;

  late String _team_display = '';
  String get team_display => _team_display;

  late String _team_safety_display = '';
  String get team_safety_display => _team_safety_display;

  late String _photo_display = '';
  String get photo_display => _photo_display;

  late String _section_display = '';
  String get section_display => _section_display;

  set team_display(String val) {
    _team_display = val;
  }

  set team_safety_display(String val) {
    _team_safety_display = val;
  }

  set photo_display(String val) {
    _photo_display = val;
  }

  set username_display(String val) {
    _username_display = val;
  }

  set section_display(String val) {
    _section_display = val;
  }

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
        final DateTime now = DateTime.now();
        final DateTime expiryTime = now.add(Duration(seconds: 160000));
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString('token', res['data']['token'].toString());
        prefs.setString('user_id', res['data']['id'].toString());
        prefs.setString('user_name', res['data']['dns_user'].toString());
        prefs.setString('team_id', res['data']['current_team_id'].toString());

        username_display = res['data']['dns_user'].toString();
        prefs.setString('expiryTime', expiryTime.toIso8601String());

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

  String getCurrenUserName() {
    String c_username = '';
    if (username_display != '') {
      c_username = username_display;
    }
    return c_username;
  }

  String getCurrenUserPhoto() {
    String c_photo = '';
    if (photo_display != '') {
      c_photo = photo_display;
    }
    return c_photo;
  }

  String getCurrenUserSection() {
    String c_section_code = '';
    if (section_display != '') {
      c_section_code = section_display;
    }
    return c_section_code;
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

        print("profile team new data is ${res['data']}");

        team_display = res['data']['current_team_id'].toString();
        team_safety_display = res['data']['current_safety_team_id'].toString();
        photo_display = res['data']['photo'].toString();
        section_display = res['data']['section_code'].toString();

        prefs.setString('team_id', res['data']['current_team_id'].toString());
        prefs.setString(
            'team_safety_id', res['data']['current_safety_team_id'].toString());
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
        print("member team data is ${res}");

        for (var i = 0; i <= res.length - 1; i++) {
          TeamMember _item = TeamMember(
            current_team_id: res[i]['current_team_id'].toString(),
            fname: res[i]['fname'].toString(),
            lname: res[i]['lname'].toString(),
            team_leader: res[i]['is_head'].toString(),
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

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //   final String token = prefs.getString('token');
    final String? expiryTimeString = prefs.getString('expiryTime').toString();

    final DateTime now = DateTime.now();
    final parsedExpiryTime = DateTime.parse(expiryTimeString!);
    if (parsedExpiryTime.isBefore(now)) {
      // _authenticatedUser = _emptyauthenicatedUser;
      notifyListeners();
      return;
    }
    final String? emp_id = prefs.getString('emp_id').toString();
    final String? userId = prefs.getString('user_id').toString();
    final String? adUsername = prefs.getString('dns_user').toString();

    final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
    _authenticatedUser = User(
      id: userId!,
      user_id: userId,
      team_id: "0",
      username: adUsername!,
    );

    _isauthenuser = true;
    setAuthTimeout(tokenLifespan);
    notifyListeners();
  }

  Future<Map<String, dynamic>> logout() async {
    //_authenticatedUser = _emptyauthenicatedUser;
    _isauthenuser = false;
    _authTimer.cancel();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    // prefs.remove('token');
    // prefs.remove('emp_id');

    // prefs.remove('username');
    // prefs.remove('userId');
    // prefs.remove('studentId');
    _isLoading = false;
    return {'success': true};
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }

  Future<dynamic> updatePhotoprofile(List<String> profilephoto) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_ad = prefs.getString("user_name").toString();
    final String token = prefs.getString("token").toString();

    final photoJson = profilephoto.map((e) => {'photo': e}).toList();
    final Map<String, dynamic> insertData = {
      'profile_photo': profilephoto,
      'ad_user': user_ad.toString(),
    };
    //print('photo profile are ${json.encode(photoJson)}');
    print('user id is ${user_ad}');
    try {
      http.Response response;
      response = await http.post(Uri.parse(url_to_update_profile_photo),
          headers: {"Authorization": token, 'Content-Type': 'application/json'},
          body: json.encode(insertData));

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (err) {
      print('has error na ja ${err}');
      return false;
    }
  }
}
