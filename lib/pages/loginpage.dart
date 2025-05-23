import 'package:flutter/material.dart';
import 'package:flutter_cic_support/appcache/appcache.dart';
import 'package:flutter_cic_support/pages/mainpage.dart';
import 'package:flutter_cic_support/pages/profilenormal.dart';
import 'package:flutter_cic_support/providers/person.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:flutter_cic_support/services/localnoti.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';

class LoginPage extends StatefulWidget {
  static const routeName = "loginpage";
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Map<String, dynamic> _formData = {
    'username': null,
    'password': null,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameText = TextEditingController();
  final TextEditingController passwordText = TextEditingController();

  bool isChecked = false;
  bool _networkisok = false;

  late Box box1;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    // TODO: implement initState
    //Provider.of<PersonData>(context, listen: false).fetchPerson();
    _checkInternet();
    createBox();
    // LocalNoti.initialize(flutterLocalNotificationsPlugin);
    super.initState();
  }

  Future<void> _checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _networkisok = false;
      });
      //_showConnectionFail();
    } else {
      setState(() {
        _networkisok = true;
      });
    }
  }

  void _showConnectionFail() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('No Internet Connection'),
        content: Text('Please check your internet connection'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void shownoti() {
    print("notiiiiiiiiiiiiiiiiiiii");
    LocalNoti.showBigTextNotification(
        title: "test",
        body: 'fdfdfdfdfdffd',
        fln: flutterLocalNotificationsPlugin);
  }

  void createBox() async {
    box1 = await Hive.openBox('logindata');
    getdata();
  }

  void getdata() async {
    if (box1.get('username') != null) {
      usernameText.text = box1.get('username');
      isChecked = true;
      setState(() {});
    }
    if (box1.get('password') != null) {
      passwordText.text = box1.get('password');
    }
  }

  void _registerDevice() async {
    await Provider.of<UserData>(context, listen: false)
        .addDeviceToken(); // register device token
  }

  void _submitForm(Function login) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    // bool res = await Provider.of<UserData>(context, listen: false)
    //     .login('donpisit.s', 'Tara0874038565');
    EasyLoading.show(status: "กําลังเข้าสู่ระบบ");
    bool res = await Provider.of<UserData>(context, listen: false)
        .login(_formData['username'], _formData['password']);
    EasyLoading.dismiss();

    if (res == true) {
      _registerDevice();
      if (isChecked) {
        box1.put('username', _formData['username']);
        box1.put('password', _formData['password']);
      }
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => AppCache()));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainPage()));
    } else {
      bool res2 = await Provider.of<UserData>(context, listen: false)
          .loginExcludeDNS(_formData['username'], _formData['password']);

      if (res2 == true) {
        _registerDevice();
        if (isChecked) {
          box1.put('username', _formData['username']);
          box1.put('password', _formData['password']);

          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => ProfileNormalPage()));
          Navigator.pushReplacementNamed(context, "profilenormal");
        }
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    'พบข้อผิดพลาด',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, right: 15.0, bottom: 8.0, left: 15.0),
                    child: Text(
                      'Username หรือ Password ไม่ถูกต้อง ลองใหม่อีกครั้งหรือติดต่อผู้ดูแล ?',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
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
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            'ตกลง',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserData users = Provider.of<UserData>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _networkisok
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                        text: const TextSpan(children: [
                      TextSpan(
                        text: "CIC",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
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
                          fontSize: 30,
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
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        buildUsernameField(),
                        const SizedBox(
                          height: 10,
                        ),
                        buildPasswordField(),
                        const SizedBox(
                          height: 20,
                        ),
                        builRememberMe(),
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 45, 172, 123),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Material(
                      child: InkWell(
                        onTap: () => _submitForm(users.login),
                        // onTap: () {
                        //   shownoti();
                        // },
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          child: const Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      color: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Build version 1.2',
                  style: TextStyle(color: Colors.grey.withOpacity(0.8)),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'Release date 23-05-2025',
                  style: TextStyle(color: Colors.grey.withOpacity(0.8)),
                ),
              ],
            )
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Center(
                child: Icon(
                  Icons.error,
                  color: Colors.red[300],
                  size: 100,
                ),
              ),
              Center(
                child: Text(
                  'ไม่สามารถเชื่อมต่อกับเซิฟเวอร์ได้ ตรวจสอบการเชื่อมต่ออินเตอร์เน็ต',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ]),
    );
  }

  Widget buildPasswordField() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      alignment: Alignment.centerLeft,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: TextFormField(
            controller: passwordText,
            decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.black45,
                ),
                border: InputBorder.none,
                hintText: 'Password'),
            obscureText: true,
            validator: (String? value) {
              if (value!.isEmpty || value.length < 1) {
                return ("กรุณากรอกรหัสผ่าน");
              }
            },
            onSaved: (String? value) {
              _formData['password'] = value;
            }),
      ),
    );
  }

  Widget buildUsernameField() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      alignment: Alignment.centerLeft,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: TextFormField(
          decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.person,
                color: Colors.black45,
              ),
              border: InputBorder.none,
              hintText: 'Username'),
          controller: usernameText,
          validator: (String? value) {
            if (value!.isEmpty || value.length < 1) {
              return 'กรุณากรอกชื่อผู้ใช้';
            }
          },
          onSaved: (String? value) {
            _formData['username'] = value;
          },
        ),
      ),
    );
  }

  Widget builRememberMe() {
    return Row(
      children: <Widget>[
        Expanded(
            flex: 1,
            child: Checkbox(
              value: isChecked,
              onChanged: (value) {
                isChecked = !isChecked;
                setState(() {});
              },
            )),
        Expanded(flex: 4, child: Text("จดจำเพื่อเข้าระบบครั้งต่อไป")),
      ],
    );
  }
}
