import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/jobplanarea.dart';
import 'package:flutter_cic_support/pages/carhistory.dart';
import 'package:flutter_cic_support/pages/carlistpage.dart';
import 'package:flutter_cic_support/pages/history.dart';
import 'package:flutter_cic_support/pages/jobcheck.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class JobplanAreaPage extends StatefulWidget {
  const JobplanAreaPage({Key? key}) : super(key: key);

  @override
  State<JobplanAreaPage> createState() => _JobplanAreaPageState();
}

class _JobplanAreaPageState extends State<JobplanAreaPage> {
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
    // TODO: implement initState
    // Provider.of<PlanData>(context, listen: false).fetchJobplan();
    // _obtainPlanArea();
    EasyLoading.show(status: "โหลดข้อมูล");
    Provider.of<PlanData>(context, listen: false).fetFinishedCheck();
    Provider.of<PlanData>(context, listen: false).fetchJobplan();
    EasyLoading.dismiss();
    super.initState();
  }

  Widget _buildList(List<JobplanArea> listcheck) {
    Widget cardlist;
    if (listcheck.length > 0) {
      cardlist = ListView.builder(
          itemCount: listcheck.length,
          itemBuilder: (BuildContext contex, int index) {
            int total_topic = Provider.of<PlanData>(contex, listen: false)
                .countTopicitem(listcheck[index].plan_area_id);
            int total_topic_counted =
                Provider.of<PlanData>(contex, listen: false)
                    .countCheckedTopicitem(listcheck[index].plan_area_id);

            Color _bgcolor = Colors.green.shade50;
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
                      _removecheckeditem(listcheck[index].plan_area_id);
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
                        color: _bgcolor,
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
                        '${listcheck[index].plan_area_name}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Text(
                        "${total_topic_counted}/${total_topic}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => JobCheckPage(
                            plan_area_id: listcheck[index].plan_area_id,
                            plan_id: listcheck[index].plan_id,
                            plan_area_name: listcheck[index].plan_area_name,
                          ))),
                ),
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
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 45, 172, 123),
      appBar: AppBar(
        title: Text("แผนพื้นที่ตรวจ 5ส."),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryPage(),
              ),
            ),
            icon: Icon(Icons.history),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarlistPage(),
              ),
            ),
            icon: Icon(Icons.error_outline),
          ),
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
            child: Consumer<PlanData>(
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
                      _plans.getAreaTitle(),
                    )),
            ),
          ),
          //_plans.checkfinish()
          Consumer<PlanData>(
            builder: ((context, _plans, _) => _plans.finishedcheck <= 0
                ? Container(
                    height: 50,
                    width: double.infinity,
                    color: Color.fromARGB(255, 45, 172, 123),
                    child: GestureDetector(
                      child: Center(
                        child: Text(
                          "ยืนยันการตรวจ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      onTap: () {
                        // Provider.of<PlanData>(context, listen: false)
                        //     .submitInspection();
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
                                          color:
                                              Color.fromARGB(255, 45, 172, 123),
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
                                                    .submitInspection();
                                            if (isSave == true) {
                                              await EasyLoading.showSuccess(
                                                  'บันทึกรายการเรียบร้อย');
                                              // Navigator.popUntil(context, ModalRoute.withName("/profile"));
                                              // Navigator.pushAndRemoveUntil(
                                              //     context,
                                              //     MaterialPageRoute(builder: (context) => ProfilePage()),
                                              //     (route) => false);
                                              int count = 0;
                                              Navigator.of(context).popUntil(
                                                  (_) => count++ >= 2);
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
                      },
                    ),
                  )
                : Text("")),
          ),
        ]),
      ),
    );
  }
}
