import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/inspectiontrans.dart';
import 'package:flutter_cic_support/models/jobcheck.dart';
import 'package:flutter_cic_support/models/jobcheckdetail.dart';

import 'package:flutter_cic_support/models/jobplanarea.dart';
import 'package:flutter_cic_support/pages/createcar.dart';
import 'package:flutter_cic_support/pages/jobcheckdetail.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class JobCheckNewPage extends StatefulWidget {
  final String plan_id;
  final String plan_area_id;
  final String plan_area_name;
  final String plan_num;
  const JobCheckNewPage({
    Key? key,
    required this.plan_id,
    required this.plan_area_id,
    required this.plan_area_name,
    required this.plan_num,
  }) : super(key: key);

  @override
  State<JobCheckNewPage> createState() => _JobCheckNewPageState();
}

class _JobCheckNewPageState extends State<JobCheckNewPage> {
  // final List<JobCheck> check_list = [
  //   JobCheck(
  //     person_id: '1',
  //     check_date: '2022-06-22',
  //     area_id: '1',
  //     area_name: 'ตู้/ชั้นเก็บอุปกรณ์/เครื่องมือ/สิ่งของ',
  //     total_check_count: '20',
  //     total_finish_check_count: '10',
  //     seq_no: 1,
  //   ),
  //   JobCheck(
  //     person_id: '1',
  //     check_date: '2022-06-22',
  //     area_id: '2',
  //     area_name: 'ตู้/ชั้นเก็บเอกสาร',
  //     total_check_count: '20',
  //     total_finish_check_count: '10',
  //     seq_no: 2,
  //   ),
  //   JobCheck(
  //     person_id: '1',
  //     check_date: '2022-06-22',
  //     area_id: '2',
  //     area_name: 'บอร์ดติดประกาศและหรือโครงสร้างองค์กร',
  //     total_check_count: '20',
  //     total_finish_check_count: '10',
  //     seq_no: 3,
  //   ),
  //   JobCheck(
  //     person_id: '1',
  //     check_date: '2022-06-22',
  //     area_id: '2',
  //     area_name: 'พื้นที่ปฏิบัติงาน ห้องทำงาน',
  //     total_check_count: '20',
  //     total_finish_check_count: '10',
  //     seq_no: 4,
  //   ),
  // ];

  @override
  void initState() {
    // TODO: implement initState
    print("area id is ${widget.plan_area_id}");
    super.initState();
  }

