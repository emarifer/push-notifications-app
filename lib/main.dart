import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import './screens/screens.dart';
import './services/push_notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationsService.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();

    PushNotificationsService.messaging
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        final snackBar = SnackBar(content: Text(message.data['product']));
        messengerKey.currentState?.showSnackBar(snackBar);
        navigatorKey.currentState
            ?.pushNamed('message', arguments: message.data['product']);
      }
    });

    // Tenemos acceso al contexto, pero en un punto alto de la aplicacion
    PushNotificationsService.messageStream.listen((message) {
      // print('MyApp: $message');

      navigatorKey.currentState?.pushNamed('message', arguments: message);

      messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      initialRoute: 'home',
      navigatorKey: navigatorKey, // Hacer Navegacion
      scaffoldMessengerKey: messengerKey, // Mostrar Snackbars
      routes: {
        'home': (_) => const HomeScreen(),
        'message': (_) => const MessageScreen()
      },
    );
  }
}

/**
 * HABILITAR MULTIDEX PARA VERSIONES DE ANDROID INFERIORES A LA 21. VER:
 * https://firebase.flutter.dev/docs/manual-installation/android/#enabling-multidex
 * 
 * https://stackoverflow.com/questions/56428612/missing-default-notification-channel-metadata-in-androidmanifest-in-flutter
 * 
 * Solución a mostrar las notificaciones cuando la App está abierta (Android). VER:
 * https://www.udemy.com/course/flutter-ios-android-fernando-herrera/learn/lecture/26303768#questions/15202366
 * https://firebase.flutter.dev/docs/messaging/notifications/#application-in-foreground
 * 
 * Cuando la aplicación esta cerrada no me navega a la siguiente pantalla. VER:
 * https://www.udemy.com/course/flutter-ios-android-fernando-herrera/learn/lecture/14951478#questions/14874092
 * https://firebase.flutter.dev/docs/messaging/notifications/#handling-interaction
 */
