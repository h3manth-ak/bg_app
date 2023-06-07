import 'package:bg_app/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permiss';
import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  // Request notification permission if denied
  final notificationPermissionStatus = await Permission.notification.status;
  if (notificationPermissionStatus.isDenied) {
    await Permission.notification.request();
  }
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Initialize the background service
  
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Initialize the background service
  await initializeService();

  runApp(const MyApp());
}
// String changer='game_changer';

// void onStart(){

// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String text='stop service';

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test application'),

      ),
      body: SafeArea(child: Center( child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          ElevatedButton(onPressed: (){
            FlutterBackgroundService().invoke('setAsForeground');
          }, 
          child: const Text("fgnd")),
          ElevatedButton(onPressed: (){
            FlutterBackgroundService().invoke('setAsBackground');
          }, 
          child: const Text('background')),
          ElevatedButton(onPressed: () async{
            // FlutterBackgroundService().invoke('stopService');
            final service=FlutterBackgroundService();

            bool isRunning=await service.isRunning();
            if(isRunning){
              service.invoke('stopService');
              setState(() {
                text='start service';
              });
            }else{
              service.startService();
              setState(() {
                text='stop service';
              });
            }
          },
          child:  Text(text)),
        ]
      ),)),
    );
      
  }
}
