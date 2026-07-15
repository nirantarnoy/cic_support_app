import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_cic_support/models/jobplanarea.dart';
import 'package:flutter_cic_support/models/securitycheckarea.dart';
import 'package:flutter_cic_support/models/securitycheckdata.dart';
import 'package:flutter_cic_support/pages/carhistory.dart';
import 'package:flutter_cic_support/pages/carlistpage.dart';
import 'package:flutter_cic_support/pages/history.dart';
import 'package:flutter_cic_support/pages/jobcheck.dart';
import 'package:flutter_cic_support/pages/jobchecknew.dart';
import 'package:flutter_cic_support/pages/plancheckcomplete.dart';
import 'package:flutter_cic_support/pages/securitycheckdetail.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_cic_support/providers/securityplan.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:flutter_cic_support/services/local_auth.dart';
import 'package:flutter_cic_support/sqlite/dbprovider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class SecuritycheckAreaPage extends StatefulWidget {
  const SecuritycheckAreaPage({Key? key}) : super(key: key);

  @override
  State<SecuritycheckAreaPage> createState() => _SecuritycheckAreaPageState();
}

class _SecuritycheckAreaPageState extends State<SecuritycheckAreaPage> {
  String current_section_code = '';
  String qrCode = '';
  Future _obtainPlanArea() async {
    return await Provider.of<PlanData>(context, listen: false).fetchJobplan();
  }

