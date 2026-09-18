import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cic_support/models/itemcart.dart';
import 'package:flutter_cic_support/models/products.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductData with ChangeNotifier {
  final String url_to_product_list = "http://172.16.0.231:3000/api/finditem";
  final String url_to_product_list_main = "http://172.16.0.231:3000/api/finditemmain";
  final String url_to_product_search_list = "http://172.16.0.231:3000/api/finditemsearch";
  final String url_to_product_search_list_main = "http://172.16.0.231:3000/api/finditemsearchmain";

  List<Products>? _product;
  List<Products> get listproduct => _product ?? [];
  List<ItemCart> orderItems = [];

  bool _isLoading = false;
  double sumCartTotal = 0;
  double sumCartAmount = 0;

  void clearCart() {
    orderItems = [];
    sumCartTotal = 0;
    sumCartAmount = 0;
    notifyListeners();
  }

  void clearAllData() {
    _product = [];
    orderItems = [];
    sumCartTotal = 0;
    sumCartAmount = 0;
    notifyListeners();
  }

  set listproduct(List<Products> val) {
    _product = val;
    notifyListeners();
  }

  bool get is_loading {
    return _isLoading;
  }

  bool addCartItem(
      String id, String name, String qty, String price, String unit_name, {String onhand = '0'}) {
    if (name != "") {
      double limitOnhand = double.tryParse(onhand.replaceAll(',', '')) ?? 0;
      ItemCart items = ItemCart(
          id: id,
          code: id,
          name: name.trim(),
          qty: qty,
          price: price,
          remark: '',
          unit_name: unit_name,
          onhand: onhand);
      int index = -1;
      if (orderItems.isNotEmpty) {
        for (int i = 0; i < orderItems.length; i++) {
          if (orderItems[i].id == id) {
            index = i;
          }
        }
        if (index > -1) {
          double currentQty = double.tryParse(orderItems[index].qty.replaceAll(',', '')) ?? 0;
          double addQty = double.tryParse(qty.replaceAll(',', '')) ?? 0;
          
          double newQty = currentQty + addQty;
          double checkOnhand = limitOnhand;
          if (checkOnhand <= 0) {
            checkOnhand = double.tryParse(orderItems[index].onhand?.toString().replaceAll(',', '') ?? '0') ?? 0;
          }
          if (checkOnhand <= 0) {
            try {
              var matchedProd = _product?.firstWhere((p) => p.id == id);
              if (matchedProd != null) {
                checkOnhand = double.tryParse(matchedProd.onhand.replaceAll(',', '')) ?? 0;
              }
            } catch (_) {}
          }

          if (newQty > checkOnhand) {
            return false;
          }

          orderItems[index].qty = newQty == newQty.toInt() ? newQty.toInt().toString() : newQty.toString();
          if (onhand != '0' && onhand.isNotEmpty) {
            orderItems[index].onhand = onhand;
          }
        } else {
          double addQty = double.tryParse(qty.replaceAll(',', '')) ?? 0;
          if (addQty > limitOnhand) {
            return false;
          }
          orderItems.add(items);
        }
      } else {
        double addQty = double.tryParse(qty.replaceAll(',', '')) ?? 0;
        if (addQty > limitOnhand) {
          return false;
        }
        orderItems.add(items);
      }
      sumCartItem();
      notifyListeners();
      return true;
    }
    return false;
  }

  void removecartitem(int index) {
    orderItems.removeAt(index);
    sumCartItem();
    notifyListeners();
  }

  void clearcartitem() {
    orderItems.clear();
    sumCartItem();
    notifyListeners();
  }

  bool updateCartQty(int index, String new_qty, {String? remark}) {
    if (index >= 0 && index < orderItems.length) {
      double newQtyVal = double.tryParse(new_qty.replaceAll(',', '')) ?? 0;
      if (newQtyVal <= 0) return false;

      double itemOnhand = double.tryParse(orderItems[index].onhand?.toString().replaceAll(',', '') ?? '0') ?? 0;
      if (itemOnhand <= 0) {
        try {
          var matchedProd = _product?.firstWhere((p) => p.id == orderItems[index].id);
          if (matchedProd != null) {
            itemOnhand = double.tryParse(matchedProd.onhand.replaceAll(',', '')) ?? 0;
          }
        } catch (_) {}
      }

      if (newQtyVal > itemOnhand) {
        return false;
      }

      orderItems[index].qty = new_qty;
      if (remark != null) {
        orderItems[index].remark = remark;
      }
      sumCartItem();
      notifyListeners();
      return true;
    }
    return false;
  }

  void sumCartItem() {
    sumCartTotal = 0;
    sumCartAmount = 0;
    for (var items in orderItems) {
      double qty = double.parse(items.qty);
      double price = double.parse(items.price);
      sumCartTotal += qty;
      sumCartAmount += (qty * price);
    }
  }

  int countCartItem(){
    return orderItems.length;
  }

  Future<dynamic> fetchProductData(String productgroup) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Map<String, dynamic> filterData = {'groupname': productgroup};
    _isLoading = true;
    notifyListeners();
    try {
      http.Response response;
      response = await http.post(
        Uri.parse(url_to_product_list),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(filterData),
      );

      if (response.statusCode == 200) {
        List<dynamic> res = json.decode(response.body);
        List<Products> data = [];
        
        for (var i = 0; i < res.length; i++) {
          final Products productresult = Products(
            id: res[i]['ITEMID'].toString(),
            name: res[i]['DESCRIPTION'].toString(),
            price: res[i]['PRICE']?.toString() ?? '0',
            unit_name: res[i]['INVENTUNIT'].toString(),
            onhand: res[i]['QTY'] == null ? '0' : res[i]['QTY'].toString(),
          );
          data.add(productresult);
        }

        listproduct = data;
      }
    } catch (_) {
      print('something went wrong!');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<dynamic> fetchProductDataBySearch(String text) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Map<String, dynamic> filterData = {'searchname': text};
    _isLoading = true;
    notifyListeners();
    try {
      http.Response response;
      response = await http.post(
        Uri.parse(url_to_product_search_list),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(filterData),
      );

      if (response.statusCode == 200) {
        List<dynamic> res = json.decode(response.body);
        List<Products> data = [];
        
        for (var i = 0; i < res.length; i++) {
          final Products productresult = Products(
            id: res[i]['ITEMID'].toString(),
            name: res[i]['DESCRIPTION'].toString(),
            price: res[i]['PRICE']?.toString() ?? '0',
            unit_name: res[i]['INVENTUNIT'].toString(),
            onhand: res[i]['QTY'] == null ? '0' : res[i]['QTY'].toString(),
          );
          data.add(productresult);
        }
        listproduct = data;
      }
    } catch (_) {
      print('something went wrong!');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<dynamic> fetchProductDataMain(String productgroup) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Map<String, dynamic> filterData = {'groupname': productgroup};
    _isLoading = true;
    notifyListeners();
    try {
      http.Response response;
      response = await http.post(
        Uri.parse(url_to_product_list_main),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(filterData),
      );

      if (response.statusCode == 200) {
        List<dynamic> res = json.decode(response.body);
        List<Products> data = [];
        
        for (var i = 0; i < res.length; i++) {
          final Products productresult = Products(
            id: res[i]['ITEMID'].toString(),
            name: res[i]['DESCRIPTION'].toString(),
            price: res[i]['PRICE']?.toString() ?? '0',
            unit_name: res[i]['INVENTUNIT'].toString(),
            onhand: res[i]['QTY'] == null ? '0' : res[i]['QTY'].toString(),
          );
          data.add(productresult);
        }
        listproduct = data;
      }
    } catch (_) {
      print('something went wrong!');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<dynamic> fetchProductDataBySearchMain(String text) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Map<String, dynamic> filterData = {'searchname': text};
    _isLoading = true;
    notifyListeners();
    try {
      http.Response response;
      response = await http.post(
        Uri.parse(url_to_product_search_list_main),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(filterData),
      );

      if (response.statusCode == 200) {
        List<dynamic> res = json.decode(response.body);
        List<Products> data = [];
        
        for (var i = 0; i < res.length; i++) {
          final Products productresult = Products(
            id: res[i]['ITEMID'].toString(),
            name: res[i]['DESCRIPTION'].toString(),
            price: res[i]['PRICE']?.toString() ?? '0',
            unit_name: res[i]['INVENTUNIT'].toString(),
            onhand: res[i]['QTY'] == null ? '0' : res[i]['QTY'].toString(),
          );
          data.add(productresult);
        }
        listproduct = data;
      }
    } catch (_) {
      print('something went wrong!');
    }
    _isLoading = false;
    notifyListeners();
  }
}
