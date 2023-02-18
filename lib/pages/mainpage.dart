import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cic_support/pages/notificationpage.dart';
import 'package:flutter_cic_support/pages/settingpage.dart';
import 'package:flutter_cic_support/providers/teamnotify.dart';
import 'package:flutter_cic_support/services/localnoti.dart';
import 'package:flutter_cic_support/widgets/bottomnav.dart';
import 'package:flutter_cic_support/widgets/menucategory.dart';
import 'package:flutter_cic_support/widgets/newswidget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late Box box2;
  @override
  void initState() {
    // TODO: implement initState
    Provider.of<TeamnotifyData>(context, listen: false).teamnotifyFetch();
    LocalNoti.initialize(flutterLocalNotificationsPlugin);
    super.initState();
    shownoti();
  }

  void shownoti() async {
    //print("notiiiiiiiiiiiiiiiiiiii");
    if (await checkdailymessage() == false) {
      LocalNoti.showBigTextNotification(
          title: "แจ้งเตือนจาก cicsupport",
          body: 'มีรายการคาคงค้างในพื้นที่ตรวจของคุณ',
          fln: flutterLocalNotificationsPlugin);
    }
  }

  Future<bool> checkdailymessage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('showmessage').toString() == "1") {
      return true;
    } else {
      prefs.setString('showmessage', '1');
      return false;
    }
  }

  // void createBox() async {
  //   box2 = await Hive.openBox('shownotidaily');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingPage(),
              )),
          icon: const Icon(
            Icons.settings,
            color: Colors.black87,
          ),
        ),
        title: RichText(
            text: const TextSpan(children: [
          TextSpan(
            text: "CIC",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1, 1),
                  color: Colors.grey,
                  blurRadius: 8.0,
                ),
              ],
            ),
          ),
          TextSpan(
            text: "SUPPORT",
            style: TextStyle(
              color: Color.fromARGB(255, 45, 172, 123),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1, 1),
                  color: Colors.grey,
                  blurRadius: 8.0,
                ),
              ],
            ),
          ),
        ])),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color.fromARGB(255, 45, 172, 123),
            ),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationPage(),
                )),
          ),
          // IconButton(
          //   icon: Icon(
          //     Icons.logout_outlined,
          //     color: Colors.purple,
          //   ),
          //   onPressed: () {},
          // ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          child: Column(
            children: [
              // Row(
              //   children: [
              //     Expanded(
              //       child: Container(
              //         margin: EdgeInsets.all(10),
              //         padding: EdgeInsets.all(10),
              //         alignment: Alignment.center,
              //         decoration: BoxDecoration(
              //           color: Colors.purple,
              //           borderRadius: BorderRadius.circular(25),
              //           gradient: LinearGradient(
              //             begin: Alignment.centerLeft,
              //             end: Alignment.centerRight,
              //             colors: [
              //               Colors.purple.withOpacity(0.5),
              //               Colors.purple,
              //             ],
              //           ),
              //         ),
              //         child: Text(
              //           '5 ส',
              //           style: TextStyle(
              //             color: Colors.white,
              //             fontWeight: FontWeight.bold,
              //             fontSize: 18,
              //           ),
              //         ),
              //       ),
              //     ),
              //     Expanded(
              //       child: Container(
              //         margin: EdgeInsets.all(10),
              //         padding: EdgeInsets.all(10),
              //         alignment: Alignment.center,
              //         decoration: BoxDecoration(
              //           color: Colors.grey.withOpacity(0.3),
              //           borderRadius: BorderRadius.circular(25),
              //         ),
              //         child: Text(
              //           'Safety',
              //           style: TextStyle(
              //             color: Colors.black,
              //             fontWeight: FontWeight.bold,
              //             fontSize: 18,
              //           ),
              //         ),
              //       ),
              //     ),
              //     Expanded(
              //       child: Container(
              //         margin: EdgeInsets.all(10),
              //         padding: EdgeInsets.all(10),
              //         alignment: Alignment.center,
              //         decoration: BoxDecoration(
              //           color: Colors.grey.withOpacity(0.3),
              //           borderRadius: BorderRadius.circular(25),
              //         ),
              //         child: Text(
              //           'Audit',
              //           style: TextStyle(
              //             color: Colors.black,
              //             fontWeight: FontWeight.bold,
              //             fontSize: 18,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // Container(
              //   height: 250,
              //   margin: EdgeInsets.all(5),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(
              //       15,
              //     ),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.grey.withOpacity(0.5),
              //         // spreadRadius: 8,
              //         blurRadius: 20,
              //         offset: Offset(0, 4),
              //       ),
              //     ],
              //   ),
              //   //child: Column(),
              // ),
              const SizedBox(
                height: 10,
              ),
              MenuCategoryWidget(),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'กิจกรรม/ข่าวสาร',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              newswidget(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomnav(),
    );
  }
}
