import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cic_support/models/product_group_menu.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductgroupData with ChangeNotifier {
  final String url_to_productgroup_list = "https://api.cicsupports.com/api/findcategory";
  final String url_to_productgroup_list_main = "https://api.cicsupports.com/api/findcategorymain";

  List<ProductGroupMenu>? _productgroup;
  List<ProductGroupMenu> get listproductgroup => _productgroup ?? [];
  bool _isLoading = false;
  int _id = 0;

  int get idProductgroup => _id;

  set idProductgroup(int val) {
    _id = val;
    notifyListeners();
  }

  set listproductgroup(List<ProductGroupMenu> val) {
    _productgroup = val;
    notifyListeners();
  }

  bool get is_loading {
    return _isLoading;
  }

  Future<dynamic> fetchProductgroup() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    _isLoading = true;
    notifyListeners();
    print("data for get category");
    try {
      http.Response response;
      response = await http.get(
        Uri.parse(url_to_productgroup_list),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> res = json.decode(response.body);
        List<ProductGroupMenu> data = [];
        
        for (var i = 0; i < res.length; i++) {
          final ProductGroupMenu groupresult = ProductGroupMenu(
            id: res[i]['cat_name'].toString(),
            name: res[i]['cat_name'].toString(),
            isactive: i == 0 ? true : false,
          );
          data.add(groupresult);
        }

        listproductgroup = data;
        _isLoading = false;
        notifyListeners();
        return listproductgroup;
      } else {
        print("category response is ${response.statusCode}");
      }
    } catch (e) {
      print("category error is ${e}");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<dynamic> fetchProductgroupmain() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    _isLoading = true;
    notifyListeners();
    print("data for get category main");
    try {
      http.Response response;
      response = await http.get(
        Uri.parse(url_to_productgroup_list_main),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> res = json.decode(response.body);
        List<ProductGroupMenu> data = [];
        
        for (var i = 0; i < res.length; i++) {
          final ProductGroupMenu groupresult = ProductGroupMenu(
            id: res[i]['cat_name'].toString(),
            name: res[i]['cat_name'].toString(),
            isactive: i == 0 ? true : false,
          );
          data.add(groupresult);
        }

        listproductgroup = data;
        _isLoading = false;
        notifyListeners();
        return listproductgroup;
      } else {
        print("category response is ${response.statusCode}");
      }
    } catch (e) {
      print("category error is ${e}");
    }
    _isLoading = false;
    notifyListeners();
  }
}
