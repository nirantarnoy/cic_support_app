import 'package:flutter/material.dart';

class ITSupportNotifyPage extends StatelessWidget {
  const ITSupportNotifyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mockup data for IT Support notifications
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'คำสั่งซ่อม #IT-2023001 ดำเนินการเสร็จสิ้น',
        'detail': 'การติดตั้งโปรแกรม Adobe Photoshop เสร็จสมบูรณ์แล้ว',
        'time': '10 นาทีที่แล้ว',
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF0F9B73),
        'isRead': false,
      },
      {
        'title': 'อัปเดตสถานะ #IT-2023005',
        'detail': 'กำลังรออะไหล่สำหรับการเปลี่ยนหน้าจอโน้ตบุ๊ก',
        'time': '2 ชั่วโมงที่แล้ว',
        'icon': Icons.hourglass_empty_rounded,
        'color': const Color(0xFFFF7E36),
        'isRead': false,
      },
      {
        'title': 'คำสั่งซ่อมใหม่ถูกมอบหมายถึงคุณ',
        'detail': 'แจ้งปัญหาอินเทอร์เน็ตใช้งานไม่ได้ที่แผนกบัญชี',
        'time': '1 วันที่แล้ว',
        'icon': Icons.assignment_rounded,
        'color': const Color(0xFF0072FF),
        'isRead': true,
      },
      {
        'title': 'แจ้งร้องขอสิทธิ์การใช้งานสำเร็จ',
        'detail': 'สิทธิ์การเข้าถึงระบบ ERP ของคุณได้รับการอนุมัติ',
        'time': '2 วันที่แล้ว',
        'icon': Icons.person_add_alt_1_rounded,
        'color': const Color(0xFF9B59B6),
        'isRead': true,
      },
    ];

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
          'การแจ้งเตือนระบบไอที',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'ไม่มีการแจ้งเตือน',
                style: TextStyle(fontFamily: 'Prompt', color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final noti = notifications[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: noti['isRead'] ? Colors.white : const Color(0xFFF0F8FF),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: noti['color'].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(noti['icon'], color: noti['color'], size: 22),
                    ),
                    title: Text(
                      noti['title'],
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontWeight: noti['isRead'] ? FontWeight.w500 : FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          noti['detail'],
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          noti['time'],
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'กำลังเปิดรายละเอียดคำสั่งซ่อม...',
                            style: TextStyle(fontFamily: 'Prompt'),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
