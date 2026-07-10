import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/jobplanarea.dart';
import 'package:flutter_cic_support/pages/carhistory.dart';
import 'package:flutter_cic_support/pages/carlistpage.dart';
import 'package:flutter_cic_support/pages/history.dart';
import 'package:flutter_cic_support/pages/jobcheck.dart';
import 'package:flutter_cic_support/pages/jobchecknew.dart';
import 'package:flutter_cic_support/pages/plancheckcomplete.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:flutter_cic_support/services/local_auth.dart';
import 'package:flutter_cic_support/sqlite/dbprovider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class JobplanAreaPage extends StatefulWidget {
  const JobplanAreaPage({Key? key}) : super(key: key);

  @override
  State<JobplanAreaPage> createState() => _JobplanAreaPageState();
}

class _JobplanAreaPageState extends State<JobplanAreaPage> {
  String current_section_code = '';
  bool _isOffline = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Future _obtainPlanArea() async {
    return await Provider.of<PlanData>(context, listen: false).fetchJobplan();
  }

  // List<JobplanArea> _checklist = [
  //   JobplanArea(
  //       plan_id: "1",
  //       plan_date: "",
  //       plan_area_id: "1",
  //       plan_area_name: "Drum Test",
  //       plan_topic_check_qty: "20",
  //       plan_topic_checked_qty: "0",
  //       status: "0"),
  //   JobplanArea(
  //       plan_id: "1",
  //       plan_date: "",
  //       plan_area_id: "1",
  //       plan_area_name: "คลังสินค้า(ตึก 11)",
  //       plan_topic_check_qty: "20",
  //       plan_topic_checked_qty: "0",
  //       status: "0"),
  //   JobplanArea(
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
    EasyLoading.show(status: "โหลดข้อมูล");
    Provider.of<PlanData>(context, listen: false).fetFinishedCheck();
    Provider.of<PlanData>(context, listen: false).fetchJobplan();
    Provider.of<PlanData>(context, listen: false).loadOfflineCounts();
    EasyLoading.dismiss();

