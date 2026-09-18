import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cic_support/models/itemcart.dart';
import 'package:flutter_cic_support/providers/store_issue_product.dart';
import 'package:flutter_cic_support/providers/storeissue.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:flutter_cic_support/services/push_notification_service.dart';

class StoreIssueCartPage extends StatefulWidget {
  @override
  _StoreIssueCartPageState createState() => _StoreIssueCartPageState();
}

class _StoreIssueCartPageState extends State<StoreIssueCartPage> {
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _jobissuenoController = TextEditingController();
  final TextEditingController _qtyEditController = TextEditingController();

  var formatter = NumberFormat('#,##,##0');
  String issue_job_no = '';
  String? _currentIdempotencyKey;
  String jobPrefix = 'WO';

  void _showEditQtyDialog(int index, List<ItemCart> listdata) {
    _qtyEditController.text = listdata[index].qty;
    _remarkController.text = listdata[index].remark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('แก้ไขรายละเอียด', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('จำนวน', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                SizedBox(height: 5),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _qtyEditController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
                SizedBox(height: 15),
                Text('หมายเหตุ', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                SizedBox(height: 5),
                TextField(
                  controller: _remarkController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                  minLines: 1,
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('ยกเลิก', style: TextStyle(color: Colors.grey.shade600)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('บันทึก', style: TextStyle(color: Colors.white)),
            onPressed: () {
              String qtyText = _qtyEditController.text.replaceAll(',', '');
              double newQty = double.tryParse(qtyText) ?? 0;

              if (newQty <= 0) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('จำนวนต้องมากกว่า 0'), backgroundColor: Colors.red));
                 return;
              }

              double currentOnhand = double.tryParse(listdata[index].onhand?.toString().replaceAll(',', '') ?? '0') ?? 0;
              if (currentOnhand <= 0) {
                try {
                  var prods = Provider.of<ProductData>(context, listen: false).listproduct;
                  var matchedProd = prods.firstWhere((p) => p.id == listdata[index].id);
                  currentOnhand = double.tryParse(matchedProd.onhand.replaceAll(',', '')) ?? 0;
                } catch (_) {}
              }

              if (currentOnhand > 0 && newQty > currentOnhand) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('จำนวน ($newQty) มากกว่ายอดคงเหลือ ($currentOnhand)'), backgroundColor: Colors.red));
                 return;
              }

              bool updated = Provider.of<ProductData>(context, listen: false)
                  .updateCartQty(index, qtyText, remark: _remarkController.text.trim());

              if (!updated) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ไม่สามารถแก้ไขจำนวนได้'), backgroundColor: Colors.red));
                 return;
              }

              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showJobDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          int maxLen = (jobPrefix == 'WO') ? 7 : 9;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text('เลขที่ใบ JOB / ใบแจ้งซ่อม', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: jobPrefix,
                            items: <String>['WO', 'PM'].map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (String? newValue) {
                              setStateDialog(() {
                                jobPrefix = newValue!;
                                _jobissuenoController.clear();
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _jobissuenoController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            labelText: 'หมายเลข',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                          maxLength: maxLen,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              if (issue_job_no.isNotEmpty)
                TextButton(
                  child: Text('ล้างข้อมูล', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    setState(() {
                      issue_job_no = '';
                      _jobissuenoController.clear();
                    });
                    Navigator.of(ctx).pop();
                  },
                ),
              TextButton(
                child: Text('ยกเลิก', style: TextStyle(color: Colors.grey.shade600)),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('บันทึก', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  bool isValid = false;
                  String errorMsg = "";
                  String inputText = _jobissuenoController.text.trim();
                  if (inputText.toUpperCase().startsWith('WO') || inputText.toUpperCase().startsWith('PM')) {
                    inputText = inputText.substring(2).trim();
                  }

                  if (jobPrefix == 'WO') {
                    if (inputText.length != 7) {
                      isValid = false;
                      errorMsg = "ระบุเลขที่ใบ JOB ไม่ครบ (WO ต้องมี 7 หลัก)";
                    } else {
                      isValid = true;
                    }
                  } else if (jobPrefix == 'PM') {
                    if (inputText.length != 9) {
                      isValid = false;
                      errorMsg = "ระบุเลขที่ใบ JOB ไม่ครบ (PM ต้องมี 9 หลัก)";
                    } else {
                      isValid = true;
                    }
                  }

                  if (isValid) {
                    String targetJobNo = jobPrefix + inputText;
                    EasyLoading.show(status: 'กำลังตรวจสอบเลข JOB...');
                    
                    bool exists = await Provider.of<StoreissueData>(context, listen: false).checkWorkOrderExist(targetJobNo);

                    if (!exists) {
                      EasyLoading.dismiss();
                      isValid = false;
                      errorMsg = "ไม่พบเลขที่ WO หรือ PM";
                    } else {
                      int jobCount = await Provider.of<StoreissueData>(context, listen: false).checkJobNoCount(targetJobNo);
                      EasyLoading.dismiss();

                      if (jobCount >= 3) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("แจ้งเตือน: เลขที่ใบ JOB ($targetJobNo) มีการทำรายการเบิกไปแล้ว $jobCount ครั้ง"),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 4),
                        ));
                      }
                    }
                  }

                  if (!isValid) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(errorMsg), backgroundColor: Colors.red,
                    ));
                  } else {
                    setState(() {
                      issue_job_no = jobPrefix + inputText;
                    });
                    Navigator.of(ctx).pop();
                  }
                },
              ),
            ],
          );
        }
      ),
    );
  }

  void _submitIssue(List<ItemCart> cartItems) async {
    if (cartItems.isEmpty) return;

    var restrict_product = ['21', '22', '31', '32'];
    bool hasRestricted = false;
    for (var item in cartItems) {
      if (item.id != null && item.id.toString().length >= 2) {
        String prefix = item.id.toString().substring(0, 2);
        if (restrict_product.contains(prefix)) {
          hasRestricted = true;
          break;
        }
      }
    }

    if (hasRestricted && issue_job_no.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
         content: Text('คุณเลือกสินค้าที่ต้องระบุเลข JOB (อะไหล่เครื่องจักร) กรุณาระบุเลข JOB ก่อนเบิก'),
         backgroundColor: Colors.red,
       ));
       return;
    }

    // Calculate total amount
    double _ordertotalamount = 0.0;
    for (var item in cartItems) {
       _ordertotalamount += (double.tryParse(item.qty.replaceAll(',', '')) ?? 0) * (double.tryParse(item.price?.toString() ?? '0') ?? 0);
    }

    EasyLoading.show(status: 'ตรวจสอบสิทธิ์ผู้อนุมัติ...');
    List<Map<String, dynamic>> validApprovers = [];
    List<Map<String, dynamic>> highLevelApprovers = [];
    bool forcePending = false;
    bool autoApprove = false;
    double userSelfApproveLimit = 0.0;
    String currentDeptName = 'ไม่ระบุแผนก';

    try {
      List<Map<String, dynamic>> userApproveToken =
          await Provider.of<UserData>(context, listen: false).fetchApproveToken();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? currentUserEmpCode = prefs.getString('emp_code');
      String? currentUserId = prefs.getString('user_id');
      currentDeptName = prefs.getString('dept_name') ?? 'ไม่ระบุแผนก';
      String? currentFCMToken;
      try {
        currentFCMToken = await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 3), onTimeout: () => null);
      } catch (_) {}

      bool isSelfApprover = false;
      if (userApproveToken != null) {
        for (int i = 0; i < userApproveToken.length; i++) {
          double limit = double.tryParse((userApproveToken[i]['approve_limit'] ?? userApproveToken[i]['final_limit'] ?? userApproveToken[i]['limit'])?.toString().replaceAll(',', '') ?? '0') ?? 0.0;
          String token = userApproveToken[i]['device_token'] ?? '';
          String empCode = userApproveToken[i]['emp_code'] ?? '';
          String userId = userApproveToken[i]['user_id'] ?? '';

          bool isSelf = (empCode.isNotEmpty && empCode == currentUserEmpCode) ||
              (userId.isNotEmpty && userId == currentUserId) ||
              (token.isNotEmpty && currentFCMToken != null && currentFCMToken.isNotEmpty && token == currentFCMToken);

          if (isSelf) {
            isSelfApprover = true;
            if (limit > userSelfApproveLimit) {
              userSelfApproveLimit = limit;
            }
          }
        }
      }

      if (isSelfApprover && _ordertotalamount <= userSelfApproveLimit) {
        autoApprove = true;
        forcePending = false;
      } else {
        autoApprove = false;
        forcePending = true;
      }

      if (!autoApprove && userApproveToken != null) {
        for (int i = 0; i < userApproveToken.length; i++) {
          double approveLimit = double.tryParse((userApproveToken[i]['approve_limit'] ?? userApproveToken[i]['final_limit'] ?? userApproveToken[i]['limit'])?.toString().replaceAll(',', '') ?? '0') ?? 0.0;
          String token = userApproveToken[i]['device_token'] ?? '';
          String approverEmpCode = userApproveToken[i]['emp_code'] ?? '';
          String approverUserId = userApproveToken[i]['user_id'] ?? '';

          bool isSelf = (approverEmpCode.isNotEmpty && approverEmpCode == currentUserEmpCode) ||
              (approverUserId.isNotEmpty && approverUserId == currentUserId) ||
              (token.isNotEmpty && currentFCMToken != null && currentFCMToken.isNotEmpty && token == currentFCMToken);

          if (isSelf) continue;

          if (approveLimit >= 10000) {
              highLevelApprovers.add(userApproveToken[i]);
          }

          if (_ordertotalamount >= 10000 && approveLimit < 10000) continue;
          if (approveLimit < _ordertotalamount) continue;

          validApprovers.add(userApproveToken[i]);
        }
      }
    } catch (e) {
      print('Error loading approvers: $e');
    }

    EasyLoading.dismiss();

    bool hasValidApprover = false;
    if (autoApprove || validApprovers.isNotEmpty || _ordertotalamount < 10000) {
      hasValidApprover = true;
    }

    if (!hasValidApprover) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("ไม่สามารถทำรายการได้ ไม่พบผู้อนุมัติที่เข้าเงื่อนไขวงเงิน"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (issue_job_no.isNotEmpty) {
      EasyLoading.show(status: 'ตรวจสอบเลขที่ใบ JOB...');
      bool exists = await Provider.of<StoreissueData>(context, listen: false).checkWorkOrderExist(issue_job_no);
      EasyLoading.dismiss();
      if (!exists) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("ไม่พบเลขที่ WO หรือ PM ในระบบหลังบ้าน"),
          backgroundColor: Colors.red,
        ));
        return;
      }

      int jobCount = await Provider.of<StoreissueData>(context, listen: false).checkJobNoCount(issue_job_no);
      if (jobCount >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("แจ้งเตือน: เลขที่ใบ JOB ($issue_job_no) มีการทำรายการเบิกไปแล้ว $jobCount ครั้ง (ส่งแจ้งเตือนไปยังผู้อนุมัติวงเงินแล้ว)"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ));
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isSubmitted = false;
        bool isSubmitting = false;

        return StatefulBuilder(
            builder: (context, StateSetter setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 700,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey[200],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      isSubmitted
                          ? (autoApprove ? 'อนุมัติการเบิกสำเร็จเรียบร้อย' : 'ส่งคำขออนุมัติเรียบร้อยแล้ว')
                          : (autoApprove ? 'ยืนยันอนุมัติเบิก (ทำรายการเอง)' : 'ยืนยันบันทึกเบิก'),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: isSubmitted || autoApprove ? Colors.green[800] : Colors.black),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSubmitted || autoApprove ? Colors.green[50] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSubmitted || autoApprove ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSubmitted || autoApprove ? Icons.check_circle : Icons.hourglass_top,
                            color: isSubmitted || autoApprove ? Colors.green : Colors.orange[800],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isSubmitted
                                  ? (autoApprove
                                      ? 'บันทึกรายการเบิกอนุมัติสำเร็จ! ทำรายการเบิกเองเรียบร้อยแล้ว'
                                      : 'บันทึกรายการเบิกสำเร็จ! ระบบส่งแจ้งเตือนไปยังผู้อนุมัติเรียบร้อยแล้ว (อยู่ระหว่างรอผู้อนุมัติ)')
                                  : (autoApprove
                                      ? 'คุณทำรายการเบิกด้วยตนเองภายในวงเงินอนุมัติ (${formatter.format(userSelfApproveLimit)} บาท) - ระบบอนุมัติให้อัตโนมัติ'
                                      : 'รอผู้บังคับบัญชาอนุมัติรายการเบิกของคุณก่อนจึงจะสามารถพิมพ์ใบเบิกเพื่อทำรายการต่อไป'),
                              style: TextStyle(
                                color: isSubmitted || autoApprove ? Colors.green[900] : Colors.red[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        autoApprove
                            ? 'สิทธิ์อนุมัติ: ทำรายการเบิกเอง อนุมัติอัตโนมัติ (ยอดเบิก ${formatter.format(_ordertotalamount)} บาท):'
                            : 'ผู้อนุมัติที่จะได้รับแจ้งเตือน (ยอดเบิก ${formatter.format(_ordertotalamount)} บาท):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[800]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: autoApprove
                          ? ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green[100],
                                child: Icon(Icons.person, color: Colors.green[800]),
                              ),
                              title: Text(
                                'อนุมัติโดยคุณเอง',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'วงเงินอนุมัติของคุณ: ${formatter.format(userSelfApproveLimit)} บาท',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              trailing: isSubmitted ? Icon(Icons.send, size: 18, color: Colors.green) : null,
                            )
                          : (validApprovers.isEmpty
                              ? Center(child: Text('ไม่มีรายชื่อผู้อนุมัติ', style: TextStyle(color: Colors.grey)))
                              : ListView.separated(
                                  itemCount: validApprovers.length,
                                  separatorBuilder: (context, index) => Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    String name = validApprovers[index]['emp_name']?.toString() ?? validApprovers[index]['name']?.toString() ?? '';
                                    String level = validApprovers[index]['level_name']?.toString() ?? validApprovers[index]['role_name']?.toString() ?? '';
                                    double limit = double.tryParse((validApprovers[index]['approve_limit'] ?? validApprovers[index]['final_limit'] ?? validApprovers[index]['limit'])?.toString().replaceAll(',', '') ?? '0') ?? 0.0;

                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue[50],
                                        child: Text(name.isNotEmpty ? name.substring(0, 1) : '?', style: TextStyle(color: Colors.blue[800])),
                                      ),
                                      title: Text(
                                        name,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        '${level.isNotEmpty ? "$level | " : ""}วงเงินอนุมัติ: ${formatter.format(limit)} บาท',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                      trailing: isSubmitted ? Icon(Icons.send, size: 18, color: Colors.green) : null,
                                    );
                                  },
                                )),
                    ),
                    const SizedBox(height: 20),
                    if (!isSubmitted)
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: MaterialButton(
                              color: isSubmitting ? Colors.grey : Colors.lightBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      final navigator = Navigator.of(context);
                                      setState(() {
                                        isSubmitting = true;
                                      });

                                      if (_currentIdempotencyKey == null) {
                                        _currentIdempotencyKey = DateTime.now().millisecondsSinceEpoch.toString() + '_' + (100000 + math.Random().nextInt(900000)).toString();
                                      }
                                      EasyLoading.show(status: 'กำลังบันทึกข้อมูล...');

                                      String? targetApproverEmpCode;
                                      String? targetApproverName;
                                      if (validApprovers.isNotEmpty) {
                                        targetApproverEmpCode = validApprovers.first['emp_code']?.toString();
                                        targetApproverName = (validApprovers.first['emp_name'] ?? validApprovers.first['name'])?.toString();
                                      }

                                      bool res = await Provider.of<StoreissueData>(context, listen: false).addJournal(
                                          cartItems,
                                          issue_job_no,
                                          forcePending: forcePending,
                                          approverEmpCode: targetApproverEmpCode,
                                          approverName: targetApproverName,
                                          idempotencyKey: _currentIdempotencyKey);

                                      if (res) {
                                        _currentIdempotencyKey = null;
                                        try {
                                          EasyLoading.show(status: 'กำลังส่งแจ้งเตือน...');

                                          final String serverKey = await PushNotificationService.getAccessToken();
                                          String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/fcmflutter-ed115/messages:send';
                                          Set<String> sentTokens = {};

                                          for (int i = 0; i < validApprovers.length; i++) {
                                            String token = validApprovers[i]['device_token'] ?? '';
                                            if (token.isEmpty || token.toLowerCase() == 'null') continue;
                                            if (sentTokens.contains(token)) continue;
                                            sentTokens.add(token);

                                            final Map<String, dynamic> message = {
                                              'message': {
                                                'token': token,
                                                'notification': {
                                                  'title': "แจ้งเตือนอนุมัติใบเบิก",
                                                  "body": "คุณมีรายการแจ้งเตือนอนุมัติใบเบิก JOB: ${issue_job_no.isNotEmpty ? issue_job_no : 'เบิกสินค้า'} จากแผนก: $currentDeptName",
                                                },
                                                'android': {
                                                  'notification': {'channel_id': 'cicsupportnoti_silent_2'}
                                                },
                                                'data': {
                                                  'route': 'storeissueapprove'
                                                }
                                              }
                                            };

                                            await http.post(
                                              Uri.parse(endpointFirebaseCloudMessaging),
                                              headers: <String, String>{
                                                'Content-Type': 'application/json',
                                                'Authorization': 'Bearer $serverKey'
                                              },
                                              body: jsonEncode(message),
                                            );
                                          }
                                        } catch (e) {
                                          print('Error sending FCM: $e');
                                        }

                                        if (issue_job_no.isNotEmpty) {
                                          try {
                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                            String empCode = prefs.getString('emp_code') ?? '';
                                            for (var cartItem in cartItems) {
                                              Map<String, dynamic> dupRes = await Provider.of<StoreissueData>(context, listen: false).checkDuplicateIssueAlert(issue_job_no, cartItem.id.toString(), cartItem.name.toString(), empCode);

                                              if (dupRes != null && dupRes['alert_triggered'] == true) {
                                                for (int j = 0; j < highLevelApprovers.length; j++) {
                                                  String t = highLevelApprovers[j]['device_token'] ?? '';
                                                  if (t.isNotEmpty && t.toLowerCase() != 'null') {
                                                    final String sKey = await PushNotificationService.getAccessToken();
                                                    String endpointFCM = 'https://fcm.googleapis.com/v1/projects/fcmflutter-ed115/messages:send';
                                                    final Map<String, dynamic> dupMessage = {
                                                      'message': {
                                                        'token': t,
                                                        'notification': {
                                                          'title': "แจ้งเตือนเบิกซ้ำซ้อน",
                                                          'body': "พบการเบิกสินค้า ${cartItem.name} ภายใต้ JOB $issue_job_no ครบ 3 ครั้ง",
                                                        },
                                                        'android': {
                                                          'notification': {'channel_id': 'cicsupportnoti_silent_2'}
                                                        },
                                                        'data': {
                                                          'route': 'storeissueapprove'
                                                        }
                                                      }
                                                    };
                                                    await http.post(
                                                      Uri.parse(endpointFCM),
                                                      headers: <String, String>{
                                                        'Content-Type': 'application/json',
                                                        'Authorization': 'Bearer $sKey'
                                                      },
                                                      body: jsonEncode(dupMessage),
                                                    );
                                                  }
                                                }
                                              }
                                            }
                                          } catch (e) {
                                            print('Error checking dup issues: $e');
                                          }
                                        }

                                        EasyLoading.dismiss();
                                        Provider.of<ProductData>(context, listen: false).clearcartitem();
                                        EasyLoading.showSuccess('บันทึกข้อมูลสำเร็จ');
                                        await Future.delayed(const Duration(seconds: 1));
                                        Navigator.of(context).pop(); // close dialog
                                        Navigator.of(context).pop(true); // close cart page
                                      } else {
                                        EasyLoading.dismiss();
                                        setState(() {
                                          isSubmitting = false;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Row(children: [Icon(Icons.error, color: Colors.white), SizedBox(width: 10), Text("เกิดข้อผิดพลาด ไม่สามารถส่งคำขอได้")]),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                    },
                              child: Text(autoApprove ? 'ยืนยันทำรายการเบิก' : 'ยืนยันส่งข้อมูลให้อนุมัติ', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MaterialButton(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: BorderSide(color: Colors.grey)),
                              onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey[700])),
                            ),
                          ),
                        ],
                      ),
                    if (isSubmitted)
                      MaterialButton(
                        minWidth: double.infinity,
                        color: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        onPressed: () {
                          Navigator.of(context).pop(); // dialog
                          Navigator.of(context).pop(true); // page
                        },
                        child: Text('ปิดหน้าต่าง / กลับไปหน้ารายการสินค้า', style: TextStyle(color: Colors.white)),
                      ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('ตะกร้าเบิกสินค้า', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep, color: Colors.white),
            tooltip: 'ล้างตะกร้า',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(Icons.delete_sweep, color: Colors.red, size: 28),
                      ),
                      SizedBox(width: 12),
                      Text('ล้างตะกร้า', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    ],
                  ),
                  content: Text('คุณต้องการลบสินค้าทั้งหมดในตะกร้าใช่หรือไม่?', style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
                  actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: Text('ยกเลิก', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text('ลบทั้งหมด', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ).then((confirmed) {
                if (confirmed == true) {
                  Provider.of<ProductData>(context, listen: false).clearcartitem();
                }
              });
            },
          )
        ],
      ),
      body: Consumer<ProductData>(
        builder: (context, productData, child) {
          var cartItems = productData.orderItems;
          
          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
                  SizedBox(height: 16),
                  Text("ไม่มีสินค้าในตะกร้า", style: TextStyle(fontSize: 18, color: Colors.grey[500])),
                ],
              ),
            );
          }

          var restrict_product = ['21', '22', '31', '32'];
          
          return Column(
            children: [
              // JOB Number Section
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('เลขที่ใบ JOB / PM', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          SizedBox(height: 4),
                          Text(issue_job_no.isEmpty ? 'ยังไม่ระบุ' : issue_job_no, 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: issue_job_no.isEmpty ? Colors.red : Colors.black87)
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.edit, size: 16, color: Colors.blue[700]),
                      label: Text(issue_job_no.isEmpty ? 'ระบุ' : 'เปลี่ยน', style: TextStyle(color: Colors.blue[700])),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue[50],
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _showJobDialog,
                    )
                  ],
                ),
              ),
              Divider(height: 1),
              
              // Item List
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    var item = cartItems[index];
                    String prefix = (item.id != null && item.id.toString().length >= 2) ? item.id.toString().substring(0, 2) : '';
                    bool isRestricted = restrict_product.contains(prefix);

                    return Dismissible(
                      key: ValueKey(item.id.toString() + index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) {
                        return showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                                  child: Icon(Icons.delete_outline, color: Colors.red, size: 28),
                                ),
                                SizedBox(width: 12),
                                Expanded(child: Text('ยืนยันการลบ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
                              ],
                            ),
                            content: Text('คุณต้องการลบ\n"${item.name ?? item.id}"\nออกจากตะกร้าใช่หรือไม่?', style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
                            actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                                child: Text('ยกเลิก', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: Text('ลบ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) {
                        productData.removecartitem(index);
                      },
                      child: InkWell(
                        onTap: () => _showEditQtyDialog(index, cartItems),
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isRestricted ? Colors.orange : Colors.green,
                                  borderRadius: BorderRadius.circular(6)
                                ),
                                child: Text(item.id.toString(), style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                    if (item.remark != null && item.remark.toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text('* ${item.remark}', style: TextStyle(fontSize: 12, color: Colors.red, fontStyle: FontStyle.italic)),
                                      ),
                                    SizedBox(height: 4),
                                    Text('ราคา: ฿${formatter.format(double.tryParse(item.price.toString()) ?? 0)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Text(item.qty.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                                      SizedBox(width: 4),
                                      Text(item.unit_name.toString(), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Bottom Bar
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('รวมรายการเบิก', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          Text('${cartItems.length} รายการ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.send_rounded, color: Colors.white),
                          label: Text('ยืนยันเบิกสินค้า', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue[700],
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _submitIssue(cartItems),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
