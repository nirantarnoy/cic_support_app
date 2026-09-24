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
    _tabController = TabController(initialIndex: 0, length: 4, vsync: this);
    super.initState();

    final String currentYear = now.year.toString();
    final String currentMonth = now.month.toString().padLeft(2, '0');

    year_list.add(now.year.toString());
    year_list.add((now.year - 1).toString());
    dropdownyearvalue = currentYear;
    dropdownvalue = month_list[now.month - 1];

    EasyLoading.show(status: "กำลังโหลดข้อมูล");
    Provider.of<PlanData>(context, listen: false).fetchFiveRank(currentYear, currentMonth);
    EasyLoading.dismiss();
  }

  Widget _buildlist(List<FiveRankData> data, int score_rank) {
    var formatter = NumberFormat('#,##,##0.##');
    if (data.isNotEmpty) {
      data.sort((a, b) => b.score.compareTo(a.score));
      return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            bool isFirst = data[index].score == data[0].score;
            bool isPass = data[index].score >= score_rank;
            int rank = isFirst ? 1 : index + 1;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isFirst 
                        ? Colors.amber.withOpacity(0.2) 
                        : Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: isFirst 
                    ? Border.all(color: Colors.amber.shade300, width: 2) 
                    : Border.all(color: Colors.grey.shade100, width: 1),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isFirst 
                        ? Colors.amber.shade50 
                        : (isPass ? Colors.blue.shade50 : Colors.red.shade50),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isFirst
                        ? const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28)
                        : (isPass 
                            ? Text(rank.toString(), style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 16))
                            : const Icon(Icons.arrow_downward_rounded, color: Colors.redAccent, size: 24)),
                  ),
                ),
                title: Text(
                  '${data[index].deptname}',
                  style: const TextStyle(
                    fontFamily: 'Prompt',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${formatter.format(data[index].score)}%',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isPass ? const Color(0xFF0F9B73) : Colors.redAccent,
                      ),
                    ),
                    Text(
                      isPass ? 'ผ่านเกณฑ์' : 'ต่ำกว่าเกณฑ์',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 10,
                        color: isPass ? Colors.grey[600] : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_chart_outlined_rounded, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'ไม่มีข้อมูล',
              style: TextStyle(fontFamily: 'Prompt', color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
  }

  // Widget _buildfivetab() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F9B73),
      appBar: AppBar(
        title: const Text('รายละเอียดกิจกรรม 5 ส.', style: TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF0F9B73),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white.withOpacity(0.2),
          ),
          indicatorWeight: 0,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          labelStyle: const TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.normal, fontSize: 14),
          isScrollable: true,
          controller: _tabController,
          tabs: const <Widget>[
            Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("สำนักงานกลุ่ม A"))),
            Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("สำนักงานกลุ่ม B"))),
            Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("โรงงานกลุ่ม A"))),
            Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("โรงงานกลุ่ม B"))),
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7FB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              Consumer<PlanData>(
                builder: (context, value, child) => getTabcontent("1", value, 98),
              ),
              Consumer<PlanData>(
                builder: (context, value, child) => getTabcontent("2", value, 98),
              ),
              Consumer<PlanData>(
                builder: (context, value, child) => getTabcontent("3", value, 95),
              ),
              Consumer<PlanData>(
                builder: (context, value, child) => getTabcontent("4", value, 95),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ค้นหาผลคะแนน 5 ส. ประจำเดือน',
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200)
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: dropdownvalue,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                      style: const TextStyle(fontFamily: 'Prompt', color: Colors.black87, fontSize: 13),
                      items: month_list.map((String value) {
                        return DropdownMenuItem(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          dropdownvalue = value.toString();
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200)
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: dropdownyearvalue,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                      style: const TextStyle(fontFamily: 'Prompt', color: Colors.black87, fontSize: 13),
                      items: year_list.map((String value) {
                        return DropdownMenuItem(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          dropdownyearvalue = value.toString();
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFF0F9B73),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
                onPressed: () {
                  var _month_value = "";
                  var indexValue = _stdmonth.indexWhere((element) => element["name"] == dropdownvalue);
                  _month_value = _stdmonth[indexValue]['id'];

                  EasyLoading.show(status: "กำลังโหลดข้อมูล");
                  Provider.of<PlanData>(context, listen: false)
                      .fetchFiveRank(dropdownyearvalue, _month_value);
                  EasyLoading.dismiss();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getTabcontent(String tab_id, PlanData value, int score_rank) {
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
              max_score = element.score; 
            }
          }
          FiveRankData _items = FiveRankData(
            deptname: element.deptname,
            score: element.score,
            rank_no: 0,
            zone_id: tab_id,
          );
          _tabvaluelist.add(_items);
          i += 1;
        }
      });

      _tabvaluelist.forEach((element) {
        if (element.score == max_score) {
          element.rank_no = 1;
        }
      });

      return Column(children: <Widget>[
        _buildSearchHeader(),
        const SizedBox(height: 12),
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
            ),
            child: SfCircularChart(
              legend: Legend(
                isVisible: false,
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                textStyle: const TextStyle(fontFamily: 'Prompt')
              ),
              series: <CircularSeries<FiveRankData, String>>[
                DoughnutSeries<FiveRankData, String>(
                  dataSource: _tabvaluelist,
                  xValueMapper: (FiveRankData sales, _) => sales.deptname,
                  yValueMapper: (FiveRankData sales, _) => sales.score,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(fontFamily: 'Prompt', fontSize: 10, fontWeight: FontWeight.bold)
                  ),
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 4),
          child: Row(
            children: const [
              Icon(Icons.leaderboard_rounded, color: Color(0xFF0F9B73), size: 20),
              SizedBox(width: 8),
              Text(
                'อันดับเรียงตามคะแนน',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: _buildlist(_tabvaluelist, score_rank),
        )
      ]);
    } else {
      return Column(children: <Widget>[
        _buildSearchHeader(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'ไม่พบข้อมูลคะแนนในเดือนนี้',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    color: Colors.grey[500],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        )
      ]);
    }
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
