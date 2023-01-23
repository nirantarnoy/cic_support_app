import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/carlist.dart';
import 'package:flutter_cic_support/models/nonconformselected.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CarData extends ChangeNotifier {
  // final String url_to_addcar = "http://192.168.60.85:1223/api/car/createcar";
  final String url_to_addcar = "http://172.16.0.231:1223/api/car/createcar";
  final String url_to_listcar_by_emp =
      "http://172.16.0.231:1223/api/car/listcarbyemp";

  late List<CarList> _carlist = [];
  List<CarList> get listcaritem => _carlist;

  set listcaritem(List<CarList> val) {
    _carlist = val;
  }

  Future<bool> addCar(
      String trans_date,
      String area_id,
      String problem_type,
      String description,
      List<NonconformSelected> nonconformlist,
      List<String> carphoto) async {
    final nonconformJson = nonconformlist.map((e) => {'id': e.id}).toList();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("user_id").toString();
    final String token = prefs.getString("token").toString();

    final photoJson = carphoto.map((e) => {'photo': e}).toList();
    final Map<String, dynamic> insertData = {
      'id': 0,
      'area_id': int.parse(area_id),
      'car_date': DateTime.now().toIso8601String(),
      'car_description': description,
      'car_type': int.parse(problem_type),
      'car_non_conform': json.encode(nonconformJson),
      'status': 1,
      'car_photo': carphoto,
      'created_by': 2,
      'emp_id': int.parse(user_id),
    };
    print('photo are ${json.encode(photoJson)}');
    try {
      http.Response response;
      response = await http.post(Uri.parse(url_to_addcar),
          headers: {"Authorization": token, 'Content-Type': 'application/json'},
          body: json.encode(insertData));
      return true;
    } catch (err) {
      print('has error na ja ${err}');
      return false;
    }
    // return true;
  }

  Future<dynamic> getCarlistByEmpId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user_id = prefs.getString("user_id").toString();
    final String token = prefs.getString("token").toString();

    try {
      http.Response response;
      response = await http.get(
          Uri.parse(url_to_listcar_by_emp + "/" + user_id),
          headers: {"Authorization": token});

      if (response.statusCode == 200) {
        // print("${json.decode(response.body)}");
        // return;
        List<dynamic> res = json.decode(response.body);
        if (res == null) {
          print("no data");
        }

        List<CarList> data = [];
        for (var i = 0; i <= res.length - 1; i++) {
          print('car no is ${res[i]['car_no'].toString()}');
          CarList _item = CarList(
            car_id: res[i]['id'].toString(),
            car_no: res[i]['car_no'] == null ? '' : res[i]['car_no'].toString(),
            car_date: res[i]['car_date'].toString(),
            module_type_id: "1",
            area_id: res[i]['area_id'].toString(),
            area_name: res[i]['area_name'].toString(),
            problem_type: "",
            description: res[i]['car_description'].toString(),
            status: res[i]['status'].toString(),
            is_new: res[i]['is_new'].toString(),
            target_finish_date: res[i]['target_finish_date'].toString(),
            responsibility: res[i]['responsibility'].toString(),
            car_non_conform: res[i]['car_non_conform'].toString(),
          );

          data.add(_item);
        }
        listcaritem = data;
        // print(listcaritem);
        notifyListeners();
        return listcaritem;
      } else {
        print("Something went wrong!");
      }
    } catch (err) {
      print(err);
    }
  }
}
