import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_cic_support/models/inspectiontrans.dart';
import 'package:flutter_cic_support/models/jobcheckdetail.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_cic_support/providers/topicitem.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class JobCheckDetailPage extends StatefulWidget {
  final String plan_id;
  final String topic_id;
  final String plan_area_id;
  const JobCheckDetailPage({
    Key? key,
    required this.topic_id,
    required this.plan_area_id,
    required this.plan_id,
  }) : super(key: key);

  @override
  State<JobCheckDetailPage> createState() => _JobCheckDetailPageState();
}

class _JobCheckDetailPageState extends State<JobCheckDetailPage> {
  int current_scored = -1;
  String current_topic_detail = "";

  Color active_color = Colors.white;
  Color active_color1 = Colors.white;
  Color active_color2 = Colors.white;
  Color active_color3 = Colors.white;
  Color active_color4 = Colors.white;
  Color submit_scored_color = Colors.white;

  @override
  void initState() {
    //  Provider.of<TopicItemData>(context, listen: false).fetchTopicItem();
    super.initState();
  }

  // final List<JobCheckDetail> check_list = [
  //   JobCheckDetail(
  //     topicid: "1",
  //     topicname: 'ตู้และอุปกรณ์',
  //     topic_detail_id: "1",
  //     topic_detail_name: 'ติดป้ายชื่อผู้รับผิดชอบ',
  //     score: '-1',
  //     status: '0',
  //   ),
  // ];

  // Widget _buildlist(List<JobCheckDetail> _elementsx) {
  //   Widget carditem;
  //   if (_elementsx.length > 0) {
  //     carditem = GroupedListView<dynamic, String>(
  //       elements: this._elements,
  //       groupBy: (element) => element['group'],
  //       groupComparator: (value1, value2) => value2.compareTo(value1),
  //       itemComparator: (item1, item2) =>
  //           item1['topicName'].compareTo(item2['topicName']),
  //       order: GroupedListOrder.DESC,
  //       useStickyGroupSeparators: true,
  //       groupSeparatorBuilder: (String value) => Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Text(
  //           value,
  //           textAlign: TextAlign.center,
  //           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //       itemBuilder: (c, element) {
  //         return Card(
  //           elevation: 8.0,
  //           margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
  //           child: SizedBox(
  //             child: ListTile(
  //               contentPadding: const EdgeInsets.symmetric(
  //                   horizontal: 20.0, vertical: 10.0),
  //               leading: const Icon(Icons.factory),
  //               title: Text(element['topicName']),
  //               trailing: const Icon(Icons.arrow_forward),
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //     return carditem;
  //   } else {
  //     return Center(
  //       child: Text('No Data'),
  //     );
  //   }
  // }