    Connectivity().checkConnectivity().then((result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
      if (!_isOffline) {
        Provider.of<PlanData>(context, listen: false).syncOfflineData();
      }
    });

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
      if (!_isOffline) {
        Provider.of<PlanData>(context, listen: false).syncOfflineData();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<int> getAreacheckCount(String area_id) async {
    int cnt = await DbProvider.instance.countCheckedTopicitemX(area_id);
    return cnt;
  }

  // Widget _buildList(List<JobplanArea> listcheck) {
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
  //     //return Text('data')
  //   }

  Widget _buildList(List<JobplanArea> listcheck) {
    print('current section code is ${current_section_code}');
    Widget cardlist;
    if (listcheck.length > 0) {
      cardlist = ListView.builder(
          itemCount: listcheck.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (BuildContext contex, int index) {
            int total_topic = Provider.of<PlanData>(contex, listen: false)
                .countTopicitem(listcheck[index].plan_area_id);
            int total_topic_counted =
                Provider.of<PlanData>(contex, listen: false)
                    .countCheckedTopicitem(listcheck[index].plan_area_id);

            Color _bgcolor = Colors.white;
            Color _line_color = Colors.black87;
            Color _status_color = const Color(0xFF4A5AE7); // Default blue
            String _status_text = 'แตะเพื่อเริ่มตรวจ / Tap to inspect';

            final bool isOwnSection = current_section_code == listcheck[index].section_code;

            if (isOwnSection) {
              _line_color = Colors.red.shade400;
              _status_color = Colors.grey;
              _status_text = 'พื้นที่ของแผนกคุณ (ตรวจไม่ได้) / Your Section';
              _bgcolor = const Color(0xFFF5F5F5); // Soft grey
            } else {
              if (total_topic_counted <= 0) {
                _bgcolor = Colors.white;
                _status_color = const Color(0xFF4A5AE7); // Blue
                _status_text = 'ยังไม่ได้ตรวจ / Tap to inspect';
              } else if (total_topic_counted > 0 &&
                  total_topic_counted < total_topic) {
                _bgcolor = const Color(0xFFFFF8E1); // Soft yellow
                _status_color = const Color(0xFFFFAD3B); // Yellow
                _status_text = 'ตรวจค้างอยู่ / In progress';
              } else if (total_topic_counted == total_topic) {
                _bgcolor = const Color(0xFFE8F5E9); // Soft green
                _status_color = const Color(0xFF0F9B73); // Green
                _status_text = 'ตรวจเสร็จสิ้น / Completed';
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Container(
                decoration: BoxDecoration(
                  color: _bgcolor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Slidable(
                    key: ValueKey(listcheck[index].plan_area_id),
                    enabled: !isOwnSection,
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (BuildContext context) {
                            _removecheckeditem(listcheck[index].plan_area_id);
                          },
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          icon: Icons.delete_rounded,
                          label: 'Clear',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (BuildContext context) {
                            _removecheckeditem(listcheck[index].plan_area_id);
                          },
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          icon: Icons.delete_rounded,
                          label: 'Clear',
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isOwnSection
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => JobCheckNewPage(
                                      plan_area_id: listcheck[index].plan_area_id,
                                      plan_id: listcheck[index].plan_id,
                                      plan_area_name: listcheck[index].plan_area_name,
                                      plan_num: listcheck[index].plan_num,
                                    ),
                                  ),
                                );
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                          child: Row(
                            children: [
                              Container(
                                height: 38,
                                width: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: isOwnSection
                                      ? Icon(
                                          Icons.home_rounded,
                                          color: Colors.red.shade400,
                                          size: 20,
                                        )
                                      : Text(
                                          "${index + 1}",
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontFamily: 'Prompt',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      listcheck[index].plan_area_name,
                                      style: TextStyle(
                                        fontFamily: 'Prompt',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: _line_color,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _status_text,
                                      style: TextStyle(
                                        fontFamily: 'Prompt',
                                        fontSize: 11,
                                        color: isOwnSection ? Colors.grey : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _status_color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "$total_topic_counted/$total_topic",
                                  style: TextStyle(
                                    fontFamily: 'Prompt',
                                    fontWeight: FontWeight.bold,
                                    color: _status_color,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
      return cardlist;
    } else {
      return const Center(
        child: Text(
          'ไม่พบข้อมูลการตรวจ',
          style: TextStyle(fontFamily: 'Prompt', color: Colors.grey),
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
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "แผนพื้นที่ตรวจ 5ส.",
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryPage(),
              ),
            ),
            icon: const Icon(Icons.history_rounded, color: Colors.black87),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarlistPage(),
              ),
            ),
            icon: const Icon(Icons.error_outline_rounded, color: Colors.black87),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F7FB),
        width: double.infinity,
        child: Column(children: <Widget>[
          if (_isOffline)
            Container(
              width: double.infinity,
              color: Colors.red.shade50,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, color: Colors.red.shade700, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "ขณะนี้คุณกำลังทำงานในโหมดออฟไลน์ (Offline Mode)",
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Consumer<PlanData>(
            builder: (context, planData, _) {
              if (planData.totalOfflineCount > 0) {
                return Container(
                  width: double.infinity,
                  color: Colors.amber.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, color: Colors.amber.shade800, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "มีรายการตรวจค้างส่งออฟไลน์: ${planData.totalOfflineCount} รายการ",
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          color: Colors.amber.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!_isOffline)
                        GestureDetector(
                          onTap: () {
                            EasyLoading.show(status: "กำลังส่งข้อมูล...");
                            planData.syncOfflineData();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade800,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "กดซิงค์",
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Consumer<PlanData>(
              builder: ((context, _plans, _) => _plans.finishedcheck > 0
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.block_flipped,
                              size: 56,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'ไม่พบรายการตรวจ',
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildList(
                      _plans.getAreaTitle(),
                    )),
            ),
          ),
          Consumer<PlanData>(
            builder: ((context, _plans, _) => _plans.finishedcheck <= 0
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 52,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F9B73), Color(0xFF2EC89F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F9B73).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            int MustChekAll = _plans.getAllMushCheckTopic();
                            int AllChecked = _plans.getAllCheckedTopic();
                            if (AllChecked < MustChekAll) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.warning_amber_rounded,
                                            size: 40,
                                            color: Colors.amber,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'แจ้งให้ทราบ',
                                          style: TextStyle(
                                            fontFamily: 'Prompt',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'พบข้อมูลการตรวจไม่ครบทุกหัวข้อ ต้องการดำเนินการต่อใช่หรือไม่?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Prompt',
                                            color: Colors.black54,
                                            height: 1.4,
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
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12)),
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  elevation: 0,
                                                ),
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                  await EasyLoading.show(status: "กำลังบันทึกข้อมูล");
                                                  bool isSave = await Provider.of<PlanData>(context, listen: false)
                                                      .submitInspection("1");
                                                  if (isSave == true) {
                                                    await EasyLoading.showSuccess('บันทึกรายการเรียบร้อย');
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => PlancheckcompletePage(),
                                                      ),
                                                    );
                                                  }
                                                  EasyLoading.dismiss();
                                                },
                                                child: const Text(
                                                  'ใช่',
                                                  style: TextStyle(
                                                    fontFamily: 'Prompt',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.black54,
                                                  side: BorderSide(color: Colors.grey.shade300),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12)),
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop(false);
                                                },
                                                child: const Text(
                                                  'ไม่ใช่',
                                                  style: TextStyle(
                                                    fontFamily: 'Prompt',
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
                            } else {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check_circle_outline_rounded,
                                            size: 40,
                                            color: Color(0xFF0F9B73),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'ยืนยันการทำรายการ',
                                          style: TextStyle(
                                            fontFamily: 'Prompt',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'ต้องการส่งผลการตรวจใช่หรือไม่?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Prompt',
                                            color: Colors.black54,
                                            height: 1.4,
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
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12)),
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  elevation: 0,
                                                ),
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                  await EasyLoading.show(status: "กำลังบันทึกข้อมูล");
                                                  bool isSave = await Provider.of<PlanData>(context, listen: false)
                                                      .submitInspection("1");
                                                  if (isSave == true) {
                                                    await EasyLoading.showSuccess('บันทึกรายการเรียบร้อย');
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => PlancheckcompletePage(),
                                                      ),
                                                    );
                                                  }
                                                  EasyLoading.dismiss();
                                                },
                                                child: const Text(
                                                  'ใช่',
                                                  style: TextStyle(
                                                    fontFamily: 'Prompt',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.black54,
                                                  side: BorderSide(color: Colors.grey.shade300),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12)),
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop(false);
                                                },
                                                child: const Text(
                                                  'ไม่ใช่',
                                                  style: TextStyle(
                                                    fontFamily: 'Prompt',
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
                          },
                          child: const Center(
                            child: Text(
                              "ยืนยันการตรวจ",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Prompt',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
          ),
        ]),
      ),
    );
  }
}
