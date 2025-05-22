import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_cic_support/models/jobplanarea.dart';
import 'package:flutter_cic_support/models/securitycheckdata.dart';
import 'package:flutter_cic_support/models/shirtdata.dart';
import 'package:flutter_cic_support/models/shirtorder.dart';
import 'package:flutter_cic_support/pages/carhistory.dart';
import 'package:flutter_cic_support/pages/carlistpage.dart';
import 'package:flutter_cic_support/pages/history.dart';
import 'package:flutter_cic_support/pages/jobcheck.dart';
import 'package:flutter_cic_support/pages/jobchecknew.dart';
import 'package:flutter_cic_support/pages/plancheckcomplete.dart';
import 'package:flutter_cic_support/pages/securitycheckdetail.dart';
import 'package:flutter_cic_support/pages/shirtorderpage.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_cic_support/providers/securityplan.dart';
import 'package:flutter_cic_support/providers/shirtemp.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:flutter_cic_support/services/local_auth.dart';
import 'package:flutter_cic_support/sqlite/dbprovider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShirtempPage extends StatefulWidget {
  const ShirtempPage({Key? key}) : super(key: key);

  @override
  State<ShirtempPage> createState() => _ShirtempPageState();
}

class _ShirtempPageState extends State<ShirtempPage> {
  final TextEditingController _textEditingController =
      new TextEditingController();
  String current_section_code = '';
  String qrCode = '';
  late int _quantity;
  int _shirt_type = -1;
  int _shirt_size = -1;
  int _shirt_pocket = -1;
  int _cart_count = 0;
  String _remark = '';
  int _shirt_qty = 1;

  String _shirt_type_name = '';
  String _shirt_size_name = '';
  String _shirt_pocket_name = '';

  String _emp_level = '0';
  String _emp_gender = '0';

  int _emp_salary_type = 0;
  int _emp_shirt_qty = 0;
  List<ShirtOrder> _fetch_orderlist = [];

  late List<ShirtOrder> _cart = [];

  String imageUrl =
      'https://img.cicsupports.com/shirtsizetable/cic_shirt_size.png';
  // Future _obtainPlanArea() async {
  //   return await Provider.of<PlanData>(context, listen: false).fetchJobplan();
  // }

  // List<Shirtemp> _checklist = [
  //   Shirtemp(
  //       plan_id: "1",
  //       plan_date: "",
  //       plan_area_id: "1",
  //       plan_area_name: "Drum Test",
  //       plan_topic_check_qty: "20",
  //       plan_topic_checked_qty: "0",
  //       status: "0"),
  //   Shirtemp(
  //       plan_id: "1",
  //       plan_date: "",
  //       plan_area_id: "1",
  //       plan_area_name: "คลังสินค้า(ตึก 11)",
  //       plan_topic_check_qty: "20",
  //       plan_topic_checked_qty: "0",
  //       status: "0"),
  //   Shirtemp(
  //       plan_id: "1",
  //       plan_date: "",
  //       plan_area_id: "1",
  //       plan_area_name: "ตัดผ้าใบ (ตึก 15)",
  //       plan_topic_check_qty: "20",
  //       plan_topic_checked_qty: "0",
  //       status: "0")
  // ];

  // Future _orderFuture = Future(() => null);

  @override
  void initState() {
    // TODO: implement initState
    // Provider.of<PlanData>(context, listen: false).fetchJobplan();
    // _obtainPlanArea();
    _quantity = 1;
    _cart_count = _cart.length;
    EasyLoading.show(status: "โหลดข้อมูล");
    //  Provider.of<PlanData>(context, listen: false).fetFinishedCheck();
    Provider.of<ShirtempData>(context, listen: false).fetchShirt();
    Provider.of<ShirtempData>(context, listen: false).fetchShirtSize();
    Provider.of<ShirtempData>(context, listen: false).fetchShirtPocket();
    Provider.of<ShirtempData>(context, listen: false).fetchShirtEmpAssingStd();
    Provider.of<ShirtempData>(context, listen: false).fetchEmpShirtOrder();

    _emp_salary_type =
        Provider.of<UserData>(context, listen: false).empsalarytype;
    _emp_level =
        Provider.of<UserData>(context, listen: false).emplevel.toString();
    _emp_gender =
        Provider.of<UserData>(context, listen: false).empgender.toString();
    _emp_shirt_qty = Provider.of<UserData>(context, listen: false).empshirtqty;

    EasyLoading.dismiss();
    super.initState();
  }

  void increateqty() {
    // print('xxx');
    setState(() {
      if (_quantity < _emp_shirt_qty) {
        _quantity++;
      }
    });
  }

