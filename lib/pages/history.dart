import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/transhistoryemp.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with TickerProviderStateMixin {
  final cellCalendarPageController = CellCalendarPageController();
  late TabController _tabController;
  final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');
  @override
  void initState() {
    super.initState();
    Provider.of<PlanData>(context, listen: false).fetchHistoryTransByEmp();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  Widget _buildlist(List<TransHistoryEmp> _list) {
    if (_list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "ไม่พบประวัติการตรวจ",
              style: TextStyle(
                  fontFamily: 'Prompt', fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _list.length,
      itemBuilder: ((context, index) {
        String _line_status =
            _list[index].status == "1" ? "ตรวจแล้ว" : "รอดำเนินการ";
        Color _line_status_color = _list[index].status == "1"
            ? const Color(0xFF0F9B73)
            : const Color(0xFFE99A24);
        IconData _status_icon = _list[index].status == "1"
            ? Icons.check_circle_rounded
            : Icons.pending_actions_rounded;
        Color _icon_bg_color = _list[index].status == "1"
            ? const Color(0xFF0F9B73).withOpacity(0.1)
            : const Color(0xFFE99A24).withOpacity(0.1);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _icon_bg_color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_status_icon, color: _line_status_color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_list[index].plan_no}",
                        style: const TextStyle(
                          fontFamily: 'Prompt',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Text(
                            "เป้าหมาย: ${dateFormatter.format(DateTime.parse(_list[index].plan_date))}",
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      if (_list[index].status == "1") ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.event_available_rounded,
                                size: 14, color: Colors.green.shade600),
                            const SizedBox(width: 6),
                            Text(
                              "ตรวจเมื่อ: ${dateFormatter.format(DateTime.parse(_list[index].plan_actual_date))}",
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 13,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _line_status_color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _line_status,
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _line_status_color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2DAC7B),
      appBar: AppBar(
        title: const Text(
          "ประวัติการตรวจ",
          style: TextStyle(
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Prompt'),
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.cleaning_services_rounded),
              text: "5 ส.",
            ),
            Tab(
              icon: Icon(Icons.security_rounded),
              text: "Safety",
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F7FB),
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Consumer<PlanData>(
              builder: (context, _plan, _) =>
                  _buildlist(_plan.listhistorytrans),
            ),
            const Center(
              child: Text(
                "ไม่มีข้อมูล Safety",
                style: TextStyle(fontFamily: 'Prompt', color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
