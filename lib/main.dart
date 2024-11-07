import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qedic/utility/Commons.dart';
import 'package:qedic/utility/LocalNotificationService.dart';

import 'HomeActivty.dart';
import 'LoginActivity.dart';
import 'firebase_options.dart';
import 'utility/HexColor.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // LocalNotificationService.createDisplayNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LocalNotificationService localNotificationService =
      LocalNotificationService();
  @override
  void initState() {
    super.initState();
    localNotificationService.requestnotificationpermition();
    localNotificationService.initlocalnotification();
    localNotificationService.firebaseInit();

    Timer(const Duration(seconds: 3), () async {
      if (await Commons.getloginstatus()) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeActivity()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginActivity()));
        // context, MaterialPageRoute(builder: (context) => ImageTest()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: HexColor(HexColor.primary_s),
        statusBarIconBrightness: Brightness.light));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: HexColor(HexColor.white),
        body: Container(
          color: HexColor(HexColor.primary_s),
          height: double.infinity,
          child: Center(
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 50),
                child: const Image(
                    color: Colors.white,
                    image: AssetImage('images/q_logo.png'))),
          ),
        ),
      ),
    );
  }
}
