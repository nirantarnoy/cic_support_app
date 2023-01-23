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
    Widget _carddata;
    if (_list.isNotEmpty) {
      _carddata = ListView.builder(
          itemCount: _list.length,
          itemBuilder: ((context, index) {
            String _line_status =
                _list[index].status == "1" ? "Completed" : "Pending";
            Color _line_status_color =
                _list[index].status == "1" ? Colors.green : Colors.red;
            return Card(
              child: ListTile(
                title: Text("${_list[index].plan_no}"),
                subtitle: Text(
                    "${dateFormatter.format(DateTime.parse(_list[index].plan_date))}"),
                trailing: Column(
                  children: [
                    Text(
                      "${_line_status}",
                      style: TextStyle(
                        color: _line_status_color,
                      ),
                    ),
                    Text(
                      "${dateFormatter.format(DateTime.parse(_list[index].plan_actual_date))}",
                      style: TextStyle(
                        color: _line_status_color,
                      ),
                    )
                  ],
                ),
              ),
            );
          }));
    } else {
      _carddata = Center(
        child: Text("No Data"),
      );
    }

    return _carddata;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 45, 172, 123),
      appBar: AppBar(
        title: Text("ประวัติการตรวจ"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.cleaning_services_rounded),
              text: "5 ส.",
            ),
            Tab(
              icon: Icon(Icons.security),
              text: "Safety",
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Consumer<PlanData>(
              builder: (context, _plan, _) =>
                  _buildlist(_plan.listhistorytrans),
            ),
            Text("safety"),
          ],
        ),
      ),
    );
  }
}
