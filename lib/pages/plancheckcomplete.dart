import 'package:flutter/material.dart';
import 'package:flutter_cic_support/pages/profile.dart';

class PlancheckcompletePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: Center(
            child: Icon(
              Icons.check_circle_outline,
              size: 150,
              color: Colors.green,
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Center(
                  child: Text(
                'ทำรายการสำเร็จ',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              )),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  child: Container(
                    height: 50,
                    child: Center(
                      child: Text(
                        "กลับหน้าหลัก",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromARGB(255, 45, 172, 123)),
                  ),
                  onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                      ModalRoute.withName("profile")),
                ),
              )
            ],
          ),
        )
      ]),
    );
  }
}
