import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:flutter_cic_support/pages/ai_chat_page.dart';
import 'package:flutter_cic_support/pages/ai_it_chat_page.dart';

class AIChatDrawer extends StatelessWidget {
  final String currentTopic;

  const AIChatDrawer({Key? key, required this.currentTopic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context, listen: false);
    final String fullName = userData.empfullname.isNotEmpty ? userData.empfullname : 'พนักงานทั่วไป';
    final String department = userData.emp_department_name.isNotEmpty ? userData.emp_department_name : 'แผนกทั่วไป';
    final String photo = userData.photo_display;
    final String displayPhotoUrl = "https://img.cicsupports.com/profile/$photo";

    return Drawer(
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: Column(
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF8A2387),
                    Color(0xFFE94057),
                    Color(0xFFF27121),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: photo.isNotEmpty ? NetworkImage(displayPhotoUrl) : null,
                child: photo.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Color(0xFFE94057))
                    : null,
              ),
              accountName: Text(
                fullName,
                style: const TextStyle(
                  fontFamily: 'Prompt',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                department,
                style: const TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
            
            // Drawer Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'หัวข้อสนทนาทั้งหมด',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),

            // Topics List
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.badge_outlined,
                    title: 'ข้อมูลส่วนตัว & Payroll',
                    topic: 'payroll',
                    color: const Color(0xFF4A5AE7),
                    onTap: () => _navigateToTopic(context, 'payroll'),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.monetization_on_outlined,
                    title: 'เงินกู้ & สวัสดิการพนักงาน',
                    topic: 'welfare',
                    color: const Color(0xFFFF7E36),
                    onTap: () => _navigateToTopic(context, 'welfare'),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.factory_outlined,
                    title: 'ข้อมูลผลิตเชิงลึก (ERP)',
                    topic: 'erp',
                    color: const Color(0xFF0F9B73),
                    onTap: () => _navigateToTopic(context, 'erp'),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.computer_outlined,
                    title: 'งานระบบ IT (Real API)',
                    topic: 'it',
                    color: const Color(0xFF8E2DE2),
                    onTap: () => _navigateToTopic(context, 'it'),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Footer/Close button
            ListTile(
              leading: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.grey),
              title: const Text(
                'กลับหน้าหลักผู้ช่วย AI',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close Drawer
                Navigator.pop(context); // Go back to AIAssistantPage
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String topic,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isSelected = currentTopic == topic;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? color : Colors.grey.shade600,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Prompt',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : Colors.black87,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              )
            : const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
        onTap: isSelected ? () => Navigator.pop(context) : onTap,
      ),
    );
  }

  void _navigateToTopic(BuildContext context, String targetTopic) {
    Navigator.pop(context); // Close Drawer

    if (targetTopic == 'it') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AIITChatPage()),
      );
    } else {
      AIChatRole role;
      if (targetTopic == 'payroll') {
        role = AIChatRole.payroll;
      } else if (targetTopic == 'welfare') {
        role = AIChatRole.welfare;
      } else {
        role = AIChatRole.erp;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AIChatPage(role: role)),
      );
    }
  }
}
