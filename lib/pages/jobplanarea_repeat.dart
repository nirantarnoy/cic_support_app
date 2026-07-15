import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/jobplanaraerepeat.dart';
import 'package:flutter_cic_support/models/jobplanarea.dart';
import 'package:flutter_cic_support/pages/carhistory.dart';
import 'package:flutter_cic_support/pages/carlistpage.dart';
import 'package:flutter_cic_support/pages/history.dart';
import 'package:flutter_cic_support/pages/jobcheck.dart';
import 'package:flutter_cic_support/pages/jobchecknew.dart';
import 'package:flutter_cic_support/pages/jobchecknew_repeat.dart';
import 'package:flutter_cic_support/pages/plancheckcomplete.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:flutter_cic_support/services/local_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class JobplanAreaRepeatPage extends StatefulWidget {
  const JobplanAreaRepeatPage({Key? key}) : super(key: key);

  @override
  State<JobplanAreaRepeatPage> createState() => _JobplanAreaRepeatPageState();
}

class _JobplanAreaRepeatPageState extends State<JobplanAreaRepeatPage> {
  String current_section_code = '';
  Future _obtainPlanArea() async {
    return await Provider.of<PlanData>(context, listen: false)
        .fetchJobplanRepeat();
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
    // TODO: implement initState
    // Provider.of<PlanData>(context, listen: false).fetchJobplan();
    // _obtainPlanArea();
    EasyLoading.show(status: "โหลดข้อมูล");
    Provider.of<PlanData>(context, listen: false).fetFinishedCheck();
    Provider.of<PlanData>(context, listen: false).fetchJobplan();
    EasyLoading.dismiss();

    super.initState();
  }

  Widget _buildList(List<JobplanAreaRepeat> listcheck) {
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
        int total_topic = Provider.of<PlanData>(context, listen: false)
            .countTopicitemRepeat(listcheck[index].plan_area_id);
        int total_topic_counted = Provider.of<PlanData>(context, listen: false)
            .countCheckedTopicitemRepeat(listcheck[index].plan_area_id);

        Color _bgcolor = Colors.white;
        Color _line_color = Colors.black87;
        Color _status_color = const Color(0xFF4A5AE7); // Default blue
        String _status_text = 'แตะเพื่อเริ่มตรวจ / Tap to inspect';

        final bool isOwnSection =
            current_section_code == listcheck[index].section_code;

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

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                              builder: (context) => JobCheckNewRepeatPage(
                                plan_area_id: listcheck[index].plan_area_id,
                                plan_id: listcheck[index].plan_id,
                                plan_area_name: listcheck[index].plan_area_name,
                                plan_num: listcheck[index].plan_num,
                              ),
                            ),
                          );
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
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
                                  color: isOwnSection
                                      ? Colors.grey
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
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
        );
      },
    );
  }

  void doNothing(BuildContext context) {}
  dynamic _removecheckeditem(String area_id) {
    //print("you press me ${area_id}");
    Provider.of<PlanData>(context, listen: false)
        .removeinspectionitemRepeat(area_id);
  }

  @override
  Widget build(BuildContext context) {
    current_section_code =
        Provider.of<UserData>(context, listen: false).getCurrenUserSection();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          "แผนพื้นที่ตรวจ 5ส. (ซ้ำ)",
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
                builder: (context) => HistoryPage(),
              ),
            ),
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarlistPage(),
              ),
            ),
            icon: const Icon(Icons.error_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: <Widget>[
          Expanded(
            child: Consumer<PlanData>(
              builder: ((context, _plans, _) => 0 > 0
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
                  : _buildList(_plans.getAreaRepeatTitle())),
            ),
          ),
          Consumer<PlanData>(
            builder: ((context, _plans, _) => 0 <= 0
                ? Container(
                    margin: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F9B73),
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
                        int MustChekAll = _plans.getAllMushCheckTopic();
                        int AllChecked = _plans.getAllCheckedTopic();
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
                                              final isAvailable =
                                                  await LocalAuthApi
                                                      .hasBiometrics();
                                              if (isAvailable) {
                                                final isAuthenticated =
                                                    await LocalAuthApi
                                                        .authenticate();
                                                if (isAuthenticated) {
                                                  print("success");
                                                  await EasyLoading.show(
                                                      status:
                                                          "กำลังบันทึกข้อมูล");
                                                  bool isSave = await Provider
                                                          .of<PlanData>(context,
                                                              listen: false)
                                                      .submitInspection("2");
                                                  if (isSave == true) {
                                                    await EasyLoading.showSuccess(
                                                        'บันทึกรายการเรียบร้อย');
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                PlancheckcompletePage()));
                                                  }
                                                  EasyLoading.dismiss();
                                                }
                                              } else {
                                                print("no bio auth");
                                                await EasyLoading.show(
                                                    status:
                                                        "กำลังบันทึกข้อมูล");
                                                bool isSave =
                                                    await Provider.of<PlanData>(
                                                            context,
                                                            listen: false)
                                                        .submitInspection("2");
                                                if (isSave == true) {
                                                  await EasyLoading.showSuccess(
                                                      'บันทึกรายการเรียบร้อย');
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              PlancheckcompletePage()));
                                                }
                                                EasyLoading.dismiss();
                                              }
                                              //  _timer?.cancel();
                                              // await EasyLoading.show(
                                              //     status: "กำลังบันทึกข้อมูล");
                                              // bool isSave =
                                              //     await Provider.of<PlanData>(
                                              //             context,
                                              //             listen: false)
                                              //         .submitInspection();
                                              // if (isSave == true) {
                                              //   await EasyLoading.showSuccess(
                                              //       'บันทึกรายการเรียบร้อย');
                                              //   // Navigator.popUntil(context, ModalRoute.withName("/profile"));
                                              //   Navigator.push(
                                              //       context,
                                              //       MaterialPageRoute(
                                              //           builder: (context) =>
                                              //               PlancheckcompletePage()));
                                              //   // (route) => false);
                                              //   // int count = 0;
                                              //   // Navigator.of(context).popUntil(
                                              //   //     (_) => count++ >= 2);
                                              // }
                                              // EasyLoading.dismiss();
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
                                              final isAvailable =
                                                  await LocalAuthApi
                                                      .hasBiometrics();
                                              if (isAvailable) {
                                                final isAuthenticated =
                                                    await LocalAuthApi
                                                        .authenticate();
                                                if (isAuthenticated) {
                                                  print("success");
                                                  await EasyLoading.show(
                                                      status:
                                                          "กำลังบันทึกข้อมูล");
                                                  bool isSave = await Provider
                                                          .of<PlanData>(context,
                                                              listen: false)
                                                      .submitInspection("2");
                                                  if (isSave == true) {
                                                    await EasyLoading.showSuccess(
                                                        'บันทึกรายการเรียบร้อย');
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                PlancheckcompletePage()));
                                                  }
                                                  EasyLoading.dismiss();
                                                }
                                              } else {
                                                print("no bio auth");
                                                await EasyLoading.show(
                                                    status:
                                                        "กำลังบันทึกข้อมูล");
                                                bool isSave =
                                                    await Provider.of<PlanData>(
                                                            context,
                                                            listen: false)
                                                        .submitInspection("2");
                                                if (isSave == true) {
                                                  await EasyLoading.showSuccess(
                                                      'บันทึกรายการเรียบร้อย');
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              PlancheckcompletePage()));
                                                }
                                                EasyLoading.dismiss();
                                              }
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
