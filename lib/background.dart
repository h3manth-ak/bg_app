import 'dart:async';
// import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart' as perm;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    print('hiiiyyy f');
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      print('hiiiyyy b');
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  print('hiiiyyy ee');

  // Initialize location tracking
  // final geolocator = Geolocator();
  Position? currentLocation;
  print('hiiiyyy be');

  // Request location permission if not granted
  // perm.PermissionStatus status = await perm.Permission.locationAlways.request();
  var serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  print('hiiiyyy afe');
  Geolocator.getPositionStream().listen((Position newPosition) {
    currentLocation = newPosition;
    print('hiii');
    print(currentLocation);

    // Update foreground notification with location info
    if (service is AndroidServiceInstance && currentLocation != null) {
      service.setForegroundNotificationInfo(
        title: "Test app",
        content:
            "Latitude: ${currentLocation!.latitude}, Longitude: ${currentLocation!.longitude}",
      );
    }
  });

  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        // Update foreground notification with location info
        if (currentLocation != null) {
          service.setForegroundNotificationInfo(
            title: "Test app",
            content:
                "Latitude: ${currentLocation!.latitude}, Longitude: ${currentLocation!.longitude}",
          );
        }
      }
    }

    // Perform other background operations

    print('background-running');
    print('testing background');
    print(currentLocation.toString());
    print(DateTime.now());
    String pos = currentLocation.toString();
    String date = DateTime.now().toString();
    String not_id = new Random().nextInt(100000).toString();
    service.invoke('update');
    Future<void> _showNotification(
      String location,
      String name,
      String notificationId,
    ) async {
      // final uniqueId = sha1.convert(utf8.encode(location + name)).toString();
      final uniqueId = new Random().nextInt(100000).toString();
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        uniqueId.hashCode,
        'Alarm',
        '$name',
        platformChannelSpecifics,
        payload: notificationId,
      );
    }
    _showNotification(pos, date, not_id);
  });
}
