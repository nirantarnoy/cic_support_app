import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/bigcheckdetail.dart';
import 'package:flutter_cic_support/models/bigplanarea.dart';
import 'package:flutter_cic_support/models/fiverank.dart';
import 'package:flutter_cic_support/models/inspectionsafetytrans.dart';
import 'package:flutter_cic_support/models/inspectiontrans.dart';
import 'package:flutter_cic_support/models/jobcheckdetail.dart';
import 'package:flutter_cic_support/models/jobplanaraerepeat.dart';
import 'package:flutter_cic_support/models/jobplanarea.dart';
import 'package:flutter_cic_support/models/jobplanareasaved.dart';
import 'package:flutter_cic_support/models/jobsafetyplanarea.dart';
import 'package:flutter_cic_support/models/nonconformtitle.dart';
import 'package:flutter_cic_support/models/personcurrentplan.dart';
import 'package:flutter_cic_support/models/personcurrentplanrepeat.dart';
import 'package:flutter_cic_support/models/planareagroup.dart';
import 'package:flutter_cic_support/models/securitycheckarea.dart';
import 'package:flutter_cic_support/models/securitycheckdata.dart';
import 'package:flutter_cic_support/models/securitycheckedlist.dart';
import 'package:flutter_cic_support/models/transhistoryemp.dart';
import 'package:flutter_cic_support/sqlite/inspectionmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:flutter_cic_support/sqlite/dbprovider.dart';

class SecurityplanData extends ChangeNotifier {
  final String url_to_security_checkplan_by_emp =
      "http://192.168.60.196:1223/api/securitycheck/findtopicbyemp";
  // final String url_to_security_checkplan_by_emp =
  //     "https://api.cicsupports.com/api/securitycheck/findtopicbyemp";
  final String url_to_getplanby_person_saved =
      "https://api.cicsupports.com/api/teaminspectionitem/findbyteamsaved";
  // final String url_to_add_security_check_trans =
  //     "http://192.168.60.192:1223/api/securitycheck/addsecuritycheck";
  final String url_to_add_security_check_trans =
      "https://api.cicsupports.com/api/securitycheck/addsecuritycheck";

  late List<SecuritycheckData> _plan = [];
  List<SecuritycheckData> get listSecurityplan => _plan;

  late List<JobplanAreaSaved> _plansaved = [];
  List<JobplanAreaSaved> get listJobplanAreaSaved => _plansaved;

  late List<SecuritycheckedList> _securitycheckedlist = [];
  List<SecuritycheckedList> get listSecuritychecked => _securitycheckedlist;

  late int _finished_check = 0;
  int get finishedcheck => _finished_check;

  late int _repeat_check = 0;
  int get repeatcheck => _repeat_check;

  late int _finished_safety_check = 0;
  int get finishedsafetycheck => _finished_safety_check;

  set finishedcheck(int val) {
    _finished_check = val;
  }

  set listSecuritychecked(List<SecuritycheckedList> val) {
    _securitycheckedlist = val;
  }

  set finishedsafetycheck(int val) {
    _finished_safety_check = val;
  }

  set listSecurityplan(List<SecuritycheckData> val) {
    _plan = val;
  }

  set listJobplanAreaSaved(List<JobplanAreaSaved> val) {
    _plansaved = val;
  }

  late List<InspectionTrans> _inspectiontrans = [];
  List<InspectionTrans> get listInspectiontrans => _inspectiontrans;

  set listInspectiontrans(List<InspectionTrans> val) {
    _inspectiontrans = val;
  }

  late List<InspectionSafetyTrans> _inspectionsafetytrans = [];
  List<InspectionSafetyTrans> get listInspectionSafetytrans =>
      _inspectionsafetytrans;

  set listInspectionSafetytrans(List<InspectionSafetyTrans> val) {
    _inspectionsafetytrans = val;
  }

  int countCheckedTopicitem(String area_id) {
    int cnt = 0;
    listSecurityplan.forEach((element) {
      if (element.id == area_id) {
        cnt += 1;
      }
    });
    return cnt;
  }

  int countCheckedTopicBigcleanitem(String area_id) {
    int cnt = 0;
    listInspectiontrans.forEach((element) {
      if (element.area_id == area_id && int.parse(element.score) > -1) {
        cnt += 1;
      }
    });
    return cnt;
  }

  void clearCheckedTrans() {
    if (listSecuritychecked.isNotEmpty) {
      listSecuritychecked.clear();
    }
  }

  void updateSecurityCheckList(String asset_id) {
    listSecurityplan.forEach((element) {
      if (element.id == asset_id) {
        element.checked_status = "1";
      }
    });
  }

  bool addcheckedtopiclist(String _asset_id, String _topic_id,
      String _checkresult, String _index, String _area_id) {
    if (listSecuritychecked.isNotEmpty) {
      listSecuritychecked.forEach((element) {
        if (element.asset_id == _asset_id &&
            element.topic_id == _topic_id &&
            element.area_id == _area_id) {
          element.check_result = _checkresult;
        } else {
          SecuritycheckedList xlist = SecuritycheckedList(
            asset_id: _asset_id,
            topic_id: _topic_id,
            check_result: _checkresult = _checkresult,
            topic_index: _index,
            area_id: _area_id,
          );

          // data.add(xlist);

          listSecuritychecked.add(xlist);
        }
      });
    } else {
      // List<SecuritycheckedList> data = [];
      SecuritycheckedList xlist = SecuritycheckedList(
        asset_id: _asset_id,
        topic_id: _topic_id,
        check_result: _checkresult = _checkresult,
        topic_index: _index,
        area_id: _area_id,
      );

      // data.add(xlist);

      listSecuritychecked.add(xlist);
    }
    print("added sucurity checked count is ${listSecuritychecked.length}");
    notifyListeners();
    return true;
  }

