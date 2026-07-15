import 'dart:convert';
import 'package:flutter_cic_support/models/personcurrentplanrepeat.dart';
import 'package:flutter_cic_support/pages/jobplanarea_repeat.dart';
import 'package:flutter_cic_support/sqlite/dbprovider.dart';
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
    Provider.of<PlanData>(context, listen: false).fetchJobplanRepeat();
    Provider.of<PlanData>(context, listen: false).fetFinishedRepeatCheck();
    EasyLoading.dismiss();
    _tabController = TabController(initialIndex: 0, length: 3, vsync: this);
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
    if (listplan.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text("ไม่มีแผนการตรวจ",
                style: TextStyle(
                    fontFamily: 'Prompt', fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listplan.length,
      itemBuilder: (BuildContext context, int index) {
        String module_type =
            listplan[index].plan_type == "1" ? "5ส." : "Safety";
        Icon plan_icon = finishedcheck <= 0
            ? const Icon(Icons.pending_actions_rounded,
                color: Color(0xFFE99A24), size: 32)
            : const Icon(Icons.check_circle_rounded,
                color: Color(0xFF0F9B73), size: 32);

        String inspection_type_name = "";
        Color inspection_type_color = Colors.black87;
        if (listplan[index].inspection_type_id == "1") {
          inspection_type_name = "รอบตรวจปกติ";
          inspection_type_color = const Color(0xFF0F9B73);
        } else if (listplan[index].inspection_type_id == "2") {
          inspection_type_name = "รอบตรวจซ้ำ";
          inspection_type_color = const Color(0xFF1565C0);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onLongPress: () async {
                await DbProvider.instance.clearTransData();
              },
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const JobplanAreaPage())),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: finishedcheck <= 0
                            ? const Color(0xFFE99A24).withOpacity(0.1)
                            : const Color(0xFF0F9B73).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: plan_icon,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${listplan[index].plan_no}',
                            style: const TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormatter.format(
                                DateTime.parse(listplan[index].plan_date)),
                            style: const TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 14,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: module_type == "5ส."
                                ? const Color(0xFF1565C0).withOpacity(0.1)
                                : const Color(0xFFE99A24).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            module_type,
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: module_type == "5ส."
                                  ? const Color(0xFF1565C0)
                                  : const Color(0xFFE99A24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          inspection_type_name,
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: inspection_type_color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildlistrepeate(
      List<PersoncurrentPlanRepeat> listplan, int finishedcheck) {
    if (listplan.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text("ไม่มีแผนการตรวจซ้ำ",
                style: TextStyle(
                    fontFamily: 'Prompt', fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listplan.length,
      itemBuilder: (BuildContext context, int index) {
        String module_type =
            listplan[index].plan_type == "1" ? "5ส." : "Safety";
        Icon plan_icon = finishedcheck <= 0
            ? const Icon(Icons.pending_actions_rounded,
                color: Color(0xFFE99A24), size: 32)
            : const Icon(Icons.check_circle_rounded,
                color: Color(0xFF0F9B73), size: 32);

        String inspection_type_name = "";
        Color inspection_type_color = Colors.black87;
        if (listplan[index].inspection_type_id == "1") {
          inspection_type_name = "รอบตรวจปกติ";
          inspection_type_color = const Color(0xFF0F9B73);
        } else if (listplan[index].inspection_type_id == "2") {
          inspection_type_name = "รอบตรวจซ้ำ";
          inspection_type_color = const Color(0xFF1565C0);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => finishedcheck <= 0
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const JobplanAreaRepeatPage()))
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: finishedcheck <= 0
                            ? const Color(0xFFE99A24).withOpacity(0.1)
                            : const Color(0xFF0F9B73).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: plan_icon,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${listplan[index].plan_no}',
                            style: const TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormatter.format(
                                DateTime.parse(listplan[index].plan_date)),
                            style: const TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 14,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: module_type == "5ส."
                                ? const Color(0xFF1565C0).withOpacity(0.1)
                                : const Color(0xFFE99A24).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            module_type,
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: module_type == "5ส."
                                  ? const Color(0xFF1565C0)
                                  : const Color(0xFFE99A24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          inspection_type_name,
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: inspection_type_color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          "แผนการตรวจ",
          style: TextStyle(
              fontFamily: 'Prompt',
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0F9B73),
          unselectedLabelColor: Colors.grey.shade400,
          indicatorColor: const Color(0xFF0F9B73),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontFamily: 'Prompt', fontWeight: FontWeight.bold),
          tabs: const <Widget>[
            Tab(icon: Icon(Icons.list_alt_rounded), text: "แผนตรวจ"),
            Tab(icon: Icon(Icons.calendar_month_rounded), text: "ปฏิทิน"),
            Tab(icon: Icon(Icons.recycling_rounded), text: "ตรวจซ้ำ"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Consumer<PlanData>(
            builder: (context, _plan, _) =>
                _buildlist(_plan.listpersoncurrentplan, _plan.finishedcheck),
          ),
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
                    style: const TextStyle(
                        fontFamily: 'Prompt', fontWeight: FontWeight.bold),
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
                        style: const TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.calendar_today_rounded,
                            color: Color(0xFF0F9B73)),
                        onPressed: () {
                          cellCalendarPageController.animateToDate(
                            DateTime.now(),
                            curve: Curves.linear,
                            duration: const Duration(milliseconds: 300),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Text(
                      "${date.month.monthName} ${date.day}",
                      style: const TextStyle(
                          fontFamily: 'Prompt', fontWeight: FontWeight.bold),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: eventsOnTheDate
                          .map((event) => Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF0F9B73).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  event.eventName,
                                  style: const TextStyle(
                                      fontFamily: 'Prompt',
                                      color: Color(0xFF0F9B73),
                                      fontWeight: FontWeight.bold),
                                ),
                              ))
                          .toList(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("ปิด",
                            style: TextStyle(
                                fontFamily: 'Prompt',
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          Consumer<PlanData>(
            builder: (context, _plan, _) => _buildlistrepeate(
                _plan.listpersoncurrentplanRepeat, _plan.repeatcheck),
          ),
        ],
      ),
    );
  }
}
