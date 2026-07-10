import 'package:flutter/material.dart';

// ─── Mockup Data Models ───────────────────────────────────────────────────────

class DepartmentProduction {
  final String id;
  final String name;
  final String shortName;
  final Color color;
  final int dailyTarget;
  final int weeklyTarget;
  final int dailyActual;
  final int weeklyActual;
  final List<int> weeklyDailyActuals; // Mon-Sat

  const DepartmentProduction({
    required this.id,
    required this.name,
    required this.shortName,
    required this.color,
    required this.dailyTarget,
    required this.weeklyTarget,
    required this.dailyActual,
    required this.weeklyActual,
    required this.weeklyDailyActuals,
  });

  double get dailyPercent => dailyTarget == 0 ? 0 : (dailyActual / dailyTarget).clamp(0, 1.5);
  double get weeklyPercent => weeklyTarget == 0 ? 0 : (weeklyActual / weeklyTarget).clamp(0, 1.5);
}

const List<DepartmentProduction> _mockDepartments = [
  DepartmentProduction(
    id: 'all',
    name: 'ทุกแผนก',
    shortName: 'ทุกแผนก',
    color: Color(0xFF4A5AE7),
    dailyTarget: 35000,
    weeklyTarget: 210000,
    dailyActual: 31420,
    weeklyActual: 163800,
    weeklyDailyActuals: [32100, 33500, 29800, 31000, 31420, 0],
  ),
  DepartmentProduction(
    id: 'canvas_walk',
    name: 'เดินผ้าใบ',
    shortName: 'เดินผ้าใบ',
    color: Color(0xFF0F9B73),
    dailyTarget: 6000,
    weeklyTarget: 36000,
    dailyActual: 5680,
    weeklyActual: 29400,
    weeklyDailyActuals: [5900, 6100, 5400, 5700, 5680, 0],
  ),
  DepartmentProduction(
    id: 'canvas_cut',
    name: 'ตัดผ้าใบ',
    shortName: 'ตัดผ้าใบ',
    color: Color(0xFFFF7E36),
    dailyTarget: 5500,
    weeklyTarget: 33000,
    dailyActual: 5120,
    weeklyActual: 26700,
    weeklyDailyActuals: [5300, 5500, 4800, 5200, 5120, 0],
  ),
  DepartmentProduction(
    id: 'wire_walk',
    name: 'เดินลวด',
    shortName: 'เดินลวด',
    color: Color(0xFF9B59B6),
    dailyTarget: 5000,
    weeklyTarget: 30000,
    dailyActual: 4350,
    weeklyActual: 22500,
    weeklyDailyActuals: [4600, 4800, 4100, 4400, 4350, 0],
  ),
  DepartmentProduction(
    id: 'rubber_face',
    name: 'ออกหน้ายาง',
    shortName: 'ออกหน้ายาง',
    color: Color(0xFF1E88E5),
    dailyTarget: 5500,
    weeklyTarget: 33000,
    dailyActual: 5300,
    weeklyActual: 27600,
    weeklyDailyActuals: [5400, 5600, 5000, 5200, 5300, 0],
  ),
  DepartmentProduction(
    id: 'assembly',
    name: 'ประกอบ',
    shortName: 'ประกอบ',
    color: Color(0xFFE53935),
    dailyTarget: 5000,
    weeklyTarget: 30000,
    dailyActual: 4820,
    weeklyActual: 25100,
    weeklyDailyActuals: [4900, 5100, 4500, 4700, 4820, 0],
  ),
  DepartmentProduction(
    id: 'vulcanize',
    name: 'นึ่งยาง',
    shortName: 'นึ่งยาง',
    color: Color(0xFF00897B),
    dailyTarget: 4200,
    weeklyTarget: 25200,
    dailyActual: 3680,
    weeklyActual: 19100,
    weeklyDailyActuals: [3900, 4000, 3500, 3700, 3680, 0],
  ),
  DepartmentProduction(
    id: 'packing',
    name: 'บรรจุยาง',
    shortName: 'บรรจุยาง',
    color: Color(0xFFFFB300),
    dailyTarget: 3800,
    weeklyTarget: 22800,
    dailyActual: 2470,
    weeklyActual: 13400,
    weeklyDailyActuals: [3000, 2900, 2500, 2600, 2470, 0],
  ),
];

