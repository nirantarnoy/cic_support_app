import 'package:flutter/material.dart';

class ITSupportTicketListPage extends StatelessWidget {
  final String status;
  final Color statusColor;

  const ITSupportTicketListPage({
    Key? key,
    required this.status,
    required this.statusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mockup Data
    final List<Map<String, dynamic>> tickets = _getMockTickets(status);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'รายการงาน: $status',
          style: const TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: tickets.isEmpty
          ? const Center(
              child: Text(
                'ไม่มีข้อมูลในสถานะนี้',
                style: TextStyle(fontFamily: 'Prompt', color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return GestureDetector(
                  onTap: () => _showTicketDetails(context, ticket),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                              color: statusColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCategoryIcon(ticket['category']),
                              color: statusColor,
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
                                      ticket['ticket_no'],
                                      style: const TextStyle(
                                        fontFamily: 'Prompt',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      ticket['date'],
                                      style: const TextStyle(
                                        fontFamily: 'Prompt',
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ticket['title'],
                                  style: const TextStyle(
                                    fontFamily: 'Prompt',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'หมวดหมู่: ${ticket['category']} | ผู้แจ้ง: ${ticket['requester']}',
                                  style: const TextStyle(
                                    fontFamily: 'Prompt',
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
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
    );
  }

  void _showTicketDetails(BuildContext context, Map<String, dynamic> ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'รายละเอียดคำสั่งซ่อม',
                    style: const TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('หมายเลขคำสั่งซ่อม:', ticket['ticket_no']),
              const SizedBox(height: 12),
              _buildDetailRow('วันที่แจ้ง:', ticket['date']),
              const SizedBox(height: 12),
              _buildDetailRow('ผู้แจ้ง:', ticket['requester']),
              const SizedBox(height: 12),
              _buildDetailRow('หมวดหมู่:', ticket['category']),
              const SizedBox(height: 12),
              _buildDetailRow('หัวข้อปัญหา:', ticket['title']),
              const SizedBox(height: 12),
              const Text(
                'รายละเอียดเพิ่มเติม:',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ticket['detail'],
                style: const TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'ปิด',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Prompt',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Prompt',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('โปรแกรม')) return Icons.code_rounded;
    if (category.contains('ฮาร์ดแวร์') || category.contains('คอมพิวเตอร์')) return Icons.computer_rounded;
    if (category.contains('รายงาน')) return Icons.bar_chart_rounded;
    if (category.contains('เครือข่าย') || category.contains('อินเทอร์เน็ต')) return Icons.wifi_rounded;
    return Icons.settings_rounded;
  }

  List<Map<String, dynamic>> _getMockTickets(String status) {
    // Generate dummy data based on status
    final List<Map<String, dynamic>> allTickets = [
      {
        'ticket_no': '#IT-2023010',
        'title': 'ขอสิทธิ์เข้าใช้ระบบ ERP (User ใหม่)',
        'detail': 'พนักงานใหม่ฝ่ายบุคคล ต้องการสิทธิ์เข้าใช้งานระบบ ERP โมดูล HR',
        'category': 'การจัดการสิทธิ์',
        'requester': 'สมชาย ใจดี',
        'date': '10 ก.ค. 2569 09:30',
        'status': 'รอดำเนินการ',
      },
      {
        'ticket_no': '#IT-2023011',
        'title': 'ปริ้นเตอร์พิมพ์ไม่ออก',
        'detail': 'เครื่องปริ้นเตอร์ส่วนกลางชั้น 2 พิมพ์ไม่ออก มีไฟสีแดงกระพริบ',
        'category': 'ฮาร์ดแวร์',
        'requester': 'มาลี สวยงาม',
        'date': '10 ก.ค. 2569 10:15',
        'status': 'รอดำเนินการ',
      },
      {
        'ticket_no': '#IT-2023008',
        'title': 'ลืมรหัสผ่านเข้าระบบเมลบริษัท',
        'detail': 'ต้องการรีเซ็ตรหัสผ่านอีเมลของบริษัทเนื่องจากลืมรหัส',
        'category': 'การใช้งานโปรแกรม',
        'requester': 'วิชัย รักงาน',
        'date': '09 ก.ค. 2569 14:20',
        'status': 'กำลังแก้ไข',
      },
      {
        'ticket_no': '#IT-2023005',
        'title': 'เปลี่ยนหน้าจอโน้ตบุ๊ก',
        'detail': 'หน้าจอโน้ตบุ๊กมีเส้นสีเขียวพาดกลางจอ ต้องการเคลมเปลี่ยนจอใหม่',
        'category': 'ฮาร์ดแวร์',
        'requester': 'ดวงใจ สว่าง',
        'date': '08 ก.ค. 2569 11:00',
        'status': 'กำลังแก้ไข',
      },
      {
        'ticket_no': '#IT-2023001',
        'title': 'ติดตั้งโปรแกรม Photoshop',
        'detail': 'ติดตั้งโปรแกรม Adobe Photoshop ให้ทีมกราฟิกใหม่',
        'category': 'การใช้งานโปรแกรม',
        'requester': 'ธนา รวยทรัพย์',
        'date': '05 ก.ค. 2569 15:45',
        'status': 'เสร็จสิ้น',
      },
      {
        'ticket_no': '#IT-2023002',
        'title': 'อินเทอร์เน็ตหลุดบ่อย',
        'detail': 'โซนโกดัง A อินเทอร์เน็ต Wi-Fi หลุดบ่อยมาก ทำงานไม่ได้',
        'category': 'อินเทอร์เน็ตเครือข่าย',
        'requester': 'สมศักดิ์ ขยัน',
        'date': '06 ก.ค. 2569 09:10',
        'status': 'เสร็จสิ้น',
      },
      {
        'ticket_no': '#IT-2023004',
        'title': 'เมาส์ใช้งานไม่ได้',
        'detail': 'ผู้ใช้งานแจ้งว่าเมาส์ใช้งานไม่ได้ แต่ตรวจสอบแล้วพบว่าสายหลุด ผู้ใช้เสียบใหม่ใช้งานได้ปกติ',
        'category': 'ฮาร์ดแวร์',
        'requester': 'ปิติ สุขสม',
        'date': '04 ก.ค. 2569 08:20',
        'status': 'ยกเลิก',
      },
      {
        'ticket_no': '#IT-2023003',
        'title': 'ขอเปลี่ยนรหัสผ่าน',
        'detail': 'ผู้ใช้งานขอยกเลิกการเปลี่ยนรหัสผ่าน เนื่องจากจำรหัสผ่านเดิมได้แล้ว',
        'category': 'การจัดการสิทธิ์',
        'requester': 'สุชาติ สบายใจ',
        'date': '03 ก.ค. 2569 11:30',
        'status': 'ยกเลิก',
      },
      {
        'ticket_no': '#IT-2023012',
        'title': 'เครื่องปรับอากาศเสีย',
        'detail': 'แอร์ในห้องประชุมเสีย ไม่เย็น (แจ้งผิด แจ้งซ่อมทั่วไป ไม่ใช่ไอที)',
        'category': 'อื่นๆ',
        'requester': 'นารี รักสวย',
        'date': '10 ก.ค. 2569 11:15',
        'status': 'แจ้งผิดหัวข้อ',
      },
      {
        'ticket_no': '#IT-2023013',
        'title': 'หลอดไฟหน้าห้องน้ำขาด',
        'detail': 'หลอดไฟขาด ต้องการให้ช่างมาเปลี่ยน (แจ้งผิด แจ้งซ่อมทั่วไป)',
        'category': 'อื่นๆ',
        'requester': 'สมบูรณ์ พูนสุข',
        'date': '10 ก.ค. 2569 11:40',
        'status': 'แจ้งผิดหัวข้อ',
      },
    ];

    if (status == 'ทั้งหมด') {
      return allTickets;
    }
    return allTickets.where((t) => t['status'] == status).toList();
  }
}
