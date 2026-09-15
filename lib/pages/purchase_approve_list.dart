import 'package:flutter/material.dart';
import 'package:flutter_cic_support/pages/purchase_approve_detail.dart';
import 'package:intl/intl.dart';

class PurchaseApproveListPage extends StatefulWidget {
  const PurchaseApproveListPage({Key? key}) : super(key: key);

  @override
  State<PurchaseApproveListPage> createState() => _PurchaseApproveListPageState();
}

class _PurchaseApproveListPageState extends State<PurchaseApproveListPage> {
  // Demo Data
  final List<Map<String, dynamic>> _demoRequests = [
    {
      'id': 'PR-202310-001',
      'requestor': 'นายสมชาย ใจดี',
      'department': 'IT Support',
      'date': '2023-10-01 10:30',
      'total': 15500.00,
      'status': 'รออนุมัติ',
      'has_attachment': true,
    },
    {
      'id': 'PR-202310-002',
      'requestor': 'นางสาวสมศรี รักงาน',
      'department': 'HR',
      'date': '2023-10-02 09:15',
      'total': 2400.00,
      'status': 'รออนุมัติ',
      'has_attachment': false,
    },
    {
      'id': 'PR-202310-005',
      'requestor': 'นายสมศักดิ์ ขยัน',
      'department': 'Production',
      'date': '2023-10-05 14:20',
      'total': 45000.00,
      'status': 'รออนุมัติ',
      'has_attachment': true,
    },
  ];

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'รายการรออนุมัติขอซื้อ',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _demoRequests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_cart_checkout_rounded, size: 48, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "ไม่พบรายการรออนุมัติขอซื้อ",
                    style: TextStyle(fontFamily: 'Prompt', fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: const Color(0xFF8E24AA),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _demoRequests.length,
                itemBuilder: (context, index) {
                  final item = _demoRequests[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PurchaseApproveDetailPage(
                          requestData: item,
                        ),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8E24AA).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Color(0xFF8E24AA),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['id'],
                                        style: const TextStyle(
                                          fontFamily: 'Prompt',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF7E36).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          item['status'],
                                          style: const TextStyle(
                                            fontFamily: 'Prompt',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFF7E36),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${item['requestor']} (${item['department']})',
                                    style: const TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            item['date'],
                                            style: const TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          if (item['has_attachment'] == true) ...[
                                            const Icon(Icons.attach_file_rounded, size: 14, color: Colors.blue),
                                            const SizedBox(width: 8),
                                          ],
                                          Text(
                                            '฿${formatter.format(item['total'])}',
                                            style: const TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F9B73),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
