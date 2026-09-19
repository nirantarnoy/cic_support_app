import 'package:flutter/material.dart';
import 'package:flutter_cic_support/providers/purchase_approve.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PurchaseApproveDetailPage extends StatefulWidget {
  final Map<String, dynamic> requestData;

  const PurchaseApproveDetailPage({Key? key, required this.requestData}) : super(key: key);

  @override
  State<PurchaseApproveDetailPage> createState() => _PurchaseApproveDetailPageState();
}

class _PurchaseApproveDetailPageState extends State<PurchaseApproveDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int prId = widget.requestData['pr_id'] ?? 0;
      if (prId > 0) {
        Provider.of<PurchaseApproveProvider>(context, listen: false).fetchPrDetail(prId);
      }
    });
  }

  Widget _buildInfoColumn(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Prompt',
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Prompt',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showReturnDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.reply_rounded, color: Colors.orange.shade800),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'ตีกลับรายการ',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'ระบุเหตุผลที่ตีกลับให้ผู้ขอแก้ไข:',
                style: TextStyle(fontFamily: 'Prompt', fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'เช่น กรุณาแนบใบเสนอราคาใหม่',
                  hintStyle: const TextStyle(fontFamily: 'Prompt', color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('ยกเลิก', style: TextStyle(fontFamily: 'Prompt', color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade400,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        EasyLoading.show(status: 'กำลังดำเนินการ...');
                        final success = await Provider.of<PurchaseApproveProvider>(context, listen: false).actionPr(
                          widget.requestData['pr_id'] ?? 0,
                          '3', // RETURN
                          reasonController.text,
                        );
                        EasyLoading.dismiss();
                        if (!context.mounted) return;
                        if (success) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext successContext) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle, color: Color(0xFF0F9B73), size: 60),
                                    const SizedBox(height: 16),
                                    const Text('สำเร็จ', style: TextStyle(fontFamily: 'Prompt', fontSize: 20, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    const Text('ส่งตีกลับเรียบร้อยแล้ว', style: TextStyle(fontFamily: 'Prompt', fontSize: 14)),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F9B73),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        minimumSize: const Size(double.infinity, 45),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(successContext);
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text('ตกลง', style: TextStyle(fontFamily: 'Prompt', color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('เกิดข้อผิดพลาดในการทำรายการ')),
                          );
                        }
                      },
                      child: const Text('ยืนยันตีกลับ', style: TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext parentContext, bool isApprove) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                isApprove ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                size: 64,
                color: isApprove ? const Color(0xFF0F9B73) : Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'ยืนยันการทำรายการ',
                style: TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                isApprove ? 'ต้องการ "อนุมัติ" รายการนี้ใช่หรือไม่?' : 'ต้องการ "ไม่อนุมัติ" รายการนี้ใช่หรือไม่?',
                style: const TextStyle(fontFamily: 'Prompt', fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('ยกเลิก', style: TextStyle(fontFamily: 'Prompt', color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isApprove ? const Color(0xFF0F9B73) : Colors.red.shade400,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        final actionStr = isApprove ? '1' : '2'; // 1=APPROVE, 2=REJECT
                        EasyLoading.show(status: 'กำลังดำเนินการ...');
                        final success = await Provider.of<PurchaseApproveProvider>(parentContext, listen: false).actionPr(
                          widget.requestData['pr_id'] ?? 0,
                          actionStr,
                          '',
                        );
                        EasyLoading.dismiss();
                        if (!parentContext.mounted) return;
                        if (success) {
                          showDialog(
                            context: parentContext,
                            barrierDismissible: false,
                            builder: (BuildContext successContext) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle, color: Color(0xFF0F9B73), size: 60),
                                    const SizedBox(height: 16),
                                    const Text('สำเร็จ', style: TextStyle(fontFamily: 'Prompt', fontSize: 20, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text(isApprove ? 'อนุมัติรายการเรียบร้อย' : 'ไม่อนุมัติรายการเรียบร้อย', style: const TextStyle(fontFamily: 'Prompt', fontSize: 14)),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F9B73),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        minimumSize: const Size(double.infinity, 45),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(successContext);
                                        Navigator.pop(parentContext, true);
                                      },
                                      child: const Text('ตกลง', style: TextStyle(fontFamily: 'Prompt', color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            const SnackBar(content: Text('เกิดข้อผิดพลาดในการทำรายการ')),
                          );
                        }
                      },
                      child: const Text('ยืนยัน', style: TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryModal(BuildContext context, List history) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.black87),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'ประวัติการดำเนินการ',
              style: TextStyle(
                color: Colors.black87,
                fontFamily: 'Prompt',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final h = history[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (index != history.length - 1)
                          Container(
                            width: 2,
                            height: 60,
                            color: Colors.indigo.shade100,
                            margin: const EdgeInsets.only(top: 4),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${h['action_type']} โดย ${h['action_by']}',
                            style: const TextStyle(fontFamily: 'Prompt', fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          if (h['remark'] != null && h['remark'].toString().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              h['remark'],
                              style: const TextStyle(fontFamily: 'Prompt', fontSize: 13, color: Colors.black87),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            h['action_date'] ?? '',
                            style: const TextStyle(fontFamily: 'Prompt', fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
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
        title: Text(
          widget.requestData['pr_no'] ?? '',
          style: const TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PurchaseApproveProvider>(
        builder: (context, provider, child) {
          if (provider.isDetailLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0F9B73)));
          }

          final detail = provider.currentPrDetail ?? {};
          final lines = (detail['lines'] as List<dynamic>?) ?? [];
          final attachments = (detail['attachments'] as List<dynamic>?) ?? [];

          return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ข้อมูลผู้ขอซื้อ',
                          style: TextStyle(fontFamily: 'Prompt', fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildInfoColumn('ผู้ขอ', detail['requestor_name'] ?? '')),
                            Expanded(child: _buildInfoColumn('แผนก', detail['req_dept'] ?? '')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildInfoColumn('วันที่ขอ', detail['request_date'] ?? '')),
                            Expanded(child: _buildInfoColumn('สถานะ', detail['status'] ?? '', valueColor: const Color(0xFFFF7E36))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'เหตุผลในการขอซื้อ',
                          style: TextStyle(fontFamily: 'Prompt', fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            detail['remark'] ?? '-',
                            style: TextStyle(fontFamily: 'Prompt', fontSize: 13, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  const Text(
                    'รายการขอซื้อ',
                    style: TextStyle(fontFamily: 'Prompt', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  
                  // Items List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lines.length,
                    itemBuilder: (context, index) {
                      final item = lines[index];
                      final total = item['total_price'] ?? 0.0;
                      final pricePerUnit = item['price_per_unit'] ?? 0.0;
                      
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8E24AA).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.inventory_rounded, color: Color(0xFF8E24AA)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item['description'] ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'Prompt',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoColumn('จำนวน', '${item['qty']} ${item['unit']}'),
                                  _buildInfoColumn('ราคา/หน่วย', formatter.format(pricePerUnit)),
                                  _buildInfoColumn('ราคารวม', formatter.format(total)),
                                ],
                              ),
                              if ((item['remark'] ?? '').toString().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.notes_rounded, size: 14, color: Colors.orange.shade800),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'หมายเหตุ: ${item['remark']}',
                                          style: TextStyle(
                                            fontFamily: 'Prompt',
                                            fontSize: 12,
                                            color: Colors.orange.shade900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Total Amount
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F9B73).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF0F9B73).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ยอดรวมทั้งสิ้น',
                          style: TextStyle(fontFamily: 'Prompt', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F9B73)),
                        ),
                        Text(
                          '฿${formatter.format(detail['total_amount'] ?? 0)}',
                          style: const TextStyle(fontFamily: 'Prompt', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F9B73)),
                        ),
                      ],
                    ),
                  ),
                  
                  // Attachments Section
                  if (attachments.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'ไฟล์แนบ',
                      style: TextStyle(fontFamily: 'Prompt', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    ...attachments.map((file) => GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('กำลังเปิดไฟล์ ${file['file_name']} ...')),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.picture_as_pdf_rounded, color: Colors.red.shade400, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file['file_name'] ?? 'เอกสารแนบ',
                                    style: const TextStyle(fontFamily: 'Prompt', fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  // Text(
                                  //   file['size'] ?? '',
                                  //   style: const TextStyle(fontFamily: 'Prompt', fontSize: 11, color: Colors.grey),
                                  // ),
                                ],
                              ),
                            ),
                            const Icon(Icons.download_rounded, color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                    )).toList(),
                  ],

                  // History / Timeline Section
                  if (detail['history'] != null && (detail['history'] as List).isNotEmpty) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.indigo.shade200, width: 1.5),
                        ),
                        icon: Icon(Icons.history_rounded, color: Colors.indigo.shade500),
                        label: Text(
                          'ดูประวัติการดำเนินการ',
                          style: TextStyle(fontFamily: 'Prompt', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo.shade600),
                        ),
                        onPressed: () => _showHistoryModal(context, detail['history'] as List),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade600,
                        side: BorderSide(color: Colors.orange.shade400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _showReturnDialog(context),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.reply_rounded, size: 18),
                          SizedBox(height: 2),
                          Text('ตีกลับ', style: TextStyle(fontFamily: 'Prompt', fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () => _showConfirmDialog(context, false),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cancel_outlined, size: 18, color: Colors.white),
                          SizedBox(height: 2),
                          Text('ไม่อนุมัติ', style: TextStyle(fontFamily: 'Prompt', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F9B73),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () => _showConfirmDialog(context, true),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.white),
                          SizedBox(height: 2),
                          Text('อนุมัติ', style: TextStyle(fontFamily: 'Prompt', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
        },
      ),
    );
  }
}
