import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_cic_support/providers/store_issue_product.dart';
import 'package:flutter_cic_support/providers/store_issue_productgroup.dart';

import 'package:flutter/material.dart';
import 'package:flutter_cic_support/firebase_options.dart';
import 'package:flutter_cic_support/pages/loginpage.dart';
import 'package:flutter_cic_support/pages/mainpage.dart';

import 'package:flutter_cic_support/pages/memberteam.dart';
import 'package:flutter_cic_support/pages/profile.dart';
import 'package:flutter_cic_support/pages/profilenormal.dart';
import 'package:flutter_cic_support/pages/securitypoint.dart';
import 'package:flutter_cic_support/pages/shirtorderpage.dart';
import 'package:flutter_cic_support/pages/storeissueapprove.dart';
import 'package:flutter_cic_support/pages/test2fa.dart';
import 'package:flutter_cic_support/pages/purchase_approve_list.dart';
import 'package:flutter_cic_support/providers/car.dart';
import 'package:flutter_cic_support/providers/person.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_cic_support/providers/securityplan.dart';
import 'package:flutter_cic_support/providers/shirtemp.dart';
import 'package:flutter_cic_support/providers/storeissue.dart';
import 'package:flutter_cic_support/providers/teamnotify.dart';
import 'package:flutter_cic_support/providers/topicitem.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:flutter_cic_support/providers/purchase_approve.dart';
import 'package:flutter_cic_support/services/localnoti.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigatorKey = GlobalKey<NavigatorState>();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();

  print("Handling a background message: ${message.notification!.body}");
}

String? _getRouteFromMessage(RemoteMessage message) {
  if (message.data['route'] != null) {
    return message.data['route'];
  }
  String title = message.notification?.title ?? '';
  if (title.contains('อนุมัติใบเบิก') || title.contains('เบิกซ้ำซ้อน') || title.contains('สโตร์') || title.contains('เบิกสินค้า')) {
    return 'storeissueapprove';
  }
  return null;
}

Future<void> _handleNavigation(String route) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token != null && token.isNotEmpty) {
    navigatorKey.currentState?.pushNamed(route);
  } else {
    await prefs.setString('pending_route', route);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isWeb = GetPlatform.isWeb;
  if (!isWeb) {
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.initFlutter('hive_db');

    print("not is web platform");

    await Firebase.initializeApp(
        options: DefaultFirebaseOptions
            .currentPlatform); // flutterfire configure and generate Default option
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("have data from firebase");
        String? route = _getRouteFromMessage(message);
        if (route != null) {
          _handleNavigation(route);
        }
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null && message.notification != null) {
        Future.delayed(const Duration(seconds: 2), () {
          String? route = _getRouteFromMessage(message);
          if (route != null) {
            _handleNavigation(route);
          }
        });
      }
    });
    //FirebaseMessaging messaging = FirebaseMessaging.instance;

    // NotificationSettings settings = await messaging.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   sound: true,
    // );

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message in the foreground');
    //   print('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  runApp(const MyApp());
  configLoading();
  setupNotification();
}

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

void setupNotification() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  // messaging.getAPNSToken().then((value) {
  messaging.getToken().then((value) {
    print('Device token is ${value}');
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage _msg) {
    print("message received");
    print(_msg.notification!.body);

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    LocalNoti.initialize(flutterLocalNotificationsPlugin);
    LocalNoti.showBigTextNotification(
        title: '${_msg.notification!.title ?? 'แจ้งเตือน'}',
        body: '${_msg.notification!.body}',
        payload: _getRouteFromMessage(_msg),
        fln: flutterLocalNotificationsPlugin);
  });
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
          ChangeNotifierProvider<PersonData>.value(value: PersonData()),
          ChangeNotifierProvider<StoreissueData>.value(value: StoreissueData()),
          ChangeNotifierProvider<SecurityplanData>.value(
              value: SecurityplanData()),
          ChangeNotifierProvider<ShirtempData>.value(value: ShirtempData()),
          ChangeNotifierProvider<PurchaseApproveProvider>.value(value: PurchaseApproveProvider()),
          ChangeNotifierProvider<ProductData>.value(value: ProductData()),
          ChangeNotifierProvider<ProductgroupData>.value(value: ProductgroupData())
        ],
        child: Consumer<UserData>(
          builder: (context, _users, _) {
            _users.autoAuthenticate();
            return MaterialApp(
              navigatorKey: navigatorKey,
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
              // home: SecurityPointPage(),
              //  home: Test2FaPage(),
              routes: {
                LoginPage.routeName: (ctx) => LoginPage(),
                ProfilePage.routeName: (ctx) => ProfilePage(),
                ProfileNormalPage.routeName: (ctx) => ProfileNormalPage(),
                StoreissueApprovePage.routeName: (ctx) =>
                    StoreissueApprovePage(team_id: ''),
                'purchase_approve': (ctx) => const PurchaseApproveListPage(),
                MainPage.routeName: (ctx) => MainPage(),
                ShirtorderPage.routeName: (ctx) => ShirtorderPage(),
              },
              builder: EasyLoading.init(),
            );
          },
        ));
  }
}
