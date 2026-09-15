import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchaseApproveDetailPage extends StatefulWidget {
  final Map<String, dynamic> requestData;

  const PurchaseApproveDetailPage({Key? key, required this.requestData}) : super(key: key);

  @override
  State<PurchaseApproveDetailPage> createState() => _PurchaseApproveDetailPageState();
}

class _PurchaseApproveDetailPageState extends State<PurchaseApproveDetailPage> {
  // Demo Items Data
  final List<Map<String, dynamic>> _demoItems = [
    {
      'product_name': 'คอมพิวเตอร์ Notebook (Dell Latitude 3420)',
      'qty': 1,
      'unit': 'เครื่อง',
      'price': 15000.00,
      'remark': 'สำหรับพนักงานใหม่',
    },
    {
      'product_name': 'เมาส์ไร้สาย Logitech',
      'qty': 1,
      'unit': 'อัน',
      'price': 500.00,
      'remark': '',
    }
  ];

  final List<Map<String, String>> _demoAttachments = [
    {'name': 'ใบเสนอราคา_Dell.pdf', 'size': '1.2 MB'},
    {'name': 'เอกสารเปรียบเทียบราคา.pdf', 'size': '800 KB'},
  ];

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
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ส่งตีกลับเรียบร้อยแล้ว')),
                        );
                        Navigator.pop(context);
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
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isApprove ? 'อนุมัติรายการเรียบร้อย' : 'ไม่อนุมัติรายการเรียบร้อย')),
                        );
                        Navigator.pop(context);
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
          widget.requestData['id'],
          style: const TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
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
                            Expanded(child: _buildInfoColumn('ผู้ขอ', widget.requestData['requestor'])),
                            Expanded(child: _buildInfoColumn('แผนก', widget.requestData['department'])),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildInfoColumn('วันที่ขอ', widget.requestData['date'])),
                            Expanded(child: _buildInfoColumn('สถานะ', widget.requestData['status'], valueColor: const Color(0xFFFF7E36))),
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
                          child: const Text(
                            'พนักงานใหม่แผนก IT และทดแทนของเดิมที่ชำรุด',
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
                    itemCount: _demoItems.length,
                    itemBuilder: (context, index) {
                      final item = _demoItems[index];
                      final total = item['price'] * item['qty'];
                      
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
                                      item['product_name'],
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
                                  _buildInfoColumn('ราคา/หน่วย', formatter.format(item['price'])),
                                  _buildInfoColumn('ราคารวม', formatter.format(total)),
                                ],
                              ),
                              if ((item['remark'] as String).isNotEmpty) ...[
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
                          '฿${formatter.format(widget.requestData['total'])}',
                          style: const TextStyle(fontFamily: 'Prompt', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F9B73)),
                        ),
                      ],
                    ),
                  ),
                  
                  // Attachments Section
                  if (widget.requestData['has_attachment'] == true) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'ไฟล์แนบ',
                      style: TextStyle(fontFamily: 'Prompt', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    ..._demoAttachments.map((file) => GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('กำลังเปิดไฟล์ ${file['name']} ...')),
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
                                    file['name']!,
                                    style: const TextStyle(fontFamily: 'Prompt', fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    file['size']!,
                                    style: const TextStyle(fontFamily: 'Prompt', fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.download_rounded, color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                    )).toList(),
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
      ),
    );
  }
}
