import 'package:flutter/material.dart';

import '../services/push_notifications_service.dart';

class CustomFloatingActions extends StatelessWidget {
  const CustomFloatingActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        FloatingActionButton(
          heroTag: 'subscribe', // VER NOTA ABAJO:
          tooltip: 'Suscribirse a las notificaciones',
          child: const Icon(
            Icons.subscriptions,
            size: 30,
          ),
          backgroundColor: Colors.blue.shade600,
          onPressed: () async {
            PushNotificationsService.subscription();
          },
        ),
        FloatingActionButton(
          heroTag: 'unsubscribe', // VER NOTA ABAJO:
          tooltip: 'Desuscribirse de las notificaciones',
          child: const Icon(
            Icons.unsubscribe,
            size: 30,
          ),
          backgroundColor: Colors.redAccent.shade400,
          onPressed: () async {
            PushNotificationsService.unsubscription();
          },
        ),
      ],
    );
  }
}

/**
 * PARA EVITAR EL ERROR [FlutterError (There are multiple heroes that share the same tag within a subtree]. VER:
 * https://stackoverflow.com/questions/51125024/there-are-multiple-heroes-that-share-the-same-tag-within-a-subtree
 */