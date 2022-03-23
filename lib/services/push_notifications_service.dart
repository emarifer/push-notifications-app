import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationsService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;

  static final StreamController<String> _messageStreamController =
      StreamController.broadcast();

  static Stream<String> get messageStream => _messageStreamController.stream;

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future _backgroundHandler(RemoteMessage message) async {
    // print('onBackgroundHandler: ${message.messageId}');
    _messageStreamController.add(message.data['product'] ?? 'No Data');
  }

  static Future _onMessageHandler(RemoteMessage message) async {
    // print('onMessageHandler: ${message.messageId}');

    _messageStreamController.add(message.data['product'] ?? 'No Data');

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    RemoteNotification? notification = message.notification;
    String iconName = const AndroidInitializationSettings('@mipmap/ic_launcher')
        .defaultIcon
        .toString();

    // Si `onMessage` es activado con una notificación, construimos nuestra propia
    // notificación local para mostrar a los usuarios, usando el canal creado.
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description, icon: iconName),
          ));
    }
  }

  static Future _onMessageOpenApp(RemoteMessage message) async {
    // print('onMessageOpenApp: ${message.messageId}');
    _messageStreamController.add(message.data['product'] ?? 'No Data');
  }

  static Future initializeApp() async {
    //Push Notifications
    await Firebase.initializeApp();
    token = await FirebaseMessaging.instance.getToken();
    print('Token: $token');

    //Handlers
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);

    //Local Notifications
  }

  static closeStreams() {
    _messageStreamController.close();
  }
}

/**
 * Solución a mostrar las notificaciones cuando la App está abierta (Android). VER:
 * https://www.udemy.com/course/flutter-ios-android-fernando-herrera/learn/lecture/26303768#questions/15202366
 * https://firebase.flutter.dev/docs/messaging/notifications/#application-in-foreground
 */
