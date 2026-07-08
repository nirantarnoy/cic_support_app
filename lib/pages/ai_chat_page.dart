import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_cic_support/widgets/ai_chat_drawer.dart';
import 'package:flutter_cic_support/utils/table_exporter.dart';

enum AIChatRole {
  payroll,
  welfare,
  erp
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final Widget? customCard;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.customCard,
  });
}

class AIChatPage extends StatefulWidget {
  final AIChatRole role;

  const AIChatPage({Key? key, required this.role}) : super(key: key);

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addInitialGreeting();
  }

  void _addInitialGreeting() {
    String greetingText = "";
    switch (widget.role) {
      case AIChatRole.payroll:
        greetingText = "สวัสดีครับ ผมคือผู้ช่วย AI ด้านข้อมูลส่วนตัวและ Payroll ยินดีต้อนรับครับ! คุณสามารถสอบถามข้อมูลสลิปเงินเดือนล่าสุด สิทธิ์วันคงเหลือ หรือการคำนวณภาษีได้ทันทีครับ";
        break;
      case AIChatRole.welfare:
        greetingText = "สวัสดีครับ ผมคือผู้ช่วย AI ด้านเงินกู้และสวัสดิการพนักงาน ยินดีต้อนรับครับ! คุณสามารถตรวจสอบเงื่อนไข วงเงินกู้สวัสดิการ กองทุนสำรองเลี้ยงชีพ หรือสิทธิต่างๆ ได้ครับ";
        break;
      case AIChatRole.erp:
        greetingText = "สวัสดีครับ ผมคือผู้ช่วย AI ด้านวิเคราะห์ข้อมูลผลิตเชิงลึกและดึงข้อมูล ERP ยินดีต้อนรับครับ! คุณสามารถขอดูสรุปยอดการผลิตวันนี้ สัญญาณการผลิต หรือปริมาณวัตถุดิบคงคลังได้เลยครับ";
        break;
    }

    _messages.add(ChatMessage(
      text: greetingText,
      isMe: false,
      timestamp: DateTime.now(),
    ));
  }

  String _getRoleTitle() {
    switch (widget.role) {
      case AIChatRole.payroll:
        return "AI Payroll Assistant";
      case AIChatRole.welfare:
        return "AI Welfare & Loans";
      case AIChatRole.erp:
        return "AI ERP & Production";
    }
  }

  List<Color> _getRoleColors() {
    switch (widget.role) {
      case AIChatRole.payroll:
        return [const Color(0xFF4A5AE7), const Color(0xFF6B8DF8)];
      case AIChatRole.welfare:
        return [const Color(0xFFFF7E36), const Color(0xFFFFAD3B)];
      case AIChatRole.erp:
        return [const Color(0xFF0F9B73), const Color(0xFF2EC89F)];
    }
  }

  IconData _getRoleIcon() {
    switch (widget.role) {
      case AIChatRole.payroll:
        return Icons.badge;
      case AIChatRole.welfare:
        return Icons.monetization_on;
      case AIChatRole.erp:
        return Icons.factory;
    }
  }

  List<String> _getSuggestedQuestions() {
    switch (widget.role) {
      case AIChatRole.payroll:
        return [
          "ขอดูสลิปเงินเดือนล่าสุดหน่อยครับ",
          "ปีนี้ผมเหลือสิทธิ์วันลาพักร้อนกี่วัน?",
          "ขอหนังสือรับรองเงินเดือนแบบดิจิทัล"
        ];
      case AIChatRole.welfare:
        return [
          "สิทธิ์เงินกู้พนักงานขอยื่นกู้ได้สูงสุดเท่าไหร่?",
          "เงื่อนไขการกู้เงินสวัสดิการฉุกเฉินมีอะไรบ้าง?",
          "ตรวจสอบสถานะการสมทบกองทุนสำรองเลี้ยงชีพ"
        ];
      case AIChatRole.erp:
        return [
          "สรุปยอดรายงานการผลิตวันนี้และสถานะไลน์ผลิต",
          "ตรวจสอบวัตถุดิบคงคลังของฝ่ายผลิตยาง",
          "พบปัญหายอด Reject สูงผิดปกติที่ไลน์ 3 หรือไม่?"
        ];
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isMe: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate AI response
    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _generateAIResponse(text);
      });
      _scrollToBottom();
    });
  }

  void _generateAIResponse(String userQuestion) {
    String responseText = "";
    Widget? customCard;

    if (widget.role == AIChatRole.payroll) {
      if (userQuestion.contains("เงินเดือน") || userQuestion.contains("สลิป")) {
        responseText = "นี่คือข้อมูลสรุปสลิปเงินเดือนประจำงวดล่าสุดของคุณครับ ระบบทำการดึงข้อมูลเข้าสู่แพลตฟอร์มแล้ว:";
        customCard = _buildPayslipCard();
      } else if (userQuestion.contains("วันลา") || userQuestion.contains("พักร้อน")) {
        responseText = "จากการตรวจสอบสิทธิ์วันลาพักร้อนประจำปีของคุณ รายละเอียดโควต้าและวันลาคงเหลือมีดังนี้ครับ:";
        customCard = _buildLeaveDaysCard();
      } else if (userQuestion.contains("หนังสือรับรอง")) {
        responseText = "ระบบออกหนังสือรับรองเงินเดือนดิจิทัลเรียบร้อยแล้วครับ คุณสามารถคลิกเพื่อดาวน์โหลดหรือส่งอีเมลฉบับนี้ได้เลย:";
        customCard = _buildSalaryCertificateCard();
      } else {
        responseText = "ผมได้รับคำถาม: '$userQuestion' ข้อมูลนี้เกี่ยวข้องกับ Payroll โดยตรง ทางผู้ช่วย AI กำลังประสานงานระบบหลัก หากต้องการดูสลิปเงินเดือนหรือวันลา สามารถเลือกปุ่มแนะนำได้ครับ";
      }
    } else if (widget.role == AIChatRole.welfare) {
      if (userQuestion.contains("สูงสุด") || userQuestion.contains("วงเงิน")) {
        responseText = "ระบบสวัสดิการได้วิเคราะห์จากอายุงานและฐานเงินเดือนของคุณแล้ว นี่คือสิทธิ์วงเงินกู้สูงสุดของคุณครับ:";
        customCard = _buildWelfareLoanCard();
      } else if (userQuestion.contains("เงื่อนไข") || userQuestion.contains("ฉุกเฉิน")) {
        responseText = "นี่คือหลักเกณฑ์และเงื่อนไขสำหรับการกู้เงินสวัสดิการฉุกเฉินพนักงานครับ:";
        customCard = _buildEmergencyLoanInfoCard();
      } else if (userQuestion.contains("กองทุน") || userQuestion.contains("สำรอง")) {
        responseText = "นี่คือสรุปยอดสะสมและอัตราสมทบกองทุนสำรองเลี้ยงชีพ (Provident Fund) ล่าสุดของคุณครับ:";
        customCard = _buildProvidentFundCard();
      } else {
        responseText = "ผมบันทึกคำถามสวัสดิการพนักงาน: '$userQuestion' ไว้แล้วครับ คุณสามารถคลิกที่เมนูแนะนำเพื่อสอบถามเงื่อนไขเงินกู้สวัสดิการ หรือเช็คสิทธิ์กองทุนสำรองเลี้ยงชีพได้อย่างรวดเร็วครับ";
      }
    } else if (widget.role == AIChatRole.erp) {
      if (userQuestion.contains("สรุปยอด") || userQuestion.contains("รายงาน")) {
        responseText = "เชื่อมต่อระบบ ERP สำเร็จ ดึงรายงานข้อมูลผลิตแบบเรียลไทม์ล่าสุด:";
        customCard = _buildErpProductionCard();
      } else if (userQuestion.contains("วัตถุดิบ") || userQuestion.contains("คงคลัง")) {
        responseText = "ข้อมูลปริมาณวัตถุดิบหลักคงเหลือในโกดัง (Warehouse) วันนี้ ดึงข้อมูลโดยตรงจากระบบ ERP:";
        customCard = _buildErpInventoryCard();
      } else if (userQuestion.contains("Reject") || userQuestion.contains("ไลน์ 3")) {
        responseText = "รายงานแจ้งเตือนการสูญเสีย (Quality Loss Alert) จากไลน์ผลิตที่ 3 ประจำกะงานวันนี้:";
        customCard = _buildErpRejectCard();
      } else {
        responseText = "ดึงข้อมูลจากระบบ ERP เพื่อประมวลผลคำถาม: '$userQuestion' สำเร็จ หากต้องการดูแดชบอร์ดสรุปยอดผลิตหรือวัตถุดิบคงคลัง สามารถเลือกจากคำถามที่แนะนำได้ครับ";
      }
    }

    _messages.add(ChatMessage(
      text: responseText,
      isMe: false,
      timestamp: DateTime.now(),
      customCard: customCard,
    ));
  }

  // --- UI Card Builders for Mock Data (Payroll, Welfare, ERP) ---

  Widget _buildPayslipCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6ED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ใบจ่ายเงินเดือน (มิถุนายน 2026)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Prompt'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "จ่ายแล้ว",
                  style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Prompt'),
                ),
              )
            ],
          ),
          const Divider(height: 20),
          _buildRowItem("เงินเดือนพื้นฐาน", "฿35,000.00"),
          _buildRowItem("ค่าล่วงเวลา (OT)", "฿4,500.00"),
          _buildRowItem("เบี้ยขยัน & เงินเพิ่ม", "฿1,200.00"),
          _buildRowItem("หักประกันสังคม (SSO)", "-฿750.00", isNegative: true),
          _buildRowItem("หักภาษี ณ ที่จ่าย", "-฿1,400.00", isNegative: true),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "รายรับสุทธิ (Net Pay)",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14, fontFamily: 'Prompt'),
              ),
              Text(
                "฿38,550.00",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A5AE7), fontSize: 16, fontFamily: 'Prompt'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 16, color: Colors.white),
              label: const Text("ดาวน์โหลดสลิป PDF", style: TextStyle(fontFamily: 'Prompt', fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A5AE7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLeaveDaysCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "สิทธิ์วันลาคงเหลือปี 2026",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Prompt'),
          ),
          const SizedBox(height: 12),
          _buildLeaveProgress("ลาพักร้อนประจำปี", 8, 12, Colors.blue),
          const SizedBox(height: 10),
          _buildLeaveProgress("ลากิจได้รับค่าจ้าง", 5, 6, Colors.amber),
          const SizedBox(height: 10),
          _buildLeaveProgress("ลาป่วย", 28, 30, Colors.green),
        ],
      ),
    );
  }

  Widget _buildSalaryCertificateCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6ED)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.picture_as_pdf, color: Colors.red.shade600, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "หนังสือรับรองเงินเดือน.pdf",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Prompt'),
                ),
                Text(
                  "ออกโดยระบบออโต้ • ขนาด 245 KB",
                  style: TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Prompt'),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF4A5AE7)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildWelfareLoanCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6ED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "สิทธิ์วงเงินกู้สวัสดิการของคุณ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Prompt'),
          ),
          const Divider(height: 20),
          _buildRowItem("ฐานเงินเดือน", "฿35,000.00"),
          _buildRowItem("อายุงานในระบบ", "3 ปี 4 เดือน"),
          _buildRowItem("อัตราดอกเบี้ยพิเศษ", "3.5% ต่อปี"),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "วงเงินกู้สูงสุดที่อนุมัติ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Prompt'),
              ),
              Text(
                "฿150,000.00",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF7E36), fontSize: 15, fontFamily: 'Prompt'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("หลักเกณฑ์เพิ่มเติม", style: TextStyle(fontFamily: 'Prompt', fontSize: 11)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7E36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("เริ่มยื่นคำขอออนไลน์", style: TextStyle(fontFamily: 'Prompt', fontSize: 11, color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmergencyLoanInfoCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFF7E36), size: 18),
              SizedBox(width: 6),
              Text(
                "หลักเกณฑ์กู้ฉุกเฉิน (Emergency Loan)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Prompt'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "1. วงเงินกู้จำกัดไม่เกิน 50% ของเงินเดือนพื้นฐาน หรือสูงสุดไม่เกิน 20,000 บาท\n"
            "2. ผ่อนชำระคืนสูงสุดไม่เกิน 6 งวด โดยหักตรงจากสลิปเงินเดือน\n"
            "3. ไม่คิดอัตราดอกเบี้ย (0% ดอกเบี้ยเพื่อช่วยเหลือกรณีจำเป็นฉุกเฉิน)\n"
            "4. ต้องแนบหลักฐานความจำเป็น (เช่น ใบรับรองแพทย์ หรือ ใบเสนอราคาซ่อมบ้าน)",
            style: TextStyle(color: Colors.black87, fontSize: 11, fontFamily: 'Prompt', height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildProvidentFundCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "ยอดสะสมกองทุนสำรองเลี้ยงชีพ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Prompt'),
              ),
              Text(
                "สถานะ: มีผล",
                style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Prompt'),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildRowItem("เงินสะสม (ส่วนของพนักงาน 5%)", "฿42,500.00"),
          _buildRowItem("เงินสมทบ (ส่วนของบริษัท 5%)", "฿42,500.00"),
          _buildRowItem("ผลประโยชน์จากยอดเงินสะสม", "฿3,820.00"),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "ยอดรวมสุทธิ (Total Balance)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Prompt'),
              ),
              Text(
                "฿88,820.00",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15, fontFamily: 'Prompt'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErpProductionCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6ED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "สรุปการผลิตประจำวัน (ERP Direct)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Prompt'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "เรียลไทม์",
                  style: TextStyle(color: Colors.green.shade700, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Prompt'),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          _buildRowItem("ยอดผลิตได้วันนี้ (Target 15,000)", "14,200 ชิ้น"),
          _buildRowItem("เปอร์เซ็นต์สำเร็จการผลิต", "94.6%"),
          _buildRowItem("อัตราคุณภาพดี (Good Rate)", "99.1%"),
          _buildRowItem("เครื่องจักรทำงานปกติ / เสียหาย", "5 เครื่อง / 0 เครื่อง"),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildErpStatBox("ไลน์ 1", "สำเร็จ 98%", Colors.green),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildErpStatBox("ไลน์ 2", "สำเร็จ 95%", Colors.green),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildErpStatBox("ไลน์ 3 (Maintenance)", "สำเร็จ 80%", Colors.red),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildErpInventoryCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "สต๊อกวัตถุดิบและยอดคงคลัง (ERP Stocks)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Prompt'),
          ),
          const Divider(height: 16),
          _buildInventoryRow("วัตถุดิบยางธรรมชาติ (เกรด A)", "8.2 ตัน", "ใช้งานได้ 4 วัน", Colors.amber),
          const SizedBox(height: 8),
          _buildInventoryRow("ลวดเหล็กสปริง (เกรดมาตรฐาน)", "12.4 ตัน", "ใช้งานได้ 9 วัน", Colors.green),
          const SizedBox(height: 8),
          _buildInventoryRow("เขม่าดำผสมคอมพาวด์ (Carbon Black)", "1.1 ตัน", "เตือน: ต่ำกว่า Safety Stock", Colors.red),
        ],
      ),
    );
  }

  Widget _buildErpRejectCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade800),
              const SizedBox(width: 8),
              Text(
                "การตรวจพบความผิดปกติ (Quality Reject Alert)",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800, fontSize: 13, fontFamily: 'Prompt'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "ในระบบ ERP พบบันทึกยอด Reject ที่ไลน์ผลิตที่ 3 (กะเช้า) สะสมจำนวน 120 ชิ้น ซึ่งสูงกว่าเกณฑ์ควบคุมคุณภาพปกติ (KPI < 1.0%) ล่าสุดทีมช่างตรวจสอบพบความร้อนของแท่นพิมพ์เพี้ยนจากเป้าหมาย 5 องศาเซลเซียส ปัจจุบันแก้ไขเรียบร้อยแล้วและควบคุมคุณภาพกลับสู่ระดับปกติ",
            style: TextStyle(color: Colors.red.shade900, fontSize: 11, fontFamily: 'Prompt', height: 1.4),
          ),
        ],
      ),
    );
  }

  // --- Helper Card Widget Subsections ---

  Widget _buildRowItem(String label, String value, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 12, fontFamily: 'Prompt'),
          ),
          Text(
            value,
            style: TextStyle(
              color: isNegative ? Colors.red : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: 'Prompt',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveProgress(String label, int used, int total, Color color) {
    double progress = used / total;
    int remaining = total - used;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'Prompt')),
            Text("ใช้ไป $used / ทั้งหมด $total วัน (คงเหลือ $remaining)",
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Prompt')),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildErpStatBox(String title, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Prompt')),
          const SizedBox(height: 2),
          Text(status, style: TextStyle(color: color, fontSize: 9, fontFamily: 'Prompt')),
        ],
      ),
    );
  }

  Widget _buildInventoryRow(String materialName, String amount, String statusText, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(materialName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Prompt')),
              Text(statusText, style: TextStyle(color: statusColor, fontSize: 9, fontFamily: 'Prompt')),
            ],
          ),
        ),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Prompt')),
      ],
    );
  }

  // --- End Helper Card Widget Subsections ---

  @override
  Widget build(BuildContext context) {
    final colors = _getRoleColors();
    String currentTopic = 'payroll';
    if (widget.role == AIChatRole.welfare) {
      currentTopic = 'welfare';
    } else if (widget.role == AIChatRole.erp) {
      currentTopic = 'erp';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: AIChatDrawer(currentTopic: currentTopic),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getRoleTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Message Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Typing indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8, top: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colors[0].withOpacity(0.1),
                    radius: 14,
                    child: Icon(_getRoleIcon(), color: colors[0], size: 14),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "AI กำลังวิเคราะห์ข้อมูล...",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontFamily: 'Prompt'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Suggested Questions Selection
          if (!_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.transparent,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: _getSuggestedQuestions().map((question) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(
                          question,
                          style: TextStyle(
                            color: colors[0],
                            fontSize: 11,
                            fontFamily: 'Prompt',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: colors[0].withOpacity(0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: colors[0].withOpacity(0.2)),
                        ),
                        onPressed: () => _handleSubmitted(question),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Chat Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        onSubmitted: _handleSubmitted,
                        style: const TextStyle(fontSize: 14, fontFamily: 'Prompt'),
                        decoration: const InputDecoration(
                          hintText: 'พิมพ์คำถามของคุณตรงนี้...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Prompt'),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _handleSubmitted(_textController.text),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showRepeatQuestionDialog(String content) {
    final colors = _getRoleColors();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.replay_circle_filled_rounded, color: colors[0]),
              const SizedBox(width: 8),
              const Text(
                'ถามซ้ำอีกครั้ง',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'คุณต้องการส่งคำถามนี้เพื่อถามซ้ำอีกครั้งหรือไม่?\n\n"$content"',
            style: const TextStyle(
              fontFamily: 'Prompt',
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'ยกเลิก',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleSubmitted(content);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors[0],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'ยืนยัน',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final colors = _getRoleColors();
    final bubbleColor = message.isMe ? colors[0] : Colors.white;
    final textColor = message.isMe ? Colors.white : Colors.black87;
    final alignment = message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleBorder = message.isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              if (!message.isMe) ...[
                CircleAvatar(
                  backgroundColor: colors[0].withOpacity(0.1),
                  radius: 15,
                  child: Icon(_getRoleIcon(), color: colors[0], size: 14),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: GestureDetector(
                  onLongPress: message.text.isNotEmpty
                      ? () => _showRepeatQuestionDialog(message.text)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: bubbleBorder,
                      border: message.isMe
                          ? null
                          : Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          height: 1.4,
                          fontFamily: 'Prompt',
                        ),
                        tableHead: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Prompt',
                        ),
                        tableBody: TextStyle(
                          color: textColor,
                          fontSize: 11,
                          fontFamily: 'Prompt',
                        ),
                        tableBorder: TableBorder.all(
                          color: message.isMe ? Colors.white.withOpacity(0.5) : Colors.grey.shade300,
                          width: 1,
                        ),
                        tableCellsPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (message.customCard != null)
            Padding(
              padding: EdgeInsets.only(left: message.isMe ? 0 : 38.0),
              child: message.customCard!,
            ),
          if (!message.isMe && TableExporter.hasTable(message.text))
            Padding(
              padding: const EdgeInsets.only(left: 38.0, top: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final success = await TableExporter.exportTable(message.text, 'ai_report');
                      if (!mounted) return;
                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'ไม่พบข้อมูลตารางหรือเกิดข้อผิดพลาดในการดาวน์โหลด',
                              style: TextStyle(fontFamily: 'Prompt'),
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: colors[0].withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colors[0].withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.download_rounded,
                            size: 14,
                            color: colors[0],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ดาวน์โหลดตาราง (CSV)',
                            style: TextStyle(
                              color: colors[0],
                              fontSize: 11,
                              fontFamily: 'Prompt',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
