import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Screens/auth/login_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_screen.dart';
import 'package:flutter_application_1/Screens/langauage_select_screen.dart';
import 'package:flutter_application_1/Screens/splash_screen.dart';
import 'package:flutter_application_1/app_traslate.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreference().initialAppPreference();
  await checkCallPermissions();
  await initializeNotifications();
  await requestNotificationPermission();
  await checkOverlayPermission();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // final prefs = await SharedPreferences.getInstance();
  final langCode = AppPreference().getString(
    PreferencesKey.selected_language,
    defValue: "en",
  );

  final translations = await AppTranslations.loadJsonTranslations();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  runApp(
    ProviderScope(child: MyApp(langCode: langCode, translations: translations)),
  );
}

Future<void> checkOverlayPermission() async {
  bool isGranted = await FlutterOverlayWindow.isPermissionGranted();

  if (!isGranted) {
    final result = await FlutterOverlayWindow.requestPermission();
    if (result!) {
      // User denied or system blocked it
      print("Overlay permission denied or blocked by system.");
      // Optional: Show alert dialog or redirect to settings
    } else {
      print("Overlay permission granted.");
    }
  }
}

Future<bool> checkCallPermissions() async {
  if (Platform.isAndroid) {
    final phoneStatus = await Permission.phone.request();

    if (phoneStatus.isGranted) {
      return true;
    } else {
      print("Phone permission not granted.");
      return false;
    }
  }
  return false;
}

class OverlayPopupApp extends StatelessWidget {
  const OverlayPopupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "👋 Hello from Overlay Popup!",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    FlutterOverlayWindow.closeOverlay();
                  },
                  child: Text("Close"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final String langCode;
  final Map<String, Map<String, String>> translations;

  const MyApp({Key? key, required this.langCode, required this.translations})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: AppTranslations(translations),
      locale: Locale(langCode),
      debugShowCheckedModeBanner: false,
      fallbackLocale: const Locale('en'),
      title: 'Diginet Solution',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: RippleSplashScreen(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> toggleOverlayPopup() async {
    final isActive = await FlutterOverlayWindow.isActive();

    if (isActive) {
      print("🔴 Overlay is active — closing it");
      await FlutterOverlayWindow.closeOverlay();
    } else {
      print("🟢 Overlay is inactive — opening it");

      final isGranted = await FlutterOverlayWindow.isPermissionGranted();
      if (!isGranted) {
        await FlutterOverlayWindow.requestPermission();
      }

      await FlutterOverlayWindow.showOverlay(
        height: 200,
        width: 300,
        alignment: OverlayAlignment.center,
        enableDrag: true,
        flag: OverlayFlag.defaultFlag,
        overlayTitle: "Overlay Title",
        overlayContent: "Hello from Popup Overlay!",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page")),
      body: Center(
        child: ElevatedButton(
          onPressed: toggleOverlayPopup,
          child: Text("Toggle Overlay"),
        ),
      ),
    );
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> requestNotificationPermission() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  if (androidImplementation != null) {
    final bool? granted =
        await androidImplementation.requestNotificationsPermission();
    print("Notification permission granted: $granted");
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      print("Notification clicked with payload: $payload");

      if (payload == 'call_summary') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const StackDashboard()),
        );
      }
    },
  );
}

Future<void> showCallEndedNotification(String number, String duration) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'call_channel_id',
        'Call Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    'Call Ended with $number',
    'Duration: $duration',
    platformChannelSpecifics,
  );
}

class CardDealGame extends StatefulWidget {
  @override
  _CardDealGameState createState() => _CardDealGameState();
}

