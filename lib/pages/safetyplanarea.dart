import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/inspectionsafetytrans.dart';
import 'package:flutter_cic_support/models/jobplanarea.dart';
import 'package:flutter_cic_support/models/jobsafetyplanarea.dart';
import 'package:flutter_cic_support/pages/carhistory.dart';
import 'package:flutter_cic_support/pages/carlistpage.dart';
import 'package:flutter_cic_support/pages/createcar.dart';
import 'package:flutter_cic_support/pages/createsafetycar.dart';
import 'package:flutter_cic_support/pages/history.dart';
import 'package:flutter_cic_support/pages/jobcheck.dart';
import 'package:flutter_cic_support/pages/jobchecknew.dart';
import 'package:flutter_cic_support/pages/plancheckcomplete.dart';
import 'package:flutter_cic_support/pages/safetycheck.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class SafetyplanAreaPage extends StatefulWidget {
  const SafetyplanAreaPage({Key? key}) : super(key: key);

  @override
  State<SafetyplanAreaPage> createState() => _SafetyplanAreaPageState();
}

class _SafetyplanAreaPageState extends State<SafetyplanAreaPage> {
  String current_section_code = '';
  bool _isOffline = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Future _obtainPlanArea() async {
    return await Provider.of<PlanData>(context, listen: false)
        .fetchSafetyJobplan();
  }

