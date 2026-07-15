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
    if (listcheck.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: listcheck.length,
        itemBuilder: (BuildContext context, int index) {
          if (listcheck[index].checked_status == "1") {
            return const SizedBox.shrink();
          }

          return Slidable(
            key: ValueKey(listcheck[index].id),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  onPressed: (BuildContext context) {
                    _removecheckeditem(listcheck[index].id);
                  },
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline_rounded,
                  label: 'ลบ',
                ),
              ],
            ),
            child: GestureDetector(
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
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fire_extinguisher_rounded,
                          color: Color(0xFFE53935),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  listcheck[index].code,
                                  style: const TextStyle(
                                    fontFamily: 'Prompt',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F9B73)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'รอตรวจสอบ',
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F9B73),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${listcheck[index].section_name} : ${listcheck[index].location_name}',
                              style: const TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_turned_in_rounded,
                  size: 48, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              "ไม่พบรายการตรวจ",
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
  }

  void doNothing(BuildContext context) {}
  dynamic _removecheckeditem(String area_id) {
    Provider.of<PlanData>(context, listen: false).removeinspectionitem(area_id);
  }

  @override
  Widget build(BuildContext context) {
    current_section_code =
        Provider.of<UserData>(context, listen: false).getCurrenUserSection();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "รายการตรวจถังดับเพลิง",
          style: TextStyle(
            fontFamily: 'Prompt',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => scanQRCode(),
            icon: const Icon(Icons.qr_code_scanner_rounded,
                color: Colors.black87),
          ),
        ],
      ),
      body: Consumer<SecurityplanData>(
        builder: ((context, _plans, _) => _plans.finishedcheck > 0
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.assignment_turned_in_rounded,
                          size: 48, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "ตรวจสอบเสร็จสิ้นแล้ว",
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : _buildList(_plans.listSecurityplan)),
      ),
    );
  }
}
