import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/inspectiontrans.dart';
import 'package:flutter_cic_support/models/jobcheckdetail.dart';
import 'package:flutter_cic_support/models/jobplanarea.dart';
import 'package:flutter_cic_support/models/nonconformtitle.dart';
import 'package:flutter_cic_support/models/planareagroup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PlanData extends ChangeNotifier {
  final String url_to_getplanby_person =
      "http://192.168.60.58:1223/api/teaminspectionitem/findbyteam";
  final String url_to_add_inspection_trans =
      "http://192.168.60.58:1223/api/plan/addinspection";

  final String url_to_plan_by_emp =
      "http://192.168.60.58:1223/api/plan/listplanbyemp";

  final String url_to_noncomformall =
      "http://192.168.60.58:1223/api/carinspection/findall";

  late List<JobplanArea> _plan = [];
  List<JobplanArea> get listJobplanArea => _plan;

  late List<NonConformTitle> _nonconform = [];
  List<NonConformTitle> get listnonconform => _nonconform;

  set listJobplanArea(List<JobplanArea> val) {
    _plan = val;
  }

  set listnonconform(List<NonConformTitle> val) {
    _nonconform = val;
  }

  late List<InspectionTrans> _inspectiontrans = [];
  List<InspectionTrans> get listInspectiontrans => _inspectiontrans;

  set listInspectiontrans(List<InspectionTrans> val) {
    _inspectiontrans = val;
  }

  List<JobplanArea> getAreaTitle() {
    List<JobplanArea> _newgroup = [];
    listJobplanArea.forEach((element) {
      int has_ = 0;
      _newgroup.forEach((item_check) {
        if (item_check.plan_area_id == element.plan_area_id) {
          has_ += 1;
        }
      });
      if (has_ > 0) {
      } else {
        JobplanArea _group = JobplanArea(
          plan_id: element.plan_id,
          plan_date: "",
          plan_area_id: element.plan_area_id,
          plan_area_name: element.plan_area_name,
          plan_topic_check_qty: "",
          plan_topic_checked_qty: "",
          status: "",
          topic_id: "",
          topic_name: "",
          topic_item_id: "",
          topic_item_name: "",
          scored: "-1",
          is_enable: element.is_enable,
          seq_sort: element.seq_sort,
          seq_sort_item: element.seq_sort_item,
        );
        _newgroup.add(_group);
      }
    });
    _newgroup.sort(
      (a, b) => int.parse(a.plan_area_id).compareTo(int.parse(b.plan_area_id)),
    );
    return _newgroup.toSet().toList();
  }

  List<JobplanArea> getTopic(String plan_area_id, String plan_id) {
    List<JobplanArea> _newgroup = [];
    listJobplanArea.forEach((element) {
      int has_ = 0;
      _newgroup.forEach((item_check) {
        if (item_check.topic_id == element.topic_id &&
            element.is_enable == "1") {
          print("Has topic naja");
          has_ += 1;
        }
      });
      if (has_ > 0) {
      } else {
        if (element.plan_area_id == plan_area_id &&
            element.plan_id == plan_id &&
            element.is_enable == "1") {
          JobplanArea _group = JobplanArea(
              plan_id: element.plan_id,
              plan_date: "",
              plan_area_id: element.plan_area_id,
              plan_area_name: "",
              plan_topic_check_qty: "",
              plan_topic_checked_qty: "",
              status: "",
              topic_id: element.topic_id,
              topic_name: element.topic_name,
              topic_item_id: "",
              topic_item_name: "",
              scored: "-1",
              is_enable: element.is_enable,
              seq_sort: element.seq_sort,
              seq_sort_item: element.seq_sort_item);
          _newgroup.add(_group);
        }
      }
    });
    return _newgroup.toSet().toList();
  }

  List<JobCheckDetail> getTopicitem(String topic_id, String area_id) {
    print('area is ${area_id}');
    List<JobCheckDetail> _list = [];

    listJobplanArea.forEach((element) {
      print('topic name enable is ${element.is_enable}');
      if (element.topic_id == topic_id &&
          element.plan_area_id == area_id &&
          element.is_enable == "1") {
        JobCheckDetail _item = JobCheckDetail(
          plan_id: element.plan_id,
          topicid: element.topic_id,
          topicname: element.topic_name,
          topic_detail_id: element.topic_item_id,
          topic_detail_name: element.topic_item_name,
          status: element.status,
          score: element.scored,
          is_enable: element.is_enable,
          seq_sort: element.seq_sort,
          seq_sort_item: element.seq_sort_item,
        );
        _list.add(_item);
      }
    });
    _list.sort(
      (a, b) =>
          int.parse(b.seq_sort_item).compareTo(int.parse(a.seq_sort_item)),
    );
    notifyListeners();
    return _list;
  }

  int getTopicitemcountByTopic(String topic_id, String area_id) {
    int cnt = 0;
    listJobplanArea.forEach((element) {
      print('topic name enable is ${element.is_enable}');
      if (element.topic_id == topic_id &&
          element.plan_area_id == area_id &&
          element.is_enable == "1") {
        cnt += 1;
      }
    });
    return cnt;
  }

  int getTopicitemcountedByTopic(String topic_id, String area_id) {
    int cnt = 0;
    listJobplanArea.forEach((element) {
      print('topic name enable is ${element.is_enable}');
      if (element.topic_id == topic_id &&
          element.plan_area_id == area_id &&
          element.is_enable == "1" &&
          element.scored != '-1') {
        cnt += 1;
      }
    });
    return cnt;
  }

  int checkfinish() {
    int isfinish = 0;
    int all = 0;
    int checked = 0;
    all = listJobplanArea.length;
    listJobplanArea.forEach((element) {
      print('topic name enable is ${element.is_enable}');
      if (element.scored != '-1') {
        checked += 1;
      }
    });
    if (checked >= all) {
      isfinish = 1;
    }
    return isfinish;
  }

  List<NonConformTitle> listofnonconform_5s() {
    return listnonconform
        .where((element) => element.module_type_id == "1")
        .toList();
  }

  bool addInspectionTrans(InspectionTrans data) {
    if (data != null) {
      listInspectiontrans.forEach((element) {
        if (element.topic_item_id == data.topic_item_id &&
            element.area_id == data.area_id) {
          element.score = data.score.toString(); // update score if exist
        } else {
          listInspectiontrans.add(data); // original line
        }
      });

      listJobplanArea.forEach((element) {
        if (element.topic_item_id == data.topic_item_id &&
            element.plan_area_id == data.area_id) {
          element.status = "1";
          element.scored = data.score.toString();
        } else {
          print("no data to add");
        }
      });

      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  int countTopicitem(String area_id) {
    int cnt = 0;
    listJobplanArea.forEach((element) {
      if (element.plan_area_id == area_id) {
        cnt += 1;
      }
    });
    return cnt;
  }

  int countCheckedTopicitem(String area_id) {
    int cnt = 0;
    listJobplanArea.forEach((element) {
      if (element.plan_area_id == area_id && int.parse(element.scored) > -1) {
        cnt += 1;
      }
    });
    return cnt;
  }

  Future<dynamic> fetchJobplan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("user_id").toString();
    final String token = prefs.getString("token").toString();
    final String team_id = prefs.getString("team_id").toString();

    notifyListeners();

    print('current team is ${team_id}');

    if (listJobplanArea.length == 0) {
      try {
        http.Response response;
        response = await http.get(
            Uri.parse(url_to_getplanby_person + "/" + team_id),
            headers: {"Authorization": token});

        if (response.statusCode == 200) {
          List<JobplanArea> data = [];
          List<dynamic> res = json.decode(response.body);

          if (res == null) {
            print("no data");
            return false;
          }

          print("data is ${res[0]["seq_sort"]}");

          for (var i = 0; i <= res.length - 1; i++) {
            final JobplanArea _item = JobplanArea(
              plan_id: res[i]["id"].toString(),
              plan_date: res[i]["plan_target_date"].toString(),
              plan_area_id: res[i]["area_inspection_id"].toString(),
              plan_area_name: res[i]["area_inspection_name"].toString(),
              plan_topic_check_qty: "0",
              plan_topic_checked_qty: "0",
              status: "0",
              topic_id: res[i]["topic_id"].toString(),
              topic_name: res[i]["topic_name"].toString(),
              topic_item_id: res[i]["topic_item_id"].toString(),
              topic_item_name: res[i]["topic_item_name"].toString(),
              scored: "-1",
              is_enable: res[i]["is_enable"].toString(),
              seq_sort: res[i]["seq_sort"].toString(),
              seq_sort_item: res[i]["seq_sort_item"].toString(),
            );

            data.add(_item);
          }
          listJobplanArea = data;
          notifyListeners();
          return listJobplanArea;
        } else {
          print("No Data");
        }
      } catch (err) {
        print("error na ja is ${err}");
      }
    }
  }

  Future<bool> submitInspection() async {
    if (listInspectiontrans.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String user_id = prefs.getString("user_id").toString();
      final String team_id = prefs.getString("team_id").toString();
      final String token = prefs.getString("token").toString();

      var addData = listInspectiontrans
          .map((e) => {
                'module_type_id': int.parse(e.module_type_id),
                'plan_id': int.parse(e.plan_id),
                'trans_date': e.trans_date,
                'emp_id': int.parse(user_id),
                'area_group_id': int.parse(e.area_group_id),
                'area_id': int.parse(e.area_id),
                'team_id': int.parse(team_id),
                'topic_id': int.parse(e.topic_id),
                'topic_item_id': int.parse(e.topic_item_id),
                'score': int.parse(e.score),
                'status': int.parse(e.status),
                'note': e.note,
                'created_at': int.parse('0'),
                'created_by': int.parse(user_id),
              })
          .toList();
      print('data save is ${json.encode(addData)}');
      try {
        http.Response response;
        response = await http.post(
          Uri.parse(url_to_add_inspection_trans),
          headers: {"Authorization": token},
          body: json.encode(addData),
        );

        if (response.statusCode == 200) {
          // List<JobplanArea> data = [];
          Map<String, dynamic> res = json.decode(response.body);
          if (res == null) {
            print("no data");
            return false;
          }
        }
        return true;
      } catch (err) {
        print("has eerror is ${err.toString()}");
        return false;
      }
    } else {
      print("not save naja");
      return false;
    }
  }

  Future<dynamic> fetchNonconformTitle() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token").toString();

    try {
      http.Response response;
      response = await http.get(Uri.parse(url_to_noncomformall),
          headers: {"Authorization": token});

      if (response.statusCode == 200) {
        List<NonConformTitle> data = [];
        List<dynamic> res = json.decode(response.body);

        if (res == null) {
          print("no data");
          return false;
        }

        //print("data is ${res}");

        for (var i = 0; i <= res.length - 1; i++) {
          final NonConformTitle _item = NonConformTitle(
            id: res[i]["id"].toString(),
            code: res[i]["code"].toString(),
            name: res[i]["name"].toString(),
            module_type_id: res[i]["module_type_id"].toString(),
            status: res[i]["status"].toString(),
            isSelected: "0",
          );

          data.add(_item);
        }
        listnonconform = data;
        notifyListeners();
        return listnonconform;
      } else {
        print("No Data");
      }
    } catch (err) {
      print("error na ja is ${err}");
    }
  }
}