  Widget _buildList(List<JobplanArea> listcheck) {
    Widget cardlist;
    if (listcheck.length > 0) {
      cardlist = new ListView.builder(
          itemCount: listcheck.length,
          itemBuilder: (BuildContext contex, int index) {
            int child_cnt = Provider.of<PlanData>(contex, listen: false)
                .getTopicitemcountByTopic(
                    listcheck[index].topic_id, listcheck[index].plan_area_id);
            int child_counted = Provider.of<PlanData>(contex, listen: false)
                .getTopicitemcountedByTopic(
                    listcheck[index].topic_id, listcheck[index].plan_area_id);

            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                      color: child_counted == child_cnt
                          ? Colors.green.shade400
                          : Colors.green.shade50,
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
                    title: Text('${listcheck[index].topic_name}'),
                    trailing: Text('${child_counted} / ${child_cnt}'),
                  ),
                ),
                // onTap: () {}
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => JobCheckDetailPage(
                          plan_id: widget.plan_id,
                          topic_id: listcheck[index].topic_id,
                          plan_area_id: listcheck[index].plan_area_id,
                          plan_num: listcheck[index].plan_num,
                        ))),
              ),
            );
          });
      return cardlist;
      //return Text('data');
    } else {
      return Text('No data');
    }
  }

  Widget _buildlist(List<JobCheckDetail> _elementsx) {
    Widget carditem;
    if (_elementsx.length > 0) {
      carditem = GroupedListView<dynamic, String>(
        elements: jsonDecode(jsonEncode(_elementsx)),
        groupBy: (element) => element['topicname'],
        groupComparator: (value1, value2) => value2.compareTo(value1),
        // itemComparator: (item1, item2) =>
        //     item1['topic_detail_name'].compareTo(item2['topic_detail_name']),

        order: GroupedListOrder.DESC,
        useStickyGroupSeparators: true,
        groupSeparatorBuilder: (String value) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        itemBuilder: (c, element) {
          return Slidable(
            key: const ValueKey(0),
            // startActionPane: ActionPane(
            //   motion: const ScrollMotion(),
            //   // dismissible: DismissiblePane(onDismissed: () {}),
            //   children: [
            //     SlidableAction(
            //       onPressed: doNothing,
            //       backgroundColor: Colors.red,
            //       foregroundColor: Colors.white,
            //       icon: Icons.delete,
            //       label: 'Clear',
            //     ),
            //     // SlidableAction(
            //     //   onPressed: doNothing,
            //     //   backgroundColor: Colors.red,
            //     //   foregroundColor: Colors.white,
            //     //   icon: Icons.delete,
            //     //   label: 'Delete',
            //     // ),
            //     // SlidableAction(
            //     //   onPressed: doNothing,
            //     //   backgroundColor: Colors.green,
            //     //   foregroundColor: Colors.white,
            //     //   icon: Icons.share,
            //     //   label: 'Share',
            //     // )
            //   ],
            // ),
            endActionPane: ActionPane(
              extentRatio: 1.0,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  // flex: 2,
                  // onPressed:
                  //     _removecheckeditem(listcheck[index].plan_area_id),
                  onPressed: (BuildContext context) {
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
                                color: Colors.red,
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
                                'ต้องการให้คะแนนเป็น 0 ใช่หรือไม่ ?',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: MaterialButton(
                                      color: Colors.green.shade300,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      onPressed: () async {
                                        await _addselected(
                                            "0",
                                            element['topicid'],
                                            element['topic_detail_id']);

                                        Navigator.of(context).pop(false);
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
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  // icon: Icons.delete,
                  label: '0',
                ),
                SlidableAction(
                  onPressed: (BuildContext context) {
                    _addselected(
                        "1", element['topicid'], element['topic_detail_id']);
                  },
                  backgroundColor: Color.fromARGB(255, 204, 146, 39),
                  foregroundColor: Colors.black,
                  //icon: Icons.one_k,
                  label: '1',
                ),
                SlidableAction(
                  onPressed: (BuildContext context) {
                    _addselected(
                        "2", element['topicid'], element['topic_detail_id']);
                  },
                  backgroundColor: Color.fromARGB(255, 213, 216, 24),
                  foregroundColor: Colors.black,
                  //  icon: Icons.share,
                  label: '2',
                ),
                SlidableAction(
                  onPressed: (BuildContext context) {
                    _addselected(
                        "3", element['topicid'], element['topic_detail_id']);
                  },
                  backgroundColor: Color.fromARGB(255, 134, 218, 24),
                  foregroundColor: Colors.black,
                  //  icon: Icons.share,
                  label: '3',
                ),
                SlidableAction(
                  onPressed: (BuildContext context) {
                    _addselected(
                        "4", element['topicid'], element['topic_detail_id']);
                  },
                  backgroundColor: Color.fromARGB(255, 135, 161, 218),
                  foregroundColor: Colors.black,
                  //  icon: Icons.share,
                  label: '4',
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: GestureDetector(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  color: int.parse(element['score']) > -1
                      ? Colors.green.shade400
                      : Colors.white,
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 6.0),
                  child: SizedBox(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      leading: int.parse(element['score']) > -1
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            )
                          : const Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                      title: Text('${element['topic_detail_name']}'),
                      trailing: Text(
                          element['score'] == "-1" ? "" : element['score']),
                    ),
                  ),
                ),
                onTap: () {},
              ),
            ),
          );
        },
      );

      return carditem;
    } else {
      return Center(
        child: Text('No Data'),
      );
    }
  }

  void doNothing(BuildContext context) {}
  dynamic _addselected(String score, dynamic topic_id, dynamic topic_item_id) {
    if (score != '') {
      // print("selected scored is ${topic_item_id}");
      InspectionTrans _inspec = InspectionTrans(
        area_group_id: '0',
        emp_id: '0',
        plan_id: widget.plan_id,
        plan_num: widget.plan_num,
        area_id: widget.plan_area_id,
        score: score.toString(),
        status: '1',
        team_id: '0',
        topic_id: topic_id,
        topic_item_id: topic_item_id,
        module_type_id: '1',
        note: '',
        trans_date: DateTime.now().toIso8601String(),
      );

      // print("data to add inspect is ${_inspec}");
      Provider.of<PlanData>(context, listen: false).addInspectionTrans(_inspec);
      // Provider.of<PlanData>(context, listen: false)
      //     .addInspectionTransDB(_inspec);

      //Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 45, 172, 123),
      appBar: AppBar(
        title: Text('หัวข้อการตรวจ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateCar(
                        plan_area_id: widget.plan_area_id,
                        plan_area_name: widget.plan_area_name,
                      ),
                    ),
                  ),
              icon: Icon(Icons.gps_fixed)),
        ],
      ),
      body: Container(
          color: Colors.grey.shade100,
          child: Column(
            children: [
              Expanded(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_on,
                          color: Colors.black,
                        ),
                        Text(
                          'พื้นที่ตรวจ ${widget.plan_area_name}',
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: Consumer<PlanData>(
                    builder: (context, topicitems, _) => _buildlist(
                        topicitems.getTopicitemNew(widget.plan_area_id))),
              ),
            ],
          )),
    );
  }
}