  void _editbottomsheet(String topic_item_id) {
    this.active_color = Colors.white;
    this.active_color1 = Colors.white;
    this.active_color2 = Colors.white;
    this.active_color3 = Colors.white;
    this.active_color4 = Colors.white;
    submit_scored_color = Colors.white;

    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setterx) {
            // state of parent
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                child: Column(children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "บันทึกคะแนน",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      )),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        color: active_color,
                                        border:
                                            Border.all(color: Colors.green)),
                                    child: Text(
                                      "0",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                              SizedBox(
                                                height: 12,
                                              ),
                                              Text(
                                                'ต้องการให้คะแนนเป็น 0 ใช่หรือไม่ ?',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              SizedBox(
                                                height: 12,
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: MaterialButton(
                                                      color:
                                                          Colors.green.shade300,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50)),
                                                      onPressed: () async {
                                                        if (current_scored !=
                                                            0) {
                                                          setterx(() {
                                                            current_scored = 0;
                                                            current_topic_detail =
                                                                "";
                                                            this.active_color =
                                                                Colors.green;
                                                            this.active_color1 =
                                                                Colors.white;
                                                            this.active_color2 =
                                                                Colors.white;
                                                            this.active_color3 =
                                                                Colors.white;
                                                            this.active_color4 =
                                                                Colors.white;
                                                            submit_scored_color =
                                                                Colors.green;
                                                            print(
                                                                current_scored);
                                                          });
                                                        } else {
                                                          this.active_color =
                                                              Colors.white;
                                                          this.active_color1 =
                                                              Colors.white;
                                                          this.active_color2 =
                                                              Colors.white;
                                                          this.active_color3 =
                                                              Colors.white;
                                                          this.active_color4 =
                                                              Colors.white;
                                                          submit_scored_color =
                                                              Colors.white;
                                                        }
                                                        Navigator.of(context)
                                                            .pop(false);
                                                      },
                                                      child: Text(
                                                        'ใช่',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Expanded(
                                                    child: MaterialButton(
                                                      color: Colors.grey[400],
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50)),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(false);
                                                      },
                                                      child: Text(
                                                        'ไม่ใช่',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
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
                              ),
                              Spacer(),
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        color: active_color1,
                                        border:
                                            Border.all(color: Colors.green)),
                                    child: Text(
                                      "1",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    if (current_scored == 1) {
                                      setterx(() {
                                        current_scored = -1;
                                        current_topic_detail = "";
                                        this.active_color = Colors.white;
                                        this.active_color1 = Colors.white;
                                        this.active_color2 = Colors.white;
                                        this.active_color3 = Colors.white;
                                        this.active_color4 = Colors.white;

                                        submit_scored_color = Colors.white;
                                        print(current_scored);
                                      });
                                    } else {
                                      setterx(() {
                                        current_scored = 1;
                                        current_topic_detail = "";
                                        this.active_color = Colors.white;
                                        this.active_color1 = Colors.green;
                                        this.active_color2 = Colors.white;
                                        this.active_color3 = Colors.white;
                                        this.active_color4 = Colors.white;
                                        submit_scored_color = Colors.green;
                                        print(current_scored);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        color: active_color2,
                                        border:
                                            Border.all(color: Colors.green)),
                                    child: Text(
                                      "2",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    if (current_scored == 2) {
                                      setterx(() {
                                        current_scored = -1;
                                        current_topic_detail = "";
                                        this.active_color = Colors.white;
                                        this.active_color1 = Colors.white;
                                        this.active_color2 = Colors.white;
                                        this.active_color3 = Colors.white;
                                        this.active_color4 = Colors.white;
                                        submit_scored_color = Colors.white;
                                        print(current_scored);
                                      });
                                    } else {
                                      setterx(() {
                                        current_scored = 2;
                                        current_topic_detail = "";
                                        this.active_color = Colors.white;
                                        this.active_color1 = Colors.white;
                                        this.active_color2 = Colors.green;
                                        this.active_color3 = Colors.white;
                                        this.active_color4 = Colors.white;
                                        submit_scored_color = Colors.green;
                                        print(current_scored);
                                      });
                                    }
                                  },
                                ),
                              ),
                              Spacer(),
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        color: this.active_color3,
                                        border:
                                            Border.all(color: Colors.green)),
                                    child: Text(
                                      "3",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    if (current_scored == 3) {
                                      setterx(() {
                                        current_scored = -1;
                                        current_topic_detail = "";
                                        this.active_color = Colors.white;
                                        this.active_color1 = Colors.white;
                                        this.active_color2 = Colors.white;
                                        this.active_color3 = Colors.white;
                                        this.active_color4 = Colors.white;
                                        submit_scored_color = Colors.white;
                                        print(current_scored);
                                      });
                                    } else {
                                      setterx(() {
                                        current_scored = 3;
                                        current_topic_detail = "";
                                        this.active_color = Colors.white;
                                        this.active_color1 = Colors.white;
                                        this.active_color2 = Colors.white;
                                        this.active_color3 = Colors.green;
                                        this.active_color4 = Colors.white;
                                        submit_scored_color = Colors.green;
                                        print(current_scored);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        color: active_color4,
                                        border:
                                            Border.all(color: Colors.green)),
                                    child: Text(
                                      "4",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    // check_list.forEach((elementx) {
                                    //   if (elementx.topicid ==
                                    //       'เครื่องใช้สำนักงาน') {
                                    //     setState(() {
                                    //       elementx.score = "4";
                                    //     });
                                    //   } else {
                                    //     setState(() {
                                    //       elementx.score = "-1";
                                    //     });
                                    //   }
                                    // });
                                    if (current_scored == 4) {
                                      setterx(() {
                                        current_scored = -1;
                                        current_topic_detail = "";
                                        this.active_color = Colors.white;
                                        this.active_color1 = Colors.white;
                                        this.active_color2 = Colors.white;
                                        this.active_color3 = Colors.white;
                                        this.active_color4 = Colors.white;
                                        submit_scored_color = Colors.white;
                                        print(current_scored);
                                      });
                                    } else {
                                      setterx(() {
                                        current_scored = 4;
                                        current_topic_detail = "";
                                        this.active_color = Colors.white;
                                        this.active_color1 = Colors.white;
                                        this.active_color2 = Colors.white;
                                        this.active_color3 = Colors.white;
                                        this.active_color4 = Colors.green;
                                        submit_scored_color = Colors.green;
                                        print(current_scored);
                                      });
                                    }
                                  },
                                ),
                              ),
                              Spacer(),
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      child: Container(
                        height: 60,
                        color: submit_scored_color,
                        alignment: Alignment.center,
                        child: Text(
                          "ตกลง",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        print("selected scored is ${current_scored}");
                        InspectionTrans _inspec = InspectionTrans(
                          area_group_id: '0',
                          emp_id: '0',
                          plan_id: widget.plan_id,
                          area_id: widget.plan_area_id,
                          score: current_scored.toString(),
                          status: '1',
                          team_id: '0',
                          topic_id: widget.topic_id,
                          topic_item_id: topic_item_id,
                          module_type_id: '1',
                          note: '',
                          trans_date: DateTime.now().toIso8601String(),
                        );
                        Provider.of<PlanData>(context, listen: false)
                            .addInspectionTrans(_inspec);

                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ]),
              ),
            );
          });
        });
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
          return GestureDetector(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              color: int.parse(element['score']) > -1
                  ? Colors.green.shade400
                  : Colors.white,
              elevation: 2.0,
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
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
                  trailing:
                      Text(element['score'] == "-1" ? "" : element['score']),
                ),
              ),
            ),
            onTap: () => _editbottomsheet(element['topic_detail_id']),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(
        title: Text('รายละเอียดการตรวจ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(children: [
          Expanded(
            flex: 4,
            //child: _buildlist(this.check_list),
            child: Consumer<PlanData>(
                builder: (context, topicitems, _) => _buildlist(topicitems
                    .getTopicitem(widget.topic_id, widget.plan_area_id))),
          ),
        ]),
      ),
    );
  }
}
