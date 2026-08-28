import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ITSupportAdminDashboardPage extends StatefulWidget {
  const ITSupportAdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<ITSupportAdminDashboardPage> createState() =>
      _ITSupportAdminDashboardPageState();
}

class _ITSupportAdminDashboardPageState
    extends State<ITSupportAdminDashboardPage> {
  bool _isLoading = true;
  List<dynamic> _workRequestSummary = [];
  List<dynamic> _paperlessSummary = [];
  List<dynamic> _workRequests = [];
  List<dynamic> _paperlessRequests = [];
  int? _selectedFilterStatus = 1; // 1 = Open, null = All
  int _selectedSystem = 0; // 0 = Paperless, 1 = CMMS
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  final String _baseUrl = 'http://192.168.60.34:3000/api/dashboard';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final startStr = '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}';
      final endStr = '${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}';

      final summaryRes = await http.get(Uri.parse('$_baseUrl/summary?startDate=$startStr&endDate=$endStr'));
      final detailsRes = await http.get(Uri.parse('$_baseUrl/details?startDate=$startStr&endDate=$endStr'));

      if (summaryRes.statusCode == 200 && detailsRes.statusCode == 200) {
        final summaryData = json.decode(summaryRes.body);
        final detailsData = json.decode(detailsRes.body);

        setState(() {
          _workRequestSummary = summaryData['workRequestSummary'] ?? [];
          _paperlessSummary = summaryData['paperlessSummary'] ?? [];
          _workRequests = detailsData['workRequests'] ?? [];
          _paperlessRequests = detailsData['paperlessRequests'] ?? [];
        });
      } else {
        _showErrorSnackBar('Failed to load data from server');
      }
    } catch (e) {
      print('Error fetching admin dashboard: $e');
      _showErrorSnackBar('Network error or API is down');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Prompt')),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // --- UI Helpers ---

  String _getStatusName(int status) {
    switch (status) {
      case 1:
        return 'รอดำเนินการ (Pending)';
      case 2:
        return 'กำลังดำเนินการ (In Progress)';
      case 3:
        return 'เสร็จสิ้น (Completed)';
      case 4:
        return 'ยกเลิก (Cancelled)';
      default:
        return 'สถานะ: $status';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int _getTotalCount(List<dynamic> summary) {
    int total = 0;
    for (var item in summary) {
      total += (item['count'] as int?) ?? 0;
    }
    return total;
  }

  String _getJobTypeName(int jobType) {
    switch (jobType) {
      case 1: return 'ระบบ/โปรแกรม (Program)';
      case 2: return 'ผู้ใช้งาน (User)';
      case 3: return 'รายงาน (Report)';
      case 4: return 'อุปกรณ์/แจ้งซ่อม (Device)';
      case 5: return 'กล้องวงจรปิด (Camera)';
      case 6: return 'โทรศัพท์ (Phone)';
      case 7: return 'กู้ข้อมูล (Restore)';
      case 8: return 'อินเทอร์เน็ต (Internet)';
      default: return 'อื่นๆ ($jobType)';
    }
  }

  Widget _buildSummaryCard(String title, List<dynamic> summary, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
            title,
            style: const TextStyle(
              fontFamily: 'Prompt',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'รวมทั้งหมด: ${_getTotalCount(summary)} รายการ',
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const Divider(),
          if (summary.isEmpty)
            const Text('ไม่มีข้อมูล',
                style: TextStyle(fontFamily: 'Prompt', color: Colors.grey))
          else
              ...summary.map((item) {
              int status = int.tryParse(item['RequestStatus']?.toString() ?? item['jobstatus']?.toString() ?? '0') ?? 0;
              int count = int.tryParse(item['count']?.toString() ?? '0') ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getStatusName(status),
                          style: const TextStyle(
                              fontFamily: 'Prompt', fontSize: 13),
                        ),
                      ],
                    ),
                    Text(
                      '$count',
                      style: const TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList()
        ],
      ),
    ),
  ),
);
}

  Widget _buildPaperlessDashboardGrid() {
    Map<int, int> counts = {};
    for (var item in _paperlessSummary) {
      int type = int.tryParse(item['jobtype']?.toString() ?? '0') ?? 0;
      int count = int.tryParse(item['count']?.toString() ?? '0') ?? 0;
      counts[type] = (counts[type] ?? 0) + count;
    }

    final boxes = [
      {'type': 1, 'title': 'Softwares', 'desc': 'โปรแกรม', 'color': Colors.green, 'icon': Icons.computer},
      {'type': 2, 'title': 'Users', 'desc': 'ผู้ใช้งาน', 'color': Colors.orange, 'icon': Icons.person},
      {'type': 3, 'title': 'Reports', 'desc': 'รายงาน', 'color': Colors.blue, 'icon': Icons.assignment},
      {'type': 4, 'title': 'Devices', 'desc': 'อุปกรณ์', 'color': Colors.black87, 'icon': Icons.print},
      {'type': 5, 'title': 'CCTVs', 'desc': 'กล้องวงจรปิด', 'color': Colors.grey.shade700, 'icon': Icons.camera_alt},
      {'type': 6, 'title': 'Telephones', 'desc': 'โทรศัพท์', 'color': Colors.pink, 'icon': Icons.phone},
      {'type': 7, 'title': 'Recoverys', 'desc': 'กู้ข้อมูล', 'color': Colors.teal, 'icon': Icons.restore},
      {'type': 8, 'title': 'Internet', 'desc': 'อินเทอร์เน็ต', 'color': Colors.indigo, 'icon': Icons.wifi},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: boxes.length,
      itemBuilder: (context, index) {
        final box = boxes[index];
        final count = counts[box['type'] as int] ?? 0;
        return Container(
          decoration: BoxDecoration(
            color: box['color'] as Color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Icon(box['icon'] as IconData, color: Colors.white, size: 24),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        box['title'] as String,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Prompt'),
                      ),
                      Text(
                        box['desc'] as String,
                        style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'Prompt'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$count',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Prompt'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTicketDetails(Map<String, dynamic> ticket, bool isWorkRequest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              isWorkRequest
                  ? 'รายละเอียดแจ้งซ่อม (HW)'
                  : 'รายละเอียดร้องขอ Paperless',
              style: const TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: ticket.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            '${e.key}:',
                            style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.key == 'jobtype' && !isWorkRequest
                                ? _getJobTypeName(int.tryParse(e.value?.toString() ?? '0') ?? 0)
                                : '${e.value}',
                            style: const TextStyle(
                                fontFamily: 'Prompt', fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('ปิด (Close)',
                    style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 16,
                        color: Colors.white)),
              ),
            ),
            if (!isWorkRequest && (ticket['jobstatus'] == 1 || ticket['jobstatus'] == null)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0072FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _convertToPM(ticket),
                  child: const Text('อนุมัติเข้าระบบ PM (Convert)',
                      style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Future<void> _convertToPM(Map<String, dynamic> ticket) async {
    Navigator.pop(context); // Close modal
    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('http://192.168.60.34:3000/api/workrequest/approve'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'recids': [ticket['recid']],
          'userId': 999 // TODO: Use real admin user ID
        }),
      );
      if (res.statusCode == 200) {
        _showErrorSnackBar('แปลงข้อมูลเข้าระบบ PM สำเร็จ');
        _fetchDashboardData();
      } else {
        _showErrorSnackBar('เกิดข้อผิดพลาดในการแปลงข้อมูล');
      }
    } catch (e) {
      _showErrorSnackBar('Network error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0072FF),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0072FF),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchDashboardData();
    }
  }

  List<dynamic> get _currentSystemRequests {
    List<dynamic> currentList = [];
    if (_selectedSystem == 0) {
      // Paperless
      for (var item in _paperlessRequests) {
        if (item is Map) {
          int st = int.tryParse(item['jobstatus']?.toString() ?? '0') ?? 0;
          if (_selectedFilterStatus == null || st == _selectedFilterStatus) {
            currentList.add(Map<String, dynamic>.from(item)..['isWorkRequest'] = false);
          }
        }
      }
    } else {
      // CMMS (4CITLive3)
      for (var item in _workRequests) {
        if (item is Map) {
          int st = int.tryParse(item['RequestStatus']?.toString() ?? '0') ?? 0;
          if (_selectedFilterStatus == null || st == _selectedFilterStatus) {
            currentList.add(Map<String, dynamic>.from(item)..['isWorkRequest'] = true);
          }
        }
      }
    }

    currentList.sort((a, b) {
      String dateAStr = (a['isWorkRequest'] ? a['ReceivedDate'] : a['jobdate'])?.toString() ?? '';
      String dateBStr = (b['isWorkRequest'] ? b['ReceivedDate'] : b['jobdate'])?.toString() ?? '';
      DateTime dateA = DateTime.tryParse(dateAStr) ?? DateTime.fromMillisecondsSinceEpoch(0);
      DateTime dateB = DateTime.tryParse(dateBStr) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });

    return currentList;
  }

  Widget _buildList(List<dynamic> data) {
    if (data.isEmpty) {
      return const Center(
        child: Text('ไม่มีรายการ',
            style: TextStyle(fontFamily: 'Prompt', color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final bool isWorkRequest = item['isWorkRequest'] == true;
        final id = isWorkRequest ? item['RequestNo'] : item['recid'];
        final desc =
            isWorkRequest ? item['ProblemDesc'] : (item['comment'] ?? 'No detail');
        final status = int.tryParse(item['RequestStatus']?.toString() ?? item['jobstatus']?.toString() ?? '0') ?? 0;
        final date = isWorkRequest ? item['ReceivedDate'] : item['jobdate'];

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(status).withOpacity(0.1),
              child: Icon(
                isWorkRequest ? Icons.computer : Icons.app_registration,
                color: _getStatusColor(status),
              ),
            ),
            title: Text(
              desc?.toString() ?? '-',
              style: const TextStyle(
                  fontFamily: 'Prompt', fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (!isWorkRequest && item['jobtype'] != null)
                  Text('ประเภท: ${_getJobTypeName(int.tryParse(item['jobtype']?.toString() ?? '0') ?? 0)}',
                      style: const TextStyle(
                          fontFamily: 'Prompt', fontSize: 12, color: Colors.blueAccent)),
                Text('รหัส: $id',
                    style: const TextStyle(
                        fontFamily: 'Prompt', fontSize: 12, color: Colors.grey)),
                Text('วันที่: $date',
                    style: const TextStyle(
                        fontFamily: 'Prompt', fontSize: 12, color: Colors.grey)),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusName(status).split(' ').first,
                style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 12,
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () => _showTicketDetails(item, isWorkRequest),
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('IT Admin Dashboard',
            style: TextStyle(
                color: Colors.black87,
                fontFamily: 'Prompt',
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.black87),
            onPressed: () => _selectDateRange(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _fetchDashboardData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // System Selector
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSystem = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedSystem == 0 ? const Color(0xFF0072FF) : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'ระบบ Paperless',
                                style: TextStyle(
                                  fontFamily: 'Prompt',
                                  fontWeight: FontWeight.bold,
                                  color: _selectedSystem == 0 ? Colors.white : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSystem = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedSystem == 1 ? const Color(0xFF0072FF) : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'ระบบ CMMS (PM)',
                                style: TextStyle(
                                  fontFamily: 'Prompt',
                                  fontWeight: FontWeight.bold,
                                  color: _selectedSystem == 1 ? Colors.white : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Summary Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _selectedSystem == 0
                      ? _buildPaperlessDashboardGrid()
                      : _buildSummaryCard(
                          'สถิติระบบ CMMS (PM)',
                          _workRequestSummary,
                          Colors.blue,
                        ),
                ),
                // Filter Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ทั้งหมด (All)', null),
                        const SizedBox(width: 8),
                        _buildFilterChip('รอดำเนินการ', 1),
                        const SizedBox(width: 8),
                        _buildFilterChip('กำลังดำเนินการ', 2),
                        const SizedBox(width: 8),
                        _buildFilterChip('เสร็จสิ้น', 3),
                        const SizedBox(width: 8),
                        _buildFilterChip('ยกเลิก', 4),
                      ],
                    ),
                  ),
                ),
                // Current System List
                Expanded(
                  child: _buildList(_currentSystemRequests),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label, int? status) {
    final isSelected = _selectedFilterStatus == status;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Prompt',
          color: isSelected ? Colors.white : Colors.grey.shade800,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF0072FF),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0072FF) : Colors.grey.shade300,
        ),
      ),
      onSelected: (bool selected) {
        setState(() {
          _selectedFilterStatus = status;
        });
      },
    );
  }
}
