import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/shirtorder.dart';
import 'package:flutter_cic_support/pages/profile.dart';
import 'package:flutter_cic_support/pages/profilenormal.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_cic_support/providers/shirtemp.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class ShirtorderPage extends StatefulWidget {
  static const routeName = '/shirtorder';
  const ShirtorderPage({Key? key}) : super(key: key);

  @override
  State<ShirtorderPage> createState() => _ShirtorderPageState();
}

class _ShirtorderPageState extends State<ShirtorderPage> {
  int total_qty = 0;
  // List<ShirtOrder> order_items = [];
  // int total_qty = 0;

  // Future _fetorderlist() async {
  //   order_items = await Provider.of<ShirtempData>(this.context, listen: false)
  //       .listshirtorder;
  // }
  int userlogin_type = 0;

  @override
  void initState() {
    // TODO: implement initState
    // _fetorderlist();
    // total_qty = order_items.length;
    userlogin_type =
        Provider.of<UserData>(this.context, listen: false).userlogintype;
    super.initState();
  }

  Widget _buildlist(List<ShirtOrder> orders) {
    if (orders.isNotEmpty) {
      return ListView.builder(
          itemCount: orders.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Dismissible(
                key: ValueKey(orders[index]),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) {
                  return showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text(
                                "ยืนยันการลบข้อมูล",
                                style: TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold),
                              ),
                              content: const Text(
                                "คุณต้องการลบรายการเสื้อนี้จากตะกร้าใช่หรือไม่",
                                style: TextStyle(fontFamily: 'Prompt'),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text("ยกเลิก", style: TextStyle(color: Colors.grey, fontFamily: 'Prompt')),
                                  onPressed: () {
                                    Navigator.of(ctx).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: const Text(
                                    "ยืนยัน",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Prompt',
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(ctx).pop(true);
                                  },
                                ),
                              ]));
                },
                onDismissed: (direction) {
                  setState(() {
                    Provider.of<ShirtempData>(context, listen: false)
                        .removeCart(index);
                  });
                  Fluttertoast.showToast(
                      msg: "ลบข้อมูลสำเร็จ",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F9B73).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.checkroom_rounded,
                        color: Color(0xFF0F9B73),
                      ),
                    ),
                    title: Text(
                      '${orders[index].shirt_type_name} - ${orders[index].shirt_size_name}',
                      style: const TextStyle(
                        fontFamily: 'Prompt',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orders[index].shirt_pocket_name,
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          if (orders[index].shirt_remark != '')
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '* ${orders[index].shirt_remark}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.redAccent,
                                  fontFamily: 'Prompt',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F9B73).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'x${orders[index].shirt_qty}',
                        style: const TextStyle(
                          color: Color(0xFF0F9B73),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          fontFamily: 'Prompt',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
    } else {
      return const Center(
        child: Text(
          "ไม่พบข้อมูลในตะกร้า",
          style: TextStyle(fontFamily: 'Prompt', color: Colors.grey, fontSize: 16),
        ),
      );
    }
  }

  Widget _buildRemark() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.15)),
      ),
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "กรณีต้องการเปลี่ยนข้อมูลเสื้อโปรดดำเนินการก่อนวันที่ 31 กรกฎาคม 2569",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: Colors.redAccent,
                fontFamily: 'Prompt',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitform(BuildContext context, List<ShirtOrder> _orderlist) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 12),
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 56,
                color: Color(0xFF0F9B73),
              ),
              const SizedBox(height: 16),
              const Text(
                'ยืนยันการทำรายการ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Prompt',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'ต้องการบันทึกข้อมูลการจองเสื้อใช่หรือไม่ ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Prompt',
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F9B73),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        await EasyLoading.show(status: "กำลังบันทึกข้อมูล");
                        bool isSave = await Provider.of<ShirtempData>(context,
                                listen: false)
                            .submitshirt(_orderlist);
                        if (isSave == true) {
                          await EasyLoading.showSuccess('บันทึกรายการเรียบร้อย');
                          if (userlogin_type == 1) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfilePage()));
                          } else {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileNormalPage()),
                                (route) => false);
                          }
                        }
                        EasyLoading.dismiss();
                      },
                      child: const Text(
                        'ใช่',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Prompt',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text(
                        'ไม่ใช่',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Prompt',
                          fontSize: 16,
                        ),
                      ),
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

  Widget _buildTotal(List<ShirtOrder> _list) {
    int total_qty = 0;
    _list.forEach((element) {
      total_qty += int.parse(element.shirt_qty);
    });
    return Text(
      '${total_qty.toString()} ตัว',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F9B73),
        fontFamily: 'Prompt',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _shirt_order = ModalRoute.of(context)?.settings.arguments as Map;
    List<ShirtOrder> order_items = _shirt_order['shirtorder'];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "สรุปรายการเลือก",
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<ShirtempData>(
                builder: (context, topicitems, _) =>
                    _buildlist(topicitems.listshirtorder),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        const Text(
                          'จำนวนรวมทั้งสิ้น',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontFamily: 'Prompt',
                          ),
                        ),
                        const Spacer(),
                        Consumer<ShirtempData>(
                          builder: (context, value, child) =>
                              _buildTotal(value.listshirtorder),
                        ),
                      ],
                    ),
                  ),
                  _buildRemark(),
                  const SizedBox(height: 8),
                  if (order_items.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F9B73), Color(0xFF2EC89F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F9B73).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              _submitform(context, order_items);
                            },
                            child: const Center(
                              child: Text(
                                "ยืนยันส่งข้อมูล",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Prompt',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
