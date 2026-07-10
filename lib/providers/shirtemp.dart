import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/shirtassignstd.dart';
import 'package:flutter_cic_support/models/shirtdata.dart';
import 'package:flutter_cic_support/models/shirtorder.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class ShirtempData extends ChangeNotifier {
  final String url_to_get_shirt_list =
      "https://api.cicsupports.com/api/shirt/listall";

  final String url_to_get_shirt_size_list =
      "https://api.cicsupports.com/api/shirt/listsize";

  final String url_to_get_shirt_pocket_list =
      "https://api.cicsupports.com/api/shirt/listpocket";

  final String url_to_add_shirt =
      "https://api.cicsupports.com/api/shirt/createshirtorder";

  final String url_to_check_uniform =
      "https://api.cicsupports.com/api/shirt/finduniformselect";

  final String url_to_get_uniform_order =
      "https://api.cicsupports.com/api/shirt/findshirtorder";

  final String url_to_get_shirt_assing_std =
      "https://api.cicsupports.com/api/shirt/findshirtassignstd";

  late List<Shirtdata> _shirt = [];
  List<Shirtdata> get listshirt => _shirt;

  late List<ShirtSizedata> _shirtsize = [];
  List<ShirtSizedata> get listshirtsize => _shirtsize;

  late List<ShirtPocketdata> _shirtpocket = [];
  List<ShirtPocketdata> get listshirtpocket => _shirtpocket;

  late List<ShirtAssignStd> _shirtassignstd = [];
  List<ShirtAssignStd> get shirtassignstdlist => _shirtassignstd;

  late List<ShirtOrder> _shirtorder = [];
  List<ShirtOrder> get listshirtorder => _shirtorder;

  int _shirtselected = 0;
  int get shirtselected => _shirtselected;

  set shirtselected(int val) {
    _shirtselected = val;
  }

  set listshirt(List<Shirtdata> val) {
    _shirt = val;
  }

  set listshirtsize(List<ShirtSizedata> val) {
    _shirtsize = val;
  }

  set listshirtpocket(List<ShirtPocketdata> val) {
    _shirtpocket = val;
  }

  set shirtassignstdlist(List<ShirtAssignStd> val) {
    _shirtassignstd = val;
  }

  set listshirtorder(List<ShirtOrder> val) {
    _shirtorder = val;
  }

  void addCart(ShirtOrder val) {
    listshirtorder.add(val);
    notifyListeners();
  }

  void removeCart(int index) {
    if (listshirtorder.isNotEmpty) {
      listshirtorder.removeAt(index);
    }
  }

  void emptyCart() {
    listshirtorder.clear();
    notifyListeners();
  }

  Future<dynamic> fetchShirt() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("emp_key").toString();
    final String token = prefs.getString("token").toString();

    notifyListeners();
    if (listshirt.length == 0) {
      try {
        http.Response response;
        response = await http.get(Uri.parse(url_to_get_shirt_list),
            headers: {"Authorization": token});

        if (response.statusCode == 200) {
          List<Shirtdata> data = [];
          final decoded = json.decode(response.body);
          if (decoded == null) {
            print("no data");
            return false;
          }
          List<dynamic> resList = [];
          if (decoded is List) {
            resList = decoded;
          } else if (decoded is Map && decoded['data'] is List) {
            resList = decoded['data'];
          }

          for (var i = 0; i <= resList.length - 1; i++) {
            final Shirtdata _item = Shirtdata(
              id: resList[i]["id"].toString(),
              name: resList[i]["name"].toString(),
              shirt_type_id: resList[i]["shirt_type_id"].toString(),
            );

            data.add(_item);
          }
          listshirt = data;
          notifyListeners();
          return listshirt;
        } else {
          print("No Data fetchShirt: ${response.statusCode} - ${response.body}");
          Fluttertoast.showToast(msg: "ดึงแบบเสื้อล้มเหลว: รหัส ${response.statusCode}");
        }
      } catch (err) {
        print("error na ja is ${err}");
        Fluttertoast.showToast(msg: "ดึงแบบเสื้อล้มเหลว: ${err.toString()}");
      }
    }
  }

  Future<dynamic> fetchShirtSize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("emp_key").toString();
    final String token = prefs.getString("token").toString();

    notifyListeners();
    if (listshirtsize.length == 0) {
      try {
        http.Response response;
        response = await http.get(Uri.parse(url_to_get_shirt_size_list),
            headers: {"Authorization": token});

        if (response.statusCode == 200) {
          List<ShirtSizedata> data = [];
          final decoded = json.decode(response.body);
          if (decoded == null) {
            print("no data");
            return false;
          }
          List<dynamic> resList = [];
          if (decoded is List) {
            resList = decoded;
          } else if (decoded is Map && decoded['data'] is List) {
            resList = decoded['data'];
          }

          for (var i = 0; i <= resList.length - 1; i++) {
            final ShirtSizedata _item = ShirtSizedata(
              id: resList[i]["id"].toString(),
              name: resList[i]["name"].toString(),
            );

            data.add(_item);
          }
          listshirtsize = data;
          notifyListeners();
          return listshirtsize;
        } else {
          print("No Data fetchShirtSize: ${response.statusCode} - ${response.body}");
          Fluttertoast.showToast(msg: "ดึงไซส์เสื้อล้มเหลว: รหัส ${response.statusCode}");
        }
      } catch (err) {
        print("error na ja is ${err}");
        Fluttertoast.showToast(msg: "ดึงไซส์เสื้อล้มเหลว: ${err.toString()}");
      }
    }
  }

  Future<dynamic> fetchShirtPocket() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("emp_key").toString();
    final String token = prefs.getString("token").toString();

    notifyListeners();
    if (listshirtpocket.length == 0) {
      try {
        http.Response response;
        response = await http.get(Uri.parse(url_to_get_shirt_pocket_list),
            headers: {"Authorization": token});

        if (response.statusCode == 200) {
          List<ShirtPocketdata> data = [];
          final decoded = json.decode(response.body);
          if (decoded == null) {
            print("no data");
            return false;
          }
          List<dynamic> resList = [];
          if (decoded is List) {
            resList = decoded;
          } else if (decoded is Map && decoded['data'] is List) {
            resList = decoded['data'];
          }

          for (var i = 0; i <= resList.length - 1; i++) {
            final ShirtPocketdata _item = ShirtPocketdata(
              id: resList[i]["id"].toString(),
              name: resList[i]["name"].toString(),
            );

            data.add(_item);
          }
          listshirtpocket = data;
          notifyListeners();
          return listshirtpocket;
        } else {
          print("No Data fetchShirtPocket: ${response.statusCode} - ${response.body}");
          Fluttertoast.showToast(msg: "ดึงลักษณะเสื้อล้มเหลว: รหัส ${response.statusCode}");
        }
      } catch (err) {
        print("error na ja is ${err}");
        Fluttertoast.showToast(msg: "ดึงลักษณะเสื้อล้มเหลว: ${err.toString()}");
      }
    }
  }

  Future<bool> submitshirt(List<ShirtOrder> _list) async {
    //return false;
    if (_list.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String user_id = prefs.getString("user_id").toString();
      final String emp_key = prefs.getString("emp_key").toString();
      final String token = prefs.getString("token").toString();
      // final String plan_num = prefs.getString("plan_num").toString();

      var jsonx = _list
          .map((e) => {
                'shirt_order_id': int.parse("0"),
                'shirt_id': int.parse(e.shirt_type),
                'shirt_size_id': int.parse(e.shirt_size),
                'shirt_pocket_id': int.parse(e.shirt_pocket),
                'qty': int.parse(e.shirt_qty),
                'remark': e.shirt_remark,
                'status': int.parse("0"),
              })
          .toList();

      final Map<String, dynamic> addData = {
        'user_id': int.parse(emp_key),
        'data': jsonx,
      };

      print('data save is ${json.encode(addData)}');
      // return false;
      try {
        http.Response response;
        response = await http.post(
          Uri.parse(url_to_add_shirt),
          headers: {"Content-Type": "application/json", "Authorization": token},
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

  Future<dynamic> fetchEmpuniform() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("emp_key").toString();
    final String token = prefs.getString("token").toString();

    notifyListeners();

    print('current user id is ${user_id}');

    try {
      http.Response response;
      response = await http.get(Uri.parse(url_to_check_uniform + "/" + user_id),
          headers: {"Authorization": token});

      if (response.statusCode == 200) {
        Map<String, dynamic> res = json.decode(response.body);
        int _is_selected = 0;
        if (res == null) {
          print("no data");
          return 0;
        }

        print("data is ${res}");

        shirtselected = res['row_count'];
        print("print row count is ${shirtselected}");
        notifyListeners();
        return shirtselected;
      } else {
        shirtselected = 0;
        print("No Data fetchEmpuniform: ${response.statusCode} - ${response.body}");
        Fluttertoast.showToast(msg: "ตรวจสอบประวัติเครื่องแบบล้มเหลว: รหัส ${response.statusCode}");
      }
    } catch (err) {
      shirtselected = 0;
      print("error na ja is ${err}");
      Fluttertoast.showToast(msg: "ตรวจสอบประวัติเครื่องแบบล้มเหลว: ${err.toString()}");
    }
  }

  Future<dynamic> fetchEmpShirtOrder() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("emp_key").toString();
    final String token = prefs.getString("token").toString();

    notifyListeners();

    // print('current user id is ${user_id}');
    print('employee order is ${url_to_get_uniform_order + "/" + user_id}');
    try {
      http.Response response;
      response = await http.get(
          Uri.parse(url_to_get_uniform_order + "/" + user_id),
          headers: {"Authorization": token});

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<ShirtOrder> data = [];
        if (decoded == null) {
          print("no data");
          return 0;
        }
        List<dynamic> resList = [];
        if (decoded is List) {
          resList = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          resList = decoded['data'];
        }

        for (var i = 0; i <= resList.length - 1; i++) {
          ShirtOrder _data = ShirtOrder(
            order_id: resList[i]['id'].toString(),
            shirt_type: resList[i]['shirt_id'].toString(),
            shirt_size: resList[i]['shirt_size_id'].toString(),
            shirt_pocket: resList[i]['shirt_pocket_id'].toString(),
            shirt_qty: resList[i]['qty'].toString(),
            shirt_remark: resList[i]['remark'].toString(),
            shirt_type_name: resList[i]['shirt_name'].toString(),
            shirt_size_name: resList[i]['shirt_size_name'].toString(),
            shirt_pocket_name: resList[i]['shirt_pocket_name'].toString(),
          );
          data.add(_data);
          print("shirt order data is ${decoded}");
        }
        listshirtorder = data;

        notifyListeners();
        return listshirtorder;
      } else {
        print("No Data fetchEmpShirtOrder: ${response.statusCode} - ${response.body}");
        Fluttertoast.showToast(msg: "ดึงรายการสั่งจองล้มเหลว: รหัส ${response.statusCode}");
      }
    } catch (err) {
      print("error na ja is ${err}");
      Fluttertoast.showToast(msg: "ดึงรายการสั่งจองล้มเหลว: ${err.toString()}");
    }
  }

  int checkShirtPermission(
      String shirt_id,
      String emp_level,
      String dep_id,
      String position_name,
      String shirt_type_id,
      String emp_salary_type,
      String emp_gender) {
    int res = 0;
    String _contain_text = 'ช่าง';
    String _contain_text_engineer = 'วิศว';
    List<String> _engineer_dept_list = [
      '19',
      '23',
      '26',
      '33',
      '44',
      '51',
      '53',
      '56',
      '57',
      '59',
      '62',
      '64',
      '68',
      '69'
    ];

    if (shirtassignstdlist.length > 0) {
      if (dep_id == '9' || dep_id == '18' || dep_id == '42') {
        // qc , store , warehouse
        if (emp_salary_type == '3' && shirt_type_id == '2') {
          // รายวัน + เสื้อคอกลม แถบเหลือง
          res += 1;
        }
        if (emp_salary_type == '1' && shirt_type_id == '1' && shirt_id == '1') {
          // รายเดือน + ประเภทโปโล + โปโลหญิง
          res += 1;
        }
        if (emp_salary_type == '1' && shirt_type_id == '1' && shirt_id == '2') {
          // รายเดือน + ประเภทโปโล + โปโลชาย
          res += 1;
        }
        // if (emp_salary_type == '1' &&
        //     shirt_type_id == '1' &&
        //     emp_gender == '1' &&
        //     shirt_id == '1') {
        //   // รายเดือน + โปโลชาย
        //   res += 1;
        // }
      } else {
        if (emp_salary_type == '3' &&
            shirt_type_id == '4' &&
            position_name != 'ช่างประจำแผนก') {
          // รายวัน + เสื้อคอกลม แถบเทา
          res += 1;
        }
        // print("not store warehouse");
        if (shirt_type_id == '3' && position_name == 'พนักงานช่าง') {
          // รายวัน + ช่าง + ช๊อป
          //print("shirt type is ${shirt_type_id}");
          res += 1;
        } else if (emp_level == '3' &&
            emp_salary_type == '3' &&
            shirt_type_id == '3' &&
            position_name == 'ช่างประจำแผนก') {
          //  ช่างรายวันเสื้อshopper
          res += 1;
        } else if (emp_level == '3' &&
            emp_salary_type == '1' &&
            shirt_type_id == '3' &&
            position_name == 'ช่างประจำแผนก') {
          //  ช่างรายเดือนเสื้อshopper
          res += 1;
        } else if (emp_level != '3' &&
            emp_salary_type == '1' &&
            shirt_type_id == '3' &&
            _engineer_dept_list.contains(dep_id) &&
            _contain_text_engineer.contains(_contain_text_engineer)) {
          //  รายเดือน วิศวกรรม เสื้อ shop ระดับหัวหน้า
          res += 1;
        } else if (emp_level == '3' &&
            emp_salary_type == '1' &&
            shirt_type_id == '3' &&
            _engineer_dept_list.contains(dep_id) &&
            _contain_text_engineer.contains(_contain_text_engineer)) {
          //  รายเดือน วิศวกรรม เสื้อ shop ระดับเจ้าหน้าที่
          res += 1;
        } else if (emp_salary_type == '1' &&
            shirt_type_id == '1' &&
            shirt_id == '2' &&
            emp_gender == '1' &&
            !position_name.contains(_contain_text) &&
            !_engineer_dept_list.contains(dep_id)) {
          // รายเดือน + โปโลชาย
          res += 1;
        } else if (emp_salary_type == '1' &&
            shirt_type_id == '1' &&
            shirt_id == '2' &&
            emp_gender == '2' &&
            !position_name.contains(_contain_text) &&
            !_engineer_dept_list.contains(dep_id)) {
          // รายเดือน + โปโลชาย + พนักงานหญิง
          res += 1;
        } else if (emp_salary_type == '1' &&
            shirt_type_id == '1' &&
            shirt_id == '1' &&
            emp_gender == '2' &&
            !position_name.contains(_contain_text) &&
            !_engineer_dept_list.contains(dep_id)) {
          // รายเดือน + โปโลหญิง + พนักงานหญิง
          res += 1;
        }
      }
    }
    return res;
  }

  Future<dynamic> fetchShirtEmpAssingStd() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("emp_key").toString();
    final String token = prefs.getString("token").toString();

    notifyListeners();
    if (shirtassignstdlist.length == 0) {
      try {
        http.Response response;
        response = await http.get(Uri.parse(url_to_get_shirt_assing_std),
            headers: {"Authorization": token});

        if (response.statusCode == 200) {
          List<ShirtAssignStd> data = [];
          final decoded = json.decode(response.body);
          if (decoded == null) {
            print("no data");
            return false;
          }
          List<dynamic> resList = [];
          if (decoded is List) {
            resList = decoded;
          } else if (decoded is Map && decoded['data'] is List) {
            resList = decoded['data'];
          }

          for (var i = 0; i <= resList.length - 1; i++) {
            final ShirtAssignStd _item = ShirtAssignStd(
              id: resList[i]["id"].toString(),
              shirt_id: resList[i]["shirt_id"].toString(),
              emp_level_id: resList[i]["emp_level_id"].toString(),
              emp_dept_id: resList[i]["emp_dept_id"].toString(),
              emp_dept_name: resList[i]["emp_dept_name"].toString(),
              emp_position_id: resList[i]["emp_position_id"].toString(),
              emp_position_name: resList[i]["emp_position_name"].toString(),
            );

            data.add(_item);
          }
          shirtassignstdlist = data;
          print("assign list len is ${shirtassignstdlist.length}");
          notifyListeners();
          return shirtassignstdlist;
        } else {
          print("No Data fetchShirtEmpAssingStd: ${response.statusCode} - ${response.body}");
          Fluttertoast.showToast(msg: "ดึงสิทธิ์เครื่องแบบล้มเหลว: รหัส ${response.statusCode}");
        }
      } catch (err) {
        print("error na ja is ${err}");
        Fluttertoast.showToast(msg: "ดึงสิทธิ์เครื่องแบบล้มเหลว: ${err.toString()}");
      }
    }
  }
}
