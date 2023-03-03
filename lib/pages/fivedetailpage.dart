import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/fiverank.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FiveDetailPage extends StatefulWidget {
  @override
  State<FiveDetailPage> createState() => _FiveDetailPageState();
}

class _FiveDetailPageState extends State<FiveDetailPage>
    with TickerProviderStateMixin {
  // List<FiveRankData> data = [
  //   FiveRankData('สารสนเทส', 1, 1),
  //   FiveRankData('วางแผน', 3, 1),
  //   FiveRankData('บุคคล', 10, 1),
  //   FiveRankData('บัญชี', 4, 2),
  //   FiveRankData('สโตร์', 8, 3),
  //   FiveRankData('คุณภาพ', 12, 4),
  //   FiveRankData('เทคนิค', 41, 5)
  // ];
  List<Country> countryList = [];
  List<String> year_list = [];
  List<String> month_list = <String>[
    "มกราคม",
    "กุมภาพันธ์",
    "มีนาคม",
    "เมษายน",
    "พฤษภาคม",
    "มิถุนายน",
    "กรกฎาคม",
    "สิงหาคม",
    "กันยายน",
    "ตุลาคม",
    "พฤศจิกายน",
    "ธันวาคม",
  ];

  // static String jsonStr = '''
  // [
  //   {"name":"a", "flag":"a1"},
  //   {"name":"b", "flag":"b1"},
  //   {"name":"c", "flag":"c1"}
  //   ]
  // ''';

  // List<Country> countryFromJson(String str) =>
  //     List<Country>.from(json.decode(str).map((x) => Country.fromJson(x)));

  // String countryToJson(List<Country> data) =>
  //     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

  String dropdownvalue = '';
  String dropdownyearvalue = '';
  var now = DateTime.now();
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    EasyLoading.show(status: "กำลังโหลดข้อมูล");
    Provider.of<PlanData>(context, listen: false).fetchFiveRank("2023", "01");
    EasyLoading.dismiss();
    _tabController = TabController(initialIndex: 0, length: 4, vsync: this);
    super.initState();

    setState(() {
      //countryList = countryFromJson(jsonStr);
      year_list.add(now.year.toString());
      year_list.add((now.year - 1).toString());
      dropdownyearvalue = year_list.first;
      dropdownvalue = month_list.first;
    });
  }

  Widget _buildlist(List<FiveRankData> data, int score_rank) {
    var formatter = NumberFormat('#,##,##0.00#');
    Widget cards;
    int nums = 0;
    if (data.isNotEmpty) {
      cards = new ListView.builder(
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            if (data[index].rank_no != 1) {
              nums += 1;
            } else {
              nums = 1;
            }
            return Card(
              elevation: 0.5,
              child: ListTile(
                leading: data[index].rank_no == 1
                    ? Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 45,
                      )
                    : data[index].score >= score_rank
                        ? Chip(
                            label: Text(
                              '${nums}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.arrow_downward,
                            color: Colors.red,
                            size: 45,
                          ),
                title: Text('${data[index].deptname}'),
                trailing: Text('${formatter.format(data[index].score)}%'),
              ),
            );
          });

      return cards;
    } else {
      return Center(
        child: Text('No Data'),
      );
    }
  }

  // Widget _buildfivetab() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  resizeToAvoidBottomInset: true,
      backgroundColor: Color.fromARGB(255, 45, 172, 123),
      appBar: AppBar(
        title: Text('รายละเอียดกิจกรรม 5 ส.'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          indicatorColor: Colors.amber,
          indicatorWeight: 5.0,
          isScrollable: true,
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              // icon: Icon(Icons.list_outlined),
              text: "สำนักงานกลุ่ม A",
            ),
            Tab(
              //icon: Icon(Icons.calendar_month),
              text: "สำนักงานกลุ่ม B",
            ),
            Tab(
              text: "โรงงานกลุ่ม A",
            ),
            Tab(
              text: "โรงงานกลุ่ม B",
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Container(
            child: Column(children: <Widget>[
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.only(
                    //   topLeft: Radius.circular(10),
                    //   topRight: Radius.circular(10),
                    // ),
                    color: Colors.white,
                  ),
                  child: Expanded(
                    flex: 5,
                    child: Consumer<PlanData>(
                      builder: (context, value, child) =>
                          getTabcontent("1", value, 98),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          Container(
            child: Column(children: <Widget>[
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.only(
                    //   topLeft: Radius.circular(10),
                    //   topRight: Radius.circular(10),
                    // ),
                    color: Colors.white,
                  ),
                  child: Consumer<PlanData>(
                    builder: (context, value, child) =>
                        getTabcontent("2", value, 98),
                  ),
                ),
              ),
            ]),
          ),
          Container(
            child: Column(children: <Widget>[
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.only(
                    //   topLeft: Radius.circular(10),
                    //   topRight: Radius.circular(10),
                    // ),
                    color: Colors.white,
                  ),
                  child: Consumer<PlanData>(
                    builder: (context, value, child) =>
                        getTabcontent("3", value, 95),
                  ),
                ),
              ),
            ]),
          ),
          Container(
            child: Column(children: <Widget>[
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.only(
                    //   topLeft: Radius.circular(10),
                    //   topRight: Radius.circular(10),
                    // ),
                    color: Colors.white,
                  ),
                  child: Consumer<PlanData>(
                    builder: (context, value, child) =>
                        getTabcontent("4", value, 95),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget getTabcontent(String tab_id, PlanData value, int score_rank) {
    Widget _content;
    List _stdmonth = [
      {'id': "01", "name": "มกราคม"},
      {'id': "02", "name": "กุมภาพันธ์"},
      {'id': "03", "name": "มีนาคม"},
      {'id': "04", "name": "เมษายน"},
      {'id': "05", "name": "พฤษภาคม"},
      {'id': "06", "name": "มิถุนายน"},
      {'id': "07", "name": "กรกฎาคม"},
      {'id': "08", "name": "สิงหาคม"},
      {'id': "09", "name": "กันยายน"},
      {'id': "10", "name": "ตุลาคม"},
      {'id': "11", "name": "พฤศจิกายน"},
      {'id': "12", "name": "ธันวาคม"},
    ];
    if (value.listfiverankdata.isNotEmpty) {
      List<FiveRankData> _tabvaluelist = [];
      double max_score = 0;
      int i = 0;

      value.listfiverankdata.forEach((element) {
        if (element.zone_id == tab_id) {
          if (i == 0) {
            max_score = element.score;
          } else {
            if (element.score > max_score) {
              max_score = element.score; // replance max score
            }
          }
          FiveRankData _items = FiveRankData(
            deptname: element.deptname,
            score: element.score,
            rank_no: 0,
            zone_id: tab_id,
          );

          _tabvaluelist.add(_items);
        }
        i += 1;
      });

      _tabvaluelist.forEach((element) {
        if (element.score == max_score) {
          element.rank_no = 1;
        }
      });

      _content = Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'อันดับคะแนน 5 ส. ประจำเดือน',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton(
                  value: dropdownvalue,
                  alignment: AlignmentDirectional.centerEnd,
                  items:
                      month_list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      dropdownvalue = value.toString();
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton(
                  value: dropdownyearvalue,
                  alignment: AlignmentDirectional.centerEnd,
                  items:
                      year_list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      dropdownyearvalue = value.toString();
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 45, 172, 123)),
                  child: Text('ค้นหา'),
                  onPressed: () {
                    setState(() {
                      var _month_value = "";
                      var indexValue = _stdmonth.indexWhere(
                          (element) => element["name"] == dropdownvalue);
                      _month_value = _stdmonth[indexValue]['id'];

                      EasyLoading.show(status: "กำลังโหลดข้อมูล");
                      Provider.of<PlanData>(context, listen: false)
                          .fetchFiveRank(dropdownyearvalue, _month_value);
                      EasyLoading.dismiss();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Expanded(
          flex: 2,
          child: SfCircularChart(
            // primaryXAxis: CategoryAxis(),
            // Chart title
            // title: ChartTitle(text: 'CAR'),
            // Enable legend
            legend: Legend(
              isVisible: false,
              overflowMode: LegendItemOverflowMode.wrap,
              position: LegendPosition.bottom,
            ),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CircularSeries<FiveRankData, String>>[
              DoughnutSeries<FiveRankData, String>(
                dataSource: _tabvaluelist,
                xValueMapper: (FiveRankData sales, _) => sales.deptname,
                yValueMapper: (FiveRankData sales, _) => sales.score,
                // name: 'Sales',
                // Enable data label
                dataLabelSettings: DataLabelSettings(isVisible: true),
              )
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'อันดับเรียงตามคะแนน',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: _buildlist(_tabvaluelist, score_rank),
          ),
        )
      ]);
    } else {
      _content = Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'อันดับคะแนน 5 ส. ประจำเดือน',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton(
                  value: dropdownvalue,
                  alignment: AlignmentDirectional.centerEnd,
                  items:
                      month_list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      dropdownvalue = value.toString();
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton(
                  value: dropdownyearvalue,
                  alignment: AlignmentDirectional.centerEnd,
                  items:
                      year_list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      dropdownyearvalue = value.toString();
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 45, 172, 123)),
                  child: Text('ค้นหา'),
                  onPressed: () {
                    setState(() {
                      var _month_value = "";
                      var indexValue = _stdmonth.indexWhere(
                          (element) => element["name"] == dropdownvalue);
                      _month_value = _stdmonth[indexValue]['id'];

                      EasyLoading.show(status: "กำลังโหลดข้อมูล");
                      Provider.of<PlanData>(context, listen: false)
                          .fetchFiveRank(dropdownyearvalue, _month_value);
                      EasyLoading.dismiss();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(Icons.hourglass_empty),
                // SizedBox(
                //   height: 5,
                // ),
                Text(
                  'ไม่พบข้อมูล กรูณาเลือกข้อมูลใหม่',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        )
      ]);
    }

    return _content;
  }
}

class Country {
  String name;
  String flag;

  Country({
    required this.name,
    required this.flag,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        name: json["name"],
        flag: json["flag"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "flag": flag,
      };
}
