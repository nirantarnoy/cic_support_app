import 'package:flutter/material.dart';

import 'package:flutter_cic_support/pages/carlistpage.dart';
import 'package:flutter_cic_support/pages/jobplanarea.dart';

import 'package:flutter_cic_support/pages/createcar.dart';
import 'package:flutter_cic_support/pages/jobcheck.dart';
import 'package:flutter_cic_support/pages/loginpage.dart';
import 'package:flutter_cic_support/pages/memberteam.dart';
import 'package:flutter_cic_support/pages/plan.dart';
// import 'package:flutter_cic_support/pages/plan.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = "profile";
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String current_username = "";
  // Future<String> _displayname() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String username = prefs.getString("user_name").toString();
  //   return username;
  // }

  @override
  void initState() {
    // TODO: implement initState
    Provider.of<UserData>(context, listen: false).fetchProfile();
    current_username =
        Provider.of<UserData>(context, listen: false).getCurrenUserName();

    super.initState();
  }

  void _logoutaction(Function logout) async {
    Map<String, dynamic> sucessInformation;
    sucessInformation = await logout();
    if (sucessInformation['success']) {
      print('logout success');
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => LoginPage()));
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  void _logout(UserData users) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                Icons.mood_bad_outlined,
                size: 32,
                color: Colors.red,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'ยืนยันการทำรายการ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'ต้องการออกจากระบบใช่หรือไม่ ?',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: MaterialButton(
                      color: Colors.red.shade300,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      onPressed: () {
                        _logoutaction(users.logout);
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
          ),
        ),
      ),
    );
  }

  void _editBottomSheet(context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.75;

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              //  height: MediaQuery.of(context).size.height * 0.9,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'เลือกรูปจาก',
                    style: TextStyle(fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('กล้องถ่ายรูป'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 45, 172, 123),
                          minimumSize: const Size.fromHeight(50)),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('คลังภาพ'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 45, 172, 123),
                          minimumSize: const Size.fromHeight(50)),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(title: Text("hlllo")),
    // );
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 45, 172, 123),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'User Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Consumer<UserData>(
            builder: (context, _users, _) => IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                ),
                onPressed: () => _logout(_users)),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.centerLeft,
        children: <Widget>[
          //Initialize the chart widget
          Container(
            margin: const EdgeInsets.only(top: 50),
            //  height: 60,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.only(
                // topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(''),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _editBottomSheet(context),
                              child: Container(
                                width: 150,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color.fromARGB(255, 45, 172, 123),
                                ),
                                child: Text(
                                  'Change Photo',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(''),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(2),
                          height: 80,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.grey.shade200,
                              ),
                              child: Center(
                                  child: Icon(
                                Icons.calendar_month,
                                color: Colors.lightBlue,
                              )),
                            ),
                            title: Text(
                              'แผนและตารางตรวจ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                            ),
                          ),
                        ),
                        //  onTap: () {}
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PlanPage())),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(2),
                          height: 80,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.grey.shade200,
                              ),
                              child: Center(
                                  child: Icon(
                                Icons.check_box_outlined,
                                color: Colors.amber,
                              )),
                            ),
                            title: Text(
                              'ตรวจกิจกรรม 5ส.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                            ),
                          ),
                        ),
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => JobplanAreaPage())),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(2),
                          height: 80,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.grey.shade200,
                              ),
                              child: Center(
                                  child: Icon(
                                Icons.safety_check,
                                color: Colors.green,
                              )),
                            ),
                            title: Text(
                              'ตรวจ Safety',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                            ),
                          ),
                        ),
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => JobCheckPage(
                                      plan_area_id: "",
                                      plan_id: "",
                                      plan_area_name: "",
                                    ))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(2),
                          height: 80,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.grey.shade200,
                              ),
                              child: Center(
                                  child: Icon(
                                Icons.cancel,
                                color: Colors.red,
                              )),
                            ),
                            title: Text(
                              'จัดการใบ CAR',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                            ),
                          ),
                        ),
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => CarlistPage())),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(2),
                          height: 80,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.grey.shade200,
                              ),
                              child: Center(
                                  child: Icon(
                                Icons.person_search,
                                color: Colors.blueGrey,
                              )),
                            ),
                            title: Text(
                              'สมาชิกทีมตรวจ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                            ),
                          ),
                        ),
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MemberTeamPage(
                                      team_id: '1',
                                    ))),
                      ),
                    ),
                    const Expanded(
                      child: Text(''),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 100,
                  width: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(
                      50,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage(
                        "http://172.16.0.231/cicsupport/backend/web/uploads/1635j0541.jpg"),
                    // backgroundImage:
                    //     NetworkImage("172.16.0.240/uploads/1635j0541.jpg"),
                  ),
                  // child: const Icon(
                  //   Icons.person,
                  //   color: Colors.purple,
                  //   size: 50,
                  // ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Consumer<UserData>(
                  builder: (context, _user, _) => Text(
                    "${current_username.toString()} (ทีมตรวจ ${_user.team_display.toString()})",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // FutureBuilder(
                //     future: _displayname(),
                //     builder: (context, snapshort) {
                //       if (!snapshort.hasData) {}
                //       return Text(
                //         "${snapshort.data}",
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.white,
                //         ),
                //       );
                //     }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
