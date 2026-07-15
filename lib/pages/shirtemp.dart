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
        shirtCards = GridView.builder(
            itemCount: shirts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3.2,
            ),
            itemBuilder: (BuildContext context, int index) {
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

              Color _shirt_type_active_color = Colors.white;
              Color _shirt_not_allow_border_color = Colors.grey.shade300;
              Color _shirt_not_allow_font_color = Colors.black87;
              Gradient? _gradient;
              BoxShadow? _shadow;

              if (_shirt_type != -1) {
                if (int.parse(shirts[index].id) == _shirt_type) {
                  _gradient = const LinearGradient(
                    colors: [Color(0xFF0F9B73), Color(0xFF2EC89F)],
                  );
                  _shirt_not_allow_font_color = Colors.white;
                  _shadow = BoxShadow(
                    color: const Color(0xFF0F9B73).withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  );
                }
              }

              if (_is_enabled == 0) {
                _shirt_type_active_color = Colors.grey.shade100;
                _shirt_not_allow_border_color = Colors.grey.shade100;
                _shirt_not_allow_font_color = Colors.grey.shade400;
              }

              return GestureDetector(
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
                  decoration: BoxDecoration(
                    color: _gradient == null ? _shirt_type_active_color : null,
                    gradient: _gradient,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    border: _gradient == null
                        ? Border.all(
                            color: _shirt_not_allow_border_color,
                            width: 1,
                          )
                        : null,
                    boxShadow: _shadow != null ? [_shadow] : null,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        shirts[index].name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _shirt_not_allow_font_color,
                          fontFamily: 'Prompt',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
      } else {
        return const Center(
          child: Text(
            'ไม่พบข้อมูล',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'Prompt',
            ),
          ),
        );
      }
    } else {
      return const Center(
        child: Text(
          'ไม่พบข้อมูล',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontFamily: 'Prompt',
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
        shirtCards = GridView.builder(
            itemCount: shirts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              Color _shirt_type_active_color = Colors.white;
              Color _shirt_not_allow_font_color = Colors.black87;
              Gradient? _gradient;
              BoxShadow? _shadow;

              if (_shirt_size != -1 && _shirt_type != -1) {
                if (int.parse(shirts[index].id) == _shirt_size) {
                  _gradient = const LinearGradient(
                    colors: [Color(0xFF0F9B73), Color(0xFF2EC89F)],
                  );
                  _shirt_not_allow_font_color = Colors.white;
                  _shadow = BoxShadow(
                    color: const Color(0xFF0F9B73).withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  );
                }
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_shirt_type != -1) {
                      _shirt_size = int.parse(shirts[index].id);
                      _shirt_size_name = shirts[index].name;
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _gradient == null ? _shirt_type_active_color : null,
                    gradient: _gradient,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    border: _gradient == null
                        ? Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          )
                        : null,
                    boxShadow: _shadow != null ? [_shadow] : null,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        shirts[index].name,
                        style: TextStyle(
                          color: _shirt_not_allow_font_color,
                          fontFamily: 'Prompt',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
      } else {
        return const Center(
          child: Text(
            'ไม่พบข้อมูล',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'Prompt',
            ),
          ),
        );
      }
    } else {
      return const Center(
        child: Text(
          'ไม่พบข้อมูล',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontFamily: 'Prompt',
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
        shirtCards = GridView.builder(
            itemCount: shirts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (BuildContext context, int index) {
              Color _shirt_type_active_color = Colors.white;
              Color _shirt_not_allow_border_color = Colors.grey.shade300;
              Color _shirt_not_allow_font_color = Colors.black87;
              Gradient? _gradient;
              BoxShadow? _shadow;

              if (_shirt_pocket != -1 && _shirt_type != -1) {
                if (_shirt_type == 1 && int.parse(shirts[index].id) != 1) {
                  if (int.parse(shirts[index].id) == _shirt_pocket) {
                    _gradient = const LinearGradient(
                      colors: [Color(0xFF0F9B73), Color(0xFF2EC89F)],
                    );
                    _shirt_not_allow_font_color = Colors.white;
                    _shadow = BoxShadow(
                      color: const Color(0xFF0F9B73).withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    );
                  }
                } else {
                  if (int.parse(shirts[index].id) == _shirt_pocket) {
                    _gradient = const LinearGradient(
                      colors: [Color(0xFF0F9B73), Color(0xFF2EC89F)],
                    );
                    _shirt_not_allow_font_color = Colors.white;
                    _shadow = BoxShadow(
                      color: const Color(0xFF0F9B73).withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    );
                  }
                }
              }

              if (_shirt_type == 1 && int.parse(shirts[index].id) == 1) {
                _shirt_type_active_color = Colors.grey.shade100;
                _shirt_not_allow_border_color = Colors.grey.shade100;
                _shirt_not_allow_font_color = Colors.grey.shade400;
              }

              if (_emp_salary_type == 3 && int.parse(shirts[index].id) == 2) {
                _shirt_type_active_color = Colors.grey.shade100;
                _shirt_not_allow_border_color = Colors.grey.shade100;
                _shirt_not_allow_font_color = Colors.grey.shade400;
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_shirt_type != -1 && _shirt_size != -1) {
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
                  decoration: BoxDecoration(
                    color: _gradient == null ? _shirt_type_active_color : null,
                    gradient: _gradient,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    border: _gradient == null
                        ? Border.all(
                            color: _shirt_not_allow_border_color,
                            width: 1,
                          )
                        : null,
                    boxShadow: _shadow != null ? [_shadow] : null,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        shirts[index].name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _shirt_not_allow_font_color,
                          fontFamily: 'Prompt',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
      } else {
        return const Center(
          child: Text(
            'ไม่พบข้อมูล',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'Prompt',
            ),
          ),
        );
      }
    } else {
      return const Center(
        child: Text(
          'ไม่พบข้อมูล',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontFamily: 'Prompt',
          ),
        ),
      );
    }

    return shirtCards;
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
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "รายละเอียดการจองเสื้อ",
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          _cart_count == 0
              ? Container()
              : IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 24),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(height: 12),
                              Icon(
                                Icons.remove_circle,
                                size: 56,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'ยืนยันล้างตะกร้า',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'Prompt',
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'คุณต้องการลบรายการเสื้อทั้งหมดในตะกร้าใช่หรือไม่?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Prompt',
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F9B73),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      onPressed: () async {
                                        await EasyLoading.show(
                                            status: "กำลังดำเนินการ");
                                        setState(() {
                                          Provider.of<ShirtempData>(context,
                                                  listen: false)
                                              .emptyCart();
                                        });
                                        EasyLoading.dismiss();
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text(
                                        'ใช่',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Prompt',
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.grey[700],
                                        side: BorderSide(color: Colors.grey.shade300),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: const Text(
                                        'ไม่ใช่',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Prompt',
                                          fontSize: 16,
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
                  padding: const EdgeInsets.only(right: 12),
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
                        const Icon(
                          Icons.shopping_cart_outlined,
                          color: Color(0xFF0F9B73),
                          size: 26,
                        ),
                        if (_cart_count > 0)
                          Positioned(
                            top: 8,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.red),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${_cart_count}',
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Shirt Type
                    _buildSectionHeader('แบบเสื้อ'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Consumer<ShirtempData>(
                        builder: (context, value, _) => _buildshirtlist(value.listshirt),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Shirt Size
                    Row(
                      children: [
                        _buildSectionHeader('ขนาดเสื้อ'),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showPopupSize(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F9B73).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.info_outline_rounded, color: Color(0xFF0F9B73), size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'ตารางไซส์เสื้อ',
                                  style: TextStyle(
                                    color: Color(0xFF0F9B73),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Prompt',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Consumer<ShirtempData>(
                        builder: (context, value, _) =>
                            _buildshirtsizelist(value.listshirtsize),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 3: Special Character (Pocket)
                    _buildSectionHeader('ลักษณะพิเศษ'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Consumer<ShirtempData>(
                        builder: (context, value, _) =>
                            _buildshirtpocketlist(value.listshirtpocket),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 4: Remark
                    _buildSectionHeader('หมายเหตุ'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TextField(
                        controller: _textEditingController,
                        maxLines: 3,
                        style: const TextStyle(fontFamily: 'Prompt', fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'ระบุรายละเอียดเพิ่มเติม (ถ้ามี)...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontFamily: 'Prompt'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF0F9B73), width: 1.5),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 5: Quantity
                    _buildSectionHeader('จำนวน'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                                onPressed: () {
                                  decreateqty();
                                },
                                icon: const Icon(Icons.remove, color: Colors.black87)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              "${_quantity.toString()}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Prompt',
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                increateqty();
                              },
                              icon: const Icon(Icons.add, color: Colors.black87),
                              splashColor: Colors.green,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // Bottom Action: Add to Cart
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F9B73), Color(0xFF2EC89F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F9B73).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (_shirt_type == -1) {
                        Fluttertoast.showToast(
                          msg: "กรุณาเลือกแบบเสื้อ",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else if (_shirt_size == -1) {
                        Fluttertoast.showToast(
                          msg: "กรุณาเลือกขนาดเสื้อ",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else if (_shirt_pocket == -1) {
                        Fluttertoast.showToast(
                          msg: "กรุณาเลือกลักษณะพิเศษ",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
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

                          Provider.of<ShirtempData>(context, listen: false)
                              .addCart(_item);
                          setState(() {
                            _cart_count =
                                Provider.of<ShirtempData>(context, listen: false)
                                    .listshirtorder
                                    .length;
                          });

                          clearInput();
                          _textEditingController.clear();

                          Fluttertoast.showToast(
                            msg: "เพิ่มรายการเสื้อเรียบร้อยแล้ว",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      }
                    },
                    child: const Center(
                      child: Text(
                        "หยิบใส่ตะกร้า",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Prompt',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF0F9B73),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 16,
            fontFamily: 'Prompt',
          ),
        ),
      ],
    );
  }
}