class _CardDealGameState extends State<CardDealGame>
    with SingleTickerProviderStateMixin {
  final cardSize = Size(30, 40);
  final Offset dealerPosition = Offset(150, 300);

  List<Offset> playerPositions = [
    Offset(50, 100), // Player 1
    Offset(250, 100), // Player 2
    Offset(150, 500), // Player 3
  ];

  List<List<Widget>> playerCards = [[], [], []];

  bool showFlyingCard = false;
  Offset flyingCardTarget = Offset(150, 300);
  Offset flyingCardStart = Offset(150, 300);
  double rotation = 0;

  Future<void> dealCardsWithFlyingEffect() async {
    for (int cardNo = 0; cardNo < 4; cardNo++) {
      for (int i = 0; i < playerPositions.length; i++) {
        setState(() {
          flyingCardStart = dealerPosition;
          flyingCardTarget = playerPositions[i];
          showFlyingCard = true;
          rotation = 0;
        });

        await Future.delayed(Duration(milliseconds: 50));

        setState(() {
          rotation = 2; // rotate during move
        });

        await Future.delayed(Duration(milliseconds: 400));

        setState(() {
          playerCards[i].add(_buildStaticCard());
          showFlyingCard = false;
        });

        await Future.delayed(Duration(milliseconds: 150));
      }
    }
  }

  Widget _buildStaticCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Image.asset(
        'assets/images/card.png',
        width: cardSize.width,
        height: cardSize.height,
      ),
    );
  }

  Widget buildFlyingCard() {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: flyingCardStart, end: flyingCardTarget),
      duration: Duration(milliseconds: 400),
      onEnd: () {},
      builder: (context, value, child) {
        return Positioned(
          left: value.dx,
          top: value.dy,
          child: Transform.rotate(
            angle: rotation,
            child: Image.asset(
              'assets/images/card.png',
              width: cardSize.width,
              height: cardSize.height,
            ),
          ),
        );
      },
    );
  }

  Widget buildPlayer(int index) {
    return Positioned(
      left: playerPositions[index].dx,
      top: playerPositions[index].dy,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.black,
            radius: 25,
            child: Text("P${index + 1}", style: TextStyle(color: Colors.white)),
          ),
          Row(children: playerCards[index]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      body: Stack(
        children: [
          // Players
          ...List.generate(3, (index) => buildPlayer(index)),

          // Flying Card Animation
          if (showFlyingCard) buildFlyingCard(),

          // Button
          Positioned(
            bottom: 40,
            left: 120,
            child: ElevatedButton(
              onPressed: dealCardsWithFlyingEffect,
              child: Text("DEAL CARDS"),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ FLUTTER FULL CODE FILE FOR flutter_callkit_incoming SETUP
// Works for Android (including app closed/background)
// ✅ FLUTTER FULL CODE FILE FOR flutter_callkit_incoming SETUP WITH UI LIKE SCREENSHOT
// Works for Android (including app closed/background)

// ✅ FLUTTER FULL CODE FILE FOR flutter_callkit_incoming SETUP WITH UI LIKE SCREENSHOT
// Works for Android (including app closed/background)

// ✅ FLUTTER FULL CODE FILE FOR flutter_callkit_incoming SETUP WITH UI LIKE SCREENSHOT
// Works for Android (including app closed/background)

// import 'package:flutter/material.dart';
// import 'package:flutter_callkit_incoming/entities/call_event.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:flutter_callkit_incoming/entities/android_params.dart';
// import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// import 'package:flutter_callkit_incoming/entities/notification_params.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:uuid/uuid.dart';
// import 'dart:async';

// final _uuid = Uuid();
// DateTime? _callStartTime;
// String? _lastCaller;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   runApp(const MyApp());
// }

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   debugPrint('✅ [BG] Message received: \${message.data}');
//   await showIncomingCall(message);
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   String? _caller;

//   @override
//   void initState() {
//     super.initState();
//     _setupFirebaseMessaging();
//     _setupCallEvents();
//     requestPermissions();
//   }

//   void requestPermissions() async {
//     await FlutterCallkitIncoming.requestNotificationPermission({
//       "title": "Notification permission",
//       "rationaleMessagePermission": "Notification permission is required to show calls.",
//       "postNotificationMessageRequired": "Allow notification permission from settings."
//     });
//   }

//   void _setupFirebaseMessaging() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//     NotificationSettings settings = await messaging.requestPermission();
//     debugPrint('🔔 Permission status: \${settings.authorizationStatus}');

//     final token = await messaging.getToken();
//     debugPrint('🎯 FCM Token: \$token');

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       debugPrint('📥 Foreground Message: \${message.data}');
//       setState(() => _caller = message.data['name'] ?? 'Unknown Caller');
//       showIncomingCall(message);
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       debugPrint('📲 Message opened from background: \${message.data}');
//     });
//   }

//   void _setupCallEvents() {
//     FlutterCallkitIncoming.onEvent.listen((event) async {
//       debugPrint('📞 CallKit Event: \$event');

//       if (event!.event == Event.actionCallStart) {
//         _callStartTime = DateTime.now();
//       }

//       if (event.event == Event.actionCallEnded || event.event == Event.actionCallDecline) {
//         final callEndTime = DateTime.now();
//         final duration = _callStartTime != null
//             ? callEndTime.difference(_callStartTime!)
//             : Duration.zero;

//         _showEndCallPopup(duration);
//       }
//     });
//   }

//   void _showEndCallPopup(Duration duration) {
//     final minutes = duration.inMinutes;
//     final seconds = duration.inSeconds % 60;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('📴 Call Ended'),
//         content: Text('Call with \${_caller ??  ${minutes}m ${seconds}s.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Demo CallKit UI')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text('📞 Waiting for incoming call...'),
//               if (_caller != null) ...[
//                 const SizedBox(height: 20),
//                 Text('👤 Last Caller: \$_caller')
//               ]
//             ],
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () async {
//             final uuid = _uuid.v4();
//             setState(() => _caller = 'Hien Nguyen');
//             final CallKitParams params = CallKitParams(
//               id: uuid,
//               nameCaller: 'Hien Nguyen',
//               handle: '0123456789',
//               avatar: 'https://i.pravatar.cc/300',
//               type: 0,
//               duration: 30000,
//               textAccept: 'Accept',
//               textDecline: 'Decline',
//               android: const AndroidParams(
//                 isCustomNotification: true,
//                 isShowLogo: true,
//                 logoUrl: 'https://i.pravatar.cc/300',
//                 ringtonePath: 'system_ringtone_default',
//                 backgroundColor: '#0955fa',
//                 backgroundUrl: '',
//                 actionColor: '#4CAF50',
//                 textColor: '#ffffff',
//                 incomingCallNotificationChannelName: "Incoming Call",
//                 missedCallNotificationChannelName: "Missed Call",
//                 isShowCallID: false,
//               ),
//               ios: IOSParams(handleType: 'generic'),
//               missedCallNotification: const NotificationParams(
//                 showNotification: true,
//                 isShowCallback: true,
//                 subtitle: 'Missed call',
//                 callbackText: 'Call back',
//               ),
//               callingNotification: const NotificationParams(
//                 showNotification: true,
//                 isShowCallback: true,
//                 subtitle: 'Calling...',
//                 callbackText: 'Hang Up',
//               ),
//               extra: {'userId': 'demo123'},
//               headers: {'apiKey': 'Abc@123!', 'platform': 'flutter'},
//             );

//             await FlutterCallkitIncoming.showCallkitIncoming(params);
//           },
//           child: const Icon(Icons.call),
//         ),
//       ),
//     );
//   }
// }

// Future<void> showIncomingCall(RemoteMessage message) async {
//   final String currentUuid = _uuid.v4();

//   final CallKitParams params = CallKitParams(
//     id: currentUuid,
//     nameCaller: message.data['name'] ?? 'Unknown Caller',
//     appName: 'Crickies App',
//     avatar: message.data['avatar'] ?? 'https://i.pravatar.cc/100',
//     handle: message.data['number'] ?? '0123456789',
//     type: 0,
//     textAccept: 'Accept',
//     textDecline: 'Decline',
//     duration: 30000,
//     missedCallNotification: const NotificationParams(
//       showNotification: true,
//       isShowCallback: true,
//       subtitle: 'Missed call',
//       callbackText: 'Call back',
//     ),
//     callingNotification: const NotificationParams(
//       showNotification: true,
//       isShowCallback: true,
//       subtitle: 'Calling...',
//       callbackText: 'Hang Up',
//     ),
//     extra: {'userId': message.data['user_id'] ?? 'unknown'},
//     headers: {'apiKey': 'Abc@123!', 'platform': 'flutter'},
//     android: const AndroidParams(
//       isCustomNotification: true,
//       isShowLogo: true,
//       logoUrl: 'https://i.pravatar.cc/100',
//       ringtonePath: 'system_ringtone_default',
//       backgroundColor: '#0955fa',
//       backgroundUrl: '',
//       actionColor: '#4CAF50',
//       textColor: '#ffffff',
//       incomingCallNotificationChannelName: "Incoming Call",
//       missedCallNotificationChannelName: "Missed Call",
//       isShowCallID: false,
//     ),
//     ios: IOSParams(
//       iconName: 'CallKitLogo',
//       handleType: 'generic',
//       supportsVideo: true,
//       maximumCallGroups: 2,
//       maximumCallsPerCallGroup: 1,
//       audioSessionMode: 'default',
//       audioSessionActive: true,
//       audioSessionPreferredSampleRate: 44100.0,
//       audioSessionPreferredIOBufferDuration: 0.005,
//       supportsDTMF: true,
//       supportsHolding: true,
//       supportsGrouping: false,
//       supportsUngrouping: false,
//       ringtonePath: 'system_ringtone_default',
//     ),
//   );

//   // debugPrint('🔔 Showing CallKit UI for: \${message.data['name']}');
//   await FlutterCallkitIncoming.showCallkitIncoming(params);
// }
