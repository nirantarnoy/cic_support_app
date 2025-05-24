import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Test2FaPage extends StatefulWidget {
  Test2FaPage({Key? key}) : super(key: key);

  @override
  State<Test2FaPage> createState() => _Test2FaPageState();
}

class _Test2FaPageState extends State<Test2FaPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? verificationId;

  @override
  void initState() {
    sendOTP("+66 0887692818");

    super.initState();
  }

  Future<void> sendOTP(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Optional: Auto login for some devices
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Error: ${e.message}");
      },
      codeSent: (String verId, int? resendToken) {
        verificationId = verId;
        print("OTP Sent!");
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  Future<void> verifyOTP(String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: smsCode,
    );
    await _auth.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