  void decreateqty() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  int checkOverQty() {
    int res = 0;
    if (_cart != null) {
      int totalqty = 0;
      _cart.forEach((element) {
        totalqty += int.parse(element.shirt_qty);
      });

      print("total qty is ${totalqty}");

      if ((totalqty + _quantity) > _emp_shirt_qty) {
        Fluttertoast.showToast(
            msg: "คุณเลือกเสื้อได้แค่ ${_emp_shirt_qty} ตัว",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        _quantity = 1;
        res = 1;
      }
    }
    return res;
  }

  void clearInput() {
    setState(() {
      _shirt_type = -1;
      _shirt_size = -1;
      _shirt_pocket = -1;
      _remark = '';
      _quantity = 1;
    });
  }

  Future<int> getAreacheckCount(String area_id) async {
    int cnt = await DbProvider.instance.countCheckedTopicitemX(area_id);
    return cnt;
  }

  Future<bool> scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!mounted) return false;
      setState(() {
        this.qrCode = qrCode;
        if (this.qrCode != '-1') {
          List<SecuritycheckData> _listafterfind =
              Provider.of<SecurityplanData>(context, listen: false)
                  .listSecurityplan;
          if (_listafterfind.isNotEmpty) {
            _listafterfind.forEach((element) {
              if (element.code == this.qrCode) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SecuritycheckDetailPage(
                              id: element.id,
                              code: element.code,
                              current_area_id: element.location_id,
                              plan_id: element.plan_id,
                            )));
              }
            });
          }
        }
      });
      return true;
    } on PlatformException {
      qrCode = 'Failed to get platform version';
      return false;
    }
  }

  void doNothing(BuildContext context) {}
  dynamic _removecheckeditem(String area_id) {
    //print("you press me ${area_id}");
    Provider.of<PlanData>(context, listen: false).removeinspectionitem(area_id);
  }

  Widget _buildshirtlist(List<Shirtdata> shirts) {
    Widget shirtCards;
    String dep_id = Provider.of<UserData>(context, listen: false)
        .empdepartmentid
        .toString();
    String pos_name = Provider.of<UserData>(context, listen: false)
        .emppositionname
        .toString();

    if (shirts != null) {
      if (shirts.length > 0) {
        shirtCards = new GridView.builder(
            itemCount: shirts.length,
            shrinkWrap: false,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 4.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              //  print("ccccc shirt type is ${shirts[index].shirt_type_id}");
              int _is_enabled =
                  Provider.of<ShirtempData>(context, listen: false)
                      .checkShirtPermission(
                          shirts[index].id,
                          _emp_level,
                          dep_id,
                          pos_name,
                          shirts[index].shirt_type_id,
                          _emp_salary_type.toString(),
                          _emp_gender.toString());

              //print("menu enable is ${_is_enabled.toString()}");

              Color _shirt_type_active_color =
                  Color.fromARGB(255, 242, 246, 242);
              Color _shirt_not_allow_border_color = Colors.green.shade400;
              Color _shirt_not_allow_font_color = Colors.black;

              if (_shirt_type != -1) {
                if (int.parse(shirts[index].id) == _shirt_type) {
                  _shirt_type_active_color = Colors.green.shade400;
                }
              }

              if (_is_enabled == 0) {
                Color _shirt_type_active_color =
                    Color.fromARGB(255, 242, 246, 242);
                _shirt_not_allow_font_color =
                    Color.fromARGB(255, 169, 171, 169);
              }

              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_is_enabled != 0) {
                        _shirt_type = int.parse(shirts[index].id);
                        _shirt_type_name = shirts[index].name;

                        _shirt_size = -1;
                        _shirt_pocket = -1;
                        _quantity = 1;
                      }
                    });
                  },
                  child: Container(
                    height: 15,
                    decoration: BoxDecoration(
                      color: _shirt_type_active_color,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                        color: _shirt_not_allow_border_color,
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        "${shirts[index].name}",
                        style: TextStyle(color: _shirt_not_allow_font_color),
                      ),
                    )),
                  ),
                ),
              );
            });
      } else {
        return Container(
          child: Center(
            child: Text(
              'ไม่พบข้อมูล',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ),
        );
      }
    } else {
      return Container(
        child: Center(
          child: Text(
            'ไม่พบข้อมูล2',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return shirtCards;
  }

  Widget _buildshirtsizelist(List<ShirtSizedata> shirts) {
    Widget shirtCards;

    if (shirts != null) {
      if (shirts.length > 0) {
        shirtCards = new GridView.builder(
            itemCount: shirts.length,
            shrinkWrap: true,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 2.5,
            ),
            itemBuilder: (BuildContext context, int index) {
              Color _shirt_type_active_color =
                  Color.fromARGB(255, 242, 246, 242);
              if (_shirt_size != -1 && _shirt_type != -1) {
                if (int.parse(shirts[index].id) == _shirt_size) {
                  _shirt_type_active_color = Colors.green;
                }
              }
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_shirt_type != -1) {
                        _shirt_size = int.parse(shirts[index].id);
                        _shirt_size_name = shirts[index].name;
                      }
                    });
                  },
                  child: Container(
                    height: 15,
                    decoration: BoxDecoration(
                      color: _shirt_type_active_color,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                        color: Colors.green.shade400,
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text("${shirts[index].name}"),
                    )),
                  ),
                ),
              );
            });
      } else {
        return Container(
          child: Center(
            child: Text(
              'ไม่พบข้อมูล',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ),
        );
      }
    } else {
      return Container(
        child: Center(
          child: Text(
            'ไม่พบข้อมูล2',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return shirtCards;
  }

  Widget _buildshirtpocketlist(List<ShirtPocketdata> shirts) {
    Widget shirtCards;

    if (shirts != null) {
      if (shirts.length > 0) {
        shirtCards = new GridView.builder(
            itemCount: shirts.length,
            shrinkWrap: false,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 2.5,
            ),
            itemBuilder: (BuildContext context, int index) {
              Color _shirt_type_active_color =
                  Color.fromARGB(255, 242, 246, 242);
              Color _shirt_not_allow_border_color = Colors.green.shade400;
              Color _shirt_not_allow_font_color = Colors.black;

              if (_shirt_pocket != -1 && _shirt_type != -1) {
                if (_shirt_type == 1 && int.parse(shirts[index].id) != 1) {
                  if (int.parse(shirts[index].id) == _shirt_pocket) {
                    _shirt_type_active_color = Colors.green;
                  }
                } else {
                  if (int.parse(shirts[index].id) == _shirt_pocket) {
                    _shirt_type_active_color = Colors.green;
                  }
                }
              }

              if (_shirt_type == 1 && int.parse(shirts[index].id) == 1) {
                _shirt_not_allow_border_color =
                    Color.fromARGB(255, 242, 246, 242);
                _shirt_not_allow_font_color =
                    Color.fromARGB(255, 169, 171, 169);
              }

              if (_emp_salary_type == 3 && int.parse(shirts[index].id) == 2) {
                _shirt_not_allow_border_color =
                    Color.fromARGB(255, 242, 246, 242);
                _shirt_not_allow_font_color =
                    Color.fromARGB(255, 169, 171, 169);
              }

              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_shirt_type != -1 && _shirt_size != -1) {
                        //  has selected shirt type
                        if (_shirt_type != 1 &&
                            int.parse(shirts[index].id) == 1) {
                          _shirt_pocket = int.parse(shirts[index].id);
                          _shirt_pocket_name = shirts[index].name;
                        } else {
                          _shirt_pocket = int.parse(shirts[index].id);
                          _shirt_pocket_name = shirts[index].name;
                        }
                      }
                      if (_shirt_type == 1 &&
                          int.parse(shirts[index].id) == 1 &&
                          _emp_salary_type == 3) {
                        _shirt_pocket = -1;
                        _shirt_pocket_name = '';
                      }
                      if (_emp_salary_type == 3 &&
                          int.parse(shirts[index].id) == 2) {
                        _shirt_pocket = -1;
                        _shirt_pocket_name = '';
                      }
                    });
                  },
                  child: Container(
                    height: 15,
                    decoration: BoxDecoration(
                      color: _shirt_type_active_color,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                        color: _shirt_not_allow_border_color,
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        "${shirts[index].name}",
                        style: TextStyle(
                          color: _shirt_not_allow_font_color,
                        ),
                      ),
                    )),
                  ),
                ),
              );
            });
      } else {
        return Container(
          child: Center(
            child: Text(
              'ไม่พบข้อมูล',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ),
        );
      }
    } else {
      return Container(
        child: Center(
          child: Text(
            'ไม่พบข้อมูล2',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return shirtCards;
  }

  Widget _buildTextRemark() {
    return TextField(
      controller: _textEditingController,
      maxLines: 5,
      decoration: InputDecoration(
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          )),
    );
  }

  _showPopupSize(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            child: SingleChildScrollView(
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _fetch_orderlist =
        Provider.of<ShirtempData>(context, listen: false).listshirtorder;
    _cart_count = _fetch_orderlist.length;
    _cart = _fetch_orderlist;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 45, 172, 123),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("เลือกรายการ"),
        actions: [
          _cart_count == 0
              ? Container()
              : IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 12,
                              ),
                              Icon(
                                Icons.remove_circle,
                                size: 32,
                                color: Colors.red.shade400,
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                'ยืนยันการทำรายการ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                'ต้องการดำเนินการต่อใช่หรือไม่ ?',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: MaterialButton(
                                      color: Color.fromARGB(255, 45, 172, 123),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      onPressed: () async {
                                        await EasyLoading.show(
                                            status: "กำลังดำเนินการ");
                                        setState(() {
                                          // _cart.clear();
                                          // _cart_count = 0;
                                          Provider.of<ShirtempData>(context,
                                                  listen: false)
                                              .emptyCart();
                                        });
                                        EasyLoading.dismiss();
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Text(
                                        'ใช่',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Expanded(
                                    child: MaterialButton(
                                      color: Colors.grey[400],
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text(
                                        'ไม่ใช่',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          _cart_count == 0
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(ShirtorderPage.routeName, arguments: {
                        'shirtorder': _cart,
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          size: 30,
                        ),
                        if (_cart_count > 0)
                          Positioned(
                            top: 5,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.red),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${_cart_count}',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                )
          //GestureDetector(
          //     onTap: () {
          //       Navigator.of(context)
          //           .pushNamed(ShirtorderPage.routeName, arguments: {
          //         'shirtorder': _cart,
          //       });
          //     },
          //     child: CircleAvatar(
          //       backgroundColor: Colors.orange,
          //       child: Center(
          //           child: Text(
          //         "${_cart_count.toString()}",
          //         style: TextStyle(
          //           fontWeight: FontWeight.bold,
          //           color: Colors.black,
          //         ),
          //       )),
          //     ),
          //   ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(children: [
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'แบบเสื้อ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Consumer<ShirtempData>(
              builder: (context, value, _) => _buildshirtlist(value.listshirt),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ขนาดเสื้อ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => _showPopupSize(context),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: Color.fromARGB(255, 35, 36, 35),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        'กดดูตารางรายละเอียด Size ตรงนี้',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Consumer<ShirtempData>(
              builder: (context, value, _) =>
                  _buildshirtsizelist(value.listshirtsize),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ลักษณะพิเศษ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Consumer<ShirtempData>(
              builder: (context, value, _) =>
                  _buildshirtpocketlist(value.listshirtpocket),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'หมายเหตุ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(
                left: 5,
                right: 5,
              ),
              child: _buildTextRemark(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'จำนวน',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 221, 218, 218),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                      onPressed: () {
                        decreateqty();
                      },
                      icon: Icon(Icons.remove)),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: Container(
                    child: Text(
                      "${_quantity.toString()}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 221, 218, 218),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      //print("button clicked");
                      increateqty();
                    },
                    icon: Icon(Icons.add),
                    splashColor: Colors.green,
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: GestureDetector(
              onTap: () {
                if (_shirt_type == -1) {
                  Fluttertoast.showToast(
                    msg: "กรุณาเลือกแบบเสื้อ",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else if (_shirt_size == -1) {
                  Fluttertoast.showToast(
                    msg: "กรุณาเลือกขนาดเสื้อ",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else if (_shirt_pocket == -1) {
                  Fluttertoast.showToast(
                    msg: "กรุณาเลือกลักษณะพิเศษ",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else {
                  _remark = _textEditingController.text;
                  if (checkOverQty() == 0) {
                    ShirtOrder _item = ShirtOrder(
                        order_id: "0",
                        shirt_type: _shirt_type.toString(),
                        shirt_type_name: _shirt_type_name,
                        shirt_size: _shirt_size.toString(),
                        shirt_size_name: _shirt_size_name,
                        shirt_pocket: _shirt_pocket.toString(),
                        shirt_pocket_name: _shirt_pocket_name,
                        shirt_qty: _quantity.toString(),
                        shirt_remark: _remark);

                    // _cart.add(_item);
                    Provider.of<ShirtempData>(context, listen: false)
                        .addCart(_item);
                    setState(() {
                      // _cart_count = _cart.length;
                      _cart_count =
                          Provider.of<ShirtempData>(context, listen: false)
                              .listshirtorder
                              .length;
                    });

                    clearInput();

                    Fluttertoast.showToast(
                      msg: "เพิ่มรายการเสื้อเรียบร้อยแล้ว",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                }
              },
              child: Container(
                color: Colors.green,
                height: 50,
                child: Center(
                  child: Text(
                    "หยิบใส่ตะกร้า",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
