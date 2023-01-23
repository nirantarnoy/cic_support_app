import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/jobcheck.dart';

import 'package:flutter_cic_support/models/jobplanarea.dart';
import 'package:flutter_cic_support/pages/createcar.dart';
import 'package:flutter_cic_support/pages/jobcheckdetail.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:provider/provider.dart';

class JobCheckPage extends StatefulWidget {
  final String plan_id;
  final String plan_area_id;
  final String plan_area_name;
  const JobCheckPage({
    Key? key,
    required this.plan_id,
    required this.plan_area_id,
    required this.plan_area_name,
  }) : super(key: key);

  @override
  State<JobCheckPage> createState() => _JobCheckPageState();
}

class _JobCheckPageState extends State<JobCheckPage> {
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
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => JobCheckDetailPage(
                          plan_id: listcheck[index].plan_id,
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
                  builder: (context, _plantopic, _) => Expanded(
                    flex: 4,
                    child: _buildList(_plantopic.getTopic(
                        widget.plan_area_id, widget.plan_id)),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
