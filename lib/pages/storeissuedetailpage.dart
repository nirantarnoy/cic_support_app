import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/storeissueline.dart';
import 'package:flutter_cic_support/pages/profile.dart';
import 'package:flutter_cic_support/pages/storeissueapprove.dart';
import 'package:flutter_cic_support/providers/storeissue.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class StoreissuedetailPage extends StatefulWidget {
  final issue_id;
  final team_id;
  StoreissuedetailPage({Key? key, this.issue_id, this.team_id})
      : super(key: key);

  @override
  State<StoreissuedetailPage> createState() => _StoreissuedetailPageState();
}

class _StoreissuedetailPageState extends State<StoreissuedetailPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.issue_id != null) {
      EasyLoading.show(status: "Loading ....");
      Provider.of<StoreissueData>(context, listen: false)
          .fetchIssueline(widget.issue_id);
      EasyLoading.dismiss();
    }
  }

  Widget _buildDetail(List<Storeissueline> _list) {
    if (_list.isEmpty) {
      return const Center(
        child: Text(
          'ไม่มีข้อมูลรายการสินค้า',
          style: TextStyle(fontFamily: 'Prompt', color: Colors.grey, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _list.length,
      itemBuilder: (context, index) {
        final item = _list[index];
        final price = double.tryParse(item.price) ?? 0.0;
        final qty = double.tryParse(item.qty) ?? 0.0;
        final total = price * qty;
        final formatter = NumberFormat('#,##0');
        
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F9B73).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF0F9B73)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product_name.trim(),
                            style: const TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'รหัส: ${item.product_id}',
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn('จำนวน', '${item.qty} ${item.unit_name}'),
                    _buildInfoColumn('ราคา/หน่วย', formatter.format(price)),
                    _buildInfoColumn('ราคารวม', formatter.format(total)),
                  ],
                ),
                if (item.remark.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notes_rounded, size: 16, color: Colors.orange.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'หมายเหตุ: ${item.remark}',
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 13,
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
    );
  }

  Widget _buildInfoColumn(String label, String value) {
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

  void _showConfirmDialog(BuildContext parentContext, bool isApprove) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
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
                style: TextStyle(fontFamily: 'Prompt', color: Colors.grey.shade600, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.grey.shade200,
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text('ยกเลิก', style: TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: isApprove ? const Color(0xFF0F9B73) : Colors.red.shade400,
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Navigator.of(dialogContext).pop(); // Close confirm dialog
                        
                        if (!parentContext.mounted) return;
                        
                        EasyLoading.show(status: "กำลังบันทึกข้อมูล...");
                        try {
                          bool isSave = await Provider.of<StoreissueData>(parentContext, listen: false)
                              .approveissue(isApprove ? 1 : 3, widget.issue_id.toString());
                          EasyLoading.dismiss();
                          
                          if (!parentContext.mounted) return;
                          
                          if (isSave) {
                            _showSuccessPopup(parentContext);
                          } else {
                            EasyLoading.showError('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
                          }
                        } catch (e) {
                          EasyLoading.dismiss();
                          EasyLoading.showError('เกิดข้อผิดพลาด: $e');
                        }
                      },
                      child: const Text('ยืนยัน', style: TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: Color(0xFF0F9B73),
              ),
              const SizedBox(height: 16),
              const Text(
                'ทำรายการสำเร็จ',
                style: TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'ระบบได้บันทึกข้อมูลของคุณเรียบร้อยแล้ว',
                style: TextStyle(fontFamily: 'Prompt', color: Colors.grey.shade600, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFF0F9B73),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => StoreissueApprovePage(
                                  team_id: widget.team_id == "" ? "" : widget.team_id,
                                )),
                        (Route<dynamic> route) => false);
                  },
                  child: const Text('ตกลง', style: TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'รายละเอียดใบเบิก',
          style: TextStyle(
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
<<<<<<< HEAD
        Expanded(
          flex: 1,
          child: Row(children: [
            Expanded(
                child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 12,
                          ),
                          Icon(
                            Icons.privacy_tip_outlined,
                            size: 32,
                            color: Colors.green.shade400,
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            'ยืนยันการทำรายการ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            'ต้องการดำเนินการต่อใช่หรือไม่ ?',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: MaterialButton(
                                  color: Color.fromARGB(255, 45, 172, 123),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50)),
                                  onPressed: () async {
                                    //  _timer?.cancel();
                                    await EasyLoading.show(
                                        status: "กำลังบันทึกข้อมูล");
                                    try {
                                      bool isSave =
                                          await Provider.of<StoreissueData>(
                                                  context,
                                                  listen: false)
                                              .approveissue(1, widget.issue_id);
                                      if (isSave == true) {
                                        await EasyLoading.showSuccess(
                                            'บันทึกรายการเรียบร้อย');
                                      }
                                    } catch (e) {
                                      EasyLoading.dismiss();
                                      await EasyLoading.showError(e.toString().replaceAll('Exception: ', ''));
                                      Navigator.of(context).pop(); // Close the dialog
                                      return; // Stop execution, don't navigate away
                                    }

                                    EasyLoading.dismiss();
                                    if (widget.team_id == "") {
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  StoreissueApprovePage(
                                                    team_id: "",
                                                  )),
                                          (Route<dynamic> route) => false);
                                    } else {
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  StoreissueApprovePage(
                                                    team_id: widget.team_id,
                                                  )),
                                          (Route<dynamic> route) => false);
                                    }
                                  },
                                  child: Text(
                                    'ใช่',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Expanded(
                                child: MaterialButton(
                                  color: Colors.grey[400],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50)),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text(
                                    'ไม่ใช่',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
=======
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<StoreissueData>(
              builder: (context, _value, _) => _buildDetail(_value.listIssueLine),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
>>>>>>> e22eb7c6d1c95d0455da2e90fabde345106aff56
                      ),
                      onPressed: () => _showConfirmDialog(context, false), // Reject
                      child: const Text('ไม่อนุมัติ', style: TextStyle(fontFamily: 'Prompt', fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
<<<<<<< HEAD
                );
              },
              child: Container(
                color: Colors.green,
                child: Center(child: Text('อนุมัติ')),
              ),
            )),
            Expanded(
              child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 12,
                              ),
                              Icon(
                                Icons.privacy_tip_outlined,
                                size: 32,
                                color: Colors.green.shade400,
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                'ยืนยันการทำรายการ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                'ต้องการดำเนินการต่อใช่หรือไม่ ?',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: MaterialButton(
                                      color: Color.fromARGB(255, 45, 172, 123),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      onPressed: () async {
                                        //  _timer?.cancel();
                                        await EasyLoading.show(
                                            status: "กำลังบันทึกข้อมูล");
                                        bool isSave =
                                            await Provider.of<StoreissueData>(
                                                    context,
                                                    listen: false)
                                                .approveissue(
                                                    3, widget.issue_id);
                                        if (isSave == true) {
                                          await EasyLoading.showSuccess(
                                              'บันทึกรายการเรียบร้อย');

                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             PlancheckcompletePage()));
                                        } catch (e) {
                                          EasyLoading.dismiss();
                                          await EasyLoading.showError(e.toString().replaceAll('Exception: ', ''));
                                          Navigator.of(context).pop(); // Close the dialog
                                          return; // Stop execution, don't navigate away
                                        }
                                        EasyLoading.dismiss();

                                        if (widget.team_id == "") {
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          StoreissueApprovePage(
                                                            team_id: "",
                                                          )),
                                                  (Route<dynamic> route) =>
                                                      false);
                                        } else {
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          StoreissueApprovePage(
                                                            team_id:
                                                                widget.team_id,
                                                          )),
                                                  (Route<dynamic> route) =>
                                                      false);
                                        }
                                      },
                                      child: Text(
                                        'ใช่',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Expanded(
                                    child: MaterialButton(
                                      color: Colors.grey[400],
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text(
                                        'ไม่ใช่',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
=======
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F9B73),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
>>>>>>> e22eb7c6d1c95d0455da2e90fabde345106aff56
                      ),
                      onPressed: () => _showConfirmDialog(context, true), // Approve
                      child: const Text('อนุมัติ', style: TextStyle(fontFamily: 'Prompt', fontSize: 16, fontWeight: FontWeight.bold)),
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
