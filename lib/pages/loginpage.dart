import 'package:flutter/material.dart';
import 'package:flutter_cic_support/appcache/appcache.dart';
import 'package:flutter_cic_support/pages/mainpage.dart';
import 'package:flutter_cic_support/providers/person.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:flutter_cic_support/services/localnoti.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

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

  late Box box1;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    // TODO: implement initState
    //Provider.of<PersonData>(context, listen: false).fetchPerson();
    createBox();
    // LocalNoti.initialize(flutterLocalNotificationsPlugin);
    super.initState();
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

  void _submitForm(Function login) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    // bool res = await Provider.of<UserData>(context, listen: false)
    //     .login('donpisit.s', 'Tara0874038565');
    bool res = await Provider.of<UserData>(context, listen: false)
        .login(_formData['username'], _formData['password']);

    if (res == true) {
      if (isChecked) {
        box1.put('username', _formData['username']);
        box1.put('password', _formData['password']);
      }
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => AppCache()));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainPage()));
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

  @override
  Widget build(BuildContext context) {
    final UserData users = Provider.of<UserData>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
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
            'Build version 0.8',
            style: TextStyle(color: Colors.grey.withOpacity(0.8)),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            'Release date 12-12-2023',
            style: TextStyle(color: Colors.grey.withOpacity(0.8)),
          ),
        ],
      ),
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