// ─── Main Page ────────────────────────────────────────────────────────────────

class ProductionDashboardPage extends StatefulWidget {
  const ProductionDashboardPage({Key? key}) : super(key: key);

  @override
  State<ProductionDashboardPage> createState() => _ProductionDashboardPageState();
}

class _ProductionDashboardPageState extends State<ProductionDashboardPage>
    with SingleTickerProviderStateMixin {
  String _selectedDeptId = 'all';
  late TabController _tabController;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DepartmentProduction get _selectedDept =>
      _mockDepartments.firstWhere((d) => d.id == _selectedDeptId);

  @override
  Widget build(BuildContext context) {
    final dept = _selectedDept;
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year + 543}';

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
          'Production Dashboard',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF0F9B73),
              indicatorWeight: 3,
              labelColor: const Color(0xFF0F9B73),
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontFamily: 'Prompt',
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'ประจำวัน'),
                Tab(text: 'ประจำสัปดาห์'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Department selector
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.factory_rounded,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'เลือกแผนก  •  ข้อมูล ณ $dateStr',
                      style: const TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'MOCKUP DATA',
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F9B73),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _mockDepartments.map((d) {
                      final selected = d.id == _selectedDeptId;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDeptId = d.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: selected ? d.color : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: d.color.withOpacity(0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : [],
                          ),
                          child: Text(
                            d.shortName,
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: selected ? Colors.white : Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _DailyView(dept: dept),
                _WeeklyView(dept: dept),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Daily View ───────────────────────────────────────────────────────────────

class _DailyView extends StatelessWidget {
  final DepartmentProduction dept;
  const _DailyView({required this.dept});

  @override
  Widget build(BuildContext context) {
    final isAll = dept.id == 'all';
    final relevantDepts = isAll
        ? _mockDepartments.where((d) => d.id != 'all').toList()
        : <DepartmentProduction>[];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary hero card
        _HeroCard(
          label: 'ยอดผลิตประจำวัน',
          actual: dept.dailyActual,
          target: dept.dailyTarget,
          percent: dept.dailyPercent,
          color: dept.color,
          unit: 'ชิ้น',
        ),
        const SizedBox(height: 16),

        // Status indicators row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.flag_rounded,
                label: 'เป้าหมาย',
                value: _fmt(dept.dailyTarget),
                unit: 'ชิ้น',
                color: Colors.grey.shade600,
                bgColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.precision_manufacturing_rounded,
                label: 'ผลิตได้',
                value: _fmt(dept.dailyActual),
                unit: 'ชิ้น',
                color: dept.color,
                bgColor: dept.color.withOpacity(0.08),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: dept.dailyActual >= dept.dailyTarget
                    ? Icons.check_circle_rounded
                    : Icons.warning_amber_rounded,
                label: 'คงเหลือ',
                value:
                    _fmt((dept.dailyTarget - dept.dailyActual).abs()),
                unit: dept.dailyActual >= dept.dailyTarget ? 'เกิน' : 'ชิ้น',
                color: dept.dailyActual >= dept.dailyTarget
                    ? const Color(0xFF0F9B73)
                    : const Color(0xFFFF7E36),
                bgColor: dept.dailyActual >= dept.dailyTarget
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFF3E0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Comparison line chart (only in "all" view)
        if (isAll) ...[
          const _SectionHeader(title: 'เปรียบเทียบยอดผลิตรายแผนก'),
          const SizedBox(height: 10),
          _CompareLineChart(
            depts: relevantDepts,
            isDaily: true,
          ),
          const SizedBox(height: 16),
          const _SectionHeader(title: 'ยอดรายแผนก'),
          const SizedBox(height: 8),
          ...relevantDepts.map((d) => _DeptRow(dept: d, isDaily: true)),
        ],
      ],
    );
  }
}

// ─── Compare Line Chart ───────────────────────────────────────────────────────

class _CompareLineChart extends StatelessWidget {
  final List<DepartmentProduction> depts;
  final bool isDaily; // true = compare dailyActual vs dailyTarget, false = weekly
  const _CompareLineChart({required this.depts, required this.isDaily});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ยอดผลิต vs เป้าหมาย (รายแผนก)',
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'เส้นทึบ = ผลิตได้  •  เส้นประ = เป้าหมาย',
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _CompareLineChartPainter(depts: depts, isDaily: isDaily),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: depts.map((d) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 3,
                    decoration: BoxDecoration(
                      color: d.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    d.shortName,
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 10,
                      color: d.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CompareLineChartPainter extends CustomPainter {
  final List<DepartmentProduction> depts;
  final bool isDaily;

  _CompareLineChartPainter({required this.depts, required this.isDaily});

  @override
  void paint(Canvas canvas, Size size) {
    final int n = depts.length;
    if (n == 0) return;

    // Find global max for y-axis scaling
    int globalMax = 0;
    for (final d in depts) {
      final t = isDaily ? d.dailyTarget : d.weeklyTarget;
      final a = isDaily ? d.dailyActual : d.weeklyActual;
      if (t > globalMax) globalMax = t;
      if (a > globalMax) globalMax = a;
    }
    if (globalMax == 0) return;
    final double yScale = size.height / (globalMax * 1.15);

    // X positions: evenly spaced
    final double xStep = size.width / (n - 1 == 0 ? 1 : n - 1);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height - (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw each department line pair (actual solid, target dashed)
    for (int di = 0; di < depts.length; di++) {
      final dept = depts[di];
      final actualVal = isDaily ? dept.dailyActual : dept.weeklyActual;
      final targetVal = isDaily ? dept.dailyTarget : dept.weeklyTarget;

      final x = di * xStep;
      final yActual = size.height - actualVal * yScale;
      final yTarget = size.height - targetVal * yScale;

      // Draw dot for actual
      final dotPaint = Paint()
        ..color = dept.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, yActual), 5, dotPaint);

      // Draw dot for target (hollow)
      final targetDotPaint = Paint()
        ..color = dept.color.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(x, yTarget), 4, targetDotPaint);

      // Connect with lines between adjacent departments
      if (di > 0) {
        final prevDept = depts[di - 1];
        final prevActual = isDaily ? prevDept.dailyActual : prevDept.weeklyActual;
        final prevTarget = isDaily ? prevDept.dailyTarget : prevDept.weeklyTarget;
        final prevX = (di - 1) * xStep;
        final prevYActual = size.height - prevActual * yScale;
        final prevYTarget = size.height - prevTarget * yScale;

        // Actual line - solid
        final linePaint = Paint()
          ..color = dept.color.withOpacity(0.7)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(prevX, prevYActual),
          Offset(x, yActual),
          linePaint,
        );

        // Target line - dashed
        _drawDashedLine(
          canvas,
          Offset(prevX, prevYTarget),
          Offset(x, yTarget),
          dept.color.withOpacity(0.35),
        );
      }
    }

    // Draw dept name labels on X axis
    for (int di = 0; di < depts.length; di++) {
      final dept = depts[di];
      final x = di * xStep;
      final tp = TextPainter(
        text: TextSpan(
          text: dept.shortName,
          style: TextStyle(
            color: dept.color,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x - tp.width / 2, size.height + 4),
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashLen = 5.0;
    const gapLen = 4.0;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final dist = (end - start).distance;
    final steps = dist / (dashLen + gapLen);
    for (int i = 0; i < steps; i++) {
      final t0 = i * (dashLen + gapLen) / dist;
      final t1 = (i * (dashLen + gapLen) + dashLen) / dist;
      canvas.drawLine(
        Offset(start.dx + dx * t0, start.dy + dy * t0),
        Offset(start.dx + dx * t1.clamp(0.0, 1.0), start.dy + dy * t1.clamp(0.0, 1.0)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Weekly View ──────────────────────────────────────────────────────────────

class _WeeklyView extends StatelessWidget {
  final DepartmentProduction dept;
  const _WeeklyView({required this.dept});

  static const _days = ['จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.'];

  @override
  Widget build(BuildContext context) {
    final isAll = dept.id == 'all';
    final relevantDepts = isAll
        ? _mockDepartments.where((d) => d.id != 'all').toList()
        : <DepartmentProduction>[];
    final maxDaily =
        dept.weeklyDailyActuals.reduce((a, b) => a > b ? a : b);
    final dailyTarget = dept.dailyTarget;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary hero card
        _HeroCard(
          label: 'ยอดผลิตประจำสัปดาห์',
          actual: dept.weeklyActual,
          target: dept.weeklyTarget,
          percent: dept.weeklyPercent,
          color: dept.color,
          unit: 'ชิ้น',
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.flag_rounded,
                label: 'เป้าสัปดาห์',
                value: _fmt(dept.weeklyTarget),
                unit: 'ชิ้น',
                color: Colors.grey.shade600,
                bgColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.precision_manufacturing_rounded,
                label: 'ผลิตได้',
                value: _fmt(dept.weeklyActual),
                unit: 'ชิ้น',
                color: dept.color,
                bgColor: dept.color.withOpacity(0.08),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Bar chart by day
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: dept.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ยอดผลิตรายวัน (สัปดาห์นี้)',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(6, (i) {
                  final val = dept.weeklyDailyActuals[i];
                  final barHeight = maxDaily == 0
                      ? 0.0
                      : (val / maxDaily) * 100;
                  final isToday = i == 4; // ศ. = today mock
                  final isEmpty = val == 0;
                  return Column(
                    children: [
                      if (!isEmpty)
                        Text(
                          _fmt(val),
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isToday ? dept.color : Colors.grey,
                          ),
                        ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        width: 32,
                        height: isEmpty ? 4 : barHeight,
                        decoration: BoxDecoration(
                          color: isEmpty
                              ? Colors.grey.shade200
                              : isToday
                                  ? dept.color
                                  : dept.color.withOpacity(0.4),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _days[i],
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 11,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday ? dept.color : Colors.grey,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey.shade100),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 2,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'เป้าหมายต่อวัน ${_fmt(dailyTarget)} ชิ้น',
                    style: const TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (isAll) ...[
          const _SectionHeader(title: 'ยอดสัปดาห์รายแผนก'),
          const SizedBox(height: 8),
          ...relevantDepts.map((d) => _DeptRow(dept: d, isDaily: false)),
        ],
      ],
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final String label;
  final int actual;
  final int target;
  final double percent;
  final Color color;
  final String unit;

  const _HeroCard({
    required this.label,
    required this.actual,
    required this.target,
    required this.percent,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (percent * 100).clamp(0, 150);
    final isGood = pct >= 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmt(actual),
                style: const TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          Text(
            'เป้าหมาย ${_fmt(target)} $unit',
            style: const TextStyle(
              fontFamily: 'Prompt',
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: AlwaysStoppedAnimation<Color>(
                isGood ? Colors.white : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$label ($unit)',
            style: const TextStyle(
              fontFamily: 'Prompt',
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeptRow extends StatelessWidget {
  final DepartmentProduction dept;
  final bool isDaily;

  const _DeptRow({required this.dept, required this.isDaily});

  @override
  Widget build(BuildContext context) {
    final actual = isDaily ? dept.dailyActual : dept.weeklyActual;
    final target = isDaily ? dept.dailyTarget : dept.weeklyTarget;
    final percent = isDaily ? dept.dailyPercent : dept.weeklyPercent;
    final pct = (percent * 100).clamp(0, 150);
    final isGood = pct >= 95;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dept.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dept.name,
                  style: const TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isGood
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isGood
                        ? const Color(0xFF0F9B73)
                        : const Color(0xFFFF7E36),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade100,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(dept.color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_fmt(actual)} / ${_fmt(target)}',
                style: const TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF0F9B73),
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
}

String _fmt(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if ((s.length - i) % 3 == 0 && i != 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
  return n.toString();
}
