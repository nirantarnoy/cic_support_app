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
import 'package:flutter_cic_support/models/transhistoryemp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PlanData extends ChangeNotifier {
  final String url_to_getplanby_person =
      "http://172.16.100.50:1223/api/teaminspectionitem/findbyteam";
  final String url_to_getplanby_person_saved =
      "http://172.16.100.50:1223/api/teaminspectionitem/findbyteamsaved";
  final String url_to_getplanby_person_repeat =
      "http://172.16.100.50:1223/api/teaminspectionitem/findbyteamrepeat";
  final String url_to_add_inspection_trans =
      "http://172.16.100.50:1223/api/plan/addinspection";

  final String url_to_add_safety_inspection_trans =
      "http://172.16.100.50:1223/api/plan/addsafetyinspection";

  final String url_to_check_safety_already_trans =
      "http://172.16.100.50:1223/api/teaminspectionitem/findtransbyempsafety";

  final String url_to_plan_by_emp =
      "http://172.16.100.50:1223/api/plan/listplanbyemp";

  final String url_to_noncomformall =
      "http://172.16.100.50:1223/api/carinspection/findall";

  final String url_to_check_already_trans =
      "http://172.16.100.50:1223/api/teaminspectionitem/findtransbyemp";

  final String url_to_check_already_trans_repeat =
      "http://172.16.100.50:1223/api/teaminspectionitem/findtransbyemprepeat";

  final String url_to_histoty_trans_by_emp =
      "http://172.16.100.50:1223/api/teaminspectionitem/findtranshistorybyemp";

  final String url_to_safety_plan =
      "http://172.16.100.50:1223/api/teaminspectionitem/findsafetyplanbyteam";

  final String url_to_five_monthly_summary =
      "http://172.16.100.50:1223/api/plan/fivemonthlysummary";

  final String url_to_bigplan_by_team =
      "http://172.16.100.50:1223/api/plan/findbigcleanplan";

  final String url_to_add_bigclean_inspection_trans =
      "http://172.16.100.50:1223/api/plan/addinspection";

  late List<JobplanArea> _plan = [];
  List<JobplanArea> get listJobplanArea => _plan;

  late List<JobplanAreaSaved> _plansaved = [];
  List<JobplanAreaSaved> get listJobplanAreaSaved => _plansaved;

  late List<JobplanAreaRepeat> _planrepeat = [];
  List<JobplanAreaRepeat> get listJobplanAreaRepeat => _planrepeat;

  late List<JobSafetyplanArea> _safety_plan = [];
  List<JobSafetyplanArea> get listSafetyJobplanArea => _safety_plan;

  late List<NonConformTitle> _nonconform = [];
  List<NonConformTitle> get listnonconform => _nonconform;

  late List<PersoncurrentPlan> _personcurrentplan = [];
  List<PersoncurrentPlan> get listpersoncurrentplan => _personcurrentplan;

  late List<PersoncurrentPlanRepeat> _personcurrentplan_repeat = [];
  List<PersoncurrentPlanRepeat> get listpersoncurrentplanRepeat =>
      _personcurrentplan_repeat;

  late List<TransHistoryEmp> _histoytrans = [];
  List<TransHistoryEmp> get listhistorytrans => _histoytrans;

  late List<FiveRankData> _fiverank = [];
  List<FiveRankData> get listfiverankdata => _fiverank;

  late List<BigplanArea> _bigplan = [];
  List<BigplanArea> get listBigplanArea => _bigplan;

  set listpersoncurrentplan(List<PersoncurrentPlan> val) {
    _personcurrentplan = val;
  }

  set listBigplanArea(List<BigplanArea> val) {
    _bigplan = val;
  }

  set listpersoncurrentplanRepeat(List<PersoncurrentPlanRepeat> val) {
    _personcurrentplan_repeat = val;
  }

  late int _finished_check = 0;
  int get finishedcheck => _finished_check;

  late int _repeat_check = 0;
  int get repeatcheck => _repeat_check;

  late int _finished_safety_check = 0;
  int get finishedsafetycheck => _finished_safety_check;

  set finishedcheck(int val) {
    _finished_check = val;
  }

  set listfiverankdata(List<FiveRankData> val) {
    _fiverank = val;
  }

  set finishedsafetycheck(int val) {
    _finished_safety_check = val;
  }

  set listJobplanArea(List<JobplanArea> val) {
    _plan = val;
  }

  set listJobplanAreaSaved(List<JobplanAreaSaved> val) {
    _plansaved = val;
  }

  set listJobplanAreaRepeat(List<JobplanAreaRepeat> val) {
    _planrepeat = val;
  }

  set listSafetyJobplanArea(List<JobSafetyplanArea> val) {
    _safety_plan = val;
  }

  set listnonconform(List<NonConformTitle> val) {
    _nonconform = val;
  }

  set listhistorytrans(List<TransHistoryEmp> val) {
    _histoytrans = val;
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
          plan_num: element.plan_num,
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
          department_code: element.department_code,
          section_code: element.section_code,
          inspection_type_id: element.inspection_type_id,
        );
        _newgroup.add(_group);
      }
    });
    _newgroup.sort(
      (a, b) => int.parse(a.plan_area_id).compareTo(int.parse(b.plan_area_id)),
    );
    return _newgroup.toSet().toList();
  }

  List<BigplanArea> getBigAreaTitle() {
    List<BigplanArea> _newgroup = [];
    listBigplanArea.forEach((element) {
      int has_ = 0;
      _newgroup.forEach((item_check) {
        if (item_check.plan_area_id == element.plan_area_id) {
          has_ += 1;
        }
      });
      if (has_ > 0) {
      } else {
        BigplanArea _group = BigplanArea(
          plan_id: element.plan_id,
          plan_date: "",
          plan_area_id: element.plan_area_id,
          plan_area_name: element.plan_area_name,
          plan_topic_check_qty: "",
          plan_topic_checked_qty: "",
          status: "",
          scored: "-1",
          topic_id: '',
          topic_item_id: '',
          topic_item_name: '',
          topic_name: '',
        );
        _newgroup.add(_group);
      }
    });
    _newgroup.sort(
      (a, b) => int.parse(a.plan_area_id).compareTo(int.parse(b.plan_area_id)),
    );
    return _newgroup.toSet().toList();
  }

  List<JobplanAreaRepeat> getAreaRepeatTitle() {
    List<JobplanAreaRepeat> _newgroup = [];
    listJobplanAreaRepeat.forEach((element) {
      int has_ = 0;
      _newgroup.forEach((item_check) {
        if (item_check.plan_area_id == element.plan_area_id) {
          has_ += 1;
        }
      });
      if (has_ > 0) {
      } else {
        JobplanAreaRepeat _group = JobplanAreaRepeat(
          plan_id: element.plan_id,
          plan_num: element.plan_num,
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
          department_code: element.department_code,
          section_code: element.section_code,
          inspection_type_id: element.inspection_type_id,
        );
        _newgroup.add(_group);
      }
    });
    _newgroup.sort(
      (a, b) => int.parse(a.plan_area_id).compareTo(int.parse(b.plan_area_id)),
    );
    return _newgroup.toSet().toList();
  }

  List<JobSafetyplanArea> getSafetyAreaTitle() {
    List<JobSafetyplanArea> _newgroup = [];
    listSafetyJobplanArea.forEach((element) {
      int has_ = 0;
      _newgroup.forEach((item_check) {
        if (item_check.plan_area_id == element.plan_area_id) {
          has_ += 1;
        }
      });
      if (has_ > 0) {
      } else {
        JobSafetyplanArea _group = JobSafetyplanArea(
          plan_id: element.plan_id,
          plan_num: element.plan_num,
          plan_date: "",
          plan_area_id: element.plan_area_id,
          plan_area_name: element.plan_area_name,
          plan_topic_check_qty: "",
          plan_topic_checked_qty: "",
          status: "0",
          scored: "0",
          department_code: element.department_code,
          section_code: element.section_code,
          inspection_type_id: element.inspection_type_id,
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
            plan_num: element.plan_num,
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
            seq_sort_item: element.seq_sort_item,
            department_code: element.department_code,
            section_code: element.section_code,
            inspection_type_id: element.inspection_type_id,
          );
          _newgroup.add(_group);
        }
      }
    });
    return _newgroup.toSet().toList();
  }

  List<JobCheckDetail> getTopicitem(String topic_id, String area_id) {
    print('area is ${area_id}');
    print('topic is ${topic_id}');
    List<JobCheckDetail> _list = [];
    List<JobCheckDetail> _list2 = [];

    listJobplanArea.forEach((element) {
      print('topic name enable is ${element.is_enable}');
      if (element.topic_id == topic_id &&
          element.plan_area_id == area_id &&
          element.is_enable == "1") {
        // JobCheckDetail _item = JobCheckDetail(
        //   plan_id: element.plan_id,
        //   topicid: element.topic_id,
        //   topicname: element.topic_name,
        //   topic_detail_id: element.topic_item_id,
        //   topic_detail_name: element.topic_item_name,
        //   status: element.status,
        //   score: element.scored,
        //   is_enable: element.is_enable,
        //   seq_sort: element.seq_sort,
        //   seq_sort_item: element.seq_sort_item,
        // );
        JobCheckDetail _item = JobCheckDetail(
          plan_id: element.plan_id == null ? '' : element.plan_id,
          topicid: element.topic_id == null ? '' : element.topic_id,
          topicname: element.topic_name == null ? '' : element.topic_name,
          topic_detail_id:
              element.topic_item_id == null ? '' : element.topic_item_id,
          topic_detail_name:
              element.topic_item_name == null ? '' : element.topic_item_name,
          status: element.status == null ? '0' : element.status,
          score: element.scored == null ? '-1' : element.scored,
          is_enable: element.is_enable == null ? '1' : element.is_enable,
          seq_sort: element.seq_sort == null ? '0' : element.seq_sort,
          seq_sort_item:
              element.seq_sort_item == null ? '0' : element.seq_sort_item,
        );
        _list.add(_item);
      }
    });
    // _list.sort(
    //   (a, b) =>
    //       int.parse(b.seq_sort_item).compareTo(int.parse(a.seq_sort_item)),
    // );
    notifyListeners();
    return _list;
  }

  List<BigCheckDetail> getBigcleanTopicitem(String area_id) {
    print('area is ${area_id}');

    List<BigCheckDetail> _list = [];
    var big_topic = ['สะสาง', 'สะดวก', 'สะอาด'];
    listBigplanArea.forEach((element) {
      if (element.plan_area_id == area_id) {
        for (var i = 0; i <= 2; i++) {
          BigCheckDetail _item = BigCheckDetail(
            plan_id: element.plan_id == null ? '' : element.plan_id,
            topicid: (i + 1).toString(),
            topicname: big_topic[i],
            topic_detail_id: (i + 1).toString(),
            topic_detail_name: big_topic[i],
            status: element.status == null ? '0' : element.status,
            score: element.scored == null ? '-1' : element.scored,
            is_enable: '',
            seq_sort: '',
            seq_sort_item: '',
          );
          _list.add(_item);
        }
      }
    });
    // _list.sort(
    //   (a, b) =>
    //       int.parse(b.seq_sort_item).compareTo(int.parse(a.seq_sort_item)),
    // );
    notifyListeners();
    return _list;
  }

  List<JobCheckDetail> getTopicitemNew(String area_id) {
    // print('area is ${area_id}');

    List<JobCheckDetail> _list = [];
    List<JobCheckDetail> _list2 = [];

    listJobplanArea.forEach((element) {
      // print('topic name enable is ${element.is_enable}');
      if (element.plan_area_id == area_id && element.is_enable == "1") {
        // JobCheckDetail _item = JobCheckDetail(
        //   plan_id: element.plan_id,
        //   topicid: element.topic_id,
        //   topicname: element.topic_name,
        //   topic_detail_id: element.topic_item_id,
        //   topic_detail_name: element.topic_item_name,
        //   status: element.status,
        //   score: element.scored,
        //   is_enable: element.is_enable,
        //   seq_sort: element.seq_sort,
        //   seq_sort_item: element.seq_sort_item,
        // );
        JobCheckDetail _item = JobCheckDetail(
          plan_id: element.plan_id == null ? '' : element.plan_id,
          topicid: element.topic_id == null ? '' : element.topic_id,
          topicname: element.topic_name == null ? '' : element.topic_name,
          topic_detail_id:
              element.topic_item_id == null ? '' : element.topic_item_id,
          topic_detail_name:
              element.topic_item_name == null ? '' : element.topic_item_name,
          status: element.status == null ? '0' : element.status,
          score: element.scored == null ? '-1' : element.scored,
          is_enable: element.is_enable == null ? '1' : element.is_enable,
          seq_sort: element.seq_sort == null ? '0' : element.seq_sort,
          seq_sort_item:
              element.seq_sort_item == null ? '0' : element.seq_sort_item,
        );
        _list.add(_item);
      }
    });
    // _list.sort(
    //   (a, b) =>
    //       int.parse(b.seq_sort_item).compareTo(int.parse(a.seq_sort_item)),
    // );
    notifyListeners();
    return _list;
  }

  List<JobCheckDetail> getTopicitemNewRepeat(String area_id) {
    // print('area is ${area_id}');

    List<JobCheckDetail> _list = [];
    List<JobCheckDetail> _list2 = [];

    listJobplanAreaRepeat.forEach((element) {
      // print('topic name enable is ${element.is_enable}');
      if (element.plan_area_id == area_id && element.is_enable == "1") {
        // JobCheckDetail _item = JobCheckDetail(
        //   plan_id: element.plan_id,
        //   topicid: element.topic_id,
        //   topicname: element.topic_name,
        //   topic_detail_id: element.topic_item_id,
        //   topic_detail_name: element.topic_item_name,
        //   status: element.status,
        //   score: element.scored,
        //   is_enable: element.is_enable,
        //   seq_sort: element.seq_sort,
        //   seq_sort_item: element.seq_sort_item,
        // );
        JobCheckDetail _item = JobCheckDetail(
          plan_id: element.plan_id == null ? '' : element.plan_id,
          topicid: element.topic_id == null ? '' : element.topic_id,
          topicname: element.topic_name == null ? '' : element.topic_name,
          topic_detail_id:
              element.topic_item_id == null ? '' : element.topic_item_id,
          topic_detail_name:
              element.topic_item_name == null ? '' : element.topic_item_name,
          status: element.status == null ? '0' : element.status,
          score: element.scored == null ? '-1' : element.scored,
          is_enable: element.is_enable == null ? '1' : element.is_enable,
          seq_sort: element.seq_sort == null ? '0' : element.seq_sort,
          seq_sort_item:
              element.seq_sort_item == null ? '0' : element.seq_sort_item,
        );
        _list.add(_item);
      }
    });
    // _list.sort(
    //   (a, b) =>
    //       int.parse(b.seq_sort_item).compareTo(int.parse(a.seq_sort_item)),
    // );
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

  int getAllMushCheckTopic() {
    int cnt = 0;
    listJobplanArea.forEach((element) {
      print('topic name enable is ${element.is_enable}');
      if (element.is_enable == "1") {
        cnt += 1;
      }
    });
    return cnt;
  }

  int getAllCheckedTopic() {
    int cnt = 0;
    listJobplanArea.forEach((element) {
      print('topic name enable is ${element.is_enable}');
      if (element.scored != "-1") {
        cnt += 1;
      }
    });
    return cnt;
  }

  int getBigAllMushCheckTopic() {
    int cnt = 0;
    if (listBigplanArea != null) {
      cnt = listBigplanArea.length * 3;
    }
    return cnt;
  }

  int getBigAllCheckedTopic() {
    int cnt = 0;
    listInspectiontrans.forEach((element) {
      if (element.score != "-1") {
        cnt += 1;
      }
    });
    return cnt;
  }

  int getAllMushCheckSafetyArea() {
    return listSafetyJobplanArea.length;
  }

  int getAllCheckedSafetyArea() {
    int cnt = 0;
    return cnt;
  }

  List<NonConformTitle> listofnonconform_5s() {
    return listnonconform
        .where((element) => element.module_type_id == "1")
        .toList();
  }

  String getNonconformName(String id) {
    String name = "";
    if (listnonconform.isNotEmpty) {
      listnonconform.forEach((element) {
        // print("loop non list ${element.id}");
        if (element.id == id) {
          name = element.name;
        }
      });
    }

    return name;
  }

  bool addInspectionTrans(InspectionTrans data) {
    if (data != null) {
      if (listInspectiontrans.isNotEmpty) {
        int has_update = 0;
        listInspectiontrans.forEach((element) {
          if (element.topic_item_id == data.topic_item_id &&
              element.area_id == data.area_id) {
            element.score = data.score.toString(); // update score if exist
            print("have data to update trans");
            has_update = 1;
          } else {
            has_update = 0; // if duplicate score please commit this line
          }
        });
        if (has_update == 0) {
          listInspectiontrans.add(data); // original line
          print("loop new data to add trans");
        }
      } else {
        listInspectiontrans.add(data); // original line
        print("first new data to add trans");
      }

      listJobplanArea.forEach((element) {
        if (element.topic_item_id == data.topic_item_id &&
            element.plan_area_id == data.area_id) {
          element.status = "1";
          element.scored = data.score.toString();
        } else {
          //print("no data to add");
        }
      });

      notifyListeners();
      return true;
    } else {
      //print("no data to add 2");
      return false;
    }
  }

  bool addBigInspectionTrans(InspectionTrans data) {
    if (data != null) {
      if (listInspectiontrans.isNotEmpty) {
        int has_update = 0;
        listInspectiontrans.forEach((element) {
          if (element.topic_item_id == data.topic_item_id &&
              element.area_id == data.area_id) {
            element.score = data.score.toString(); // update score if exist
            print("have data to update trans");
            has_update = 1;
          } else {
            has_update = 0; // if duplicate score please commit this line
          }
        });
        if (has_update == 0) {
          listInspectiontrans.add(data); // original line
          print("loop new data to add trans");
        }
      } else {
        listInspectiontrans.add(data); // original line
        print("first new data to add trans");
      }

      // listBigplanArea.forEach((element) {
      //   if (element.plan_area_id == data.area_id) {
      //     element.status = "1";
      //     element.scored = data.score.toString();
      //   } else {
      //     print("no data to add");
      //   }
      // });

      notifyListeners();
      return true;
    } else {
      //print("no data to add 2");
      return false;
    }
  }

  String checkBigLineScore(String topic_id, String area_id) {
    String score = '-1';
    listInspectiontrans.forEach((element) {
      if (element.area_id == area_id && element.topic_id == topic_id) {
        score = element.score;
      }
    });
    return score;
  }

  bool addInspectionTransRepeat(InspectionTrans data) {
    if (data != null) {
      if (listInspectiontrans.isNotEmpty) {
        int has_update = 0;
        listInspectiontrans.forEach((element) {
          if (element.topic_item_id == data.topic_item_id &&
              element.area_id == data.area_id) {
            element.score = data.score.toString(); // update score if exist
            print("have data to update trans");
            has_update = 1;
          } else {
            has_update = 0; // if duplicate score please commit this line
          }
        });
        if (has_update == 0) {
          listInspectiontrans.add(data); // original line
          print("loop new data to add trans");
        }
      } else {
        listInspectiontrans.add(data); // original line
        print("first new data to add trans");
      }

      listJobplanAreaRepeat.forEach((element) {
        if (element.topic_item_id == data.topic_item_id &&
            element.plan_area_id == data.area_id) {
          element.status = "1";
          element.scored = data.score.toString();
        } else {
          //print("no data to add");
        }
      });

      notifyListeners();
      return true;
    } else {
      //print("no data to add 2");
      return false;
    }
  }

  bool removeinspectionitem(String area_id) {
    if (listJobplanArea.isNotEmpty && area_id != null) {
      // listInspectiontrans.forEach((element) {
      //   print(element.area_id);
      // });

      listJobplanArea.forEach((element) {
        if (element.plan_area_id == area_id) {
          print("remove area id is ${area_id} and ${element.plan_area_id}");
          element.scored = "-1";
        }
      });
      //   listInspectiontrans.removeWhere((item) =>
      //       item.area_id == area_id); // remove all checked score of this area
      //   print("remove checked topic item");
    }
    notifyListeners();
    return true;
  }

  bool removeBigCleaninspectionitem(String area_id) {
    if (listInspectiontrans.isNotEmpty && area_id != null) {
      // listInspectiontrans.forEach((element) {
      //   print(element.area_id);
      // });

      listInspectiontrans.forEach((element) {
        if (element.area_id == area_id) {
          print("remove area id is ${area_id} and ${element.area_id}");
          element.score = "-1";
        }
      });
      //   listInspectiontrans.removeWhere((item) =>
      //       item.area_id == area_id); // remove all checked score of this area
      //   print("remove checked topic item");
    }
    notifyListeners();
    return true;
  }

  bool removeinspectionitemRepeat(String area_id) {
    if (listJobplanAreaRepeat.isNotEmpty && area_id != null) {
      // listInspectiontrans.forEach((element) {
      //   print(element.area_id);
      // });

      listJobplanAreaRepeat.forEach((element) {
        if (element.plan_area_id == area_id) {
          print("remove area id is ${area_id} and ${element.plan_area_id}");
          element.scored = "-1";
        }
      });
      //   listInspectiontrans.removeWhere((item) =>
      //       item.area_id == area_id); // remove all checked score of this area
      //   print("remove checked topic item");
    }
    notifyListeners();
    return true;
  }

  bool addInspectionSafetyTrans(InspectionSafetyTrans data) {
    if (data != null) {
      if (listInspectionSafetytrans.isNotEmpty) {
        int has_update = 0;
        listInspectionSafetytrans.forEach((element) {
          if (element.area_id == data.area_id) {
            element.score = data.score.toString(); // update score if exist
            print("have data to update trans");
            has_update = 1;
          } else {
            has_update = 0; // if duplicate score please commit this line
          }
        });
        if (has_update == 0) {
          listInspectionSafetytrans.add(data); // original line
          print("loop new data to add trans");
        }
      } else {
        listInspectionSafetytrans.add(data); // original line
        print("first new data to add trans");
      }

      listSafetyJobplanArea.forEach((element) {
        if (element.plan_area_id == data.area_id) {
          element.status = "1";
          element.scored = data.score.toString();
        } else {
          //print("no data to add");
        }
      });

      notifyListeners();
      return true;
    } else {
      //print("no data to add 2");
      return false;
    }
  }

  bool removesafetyinspectionitem(String area_id) {
    if (listSafetyJobplanArea.isNotEmpty && area_id != null) {
      // listInspectiontrans.forEach((element) {
      //   print(element.area_id);
      // });

      listInspectionSafetytrans.forEach((element) {
        if (element.area_id == area_id) {
          print("remove area id is ${area_id} and ${element.area_id}");
          element.score = "0";
        }
      });
      //   listInspectiontrans.removeWhere((item) =>
      //       item.area_id == area_id); // remove all checked score of this area
      //   print("remove checked topic item");
    }
    notifyListeners();
    return true;
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

  int countCheckedTopicBigcleanitem(String area_id) {
    int cnt = 0;
    listInspectiontrans.forEach((element) {
      if (element.area_id == area_id && int.parse(element.score) > -1) {
        cnt += 1;
      }
    });
    return cnt;
  }

  void clearInspectionTrans() {
    if (listInspectiontrans.isNotEmpty) {
      listInspectiontrans.clear();
    }
    if (listJobplanArea.isNotEmpty) {
      listJobplanArea.clear();
    }
  }

  int countTopicitemRepeat(String area_id) {
    int cnt = 0;
    listJobplanAreaRepeat.forEach((element) {
      if (element.plan_area_id == area_id) {
        cnt += 1;
      }
    });
    return cnt;
  }

  int countCheckedTopicitemRepeat(String area_id) {
    int cnt = 0;
    listJobplanAreaRepeat.forEach((element) {
      if (element.plan_area_id == area_id && int.parse(element.scored) > -1) {
        cnt += 1;
      }
    });
    return cnt;
  }

  int checkhaschecklist(String area_id) {
    int cnt = 0;
    listInspectionSafetytrans.forEach((element) {
      if (element.area_id == area_id && element.score != "0") {
        cnt += 1;
      }
    });
    return cnt;
  }

  int hasBigcleanArea() {
    int cnt = 0;
    if (listBigplanArea != null) {
      cnt = listBigplanArea.length;
    }

    return cnt;
  }

  Future<dynamic> fetchJobplan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("user_id").toString();
    final String token = prefs.getString("token").toString();
    final String team_id = prefs.getString("team_id").toString();

    notifyListeners();

    print('current team is ${team_id}');

    //listJobplanArea.clear();
    if (listJobplanArea.length == 0) {
      try {
        http.Response response;
        response = await http.get(
            Uri.parse(url_to_getplanby_person + "/" + team_id),
            headers: {"Authorization": token});

        if (response.statusCode == 200) {
          List<JobplanArea> data = [];
          List<PersoncurrentPlan> personplan_data = [];
          List<dynamic> res = json.decode(response.body);

          if (res == null) {
            print("no data");
            return false;
          }

          print("data plan_num is ${res[0]["plan_num"]}");

          for (var i = 0; i <= res.length - 1; i++) {
            final JobplanArea _item = JobplanArea(
              plan_id: res[i]["id"].toString(),
              plan_num: res[i]["plan_num"].toString(),
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
              is_enable: res[i]["is_enable"] == null
                  ? ''
                  : res[i]["is_enable"].toString(),
              seq_sort: res[i]["seq_sort"].toString(),
              seq_sort_item: res[i]["seq_sort_item"].toString(),
              department_code: res[i]["department_code"].toString(),
              section_code: res[i]["section_code"].toString(),
              inspection_type_id: res[i]["inspection_type_id"].toString(),
            );

            if (i == 0) {
              final PersoncurrentPlan personplan = PersoncurrentPlan(
                plan_id: res[i]["plan_id"].toString(),
                plan_no: res[i]["plan_no"].toString(),
                plan_date: res[i]["plan_target_date"].toString(),
                plan_status: "0",
                plan_type: res[i]["module_type_id"].toString(),
                inspection_type_id: res[i]['inspection_type_id'].toString(),
              );
              personplan_data.add(personplan);
            }

            data.add(_item);
          }
          listJobplanArea = data;
          listpersoncurrentplan = personplan_data;
          print("section code is ${data[0].section_code}");
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

  Future<dynamic> fetchBigcleanplan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("user_id").toString();
    final String token = prefs.getString("token").toString();
    final String team_id = prefs.getString("bigclean_team_id").toString();

    final Map<String, dynamic> filterData = {
      'team_id': int.parse(team_id),
      'user_id': int.parse(user_id),
    };

    notifyListeners();

    print('current bigclean team is ${team_id}');

    //listJobplanArea.clear();
    //if (listBigplanArea.length == 0) {
    listBigplanArea.clear();
    try {
      http.Response response;
      // response = await http.get(
      //     Uri.parse(url_to_bigplan_by_team + "/" + team_id),
      //     headers: {"Authorization": token});

      response = await http.post(Uri.parse(url_to_bigplan_by_team),
          headers: {"Authorization": token, 'Content-Type': 'application/json'},
          body: json.encode(filterData));

      if (response.statusCode == 200) {
        List<BigplanArea> data = [];
        //  List<PersoncurrentPlan> personplan_data = [];
        List<dynamic> res = json.decode(response.body);

        if (res == null) {
          print("no data");
          return false;
        }

        print("data plan_num is ${res[0]["plan_num"]}");

        for (var i = 0; i <= res.length - 1; i++) {
          final BigplanArea _item = BigplanArea(
            plan_id: res[i]["id"].toString(),
            plan_date: res[i]["bigplan_date"].toString(),
            plan_area_id: res[i]["area_def_id"].toString(),
            plan_area_name: res[i]["area_def_name"].toString(),
            plan_topic_check_qty: "0",
            plan_topic_checked_qty: "0",
            status: "0",
            scored: "-1",
            topic_id: '',
            topic_item_id: '',
            topic_item_name: '',
            topic_name: '',
          );

          data.add(_item);
        }
        listBigplanArea = data;
        notifyListeners();
        return listBigplanArea;
      } else {
        print("No Data");
      }
    } catch (err) {
      print("error na ja is ${err}");
    }
    //}
  }

  Future<dynamic> fetchJobplanSaved() async {
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

  Future<dynamic> fetchJobplanRepeat() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("user_id").toString();
    final String token = prefs.getString("token").toString();
    // final String team_id = prefs.getString("team_id").toString();

    notifyListeners();

    print('current find repeat user is ${user_id}');

    //if (listJobplanAreaRepeat.length == 0) {
    try {
      http.Response response;
      response = await http.get(
          Uri.parse(url_to_getplanby_person_repeat + "/" + user_id),
          headers: {"Authorization": token});

      if (response.statusCode == 200) {
        List<JobplanAreaRepeat> data = [];
        List<PersoncurrentPlanRepeat> personplan_repeat_data = [];
        List<dynamic> res = json.decode(response.body);

        if (res == null) {
          print("no data");
          return false;
        }

        print("data repeat plan_num is ${res[0]["plan_num"]}");

        for (var i = 0; i <= res.length - 1; i++) {
          final JobplanAreaRepeat _item = JobplanAreaRepeat(
            plan_id: res[i]["id"].toString(),
            plan_num: res[i]["plan_num"].toString(),
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
            is_enable: res[i]["is_enable"] == null
                ? ''
                : res[i]["is_enable"].toString(),
            seq_sort: res[i]["seq_sort"].toString(),
            seq_sort_item: res[i]["seq_sort_item"].toString(),
            department_code: res[i]["department_code"].toString(),
            section_code: res[i]["section_code"].toString(),
            inspection_type_id: res[i]["inspection_type_id"].toString(),
          );

          if (i == 0) {
            final PersoncurrentPlanRepeat personplan_repeat =
                PersoncurrentPlanRepeat(
              plan_id: res[i]["plan_id"].toString(),
              plan_no: res[i]["plan_no"].toString(),
              plan_date: res[i]["plan_target_date"].toString(),
              plan_status: "0",
              plan_type: res[i]["module_type_id"].toString(),
              inspection_type_id: res[i]['inspection_type_id'].toString(),
            );
            personplan_repeat_data.add(personplan_repeat);
          }

          data.add(_item);
        }
        listJobplanAreaRepeat.clear();
        listJobplanAreaRepeat = data;
        listpersoncurrentplanRepeat = personplan_repeat_data;
        notifyListeners();
        return listJobplanAreaRepeat;
      } else {
        print("No Data");
      }
    } catch (err) {
      print("error na ja is ${err}");
    }
    //}
  }

  Future<dynamic> fetchFiveRank(String _year, String _month) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("user_id").toString();
    final String token = prefs.getString("token").toString();

    listfiverankdata.clear();
    notifyListeners();

    final Map<String, dynamic> insertData = {
      'year': int.parse(_year),
      'month': int.parse(_month),
    };

    // if (listfiverankdata.length == 0) {
    try {
      http.Response response;
      response = await http.post(Uri.parse(url_to_five_monthly_summary),
          headers: {"Authorization": token, 'Content-Type': 'application/json'},
          body: json.encode(insertData));

      if (response.statusCode == 200) {
        List<FiveRankData> data = [];
        List<FiveRankData> personplan_data = [];
        List<dynamic> res = json.decode(response.body);

        if (res == null) {
          print("no data");
          return false;
        }

        print("data five rank is ${res[0]["area_name"]}");

        for (var i = 0; i <= res.length - 1; i++) {
          final FiveRankData _item = FiveRankData(
            deptname: res[i]["area_name"].toString(),
            score: double.parse(res[i]["sum_value"].toString()),
            zone_id: res[i]["zone_id"].toString(),
            rank_no: 0,
          );

          data.add(_item);
        }
        listfiverankdata = data;

        notifyListeners();
        return listfiverankdata;
      } else {
        print("No Data");
      }
    } catch (err) {
      print("error na ja is ${err}");
    }
    // }
  }

  Future<dynamic> fetchSafetyJobplan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("user_id").toString();
    final String token = prefs.getString("token").toString();
    final String team_safety_id = prefs.getString("team_safety_id").toString();

    notifyListeners();

    print('current safety team is ${team_safety_id}');

    if (listSafetyJobplanArea.length == 0) {
      try {
        http.Response response;
        response = await http.get(
            Uri.parse(url_to_safety_plan + "/" + team_safety_id),
            headers: {"Authorization": token});

        if (response.statusCode == 200) {
          List<JobSafetyplanArea> data = [];
          List<PersoncurrentPlan> personplan_data = [];
          List<dynamic> res = json.decode(response.body);

          if (res == null) {
            print("no data");
            return false;
          }

          print("data plan_num is ${res[0]["plan_num"]}");

          for (var i = 0; i <= res.length - 1; i++) {
            final JobSafetyplanArea _item = JobSafetyplanArea(
              plan_id: res[i]["id"].toString(),
              plan_num: res[i]["plan_num"].toString(),
              plan_date: res[i]["plan_target_date"].toString(),
              plan_area_id: res[i]["area_inspection_id"].toString(),
              plan_area_name: res[i]["area_inspection_name"].toString(),
              plan_topic_check_qty: "0",
              plan_topic_checked_qty: "0",
              status: "0",
              scored: "0",
              department_code: res[i]["department_code"].toString(),
              section_code: res[i]["section_code"].toString(),
              inspection_type_id: res[i]["inspection_type_id"].toString(),
            );

            // if (i == 0) {
            //   final PersoncurrentPlan personplan = PersoncurrentPlan(
            //     plan_id: res[i]["plan_id"].toString(),
            //     plan_no: res[i]["plan_no"].toString(),
            //     plan_date: res[i]["plan_target_date"].toString(),
            //     plan_status: "0",
            //     plan_type: res[i]["module_type_id"].toString(),
            //     inspection_type_id: res[i]['inspection_type_id'].toString(),
            //   );
            //   personplan_data.add(personplan);
            // }

            data.add(_item);
          }
          listSafetyJobplanArea = data;
          //    listpersoncurrentplan = personplan_data;
          print("section code is ${data[0].section_code}");
          notifyListeners();
          return listSafetyJobplanArea;
        } else {
          print("No Data");
        }
      } catch (err) {
        print("error na ja is ${err}");
      }
    }
  }

  Future<bool> submitInspection(String action_type_id) async {
    print("list data is ${listInspectiontrans[0].area_id}");
    // return false;
    if (listInspectiontrans.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String user_id = prefs.getString("user_id").toString();
      final String team_id = prefs.getString("team_id").toString();
      final String token = prefs.getString("token").toString();
      // final String plan_num = prefs.getString("plan_num").toString();

      var addData = listInspectiontrans
          .map((e) => {
                'module_type_id': int.parse(e.module_type_id),
                'plan_id': int.parse(e.plan_num),
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
                'action_type_id': int.parse(action_type_id),
              })
          .toList();
      // var addData = listInspectiontrans
      //     .map((e) => {
      //           'module_type_id': e.module_type_id,
      //           'plan_id': e.plan_num,
      //           'trans_date': e.trans_date,
      //           'emp_id': user_id,
      //           'area_group_id': e.area_group_id,
      //           'area_id': e.area_id,
      //           'team_id': team_id,
      //           'topic_id': e.topic_id,
      //           'topic_item_id': e.topic_item_id,
      //           'score': e.score,
      //           'status': e.status,
      //           'note': e.note,
      //           'created_at': '0',
      //           'created_by': user_id,
      //         })
      //     .toList();
      print('data save is ${json.encode(addData)}');
      // return false;
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
          print("save transaction ok");
          clearInspectionTrans(); // clear list after save finished
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

  Future<bool> submitBigcleanInspection() async {
    // print("list data is ${listInspectiontrans[0].area_id}");
    // return false;
    if (listInspectiontrans.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String user_id = prefs.getString("user_id").toString();
      final String team_id = prefs.getString("bigclean_team_id").toString();
      final String token = prefs.getString("token").toString();
      // final String plan_num = prefs.getString("plan_num").toString();

      var addData = listInspectiontrans
          .map((e) => {
                'module_type_id': 3,
                'plan_id': int.parse(e.plan_num),
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
                'action_type_id': 1,
              })
          .toList();

      print('data bigclean save is ${json.encode(addData)}');
      // return false;
      try {
        http.Response response;
        response = await http.post(
          Uri.parse(url_to_add_bigclean_inspection_trans),
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
          print("save big clean transaction ok");
          clearInspectionTrans(); // clear list after save finished
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

  Future<bool> submitSafetyInspection() async {
    print("list data is ${listInspectionSafetytrans[0].area_id}");
    // return false;
    if (listInspectionSafetytrans.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String user_id = prefs.getString("user_id").toString();
      final String team_safety_id =
          prefs.getString("team_safety_id").toString();
      final String token = prefs.getString("token").toString();
      // final String plan_num = prefs.getString("plan_num").toString();

      var addData = listInspectionSafetytrans
          .map((e) => {
                'module_type_id': int.parse(e.module_type_id),
                'plan_id': int.parse(e.plan_num),
                'trans_date': e.trans_date,
                'emp_id': int.parse(user_id),
                'area_group_id': int.parse(e.area_group_id),
                'area_id': int.parse(e.area_id),
                'team_id': int.parse(team_safety_id),
                'score': int.parse(e.score),
                'status': int.parse(e.status),
                'note': e.note,
                'created_at': int.parse('0'),
                'created_by': int.parse(user_id),
              })
          .toList();

      //  print('data save is ${json.encode(addData)}');
      // return false;
      try {
        http.Response response;
        response = await http.post(
          Uri.parse(url_to_add_safety_inspection_trans),
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
          print("save transaction ok");
          clearInspectionTrans(); // clear list after save finished
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

        // print("non conform data is ${res}");

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

  Future<dynamic> fetFinishedCheck() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("user_id").toString();
    final String team_id = prefs.getString("team_id").toString();
    final String token = prefs.getString("token").toString();

    notifyListeners();

    final Map<String, dynamic> checkData = {
      'teamid': team_id,
      'empid': user_id,
    };
    print('data find is ${checkData}');
    try {
      http.Response response;
      response = await http.post(Uri.parse(url_to_check_already_trans),
          headers: {'Content-Type': 'application/json', "Authorization": token},
          body: json.encode(checkData));

      print("response is ${response.statusCode}");
      if (response.statusCode == 200) {
        int res = json.decode(response.body);

        // Map<String, dynamic> res = json.decode(response.body);
        print("data res is check already ${res}");
        // if (res == null) {
        //   print("no data");
        //   return false;
        // }

        finishedcheck = res;
        notifyListeners();
        return _finished_check;
      } else {
        print("No Data From Check");
      }
    } catch (err) {
      print("error na is ${err}");
    }
  }

  Future<dynamic> fetFinishedRepeatCheck() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("user_id").toString();
    final String team_id = prefs.getString("team_id").toString();
    final String token = prefs.getString("token").toString();

    notifyListeners();

    final Map<String, dynamic> checkData = {
      'teamid': team_id,
      'empid': user_id,
    };
    print('data find is ${checkData}');
    try {
      http.Response response;
      response = await http.post(Uri.parse(url_to_check_already_trans_repeat),
          headers: {'Content-Type': 'application/json', "Authorization": token},
          body: json.encode(checkData));

      print("response is ${response.statusCode}");
      if (response.statusCode == 200) {
        int res = json.decode(response.body);

        // Map<String, dynamic> res = json.decode(response.body);
        print("data res is check already ${res}");
        // if (res == null) {
        //   print("no data");
        //   return false;
        // }

        _repeat_check = res;
        notifyListeners();
        return _repeat_check;
      } else {
        print("No Data From Check");
      }
    } catch (err) {
      print("error na is ${err}");
    }
  }

  Future<dynamic> fetSafetyFinishedCheck() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("user_id").toString();
    final String team_safety_id = prefs.getString("team_safety_id").toString();
    final String token = prefs.getString("token").toString();

    notifyListeners();

    final Map<String, dynamic> checkData = {
      'teamid': team_safety_id,
      'empid': user_id,
    };
    print('data find is ${checkData}');
    print('token find is ${token}');
    try {
      http.Response response;
      response = await http.post(Uri.parse(url_to_check_safety_already_trans),
          headers: {'Content-Type': 'application/json', "Authorization": token},
          body: json.encode(checkData));

      print("response is ${response.statusCode}");
      if (response.statusCode == 200) {
        int res = json.decode(response.body);

        // Map<String, dynamic> res = json.decode(response.body);
        print("data res is check already ${res}");
        // if (res == null) {
        //   print("no data");
        //   return false;
        // }

        finishedsafetycheck = res;
        notifyListeners();
        return _finished_safety_check;
      } else {
        print("No Data From Check Naja");
      }
    } catch (err) {
      print("error na is ${err}");
    }
  }

  Future<dynamic> fetchHistoryTransByEmp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("user_id").toString();
    final String token = prefs.getString("token").toString();

    notifyListeners();

    print('current user id is ${user_id}');

    try {
      http.Response response;
      response = await http.get(
          Uri.parse(url_to_histoty_trans_by_emp + "/" + user_id),
          headers: {"Authorization": token});

      if (response.statusCode == 200) {
        List<TransHistoryEmp> data = [];

        List<dynamic> res = json.decode(response.body);

        if (res == null) {
          print("no data");
          return false;
        }

        print("data history is ${res}");

        for (var i = 0; i <= res.length - 1; i++) {
          final TransHistoryEmp _item = TransHistoryEmp(
            plan_id: res[i]["plan_id"].toString(),
            plan_no: res[i]["plan_no"].toString(),
            plan_date: res[i]["plan_date"].toString(),
            team_id: res[i]["team_id"].toString(),
            status: res[i]["status"].toString(),
            plan_actual_date: res[i]["plan_actual_date"].toString(),
          );

          data.add(_item);
        }
        listhistorytrans = data;
        notifyListeners();
        return listhistorytrans;
      } else {
        print("No Data");
      }
    } catch (err) {
      print("error na ja is ${err}");
    }
  }
}
