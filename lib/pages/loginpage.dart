import 'package:flutter/material.dart';
import 'package:flutter_cic_support/app_config.dart';
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
  bool _obscurePassword = true;

  late Box box1;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    _checkInternet();
    createBox();
    super.initState();
  }

  Future<void> _checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _networkisok = false;
      });
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

    EasyLoading.show(status: "กําลังเข้าสู่ระบบ");
    bool res = await Provider.of<UserData>(context, listen: false)
        .login(_formData['username'], _formData['password']);
    EasyLoading.dismiss();

    bool loginSuccess = false;
    if (res == true) {
      loginSuccess = true;
    } else {
      bool res2 = await Provider.of<UserData>(context, listen: false)
          .loginExcludeDNS(_formData['username'], _formData['password']);
      if (res2 == true) {
        loginSuccess = true;
      }
    }

    if (loginSuccess) {
      // Fetch latest profile details from backend to ensure correct team IDs are loaded
      await Provider.of<UserData>(context, listen: false).fetchProfile();

      _registerDevice();
      if (isChecked) {
        box1.put('username', _formData['username']);
        box1.put('password', _formData['password']);
      }
      
      final String teamId = Provider.of<UserData>(context, listen: false).team_display;
      if (teamId != '' && teamId != '0' && teamId != 'null') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainPage()));
      } else {
        Navigator.pushReplacementNamed(context, "profilenormal");
      }
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'พบข้อผิดพลาด',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Text(
                  'Username หรือ Password ไม่ถูกต้อง ลองใหม่อีกครั้งหรือติดต่อผู้ดูแลระบบ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey[700], height: 1.4),
                ),
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text(
                          'ตกลง',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
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
  }

  @override
  Widget build(BuildContext context) {
    final UserData users = Provider.of<UserData>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF073F2F), Color(0xFF1E8F68)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _networkisok
              ? Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          elevation: 12,
                          shadowColor: Colors.black38,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 36.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RichText(
                                      text: const TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "CIC ",
                                            style: TextStyle(
                                              color: Color(0xFF222222),
                                              fontSize: 32,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "SUPPORT",
                                            style: TextStyle(
                                              color: Color(0xFF2DAC7B),
                                              fontSize: 32,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "ระบบสนับสนุนข้อมูลการทำงาน CIC",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 36),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      buildUsernameField(),
                                      const SizedBox(height: 16),
                                      buildPasswordField(),
                                      const SizedBox(height: 12),
                                      builRememberMe(),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF2DAC7B), Color(0xFF1D8F60)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF2DAC7B).withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _submitForm(users.login),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          width: double.infinity,
                                          height: 56,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "เข้าสู่ระบบ / Login",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
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
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Build version ${AppConfig.buildVersion}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Release date ${AppConfig.buildDate}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      elevation: 12,
                      shadowColor: Colors.black38,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              color: Colors.red[400],
                              size: 72,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'ไม่สามารถเชื่อมต่ออินเทอร์เน็ต',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ตของท่าน แล้วลองใหม่อีกครั้ง',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2DAC7B),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              ),
                              onPressed: _checkInternet,
                              child: const Text(
                                'ลองใหม่อีกครั้ง',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        controller: passwordText,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'Password / รหัสผ่าน',
          labelStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF2DAC7B),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2DAC7B), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        validator: (String? value) {
          if (value == null || value.isEmpty || value.length < 1) {
            return "กรุณากรอกรหัสผ่าน";
          }
          return null;
        },
        onSaved: (String? value) {
          _formData['password'] = value;
        },
      ),
    );
  }

  Widget buildUsernameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        controller: usernameText,
        decoration: InputDecoration(
          labelText: 'Username / ชื่อผู้ใช้งาน',
          labelStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
          prefixIcon: const Icon(
            Icons.person_outline_rounded,
            color: Color(0xFF2DAC7B),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2DAC7B), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        validator: (String? value) {
          if (value == null || value.isEmpty || value.length < 1) {
            return 'กรุณากรอกชื่อผู้ใช้';
          }
          return null;
        },
        onSaved: (String? value) {
          _formData['username'] = value;
        },
      ),
    );
  }

  Widget builRememberMe() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () {
          setState(() {
            isChecked = !isChecked;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isChecked,
                  activeColor: const Color(0xFF2DAC7B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "จดจำเพื่อเข้าระบบครั้งต่อไป",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