  // List<SecuritycheckArea> _checklist = [
  //   SecuritycheckArea(
  //       plan_id: "1",
  //       plan_date: "",
  //       plan_area_id: "1",
  //       plan_area_name: "Drum Test",
  //       plan_topic_check_qty: "20",
  //       plan_topic_checked_qty: "0",
  //       status: "0"),
  //   SecuritycheckArea(
  //       plan_id: "1",
  //       plan_date: "",
  //       plan_area_id: "1",
  //       plan_area_name: "คลังสินค้า(ตึก 11)",
  //       plan_topic_check_qty: "20",
  //       plan_topic_checked_qty: "0",
  //       status: "0"),
  //   SecuritycheckArea(
  //       plan_id: "1",
  //       plan_date: "",
  //       plan_area_id: "1",
  //       plan_area_name: "ตัดผ้าใบ (ตึก 15)",
  //       plan_topic_check_qty: "20",
  //       plan_topic_checked_qty: "0",
  //       status: "0")
  // ];
  @override
  void initState() {
    // TODO: implement initState
    // Provider.of<PlanData>(context, listen: false).fetchJobplan();
    // _obtainPlanArea();
    EasyLoading.show(status: "โหลดข้อมูล");
    //  Provider.of<PlanData>(context, listen: false).fetFinishedCheck();
    Provider.of<SecurityplanData>(context, listen: false)
        .fetchSecurityCheckplan();
    EasyLoading.dismiss();

    super.initState();
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

  // Widget _buildList(List<SecuritycheckArea> listcheck) {
  //   Widget cardlist;
  //   if (listcheck.length > 0) {
  //     cardlist = ListView.builder(
  //         itemCount: listcheck.length,
  //         itemBuilder: (BuildContext contex, int index) {
  //           return FutureBuilder<int>(
  //               future: getAreacheckCount(listcheck[index].plan_area_id),
  //               builder: (contex, snapshot) {
  //                 if (snapshot.hasData &&
  //                     snapshot.connectionState == ConnectionState.done) {
  //                   int total_topic =
  //                       Provider.of<PlanData>(contex, listen: false)
  //                           .countTopicitem(listcheck[index].plan_area_id);
  //                   int? total_topic_counted = snapshot.data;

  //                   Color _bgcolor = Colors.green.shade50;
  //                   Color _line_color = Colors.black;

  //                   if (current_section_code == listcheck[index].section_code) {
  //                     _line_color = Colors.red;
  //                   }
  //                   if (total_topic_counted! <= 0) {
  //                     _bgcolor = Colors.green.shade50;
  //                   } else if (total_topic_counted > 0 &&
  //                       total_topic_counted < total_topic) {
  //                     _bgcolor = Color.fromARGB(255, 235, 177, 17);
  //                   }
  //                   if (total_topic_counted == total_topic) {
  //                     _bgcolor = Colors.green.shade400;
  //                   }
  //                   return Slidable(
  //                     key: const ValueKey(0),
  //                     enabled:
  //                         current_section_code == listcheck[index].section_code
  //                             ? false
  //                             : true,
  //                     startActionPane: ActionPane(
  //                       motion: const ScrollMotion(),
  //                       // dismissible: DismissiblePane(onDismissed: () {}),
  //                       children: [
  //                         SlidableAction(
  //                           onPressed: doNothing,
  //                           backgroundColor: Colors.red,
  //                           foregroundColor: Colors.white,
  //                           icon: Icons.delete,
  //                           label: 'Clear',
  //                         ),
  //                         // SlidableAction(
  //                         //   onPressed: doNothing,
  //                         //   backgroundColor: Colors.red,
  //                         //   foregroundColor: Colors.white,
  //                         //   icon: Icons.delete,
  //                         //   label: 'Delete',
  //                         // ),
  //                         // SlidableAction(
  //                         //   onPressed: doNothing,
  //                         //   backgroundColor: Colors.green,
  //                         //   foregroundColor: Colors.white,
  //                         //   icon: Icons.share,
  //                         //   label: 'Share',
  //                         // )
  //                       ],
  //                     ),
  //                     endActionPane: ActionPane(
  //                       motion: const ScrollMotion(),
  //                       children: [
  //                         SlidableAction(
  //                           // flex: 2,
  //                           // onPressed:
  //                           //     _removecheckeditem(listcheck[index].plan_area_id),
  //                           onPressed: (BuildContext context) {
  //                             print("you pressed meeee");
  //                             _removecheckeditem(listcheck[index].plan_area_id);
  //                           },
  //                           backgroundColor: Colors.red,
  //                           foregroundColor: Colors.white,
  //                           icon: Icons.delete,
  //                           label: 'Clear',
  //                         ),
  //                         // SlidableAction(
  //                         //   onPressed: doNothing,
  //                         //   backgroundColor: Colors.red,
  //                         //   foregroundColor: Colors.white,
  //                         //   icon: Icons.delete,
  //                         //   label: 'Delete',
  //                         // ),
  //                         // SlidableAction(
  //                         //   onPressed: doNothing,
  //                         //   backgroundColor: Colors.green,
  //                         //   foregroundColor: Colors.white,
  //                         //   icon: Icons.share,
  //                         //   label: 'Share',
  //                         // )
  //                       ],
  //                     ),
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(5.0),
  //                       child: GestureDetector(
  //                           child: Container(
  //                             padding: EdgeInsets.all(5),
  //                             margin: EdgeInsets.only(top: 1),
  //                             decoration: BoxDecoration(
  //                                 color: current_section_code ==
  //                                         listcheck[index].section_code
  //                                     ? Colors.grey.shade300
  //                                     : _bgcolor,
  //                                 borderRadius:
  //                                     BorderRadius.all(Radius.circular(5))),
  //                             child: ListTile(
  //                               leading: Container(
  //                                 height: 30,
  //                                 width: 30,
  //                                 decoration: BoxDecoration(
  //                                   borderRadius: BorderRadius.circular(50),
  //                                   color: Colors.white,
  //                                 ),
  //                                 child: Center(
  //                                     child: current_section_code ==
  //                                             listcheck[index].section_code
  //                                         ? Icon(
  //                                             Icons.home,
  //                                             color: Colors.red,
  //                                           )
  //                                         : Text(
  //                                             "${(index + 1).toString()}",
  //                                             style: TextStyle(
  //                                               color: Colors.black,
  //                                               fontWeight: FontWeight.bold,
  //                                             ),
  //                                           )),
  //                               ),
  //                               title: Text(
  //                                 '${listcheck[index].plan_area_name}',
  //                                 style: TextStyle(
  //                                   fontWeight: FontWeight.bold,
  //                                   color: _line_color,
  //                                 ),
  //                               ),
  //                               trailing: Text(
  //                                 "${total_topic_counted}/${total_topic}",
  //                                 style: TextStyle(
  //                                   fontWeight: FontWeight.bold,
  //                                   color: _line_color,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           onTap: () {
  //                             current_section_code ==
  //                                     listcheck[index].section_code
  //                                 ? null
  //                                 : Navigator.of(context).push(
  //                                     MaterialPageRoute(
  //                                       builder: (context) => JobCheckNewPage(
  //                                         plan_area_id:
  //                                             listcheck[index].plan_area_id,
  //                                         plan_id: listcheck[index].plan_id,
  //                                         plan_area_name:
  //                                             listcheck[index].plan_area_name,
  //                                         plan_num: listcheck[index].plan_num,
  //                                       ),
  //                                     ),
  //                                   );
  //                           }),
  //                     ),
  //                   );
  //                 } else {
  //                   int total_topic =
  //                       Provider.of<PlanData>(contex, listen: false)
  //                           .countTopicitem(listcheck[index].plan_area_id);
  //                   int total_topic_counted = Provider.of<PlanData>(contex,
  //                           listen: false)
  //                       .countCheckedTopicitem(listcheck[index].plan_area_id);

  //                   Color _bgcolor = Colors.green.shade50;
  //                   Color _line_color = Colors.black;

  //                   if (current_section_code == listcheck[index].section_code) {
  //                     _line_color = Colors.red;
  //                   }
  //                   if (total_topic_counted! <= 0) {
  //                     _bgcolor = Colors.green.shade50;
  //                   } else if (total_topic_counted > 0 &&
  //                       total_topic_counted < total_topic) {
  //                     _bgcolor = Color.fromARGB(255, 235, 177, 17);
  //                   }
  //                   if (total_topic_counted == total_topic) {
  //                     _bgcolor = Colors.green.shade400;
  //                   }
  //                   return Slidable(
  //                     key: const ValueKey(0),
  //                     enabled:
  //                         current_section_code == listcheck[index].section_code
  //                             ? false
  //                             : true,
  //                     startActionPane: ActionPane(
  //                       motion: const ScrollMotion(),
  //                       // dismissible: DismissiblePane(onDismissed: () {}),
  //                       children: [
  //                         SlidableAction(
  //                           onPressed: doNothing,
  //                           backgroundColor: Colors.red,
  //                           foregroundColor: Colors.white,
  //                           icon: Icons.delete,
  //                           label: 'Clear',
  //                         ),
  //                         // SlidableAction(
  //                         //   onPressed: doNothing,
  //                         //   backgroundColor: Colors.red,
  //                         //   foregroundColor: Colors.white,
  //                         //   icon: Icons.delete,
  //                         //   label: 'Delete',
  //                         // ),
  //                         // SlidableAction(
  //                         //   onPressed: doNothing,
  //                         //   backgroundColor: Colors.green,
  //                         //   foregroundColor: Colors.white,
  //                         //   icon: Icons.share,
  //                         //   label: 'Share',
  //                         // )
  //                       ],
  //                     ),
  //                     endActionPane: ActionPane(
  //                       motion: const ScrollMotion(),
  //                       children: [
  //                         SlidableAction(
  //                           // flex: 2,
  //                           // onPressed:
  //                           //     _removecheckeditem(listcheck[index].plan_area_id),
  //                           onPressed: (BuildContext context) {
  //                             print("you pressed meeee");
  //                             _removecheckeditem(listcheck[index].plan_area_id);
  //                           },
  //                           backgroundColor: Colors.red,
  //                           foregroundColor: Colors.white,
  //                           icon: Icons.delete,
  //                           label: 'Clear',
  //                         ),
  //                         // SlidableAction(
  //                         //   onPressed: doNothing,
  //                         //   backgroundColor: Colors.red,
  //                         //   foregroundColor: Colors.white,
  //                         //   icon: Icons.delete,
  //                         //   label: 'Delete',
  //                         // ),
  //                         // SlidableAction(
  //                         //   onPressed: doNothing,
  //                         //   backgroundColor: Colors.green,
  //                         //   foregroundColor: Colors.white,
  //                         //   icon: Icons.share,
  //                         //   label: 'Share',
  //                         // )
  //                       ],
  //                     ),
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(5.0),
  //                       child: GestureDetector(
  //                           child: Container(
  //                             padding: EdgeInsets.all(5),
  //                             margin: EdgeInsets.only(top: 1),
  //                             decoration: BoxDecoration(
  //                                 color: current_section_code ==
  //                                         listcheck[index].section_code
  //                                     ? Colors.grey.shade300
  //                                     : _bgcolor,
  //                                 borderRadius:
  //                                     BorderRadius.all(Radius.circular(5))),
  //                             child: ListTile(
  //                               leading: Container(
  //                                 height: 30,
  //                                 width: 30,
  //                                 decoration: BoxDecoration(
  //                                   borderRadius: BorderRadius.circular(50),
  //                                   color: Colors.white,
  //                                 ),
  //                                 child: Center(
  //                                     child: current_section_code ==
  //                                             listcheck[index].section_code
  //                                         ? Icon(
  //                                             Icons.home,
  //                                             color: Colors.red,
  //                                           )
  //                                         : Text(
  //                                             "${(index + 1).toString()}",
  //                                             style: TextStyle(
  //                                               color: Colors.black,
  //                                               fontWeight: FontWeight.bold,
  //                                             ),
  //                                           )),
  //                               ),
  //                               title: Text(
  //                                 '${listcheck[index].plan_area_name}',
  //                                 style: TextStyle(
  //                                   fontWeight: FontWeight.bold,
  //                                   color: _line_color,
  //                                 ),
  //                               ),
  //                               trailing: Text(
  //                                 "${total_topic_counted}/${total_topic}",
  //                                 style: TextStyle(
  //                                   fontWeight: FontWeight.bold,
  //                                   color: _line_color,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           onTap: () {
  //                             current_section_code ==
  //                                     listcheck[index].section_code
  //                                 ? null
  //                                 : Navigator.of(context).push(
  //                                     MaterialPageRoute(
  //                                       builder: (context) => JobCheckNewPage(
  //                                         plan_area_id:
  //                                             listcheck[index].plan_area_id,
  //                                         plan_id: listcheck[index].plan_id,
  //                                         plan_area_name:
  //                                             listcheck[index].plan_area_name,
  //                                         plan_num: listcheck[index].plan_num,
  //                                       ),
  //                                     ),
  //                                   );
  //                           }),
  //                     ),
  //                   );
  //                 }
  //               });
  //         });
  //     return cardlist;
  //     //return Text('data');
  //   } else {
  //     return Text('No data');
  //   }
  // }

  Widget _buildList(List<SecuritycheckData> listcheck) {
    Widget cardlist;
    if (listcheck.length > 0) {
      cardlist = ListView.builder(
          itemCount: listcheck.length,
          itemBuilder: (BuildContext contex, int index) {
            if (listcheck[index].checked_status == "1") {
              return SizedBox.shrink();
            }
            String asset_plan_id = '0';
            if (listcheck[index].plan_id != null ||
                listcheck[index].plan_id != "") {
              asset_plan_id = listcheck[index].plan_id;
            }

            int total_topic = Provider.of<PlanData>(contex, listen: false)
                .countTopicitem(listcheck[index].id);
            int total_topic_counted =
                Provider.of<PlanData>(contex, listen: false)
                    .countCheckedTopicitem(listcheck[index].id);

            // int total_topic_counted =
            //     getAreacheckCount(listcheck[index].plan_area_id);

            Color _bgcolor = Colors.green.shade50;
            Color _line_color = Colors.black;

            if (total_topic_counted <= 0) {
              _bgcolor = Colors.green.shade50;
            } else if (total_topic_counted > 0 &&
                total_topic_counted < total_topic) {
              _bgcolor = Color.fromARGB(255, 235, 177, 17);
            }
            if (total_topic_counted == total_topic) {
              _bgcolor = Colors.green.shade400;
            }
            return Slidable(
              key: const ValueKey(0),
              enabled: true,
              startActionPane: ActionPane(
                motion: const ScrollMotion(),
                // dismissible: DismissiblePane(onDismissed: () {}),
                children: [
                  SlidableAction(
                    onPressed: doNothing,
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Clear',
                  ),
                  // SlidableAction(
                  //   onPressed: doNothing,
                  //   backgroundColor: Colors.red,
                  //   foregroundColor: Colors.white,
                  //   icon: Icons.delete,
                  //   label: 'Delete',
                  // ),
                  // SlidableAction(
                  //   onPressed: doNothing,
                  //   backgroundColor: Colors.green,
                  //   foregroundColor: Colors.white,
                  //   icon: Icons.share,
                  //   label: 'Share',
                  // )
                ],
              ),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    // flex: 2,
                    // onPressed:
                    //     _removecheckeditem(listcheck[index].plan_area_id),
                    onPressed: (BuildContext context) {
                      print("you pressed meeee");
                      _removecheckeditem(listcheck[index].id);
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Clear',
                  ),
                  // SlidableAction(
                  //   onPressed: doNothing,
                  //   backgroundColor: Colors.red,
                  //   foregroundColor: Colors.white,
                  //   icon: Icons.delete,
                  //   label: 'Delete',
                  // ),
                  // SlidableAction(
                  //   onPressed: doNothing,
                  //   backgroundColor: Colors.green,
                  //   foregroundColor: Colors.white,
                  //   icon: Icons.share,
                  //   label: 'Share',
                  // )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: ListTile(
                        leading: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white,
                          ),
                          child: Center(
                              child: Text(
                            "${(index + 1).toString()}",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        ),
                        title: Text(
                          '${listcheck[index].code}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _line_color,
                          ),
                        ),
                        // title: Text(
                        //   '${asset_plan_id}',
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //     color: _line_color,
                        //   ),
                        // ),
                        subtitle: Text(
                            '${listcheck[index].section_name} : ${listcheck[index].location_name}'),
                        // trailing: Text(
                        //   "${total_topic_counted}/${total_topic}",
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //     color: _line_color,
                        //   ),
                        // ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SecuritycheckDetailPage(
                            id: listcheck[index].id,
                            code: listcheck[index].code,
                            current_area_id: listcheck[index].location_id,
                            plan_id: listcheck[index].plan_id,
                          ),
                        ),
                      );
                    }),
              ),
            );
          });
      return cardlist;
      //return Text('data');
    } else {
      return Text('No data');
    }
  }

  void doNothing(BuildContext context) {}
  dynamic _removecheckeditem(String area_id) {
    //print("you press me ${area_id}");
    Provider.of<PlanData>(context, listen: false).removeinspectionitem(area_id);
  }

  @override
  Widget build(BuildContext context) {
    current_section_code =
        Provider.of<UserData>(context, listen: false).getCurrenUserSection();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromARGB(255, 45, 172, 123),
      appBar: AppBar(
        title: Text("รายการตรวจถังดับเพลิง"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => scanQRCode(),
            icon: Icon(Icons.qr_code_scanner_outlined),
          ),
          // IconButton(
          //   onPressed: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => CarlistPage(),
          //     ),
          //   ),
          //   icon: Icon(Icons.error_outline),
          // ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade100,
        width: double.infinity,
        child: Column(children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Expanded(
            flex: 5,
            child: Consumer<SecurityplanData>(
              builder: ((context, _plans, _) => _plans.finishedcheck > 0
                  ? Center(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(""),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(children: [
                              Icon(
                                Icons.block,
                                size: 50,
                                color: Color.fromARGB(255, 45, 172, 123),
                              ),
                              Center(
                                  child: Text(
                                'ไม่พบรายการตรวจ',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              )),
                            ]),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(""),
                          ),
                        ],
                      ),
                    )
                  : _buildList(
                      _plans.listSecurityplan,
                    )),
            ),
          ),
          //_plans.checkfinish()
          // Consumer<SecurityplanData>(
          //   builder: ((context, _plans, _) => _plans.finishedcheck <= 0
          //       ? Container(
          //           height: 50,
          //           width: double.infinity,
          //           color: Color.fromARGB(255, 45, 172, 123),
          //           child: GestureDetector(
          //             child: Center(
          //               child: Text(
          //                 "ยืนยันการตรวจ",
          //                 style: TextStyle(
          //                   color: Colors.white,
          //                   fontSize: 18,
          //                 ),
          //               ),
          //             ),
          //             onTap: () {
          //               // Provider.of<PlanData>(context, listen: false)
          //               //     .submitInspection();
          //               // int MustChekAll = _plans.getAllMushCheckTopic();
          //               // int AllChecked = _plans.getAllCheckedTopic();
          //               if (0 < 1) {
          //                 showDialog(
          //                   context: context,
          //                   barrierDismissible: false,
          //                   builder: (context) => Dialog(
          //                     backgroundColor: Colors.amber,
          //                     shape: RoundedRectangleBorder(
          //                         borderRadius: BorderRadius.circular(20)),
          //                     child: Padding(
          //                       padding: const EdgeInsets.all(8.0),
          //                       child: Column(
          //                         mainAxisSize: MainAxisSize.min,
          //                         mainAxisAlignment: MainAxisAlignment.center,
          //                         children: <Widget>[
          //                           SizedBox(
          //                             height: 12,
          //                           ),
          //                           Icon(
          //                             Icons.error,
          //                             size: 32,
          //                             color: Colors.red,
          //                           ),
          //                           SizedBox(
          //                             height: 12,
          //                           ),
          //                           Text(
          //                             'แจ้งให้ทราบ',
          //                             style: TextStyle(
          //                                 fontWeight: FontWeight.bold,
          //                                 fontSize: 20),
          //                           ),
          //                           SizedBox(
          //                             height: 12,
          //                           ),
          //                           Text(
          //                             'พบข้อมูลการตรวจไม่ครบหัวข้อ ต้องการดำเนินการต่อใช่หรือไม่ ?',
          //                             style: TextStyle(
          //                                 fontWeight: FontWeight.normal),
          //                           ),
          //                           SizedBox(
          //                             height: 12,
          //                           ),
          //                           Row(
          //                             children: <Widget>[
          //                               Expanded(
          //                                 child: MaterialButton(
          //                                   color: Color.fromARGB(
          //                                       255, 45, 172, 123),
          //                                   shape: RoundedRectangleBorder(
          //                                       borderRadius:
          //                                           BorderRadius.circular(50)),
          //                                   onPressed: () async {
          //                                     final isAvailable =
          //                                         await LocalAuthApi
          //                                             .hasBiometrics();
          //                                     if (isAvailable) {
          //                                       final isAuthenticated =
          //                                           await LocalAuthApi
          //                                               .authenticate();
          //                                       if (isAuthenticated) {
          //                                         print("success");
          //                                         await EasyLoading.show(
          //                                             status:
          //                                                 "กำลังบันทึกข้อมูล");
          //                                         bool isSave = await Provider
          //                                                 .of<PlanData>(context,
          //                                                     listen: false)
          //                                             .submitInspection("1");
          //                                         if (isSave == true) {
          //                                           await EasyLoading.showSuccess(
          //                                               'บันทึกรายการเรียบร้อย');
          //                                           Navigator.push(
          //                                               context,
          //                                               MaterialPageRoute(
          //                                                   builder: (context) =>
          //                                                       PlancheckcompletePage()));
          //                                         }
          //                                         EasyLoading.dismiss();
          //                                       }
          //                                     } else {
          //                                       print("no bio auth");
          //                                       await EasyLoading.show(
          //                                           status:
          //                                               "กำลังบันทึกข้อมูล");
          //                                       bool isSave =
          //                                           await Provider.of<PlanData>(
          //                                                   context,
          //                                                   listen: false)
          //                                               .submitInspection("1");
          //                                       if (isSave == true) {
          //                                         await EasyLoading.showSuccess(
          //                                             'บันทึกรายการเรียบร้อย');
          //                                         Navigator.push(
          //                                             context,
          //                                             MaterialPageRoute(
          //                                                 builder: (context) =>
          //                                                     PlancheckcompletePage()));
          //                                       }
          //                                       EasyLoading.dismiss();
          //                                     }
          //                                     //  _timer?.cancel();
          //                                     // await EasyLoading.show(
          //                                     //     status: "กำลังบันทึกข้อมูล");
          //                                     // bool isSave =
          //                                     //     await Provider.of<PlanData>(
          //                                     //             context,
          //                                     //             listen: false)
          //                                     //         .submitInspection();
          //                                     // if (isSave == true) {
          //                                     //   await EasyLoading.showSuccess(
          //                                     //       'บันทึกรายการเรียบร้อย');
          //                                     //   // Navigator.popUntil(context, ModalRoute.withName("/profile"));
          //                                     //   Navigator.push(
          //                                     //       context,
          //                                     //       MaterialPageRoute(
          //                                     //           builder: (context) =>
          //                                     //               PlancheckcompletePage()));
          //                                     //   // (route) => false);
          //                                     //   // int count = 0;
          //                                     //   // Navigator.of(context).popUntil(
          //                                     //   //     (_) => count++ >= 2);
          //                                     // }
          //                                     // EasyLoading.dismiss();
          //                                   },
          //                                   child: Text(
          //                                     'ใช่',
          //                                     style: TextStyle(
          //                                       fontWeight: FontWeight.bold,
          //                                       color: Colors.white,
          //                                     ),
          //                                   ),
          //                                 ),
          //                               ),
          //                               Spacer(),
          //                               Expanded(
          //                                 child: MaterialButton(
          //                                   color: Colors.grey[400],
          //                                   shape: RoundedRectangleBorder(
          //                                       borderRadius:
          //                                           BorderRadius.circular(50)),
          //                                   onPressed: () {
          //                                     Navigator.of(context).pop(false);
          //                                   },
          //                                   child: Text(
          //                                     'ไม่ใช่',
          //                                     style: TextStyle(
          //                                       fontWeight: FontWeight.bold,
          //                                     ),
          //                                   ),
          //                                 ),
          //                               ),
          //                             ],
          //                           )
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 );
          //               } else {
          //                 showDialog(
          //                   context: context,
          //                   barrierDismissible: false,
          //                   builder: (context) => Dialog(
          //                     shape: RoundedRectangleBorder(
          //                         borderRadius: BorderRadius.circular(20)),
          //                     child: Padding(
          //                       padding: const EdgeInsets.all(8.0),
          //                       child: Column(
          //                         mainAxisSize: MainAxisSize.min,
          //                         mainAxisAlignment: MainAxisAlignment.center,
          //                         children: <Widget>[
          //                           SizedBox(
          //                             height: 12,
          //                           ),
          //                           Icon(
          //                             Icons.privacy_tip_outlined,
          //                             size: 32,
          //                             color: Colors.green.shade400,
          //                           ),
          //                           SizedBox(
          //                             height: 12,
          //                           ),
          //                           Text(
          //                             'ยืนยันการทำรายการ',
          //                             style: TextStyle(
          //                                 fontWeight: FontWeight.bold,
          //                                 fontSize: 20),
          //                           ),
          //                           SizedBox(
          //                             height: 12,
          //                           ),
          //                           Text(
          //                             'ต้องการดำเนินการต่อใช่หรือไม่ ?',
          //                             style: TextStyle(
          //                                 fontWeight: FontWeight.normal),
          //                           ),
          //                           SizedBox(
          //                             height: 12,
          //                           ),
          //                           Row(
          //                             children: <Widget>[
          //                               Expanded(
          //                                 child: MaterialButton(
          //                                   color: Color.fromARGB(
          //                                       255, 45, 172, 123),
          //                                   shape: RoundedRectangleBorder(
          //                                       borderRadius:
          //                                           BorderRadius.circular(50)),
          //                                   onPressed: () async {
          //                                     final isAvailable =
          //                                         await LocalAuthApi
          //                                             .hasBiometrics();
          //                                     if (isAvailable) {
          //                                       final isAuthenticated =
          //                                           await LocalAuthApi
          //                                               .authenticate();
          //                                       if (isAuthenticated) {
          //                                         print("success");
          //                                         await EasyLoading.show(
          //                                             status:
          //                                                 "กำลังบันทึกข้อมูล");
          //                                         bool isSave = await Provider
          //                                                 .of<PlanData>(context,
          //                                                     listen: false)
          //                                             .submitInspection("1");
          //                                         if (isSave == true) {
          //                                           await EasyLoading.showSuccess(
          //                                               'บันทึกรายการเรียบร้อย');
          //                                           Navigator.push(
          //                                               context,
          //                                               MaterialPageRoute(
          //                                                   builder: (context) =>
          //                                                       PlancheckcompletePage()));
          //                                         }
          //                                         EasyLoading.dismiss();
          //                                       }
          //                                     } else {
          //                                       print("no bio auth");
          //                                       await EasyLoading.show(
          //                                           status:
          //                                               "กำลังบันทึกข้อมูล");
          //                                       bool isSave =
          //                                           await Provider.of<PlanData>(
          //                                                   context,
          //                                                   listen: false)
          //                                               .submitInspection("1");
          //                                       if (isSave == true) {
          //                                         await EasyLoading.showSuccess(
          //                                             'บันทึกรายการเรียบร้อย');
          //                                         Navigator.push(
          //                                             context,
          //                                             MaterialPageRoute(
          //                                                 builder: (context) =>
          //                                                     PlancheckcompletePage()));
          //                                       }
          //                                       EasyLoading.dismiss();
          //                                     }
          //                                     // final biometrics =
          //                                     //     await LocalAuthApi
          //                                     //         .getBiometrics();

          //                                     //  _timer?.cancel();
          //                                   },
          //                                   child: Text(
          //                                     'ใช่',
          //                                     style: TextStyle(
          //                                       fontWeight: FontWeight.bold,
          //                                       color: Colors.white,
          //                                     ),
          //                                   ),
          //                                 ),
          //                               ),
          //                               Spacer(),
          //                               Expanded(
          //                                 child: MaterialButton(
          //                                   color: Colors.grey[400],
          //                                   shape: RoundedRectangleBorder(
          //                                       borderRadius:
          //                                           BorderRadius.circular(50)),
          //                                   onPressed: () {
          //                                     Navigator.of(context).pop(false);
          //                                   },
          //                                   child: Text(
          //                                     'ไม่ใช่',
          //                                     style: TextStyle(
          //                                       fontWeight: FontWeight.bold,
          //                                     ),
          //                                   ),
          //                                 ),
          //                               ),
          //                             ],
          //                           )
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 );
          //               }
          //             },
          //           ),
          //         )
          //       : Text("")),
          // ),
        ]),
      ),
    );
  }
}
