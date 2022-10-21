import 'package:flutter/material.dart';
import 'package:flutter_cic_support/pages/mainpage.dart';
import 'package:flutter_cic_support/pages/notificationpage.dart';
import 'package:flutter_cic_support/pages/profile.dart';

class bottomnav extends StatefulWidget {
  const bottomnav({
    Key? key,
  }) : super(key: key);

  @override
  State<bottomnav> createState() => _bottomnavState();
}

class _bottomnavState extends State<bottomnav> {
  int _currentIndex = 0;

  @override
  void initState() {
    _currentIndex = 0;
    super.initState();
  }

  void _onTaped(int index) {
    if (index == 0) {
      setState(() {
        _currentIndex = index;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(),
          ),
        );
      });
    } else if (index == 1) {
      setState(() {
        _currentIndex = index;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationPage(),
          ),
        );
      });
    } else if (index == 2) {
      setState(() {
        _currentIndex = index;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.purple,
          currentIndex: _currentIndex,
          onTap: _onTaped,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
            BottomNavigationBarItem(
                icon: new Stack(
                  children: <Widget>[
                    Icon(Icons.notifications_active),
                    Positioned(
                        top: 0,
                        right: 0,
                        child: Stack(
                          children: [
                            Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.red,
                              ),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  "1",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
                label: 'การแจ้งเตือน'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'ข้อมูลผู้ใช้')
          ],
        ),
      ],
    );
  }
}