  String checkhaschecklist(String _asset_id, String _topic_id, String _index) {
    String str = "";
    if (listSecuritychecked.isNotEmpty) {
      listSecuritychecked.forEach((element) {
        if (element.asset_id == _asset_id &&
            element.topic_id == _topic_id &&
            element.topic_index == _index &&
            element.check_result != "") {
          str = element.check_result;
        }
      });

      //print("security checked list is ${listSecuritychecked[0].asset_id}");
    }

    return str;
  }

  Future<dynamic> fetchSecurityCheckplan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("emp_key").toString();
    final String token = prefs.getString("token").toString();

    final Map<String, dynamic> filterData = {
      'user_id': int.parse(user_id),
    };

    notifyListeners();

    //listJobplanArea.clear();
    if (listSecurityplan.length == 0) {
      try {
        http.Response response;
        response = await http.post(
          Uri.parse(url_to_security_checkplan_by_emp),
          headers: {"Authorization": token, 'Content-Type': 'application/json'},
          body: json.encode(filterData),
        );

        if (response.statusCode == 200) {
          List<SecuritycheckData> data = [];
          List<dynamic> res = json.decode(response.body);

          if (res == null) {
            print("no data");
            return false;
          }

          for (var i = 0; i <= res.length - 1; i++) {
            final SecuritycheckData _item = SecuritycheckData(
              id: res[i]["id"].toString(),
              code: res[i]["code"].toString(),
              description: res[i]["description"].toString(),
              location_id: res[i]["location_id"].toString(),
              location_name: res[i]["location_name"].toString(),
              building_id: res[i]["building_id"].toString(),
              status: res[i]["status"].toString(),
              assign_emp_id: res[i]["assign_emp_id"].toString(),
              section_name: res[i]["section_name"].toString(),
              checked_status: "0",
              plan_id: res[i]["plan_id"].toString(),
            );

            data.add(_item);
          }
          listSecurityplan = data;
          notifyListeners();
          return listSecurityplan;
        } else {
          print("No Data");
        }
      } catch (err) {
        print("error na ja is ${err}");
      }
    }
  }

  Future<bool> submitSecuritycheck(String _asset_id, String _remark,
      List<String> _photo, String _plan_id) async {
    // print("list data is ${listInspectiontrans[0].area_id}");
    // return false;
    if (listSecuritychecked.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String user_id = prefs.getString("user_id").toString();
      // final String team_id = prefs.getString("team_id").toString();
      final String token = prefs.getString("token").toString();
      // final String plan_num = prefs.getString("plan_num").toString();
      int new_plan_id = 0;
      if (_plan_id != null || _plan_id != "") {
        new_plan_id = int.parse(_plan_id);
      }
      new_plan_id += 1;

      var addData = listSecuritychecked
          .map((e) => {
                'asset_id': int.parse(e.asset_id),
                'topic_id': int.parse(e.topic_id),
                'check_status': int.parse(e.check_result),
                'area_id': int.parse(e.area_id),
              })
          .toList();

      final Map<String, dynamic> insertData = {
        'user_id': int.parse(user_id),
        'remark': _remark,
        'photo': _photo,
        'data': addData,
        'plan_id': new_plan_id,
      };

      print('data save is ${json.encode(insertData)}');
      // return false;
      try {
        http.Response response;
        response = await http.post(
          Uri.parse(url_to_add_security_check_trans),
          headers: {"Authorization": token, 'Content-Type': 'application/json'},
          body: json.encode(insertData),
        );

        if (response.statusCode == 200) {
          // List<JobplanArea> data = [];
          Map<String, dynamic> res = json.decode(response.body);
          if (res == null) {
            print("no data");
            return false;
          }
          print("save security check is ok");
          clearCheckedTrans(); // clear list after save finished
          updateSecurityCheckList(_asset_id); // update line after save data
        }
        return true;
      } catch (err) {
        print("has eerror is ${err.toString()}");
        return false;
      }
      //return true;
    } else {
      print("not save naja");
      return false;
    }
  }

  Future<dynamic> fetchJobplanSaved() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("user_id").toString();
    final String token = prefs.getString("token").toString();
    final String team_id = prefs.getString("team_id").toString();

    notifyListeners();

    if (listSecurityplan.length == 0) {
      try {
        http.Response response;
        response = await http.get(
            Uri.parse(url_to_getplanby_person_saved + "/" + team_id),
            headers: {"Authorization": token});

        if (response.statusCode == 200) {
          List<JobplanAreaSaved> data = [];
          List<dynamic> res = json.decode(response.body);

          if (res == null) {
            print("no data");
            return false;
          }

          print("data plan_num is ${res[0]["plan_num"]}");

          for (var i = 0; i <= res.length - 1; i++) {
            final JobplanAreaSaved _item = JobplanAreaSaved(
              plan_id: res[i]["id"].toString(),
              plan_date: res[i]["plan_target_date"].toString(),
              plan_area_id: res[i]["area_inspection_id"].toString(),
              plan_area_name: res[i]["area_inspection_name"].toString(),
              status: "0",
            );

            data.add(_item);
          }
          listJobplanAreaSaved = data;

          notifyListeners();
          return listJobplanAreaSaved;
        } else {
          print("No Data");
        }
      } catch (err) {
        print("error na ja is ${err}");
      }
    }
  }
}
