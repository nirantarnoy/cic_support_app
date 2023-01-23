import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CarHistoryPage extends StatefulWidget {
  const CarHistoryPage({Key? key}) : super(key: key);

  @override
  State<CarHistoryPage> createState() => _CarHistoryPageState();
}

class _CarHistoryPageState extends State<CarHistoryPage>
    with TickerProviderStateMixin {
  final cellCalendarPageController = CellCalendarPageController();
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(153, 161, 12, 24),
      appBar: AppBar(
        title: Text("ประวัติการออกใบ CAR"),
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
            Text("table plan"),
            Text("safety"),
          ],
        ),
      ),
    );
  }
}
