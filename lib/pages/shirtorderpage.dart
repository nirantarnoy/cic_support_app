import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/shirtorder.dart';
import 'package:flutter_cic_support/pages/profile.dart';
import 'package:flutter_cic_support/pages/profilenormal.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_cic_support/providers/shirtemp.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class ShirtorderPage extends StatefulWidget {
  static const routeName = '/shirtorder';
  const ShirtorderPage({Key? key}) : super(key: key);

  @override
  State<ShirtorderPage> createState() => _ShirtorderPageState();
}

class _ShirtorderPageState extends State<ShirtorderPage> {
  int total_qty = 0;
  // List<ShirtOrder> order_items = [];
  // int total_qty = 0;

  // Future _fetorderlist() async {
  //   order_items = await Provider.of<ShirtempData>(this.context, listen: false)
  //       .listshirtorder;
  // }
  int userlogin_type = 0;

  @override
  void initState() {
    // TODO: implement initState
    // _fetorderlist();
    // total_qty = order_items.length;
    userlogin_type =
        Provider.of<UserData>(this.context, listen: false).userlogintype;
    super.initState();
  }

  Widget _buildlist(List<ShirtOrder> orders) {
    Widget itemcards;
    if (orders.isNotEmpty) {
      if (orders.length > 0) {
        itemcards = new ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, int index) {
              return Dismissible(
                key: ValueKey(orders[index]),
                background: Container(
                  color: Colors.red,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) {
                  return showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                              title: Text("ยืนยันการลบข้อมูล"),
                              content: Text("คุณต้องการลบข้อมูลใช่หรือไม่"),
                              actions: [
                                TextButton(
                                  child: Text("ยกเลิก"),
                                  onPressed: () {
                                    Navigator.of(ctx).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: Text("ยืนยัน"),
                                  onPressed: () {
                                    Navigator.of(ctx).pop(true);
                                  },
                                ),
                              ]));
                },
                onDismissed: (direction) {
                  setState(() {
                    // orders.forEach((element) {
                    //   if (element.shirt_type == orders[index].shirt_type) {
                    //     orders.removeWhere((item) =>
                    //         item.shirt_type == orders[index].shirt_type);
                    //     print("remove item ${orders[index].shirt_type}");

                    //     // Provider.of<ShirtempData>(context, listen: false)
                    //     //     .removeCart(orders[index].shirt_type);
                    //   }
                    // });
                    Provider.of<ShirtempData>(context, listen: false)
                        .removeCart(index);
                    // orders.removeAt(index);
                  });
                  // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //   content: Text("ลบข้อมูลสําเร็จ"),
                  // ));
                  Fluttertoast.showToast(
                      msg: "ลบข้อมูลสําเร็จ",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0);
                },
                child: ListTile(
                  title: Text(
                      '${orders[index].shirt_type_name} ${orders[index].shirt_size_name}'),
                  subtitle: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text('${orders[index].shirt_pocket_name}'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: orders[index].shirt_remark != ''
                                ? Text(
                                    '*** ${orders[index].shirt_remark}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red,
                                    ),
                                  )
                                : Text(''),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text('${orders[index].shirt_qty}'),
                ),
              );
            });
      } else {
        return Center(
          child: Text("ไม่พบข้อมูล"),
        );
      }
    } else {
      return Center(
        child: Text("ไม่พบข้อมูล"),
      );
    }

    return itemcards;
  }

  Widget _buildRemark() {
    return Text(
        "กรณีต้องการเปลี่ยนข้อมูลเสื้อโปรดดำเนินการก่อนวันที่ 30 มิถุนายน 2568",
        style: TextStyle(
            fontWeight: FontWeight.normal, fontSize: 11, color: Colors.red));
  }

  void _submitform(BuildContext context, List<ShirtOrder> _orderlist) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                Icons.privacy_tip_outlined,
                size: 32,
                color: Colors.green.shade400,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'ยืนยันการทำรายการ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                          borderRadius: BorderRadius.circular(50)),
                      onPressed: () async {
                        // final isAvailable =
                        //     await LocalAuthApi
                        //         .hasBiometrics();
                        // if (isAvailable) {
                        //   final isAuthenticated =
                        //       await LocalAuthApi
                        //           .authenticate();
                        //   if (isAuthenticated) {
                        //     print("success");
                        //     await EasyLoading.show(
                        //         status:
                        //             "กำลังบันทึกข้อมูล");
                        //     bool isSave = await Provider
                        //             .of<PlanData>(context,
                        //                 listen: false)
                        //         .submitInspection("1");
                        //     if (isSave == true) {
                        //       await EasyLoading.showSuccess(
                        //           'บันทึกรายการเรียบร้อย');
                        //       Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //               builder: (context) =>
                        //                   PlancheckcompletePage()));
                        //     }
                        //     EasyLoading.dismiss();
                        //   }
                        // } else {
                        //   print("no bio auth");
                        //   await EasyLoading.show(
                        //       status:
                        //           "กำลังบันทึกข้อมูล");
                        //   bool isSave =
                        //       await Provider.of<PlanData>(
                        //               context,
                        //               listen: false)
                        //           .submitInspection("1");
                        //   if (isSave == true) {
                        //     await EasyLoading.showSuccess(
                        //         'บันทึกรายการเรียบร้อย');
                        //     Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (context) =>
                        //                 PlancheckcompletePage()));
                        //   }
                        //   EasyLoading.dismiss();
                        // }

                        await EasyLoading.show(status: "กำลังบันทึกข้อมูล");
                        bool isSave = await Provider.of<ShirtempData>(context,
                                listen: false)
                            .submitshirt(_orderlist);
                        if (isSave == true) {
                          await EasyLoading.showSuccess(
                              'บันทึกรายการเรียบร้อย');
                          if (userlogin_type == 1) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfilePage()));
                          } else {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileNormalPage()),
                                (route) => false);
                          }
                        }
                        EasyLoading.dismiss();

                        // final biometrics =
                        //     await LocalAuthApi
                        //         .getBiometrics();

                        //  _timer?.cancel();
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
                          borderRadius: BorderRadius.circular(50)),
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
  }

  Widget _buildTotal(List<ShirtOrder> _list) {
    int total_qty = 0;
    _list.forEach((element) {
      total_qty += int.parse(element.shirt_qty);
    });
    return Text(
      '${total_qty.toString()}',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _shirt_order = ModalRoute.of(context)?.settings.arguments as Map;
    List<ShirtOrder> order_items = _shirt_order['shirtorder'];
    // order_items.forEach((el) {
    //   total_qty = (total_qty + int.parse(el.shirt_qty));
    // });
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 45, 172, 123),
      appBar: AppBar(
        title: Text("รายละเอียดการเลือก"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(children: [
          // Expanded(
          //   flex: 5,
          //   child: order_items.isNotEmpty
          //       ? _buildlist(order_items)
          //       : Center(
          //           child: Text("ไม่พบข้อมูล"),
          //         ),
          // ),
          Expanded(
            flex: 5,
            child: Consumer<ShirtempData>(
              builder: (context, topicitems, _) =>
                  _buildlist(topicitems.listshirtorder),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(2.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'จำนวนรวม',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Consumer<ShirtempData>(
                    builder: (context, value, child) =>
                        _buildTotal(value.listshirtorder),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(2.0),
            child: _buildRemark(),
          ),
          order_items.isNotEmpty
              ? Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      _submitform(context, order_items);
                    },
                    child: Container(
                      height: 18,
                      color: Colors.green,
                      child: Center(
                          child: Text(
                        "ยืนยันส่งข้อมูล",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ),
                  ))
              : Text(''),
        ]),
      ),
    );
  }
}
