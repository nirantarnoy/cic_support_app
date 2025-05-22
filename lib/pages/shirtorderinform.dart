import 'package:flutter/material.dart';

class ShirtorderInformPage extends StatelessWidget {
  const ShirtorderInformPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text("เลือกเบอร์เสื้อ")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_outlined,
              color: Colors.green[300],
              size: 90,
            ),
            Text(
              "คุณได้ทำการเลือกระบุข้อมูลเสื้อฟอร์มไปเรียบร้อยแล้ว",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
