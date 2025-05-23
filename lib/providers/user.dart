import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cic_support/main.dart';

import 'package:flutter_cic_support/models/person.dart';
import 'package:flutter_cic_support/models/teammerber.dart';
import 'package:flutter_cic_support/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserData with ChangeNotifier {
  final String url_to_login = "https://api.cicsupports.com/api/auth/login";
  final String url_to_profile = "https://api.cicsupports.com/api/user/profile";
  final String url_to_profile_normal =
      "https://api.cicsupports.com/api/user/profilenormal";

  final String url_to_login_exclude_dns =
      "https://api.cicsupports.com/api/auth/loginexcludedns";
  // final String url_to_login_exclude_dns =
  //     "http://192.168.60.196:1223/api/auth/loginexcludedns";
  final String url_to_update_profile_photo =
      "https://api.cicsupports.com/api/user/updatephoto";
  final String url_to_update_profile_photo_normal =
      "https://api.cicsupports.com/api/user/updatephotonormal";
  final String url_to_teammember =
      "https://api.cicsupports.com/api/user/teammember";
  final String url_to_teamsafetymember =
      "https://api.cicsupports.com/api/user/teamsafetymember";

  final String url_to_add_device_token =
      "http://api.cicsupports.com/api/user/adddevicetoken";

  late User _authenticatedUser;
  late User _emptyauthenicatedUser;
  late Timer _authTimer;

  // List<User> _user;
  // List<User> _userlogin;
  // List<User> get listuser => _user;
  // List<User> get listuserlogin => _userlogin;
  bool _isLoading = false;
  bool _isauthenuser = false;
  int _isUniformSelected = 0;
  int _emp_salary_type = 0;
  int _emp_level = 0;
  int _emp_gender = 0;
  int _emp_shirt_qty = 0;
  int _userlogin_type = 0;

  late List<TeamMember> _memberTeam = [];
  List<TeamMember> get listmemberteam => _memberTeam;

  late List<TeamMember> _memberSafetyTeam = [];
  List<TeamMember> get listmembersafetyteam => _memberSafetyTeam;

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

  late String _empfullname = '';
  String get empfullname => _empfullname;

  int get unitformSelected => _isUniformSelected;

  int get empsalarytype => _emp_salary_type;

  int get emplevel => _emp_level;

  int get empgender => _emp_gender;

  int get empshirtqty => _emp_shirt_qty;

  int _emp_department_id = 0;
  int get empdepartmentid => _emp_department_id;

  int get userlogintype => _userlogin_type;

  String _emp_department_name = '';
  String get emp_department_name => _emp_department_name;

  String _emp_position_name = '';
  String get emppositionname => _emp_position_name;

  set empfullname(String val) {
    _empfullname = val;
  }

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

  set listmembersafetyteam(List<TeamMember> val) {
    _memberSafetyTeam = val;
  }

  set unitformSelected(int val) {
    _isUniformSelected = val;
  }

  set empsalarytype(int val) {
    _emp_salary_type = val;
  }

  set emplevel(int val) {
    _emp_level = val;
  }

  set empdepartmentid(int val) {
    _emp_department_id = val;
  }

  set empdepartmentname(String val) {
    _emp_department_name = val;
  }

  set emppositionname(String val) {
    _emp_position_name = val;
  }

  set empgender(int val) {
    _emp_gender = val;
  }

  set empshirtqty(int val) {
    _emp_shirt_qty = val;
  }

  set userlogintype(int val) {
    _userlogin_type = val;
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
          bigclean_team_id: res['data']['bigclean_current_team_id'].toString(),
        );

        data.add(user);
        final DateTime now = DateTime.now();
        final DateTime expiryTime = now.add(Duration(seconds: 160000));
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString('token', res['data']['token'].toString());
        prefs.setString('user_id', res['data']['id'].toString());
        prefs.setString('user_name', res['data']['dns_user'].toString());
        prefs.setString('team_id', res['data']['current_team_id'].toString());
        prefs.setString('bigclean_team_id',
            res['data']['bigclean_current_team_id'].toString());

        username_display = res['data']['dns_user'].toString();
        prefs.setString('expiryTime', expiryTime.toIso8601String());

        userlogintype = 1; // AD User

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

  Future<dynamic> loginExcludeDNS(String username, String pwd) async {
    final Map<String, dynamic> loginData = {
      'username': username,
      'password': pwd,
    };

    print("data login is ${loginData}");

    try {
      http.Response response;
      response = await http.post(Uri.parse(url_to_login_exclude_dns),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(loginData));

      if (response.statusCode == 200) {
        Map<String, dynamic> res = json.decode(response.body);
        List<Person> data = [];

        if (res == null) {
          notifyListeners();
          return false;
        }

        if (res['data']['level_type_id'] == 3) {
          // return false;
        }

        final Person user = Person(
          id: res['data']['id'].toString(),
          person_name: res['data']['fname'].toString() +
              " " +
              res['data']['lname'].toString(),
          team_id: "",
          bigclean_team_id: "",
          emp_key: res['data']['emp_ref_id'].toString(),
        );

        data.add(user);
        final DateTime now = DateTime.now();
        final DateTime expiryTime = now.add(Duration(seconds: 160000));
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString('token', res['data']['token'].toString());
        prefs.setString('user_id', res['data']['id'].toString());
        prefs.setString('emp_code', res['data']['emp_code'].toString());
        prefs.setString('user_name', res['data']['dns_user'].toString());
        prefs.setString('team_id', res['data']['current_team_id'].toString());
        prefs.setString('emp_key', res['data']['emp_ref_id'].toString());
        prefs.setString('salary_type', res['data']['salary_type'].toString());
        prefs.setString(
            'department_id', res['data']['department_id'].toString());
        prefs.setString('position_id', res['data']['position_id'].toString());
        prefs.setString(
            'position_name', res['data']['position_name'].toString());
        prefs.setString('bigclean_team_id',
            res['data']['bigclean_current_team_id'].toString());

        username_display = res['data']['dns_user'].toString();
        empfullname = res['data']['fname'] + " " + res['data']['lname'];
        prefs.setString('expiryTime', expiryTime.toIso8601String());

        print("res data is ${res['data']}");
        // print("token is ${res['data']['token']}");

        print("emp key is ${res['data']['emp_ref_id'].toString()}");

        unitformSelected = res['data']['uniform_selected'];
        empsalarytype = res['data']['salary_type'];
        emplevel = res['data']['level_type_id'];
        empdepartmentid = int.parse(res['data']['department_id'].toString());
        emppositionname = res['data']['position_name'].toString();
        empgender = res['data']['emp_gender'];
        empshirtqty = res['data']['shirt_qty'];

        photo_display = res['data']['photo'].toString();

        userlogintype = 2; // Employee
        notifyListeners();
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

    //photo_display = '';
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

        //print("profile team new data is ${res['data']}");

        team_display = res['data']['current_team_id'].toString();
        team_safety_display = res['data']['current_safety_team_id'].toString();
        photo_display = res['data']['photo'].toString();
        section_display = res['data']['section_code'].toString();
        prefs.setString('emp_code', res['data']['emp_code'].toString());
        prefs.setString('emp_key', res['data']['emp_key'].toString());

        prefs.setString('team_id', res['data']['current_team_id'].toString());
        prefs.setString('bigclean_team_id',
            res['data']['current_bigclean_team_id'].toString());
        prefs.setString(
            'team_safety_id', res['data']['current_safety_team_id'].toString());

        empsalarytype = res['data']['salary_type'];
        emplevel = res['data']['level_type_id'];
        empdepartmentid = int.parse(res['data']['department_id'].toString());
        emppositionname = res['data']['position_name'].toString();
        empgender = res['data']['emp_gender'];
        empshirtqty = res['data']['shirt_qty'];
        print('emp photo profile is ${photo_display}');

        notifyListeners();
        return true;
      } else {
        print(response.body);
      }
    } catch (err) {
      print('error is ${err}');
    }
  }

  Future<dynamic> fetchProfileNormal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token").toString();
    final String emp_key = prefs.getString("emp_key").toString();

    //photo_display = '';
    try {
      http.Response response;
      response = await http.get(
        Uri.parse(url_to_profile_normal + "/" + emp_key),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res = json.decode(response.body);
        List<TeamMember> data = [];

        if (res == null) {
          notifyListeners();
          return false;
        }

        photo_display = res['data']['photo'].toString();
        print("normal photo is ${photo_display}");

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

  Future<dynamic> findTeamSafetyMember() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token").toString();
    final String safety_team_id = prefs.getString("team_safety_id").toString();

    try {
      http.Response response;
      response = await http.get(
        Uri.parse(url_to_teamsafetymember + "/" + safety_team_id),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        List<dynamic> res = json.decode(response.body);
        List<TeamMember> data = [];

        if (res == null) {
          notifyListeners();
          return false;
        }
        print("member safety team data is ${res}");

        for (var i = 0; i <= res.length - 1; i++) {
          TeamMember _item = TeamMember(
            current_team_id: res[i]['current_safety_team_id'].toString(),
            fname: res[i]['fname'].toString(),
            lname: res[i]['lname'].toString(),
            team_leader: res[i]['is_head'].toString(),
          );
          data.add(_item);
        }
        listmembersafetyteam = data;
        notifyListeners();
        //  print("data is ${data[0].fname}");
        return listmembersafetyteam;
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
    prefs.remove('token');
    prefs.remove('emp_id');
    prefs.remove('emp_code');

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
    print('photo profile are ${json.encode(photoJson)}');
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

  Future<dynamic> updatePhotoprofilenormal(List<String> profilephoto) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String emp_key = prefs.getString("emp_key").toString();
    final String token = prefs.getString("token").toString();

    final photoJson = profilephoto.map((e) => {'photo': e}).toList();
    final Map<String, dynamic> insertData = {
      'profile_photo': profilephoto,
      'emp_ref_id': int.parse(emp_key),
    };
    print('photo profile are ${json.encode(photoJson)}');
    print('emp key id is ${emp_key}');
    try {
      http.Response response;
      response = await http.post(Uri.parse(url_to_update_profile_photo_normal),
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

  Future<bool> addDeviceToken() async {
    String _user_id = "";
    bool _iscompleted = false;

    String? _device_token = await FirebaseMessaging.instance.getToken();

    if (_device_token != null || _device_token != "") {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _user_id = prefs.getString('user_id') ?? "";
      final String? token = prefs.getString('token');
      final Map<String, dynamic> addData = {
        'user_id': int.parse(_user_id),
        'device_token': _device_token,
      };
      print('device token is ${_device_token}');

      print('data will save device token is ${addData}');
      try {
        http.Response response;
        response = await http.post(Uri.parse(url_to_add_device_token),
            headers: {
              "Authorization": token!,
              'Content-Type': 'application/json'
            },
            body: json.encode(addData));

        if (response.statusCode == 200) {
          Map<String, dynamic> res = json.decode(response.body);
          print('add device token is ${res}');
          _iscompleted = true;
        } else {
          _iscompleted = false;
        }
      } catch (error) {
        _iscompleted = false;
      }
      return _iscompleted;
    } else {
      return _iscompleted;
    }
  }
}
