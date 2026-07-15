import 'package:flutter/material.dart';

class CarHistoryPage extends StatefulWidget {
  const CarHistoryPage({Key? key}) : super(key: key);

  @override
  State<CarHistoryPage> createState() => _CarHistoryPageState();
}

class _CarHistoryPageState extends State<CarHistoryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  Widget _buildEmptyState(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Prompt',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ไม่พบประวัติการออกใบ CAR ในระบบ',
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "ประวัติการออกใบ CAR",
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF0F9B73),
          indicatorWeight: 3,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.black38,
          labelStyle: const TextStyle(
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Prompt',
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: const <Widget>[
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
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            _buildEmptyState("ประวัติ 5 ส.", Icons.cleaning_services_rounded),
            _buildEmptyState("ประวัติ Safety", Icons.security),
          ],
        ),
      ),
    );
  }
}
