import 'package:flutter/material.dart';
import 'package:flutter_cic_support/pages/loginpage.dart';
import 'package:flutter_cic_support/pages/mainpage.dart';

import 'package:flutter_cic_support/pages/memberteam.dart';
import 'package:flutter_cic_support/pages/profile.dart';
import 'package:flutter_cic_support/providers/car.dart';
import 'package:flutter_cic_support/providers/person.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_cic_support/providers/teamnotify.dart';
import 'package:flutter_cic_support/providers/topicitem.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_cic_support/providers/person.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
  void configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 5000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.yellow
      ..backgroundColor = Colors.green
      ..indicatorColor = Colors.yellow
      ..textColor = Colors.yellow
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = true
      ..dismissOnTap = false;
    //..customAnimation = CustomAnimation();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<PersonData>.value(value: PersonData()),
          ChangeNotifierProvider<UserData>.value(value: UserData()),
          ChangeNotifierProvider<TopicItemData>.value(value: TopicItemData()),
          ChangeNotifierProvider<PlanData>.value(value: PlanData()),
          ChangeNotifierProvider<CarData>.value(value: CarData()),
          ChangeNotifierProvider<TeamnotifyData>.value(value: TeamnotifyData()),
          ChangeNotifierProvider<PersonData>.value(value: PersonData())
        ],
        child: Consumer<UserData>(
          builder: (context, _users, _) {
            _users.autoAuthenticate();
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'CIC Support',
              theme: ThemeData(
                // This is the theme of your application.
                //
                // Try running your application with "flutter run". You'll see the
                // application has a blue toolbar. Then, without quitting the app, try
                // changing the primarySwatch below to Colors.green and then invoke
                // "hot reload" (press "r" in the console where you ran "flutter run",
                // or simply save your changes to "hot reload" in a Flutter IDE).
                // Notice that the counter didn't reset back to zero; the application
                // is not restarted.
                primarySwatch: Colors.blue,
                fontFamily: 'Kanit-Regular',
              ),
              home: LoginPage(),
              routes: {
                ProfilePage.routeName: (ctx) => ProfilePage(),
              },
              builder: EasyLoading.init(),
            );
          },
        ));
  }
}
