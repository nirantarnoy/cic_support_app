import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/personcurrentplan.dart';
import 'package:flutter_cic_support/pages/jobplanarea.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({Key? key}) : super(key: key);

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> with TickerProviderStateMixin {
  //final DateFormat dateFormatter = DateFormat('dd-MM-yyyy HH:mm');
  final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');
  List<CalendarEvent> _sampleEvents = [];
  // final List<CalendarEvent> _sampleEvents = [
  //   CalendarEvent(eventName: "ตรวจ 5 ส", eventDate: DateTime.now()),
  //   CalendarEvent(eventName: "ประชุม", eventDate: DateTime.now())
  // ];

  final cellCalendarPageController = CellCalendarPageController();
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    EasyLoading.show(status: "โหลดข้อมูล");
    Provider.of<PlanData>(context, listen: false).fetFinishedCheck();
    Provider.of<PlanData>(context, listen: false).fetchJobplan();
    EasyLoading.dismiss();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  List<CalendarEvent> _xx() {
    // final List<CalendarEvent> _abc = [
    //   CalendarEvent(eventName: "ตรวจ 5 ส", eventDate: DateTime.now()),
    //   CalendarEvent(eventName: "ประชุม", eventDate: DateTime.now())
    // ];
    List<CalendarEvent> _addlistitem = [];
    List<PersoncurrentPlan> listx =
        Provider.of<PlanData>(context, listen: false).listpersoncurrentplan;
    if (listx.isNotEmpty) {
      listx.forEach((element) {
        print('plan no is ${element.plan_no}');
        final CalendarEvent _items = CalendarEvent(
          eventName: "${element.plan_no}",
          eventDate: DateTime.now(),
        );

        _addlistitem.add(_items);
      });
    }

    _sampleEvents = _addlistitem;
    return _addlistitem;
  }

  Widget _buildlist(List<PersoncurrentPlan> listplan, int finishedcheck) {
    Widget cards;
    if (listplan.length > 0) {
      // _createEvent(listplan);
      cards = ListView.builder(
          itemCount: listplan.length,
          itemBuilder: (BuildContext context, int index) {
            String module_type =
                listplan[index].plan_type == "1" ? "5ส." : "Safety";
            Icon plan_icon = finishedcheck <= 0
                ? Icon(
                    Icons.close,
                    color: Colors.red,
                  )
                : Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  );
            String inspection_type_name = "";
            Color inspection_type_color = Colors.black;
            if (listplan[index].inspection_type_id == "1") {
              inspection_type_name = "รอบตรวจปกติ";
              inspection_type_color = Colors.green;
            } else if (listplan[index].inspection_type_id == "2") {
              inspection_type_name = "รอบตรวจซ้ำ";
              inspection_type_color = Colors.blue;
            }
            // print("inspection type is ${listplan[index].inspection_type_id}");
            return Card(
              child: GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => JobplanAreaPage())),
                child: ListTile(
                  leading: plan_icon,
                  title: Text('${listplan[index].plan_no}'),
                  subtitle: Text(
                      '${dateFormatter.format(DateTime.parse(listplan[index].plan_date))}'),
                  trailing: Column(
                    children: <Widget>[
                      Text(
                        '${module_type}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${inspection_type_name}",
                        style: TextStyle(color: inspection_type_color),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
      return cards;
    } else {
      return Center(
        child: Text("No Data"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 45, 172, 123),
      appBar: AppBar(
        title: Text("แผนการตรวจ"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.list_outlined),
            ),
            Tab(
              icon: Icon(Icons.calendar_month),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Container(
                child: Consumer<PlanData>(
              builder: (context, _plan, _) =>
                  _buildlist(_plan.listpersoncurrentplan, _plan.finishedcheck),
            )),
            Container(
              color: Colors.white,
              child: CellCalendar(
                cellCalendarPageController: cellCalendarPageController,
                events: _xx(),
                daysOfTheWeekBuilder: (dayIndex) {
                  final labels = ["อา", "จ", "อ", "พ", "พฤ", "ศ", "ส"];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      labels[dayIndex],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                monthYearLabelBuilder: (datetime) {
                  final year = datetime!.year.toString();
                  final month = datetime.month.monthName;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Text(
                          "$month  $year",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.calendar_today),
                          onPressed: () {
                            cellCalendarPageController.animateToDate(
                              DateTime.now(),
                              curve: Curves.linear,
                              duration: Duration(milliseconds: 300),
                            );
                          },
                        )
                      ],
                    ),
                  );
                },
                onCellTapped: (date) {
                  final eventsOnTheDate = _sampleEvents.where((event) {
                    final eventDate = event.eventDate;
                    return eventDate.year == date.year &&
                        eventDate.month == date.month &&
                        eventDate.day == date.day;
                  }).toList();
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            title: Text(date.month.monthName +
                                " " +
                                date.day.toString()),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: eventsOnTheDate
                                  .map(
                                    (event) => Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(4),
                                      margin: EdgeInsets.only(bottom: 12),
                                      color: event.eventBackgroundColor,
                                      child: Text(
                                        event.eventName,
                                        style: TextStyle(
                                            color: event.eventTextColor),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ));
                },
                onPageChanged: (firstDate, lastDate) {
                  /// Called when the page was changed
                  /// Fetch additional events by using the range between [firstDate] and [lastDate] if you want
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
