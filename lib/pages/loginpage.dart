import 'package:flutter/material.dart';
import 'package:flutter_cic_support/pages/mainpage.dart';
import 'package:flutter_cic_support/providers/person.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
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

  @override
  void initState() {
    // TODO: implement initState
    //Provider.of<PersonData>(context, listen: false).fetchPerson();
    super.initState();
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

    if (res) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserData users = Provider.of<UserData>(context, listen: false);

    return Scaffold(
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
                    color: Colors.purple,
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
                ],
              )),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                child: InkWell(
                  onTap: () => _submitForm(users.login),
                  // onTap: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (contex) => MainPage(),
                  //     ),
                  //   );
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
            'version 0.1',
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
}
