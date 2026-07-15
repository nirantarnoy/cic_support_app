import 'package:flutter/material.dart';
import 'package:flutter_cic_support/pages/it_support_notify.dart';
import 'package:flutter_cic_support/pages/it_support_ticket_list.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ITSupportDashboardPage extends StatefulWidget {
  const ITSupportDashboardPage({Key? key}) : super(key: key);

  @override
  State<ITSupportDashboardPage> createState() => _ITSupportDashboardPageState();
}

class _ITSupportDashboardPageState extends State<ITSupportDashboardPage> {
  // Mockup Data
  final int pendingTickets = 15;
  final int inProgressTickets = 32;
  final int completedTickets = 70;
  final int canceledTickets = 5;
  final int wrongCategoryTickets = 3;
  final int totalTickets = 125; // 15 + 32 + 70 + 5 + 3 = 125

  late List<_ChartData> chartData;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    chartData = [
      _ChartData('โปรแกรม', 45, const Color(0xFF0F9B73)),
      _ChartData('อุปกรณ์คอมฯ', 35, const Color(0xFFE94057)),
      _ChartData('ขอรายงาน', 25, const Color(0xFF1A2980)),
      _ChartData('ขอผู้ใช้งาน', 20, const Color(0xFFF2C94C)),
    ];
    _tooltipBehavior = TooltipBehavior(
        enable: true, textStyle: const TextStyle(fontFamily: 'Prompt'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'ระบบแจ้งซ่อมไอที',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.black87),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ITSupportNotifyPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Summary Cards
            _buildSectionTitle('สถานะการแจ้งซ่อม (เดือนนี้)'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    title: 'ทั้งหมด',
                    count: totalTickets,
                    icon: Icons.assignment_rounded,
                    color: const Color(0xFF0072FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    title: 'รอดำเนินการ',
                    count: pendingTickets,
                    icon: Icons.hourglass_empty_rounded,
                    color: const Color(0xFFFF7E36),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    title: 'กำลังแก้ไข',
                    count: inProgressTickets,
                    icon: Icons.build_circle_rounded,
                    color: const Color(0xFF9B59B6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    title: 'เสร็จสิ้น',
                    count: completedTickets,
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF0F9B73),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    title: 'ยกเลิก',
                    count: canceledTickets,
                    icon: Icons.cancel_rounded,
                    color: const Color(0xFFE53935),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    title: 'แจ้งผิดหัวข้อ',
                    count: wrongCategoryTickets,
                    icon: Icons.report_problem_rounded,
                    color: const Color(0xFFFFB300),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Chart Section
            _buildSectionTitle('สัดส่วนตามประเภทการแจ้งซ่อม'),
            const SizedBox(height: 12),
            Container(
              height: 250,
              padding: const EdgeInsets.all(12),
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
              child: SfCircularChart(
                tooltipBehavior: _tooltipBehavior,
                legend: Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap,
                  position: LegendPosition.bottom,
                  textStyle:
                      const TextStyle(fontFamily: 'Prompt', fontSize: 12),
                ),
                series: <CircularSeries>[
                  DoughnutSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.category,
                    yValueMapper: (_ChartData data, _) => data.value,
                    pointColorMapper: (_ChartData data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 10,
                          color: Colors.white),
                    ),
                    innerRadius: '60%',
                    enableTooltip: true,
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Menu Section
            _buildSectionTitle('เมนูหลักการแจ้งซ่อม'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.9,
              children: [
                _buildMenuButton(
                  title: 'แจ้งการใช้งานโปรแกรม',
                  icon: Icons.code_rounded,
                  colors: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
                ),
                _buildMenuButton(
                  title: 'แจ้งอุปกรณ์คอมพิวเตอร์',
                  icon: Icons.computer_rounded,
                  colors: [const Color(0xFFf83600), const Color(0xFFf9d423)],
                ),
                _buildMenuButton(
                  title: 'แจ้งร้องขอรายงาน',
                  icon: Icons.bar_chart_rounded,
                  colors: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
                ),
                _buildMenuButton(
                  title: 'แจ้งร้องขอผู้ใช้งาน',
                  icon: Icons.person_add_alt_1_rounded,
                  colors: [const Color(0xFF834d9b), const Color(0xFFd04ed6)],
                ),
                _buildMenuButton(
                  title: 'กล้องวงจรปิด',
                  icon: Icons.camera_indoor_rounded,
                  colors: [const Color(0xFFff0844), const Color(0xFFffb199)],
                ),
                _buildMenuButton(
                  title: 'กู้ข้อมูล',
                  icon: Icons.settings_backup_restore_rounded,
                  colors: [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
                ),
                _buildMenuButton(
                  title: 'โทรศัพท์',
                  icon: Icons.phone_in_talk_rounded,
                  colors: [const Color(0xFFfa709a), const Color(0xFFfee140)],
                ),
                _buildMenuButton(
                  title: 'อินเทอร์เน็ต',
                  icon: Icons.wifi_rounded,
                  colors: [const Color(0xFF30cfd0), const Color(0xFF330867)],
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF0072FF),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Prompt',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ITSupportTicketListPage(
                status: title,
                statusColor: color,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildMenuButton({
    required String title,
    required IconData icon,
    required List<Color> colors,
  }) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'กำลังเข้าสู่: $title',
              style: const TextStyle(fontFamily: 'Prompt'),
            ),
            backgroundColor: colors[0],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.category, this.value, this.color);
  final String category;
  final double value;
  final Color color;
}
