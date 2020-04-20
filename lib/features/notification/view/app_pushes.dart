import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppPushs extends StatefulWidget {
  AppPushs({
    @required this.child,
  });

  final Widget child;

  @override
  _AppPushsState createState() => _AppPushsState();
}

class _AppPushsState extends State<AppPushs> {
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _initLocalNotifications();
    _initFirebaseMessaging();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _initLocalNotifications() {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_stat_group');
    const initializationSettingsIOS = IOSInitializationSettings();
    const initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onSelectNotification);
  }

  Future _onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => SecondScreen(payload)),
    // );
  }

  void _initFirebaseMessaging() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('AppPushs onMessage : $message');
        _showNotification(message);
        return;
      },
      onBackgroundMessage: Platform.isIOS ? null : backgroundMessageHandler,
      onResume: (Map<String, dynamic> message) {
        print('AppPushs onResume : $message');
        if (Platform.isIOS) {
          _showNotification(message);
        }
        return;
      },
      onLaunch: (Map<String, dynamic> message) {
        print('AppPushs onLaunch : $message');
        return;
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  static Future<dynamic> backgroundMessageHandler(
    Map<String, dynamic> message,
  ) {
    print('AppPushs backgroundMessageHandler : $message');
    _showNotification(message);
    return Future<void>.value();
  }

  static Future _showNotification(Map<String, dynamic> message) async {
    String pushTitle;
    String pushText;
    String type;
    String payloadQuizId;

    if (Platform.isAndroid) {
      final nodeData = message['data'];
      payloadQuizId = nodeData['quizId'];
      pushTitle = 'Hai kamu dapat kartu!';
      pushText = 'Coba jawab kaartu dari ${nodeData['userSenderUsername']}';
      type = nodeData['action'];
    } else {
      payloadQuizId = message['quizId'];
      pushTitle = 'Hai kamu dapat kartu!';
      pushText = 'Coba jawab kaartu dari ${message['userSenderUsername']}';
      type = message['type'];
    }
    print('AppPushs pushTitle : $pushTitle');
    print('AppPushs pushText : $pushText');
    print('AppPushs pushType : $type');

    final AndroidNotificationDetails platformChannelSpecificsAndroid =
        AndroidNotificationDetails(
      'karabarabChannelId',
      'Perang Kartu',
      'Pemberitahuan Kartu yang dikirim dari lawan',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );

    const platformChannelSpecificsIos =
        IOSNotificationDetails(presentSound: false);
    final platformChannelSpecifics = NotificationDetails(
        platformChannelSpecificsAndroid, platformChannelSpecificsIos);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        0,
        pushTitle,
        pushText,
        platformChannelSpecifics,
        payload: payloadQuizId,
      );
    });
  }
}
