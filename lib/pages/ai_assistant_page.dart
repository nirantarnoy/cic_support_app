import 'package:flutter/material.dart';
import 'package:flutter_cic_support/pages/ai_chat_page.dart';
import 'package:flutter_cic_support/pages/ai_it_chat_page.dart';

class AIAssistantPage extends StatelessWidget {
  static const routeName = 'ai_assistant_page';

  const AIAssistantPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Assistant',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8A2387),
                      Color(0xFFE94057),
                      Color(0xFFF27121),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE94057).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 30),
                        SizedBox(width: 10),
                        Text(
                          'สวัสดีครับ! ผมคือผู้ช่วย AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Prompt',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ยินดีต้อนรับสู่ระบบผู้ช่วยอัจฉริยะ คุณต้องการสอบถามหรือขอคำแนะนำในด้านใดเป็นพิเศษในวันนี้ครับ?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontFamily: 'Prompt',
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'เลือกหัวข้อที่ต้องการบริการ',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Prompt',
                ),
              ),
              const SizedBox(height: 15),
              // Option Cards
              _buildRoleCard(
                context: context,
                title: 'ข้อมูลส่วนตัว & Payroll',
                subtitle: 'สอบถามสลิปเงินเดือนล่าสุด, ภาษี, วันคงเหลือ และสิทธิวันลาต่างๆ',
                icon: Icons.badge,
                gradientColors: [
                  const Color(0xFF4A5AE7),
                  const Color(0xFF6B8DF8),
                ],
                role: AIChatRole.payroll,
              ),
              const SizedBox(height: 15),
              _buildRoleCard(
                context: context,
                title: 'เงินกู้ & สวัสดิการพนักงาน',
                subtitle: 'ตรวจสอบสิทธิ์เงินกู้พนักงาน, กองทุนสำรองเลี้ยงชีพ และสวัสดิการอื่นๆ',
                icon: Icons.monetization_on,
                gradientColors: [
                  const Color(0xFFFF7E36),
                  const Color(0xFFFFAD3B),
                ],
                role: AIChatRole.welfare,
              ),
              const SizedBox(height: 15),
              _buildRoleCard(
                context: context,
                title: 'ข้อมูลผลิตเชิงลึก (ERP)',
                subtitle: 'วิเคราะห์ยอดการผลิตประจำวัน, คลังสินค้า และข้อมูลวัตถุดิบฝ่ายผลิต',
                icon: Icons.factory,
                gradientColors: [
                  const Color(0xFF0F9B73),
                  const Color(0xFF2EC89F),
                ],
                role: AIChatRole.erp,
              ),
              const SizedBox(height: 15),
              _buildRoleCard(
                context: context,
                title: 'งานระบบ IT',
                subtitle: 'แจ้งปัญหาคอมพิวเตอร์, ระบบเครือข่าย, ขอสิทธิ์ใช้งาน หรือสอบถามปัญหาระบบไอทีต่างๆ',
                icon: Icons.computer,
                gradientColors: [
                  const Color(0xFF8E2DE2),
                  const Color(0xFF4A00E0),
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AIITChatPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),
              // Disclaimer Note
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber.shade800,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'หมายเหตุ: เป็นข้อมูลสำหรับทดสอบเพื่อเตรียมความพร้อมสำหรับนำ AI มาใช้งานเท่านั้น',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontFamily: 'Prompt',
                          height: 1.4,
                        ),
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
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    AIChatRole? role,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? () {
              if (role != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AIChatPage(role: role),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Icon Container with gradient
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 15),
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Prompt',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontFamily: 'Prompt',
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey.shade400,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