  @override
  void initState() {
    EasyLoading.show(status: "โหลดข้อมูล");
    Provider.of<PlanData>(context, listen: false).fetSafetyFinishedCheck();
    Provider.of<PlanData>(context, listen: false).fetchSafetyJobplan();
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

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
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

  Widget _buildList(List<JobSafetyplanArea> listcheck) {
    if (listcheck.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text("ไม่พบรายการตรวจ",
                style: TextStyle(
                    fontFamily: 'Prompt', fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: listcheck.length,
      itemBuilder: (BuildContext context, int index) {
        int line_is_checked = Provider.of<PlanData>(context, listen: false)
            .checkhaschecklist(listcheck[index].plan_area_id);

        Color _bgcolor = Colors.white;
        Color _iconBgColor = const Color(0xFFE99A24).withOpacity(0.1);
        Color _iconColor = const Color(0xFFE99A24);

        if (line_is_checked > 0) {
          _bgcolor = const Color(0xFFF0FDF4); // Very light green
          _iconBgColor = const Color(0xFF0F9B73).withOpacity(0.1);
          _iconColor = const Color(0xFF0F9B73);
        }

        return Slidable(
          key: ValueKey(listcheck[index].plan_area_id),
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12)),
                onPressed: (BuildContext context) {
                  _removesafetycheckeditem(listcheck[index].plan_area_id);
                },
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                icon: Icons.delete_outline_rounded,
                label: 'Clear',
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (BuildContext context) {
                  InspectionSafetyTrans _item = InspectionSafetyTrans(
                    module_type_id: "2",
                    plan_id: listcheck[index].plan_id,
                    trans_date: DateTime.now().toIso8601String(),
                    emp_id: "0",
                    area_group_id: "0",
                    area_id: listcheck[index].plan_area_id,
                    team_id: "0",
                    score: "1",
                    status: "1",
                    note: "",
                    plan_num: listcheck[index].plan_num,
                  );
                  Provider.of<PlanData>(context, listen: false)
                      .addInspectionSafetyTrans(_item);
                },
                backgroundColor: const Color(0xFF0F9B73),
                foregroundColor: Colors.white,
                icon: Icons.check_circle_outline_rounded,
                label: 'OK',
              ),
              SlidableAction(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
                onPressed: (BuildContext context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateSafetyCar(
                        plan_area_id: listcheck[index].plan_area_id,
                        plan_area_name: listcheck[index].plan_area_name,
                      ),
                    ),
                  );
                },
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                icon: Icons.error_outline_rounded,
                label: 'CAR',
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: _bgcolor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _iconBgColor,
                ),
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      color: _iconColor,
                      fontFamily: 'Prompt',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              title: Text(
                '${listcheck[index].plan_area_name}',
                style: const TextStyle(
                  fontFamily: 'Prompt',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void doNothing(BuildContext context) {}
  dynamic _removesafetycheckeditem(String area_id) {
    //print("you press me ${area_id}");
    Provider.of<PlanData>(context, listen: false)
        .removesafetyinspectionitem(area_id);
  }

  @override
  Widget build(BuildContext context) {
    current_section_code =
        Provider.of<UserData>(context, listen: false).getCurrenUserSection();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          "แผนพื้นที่ตรวจ Safety",
          style: TextStyle(
              fontFamily: 'Prompt',
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SafetyCheckPage())),
            icon: const Icon(Icons.list_alt_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: <Widget>[
          if (_isOffline)
            Container(
              width: double.infinity,
              color: Colors.red.shade50,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded,
                      color: Colors.red.shade700, size: 16),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          color: Colors.amber.shade800, size: 16),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
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
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Consumer<PlanData>(
              builder: ((context, _plans, _) => _plans.finishedsafetycheck > 0
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.assignment_turned_in_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text("ไม่มีแผนการตรวจค้าง",
                              style: TextStyle(
                                  fontFamily: 'Prompt',
                                  fontSize: 18,
                                  color: Colors.grey)),
                        ],
                      ),
                    )
                  : _buildList(_plans.getSafetyAreaTitle())),
            ),
          ),
          Consumer<PlanData>(
            builder: ((context, _plans, _) => _plans.finishedcheck <= 0
                ? Container(
                    margin: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE99A24),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "ยืนยันการตรวจ",
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        // Provider.of<PlanData>(context, listen: false)
                        //     .submitInspection();
                        int MustChekAll = _plans.getAllMushCheckSafetyArea();
                        int AllChecked = _plans.getAllCheckedSafetyArea();
                        if (AllChecked < MustChekAll) {
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
                                      Icons.error,
                                      size: 32,
                                      color: Colors.red,
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Text(
                                      'แจ้งให้ทราบ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Text(
                                      'พบข้อมูลการตรวจไม่ครบหัวข้อ ต้องการดำเนินการต่อใช่หรือไม่ ?',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: MaterialButton(
                                            color: Color.fromARGB(
                                                255, 45, 172, 123),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            onPressed: () async {
                                              //  _timer?.cancel();
                                              await EasyLoading.show(
                                                  status: "กำลังบันทึกข้อมูล");
                                              bool isSave =
                                                  await Provider.of<PlanData>(
                                                          context,
                                                          listen: false)
                                                      .submitSafetyInspection();
                                              if (isSave == true) {
                                                await EasyLoading.showSuccess(
                                                    'บันทึกรายการเรียบร้อย');
                                                // Navigator.popUntil(context, ModalRoute.withName("/profile"));
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PlancheckcompletePage()));
                                                // (route) => false);
                                                // int count = 0;
                                                // Navigator.of(context).popUntil(
                                                //     (_) => count++ >= 2);
                                              }
                                              EasyLoading.dismiss();
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
                        } else {
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
                                      Icons.privacy_tip_outlined,
                                      size: 32,
                                      color: Colors.green.shade400,
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Text(
                                      'ยืนยันการทำรายการ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Text(
                                      'ต้องการดำเนินการต่อใช่หรือไม่ ?',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: MaterialButton(
                                            color: Color.fromARGB(
                                                255, 45, 172, 123),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            onPressed: () async {
                                              //  _timer?.cancel();
                                              await EasyLoading.show(
                                                  status: "กำลังบันทึกข้อมูล");
                                              bool isSave =
                                                  await Provider.of<PlanData>(
                                                          context,
                                                          listen: false)
                                                      .submitInspection("1");
                                              if (isSave == true) {
                                                await EasyLoading.showSuccess(
                                                    'บันทึกรายการเรียบร้อย');
                                                // Navigator.popUntil(context, ModalRoute.withName("/profile"));
                                                // Navigator.pushAndRemoveUntil(
                                                //     context,
                                                //     MaterialPageRoute(builder: (context) => ProfilePage()),
                                                //     (route) => false);
                                                // int count = 0;
                                                // Navigator.of(context).popUntil(
                                                //     (_) => count++ >= 2);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PlancheckcompletePage()));
                                              }
                                              EasyLoading.dismiss();
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
                        }
                      },
                    ),
                  )
                : const SizedBox.shrink()),
          ),
        ]),
      ),
    );
  }
}
