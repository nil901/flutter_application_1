import 'dart:async';
import 'dart:developer';
import 'package:call_log/call_log.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
import 'package:flutter_application_1/Screens/auth/notifaction_screen.dart';
import 'package:flutter_application_1/Screens/auto_call_dashbard/auto_call_dashbaord.dart';
import 'package:flutter_application_1/Screens/call_logs_history.dart';
import 'package:flutter_application_1/Screens/dashboard_task/dashbord_graf.dart';
import 'package:flutter_application_1/Screens/dashboard_task/due_today_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/pending_follow_ups_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/today_followups_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/towmorrow_screen.dart';
import 'package:flutter_application_1/Screens/leds/leds_from_call.dart';
import 'package:flutter_application_1/Screens/task/task_screen.dart';
import 'package:flutter_application_1/Screens/upload_all_file_wigets.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/api_service/urls.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/global/utils.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/leds_model/branch_model.dart';
import 'package:flutter_application_1/models/leds_model/dashbard_model.dart';
import 'package:flutter_application_1/models/leds_model/get_leads_status_model.dart';
import 'package:flutter_application_1/models/leds_model/sorce_model.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:flutter_application_1/utils/custom_drawer.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';

final dashboardCountProvider = StateProvider<DashboardCountModel?>(
  (ref) => null,
);
Future<void> fetchDashboardCount(WidgetRef ref) async {
  ref.invalidate(dashboardCountProvider);
  final dashboardNotifier = ref.read(dashboardCountProvider.notifier);

  try {
    // Clear previous data
    dashboardNotifier.state = null;

    // API request
    final response = await ApiService().getRequest(dashboardcard);

    if (response != null && response.statusCode == 200) {
      log("ssssssssssssssssssssssss${response.data}");
      final data = DashboardCountModel.fromJson(response.data);
      dashboardNotifier.state = data;
    } else {
      print("Dashboard API returned status: ${response?.statusCode}");
    }
  } catch (e) {
    print("Dashboard Count API Error: $e");
  }
}

class StackDashboard extends ConsumerStatefulWidget {
  const StackDashboard({super.key});

  @override
  ConsumerState<StackDashboard> createState() => _StackDashboardState();
}

class _StackDashboardState extends ConsumerState<StackDashboard>
    with WidgetsBindingObserver {
  static const MethodChannel platform = MethodChannel(
    'com.example.call_tracker',
  );

  bool isLoading = false;
  bool isDialogOpen = false;

  bool _isAppInitiatedCall = false; // (तुझ्या logic साठी ठेवला)
  bool _isIncomingCallRinging = false;
  bool _appInForeground = true;
  bool _handlerAttached = false;

  String _callStatus = '';
  String _incomingNumber = '';
  String _duration = '';

  DateTime? _lastEndedHandledAt;

  bool _didInitialLoad = false;

  CancelToken? _dashCancel; // Dio cancel (optional)
  bool _isFetchingDash = false; // guard

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ First frame नंतर safe call (context/providers ready)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_didInitialLoad) {
        _didInitialLoad = true;
        fetchDashboardCount(ref); // <-- only this
      }
    });

    _startCallTracking("00:00:00");
    _attachCallHandler();
  }

  // ---- Lifecycle: foreground/background ----
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appInForeground = (state == AppLifecycleState.resumed);
  }

  // ---- Attach / Detach platform handler ----
  void _attachCallHandler() {
    if (_handlerAttached) return;
    platform.setMethodCallHandler(_onPlatformCall);
    _handlerAttached = true;
  }

  void _detachCallHandler() {
    if (!_handlerAttached) return;
    platform.setMethodCallHandler(null);
    _handlerAttached = false;
  }

  // ---- Native invoke helpers ----
  Future<void> launchAppFromBackground() async {
    try {
      await platform.invokeMethod('launchAppFromBackground');
    } catch (e) {
      log("Error launching app: $e");
    }
  }

  Future<void> _startCallTracking(String formattedDuration) async {
    try {
      final result = await platform.invokeMethod('startCallTracking');
      if (result != true) {
        if (!mounted) return;
        setState(() {
          _callStatus = 'Permission denied or error starting call tracking';
        });
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _callStatus = 'Failed to start call tracking: ${e.message}';
      });
    }
  }

  // ---- Platform callbacks (single source of truth) ----
  Future<dynamic> _onPlatformCall(MethodCall call) async {
    if (!mounted) return null;

    switch (call.method) {
      case 'onCallRinging':
        {
          final map = (call.arguments is Map) ? (call.arguments as Map) : {};
          final number = (map['number'] as String?) ?? 'Unknown';
          final direction = (map['direction'] as String?) ?? 'unknown';
          log("Incoming call ringing from: $number, direction: $direction");

          if (!mounted) return null;
          setState(() {
            _callStatus = number;
            _incomingNumber = number;
            _isIncomingCallRinging = true;
          });
          break;
        }

      case 'onCallStarted':
        {
          // optional
          break;
        }

      case 'onCallEnded':
        {
          // ✅ duplicate ended debounce (1s)
          final now = DateTime.now();
          if (_lastEndedHandledAt != null &&
              now.difference(_lastEndedHandledAt!).inMilliseconds < 1000) {
            return null;
          }
          _lastEndedHandledAt = now;

          final map = (call.arguments is Map) ? (call.arguments as Map) : {};
          final number = (map['number'] as String?) ?? _incomingNumber;
          final durationMillis = (map['duration'] as int?) ?? 0;

          log("Call Arguments: $map");
          log("isIncomingCallRinging: $_isIncomingCallRinging");

          if (!_isIncomingCallRinging) {
            // outgoing / unknown, UI skip
            return null;
          }

          final secs = (durationMillis / 1000).round();
          final formattedDuration = _formatHMS(secs);

          // ---- Lead Status (safe) ----
          try {
            if (!mounted) return null;
            final resp = await ApiService()
                .postRequest(getLeadStatus, {"mobile": number})
                .timeout(const Duration(seconds: 20));

            if (!mounted) return null;
            final message = resp?.data["message"] as String?;
            final leadData = resp?.data['lead'] as Map<String, dynamic>?;

            final notifier = ref.read(getAllLedsStatusProvider.notifier);
            notifier.state = [];

            if (message == "LeadStatus fetched" && leadData != null) {
              notifier.state = [GetLeadStatusUpdateModel.fromJson(leadData)];
              Utils().showToastMessage('Call from $number ended. $message');
            }
          } catch (e) {
            if (mounted) {
              Utils().showToastMessage("Lead status fetch failed: $e");
            }
          }

          if (mounted) {
            await _startCheckingCallLog(formattedDuration);
          }

          // reset ring flag
          _isIncomingCallRinging = false;
          break;
        }

      default:
        log("Unhandled platform method: ${call.method}");
    }
    return null;
  }

  // ---- Helpers ----
  String _formatHMS(int seconds) {
    final d = Duration(seconds: seconds);
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}";
  }

  PhoneStateStatus status = PhoneStateStatus.NOTHING;
  Stream<PhoneStateStatus>? phoneStateStream;

  Future<void> _startCheckingCallLog(String duration) async {
    final now = DateTime.now();
    final formattedDate = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
    ).format(now);
    log("Call ended at: $formattedDate, duration: $duration");

    // ✅ foreground असलं तरच popup
    if (_appInForeground) {
      _showCallPopupZeroAnim(duration);
    } else {
      // background असल्यास normal dialog टाकू नका; notification/overlay वापरा
      // Utils().showLocalNotification(...)
    }
  }

  // ---- FAST & SAFE POPUP (zero animation + context safety) ----
  void _showCallPopupZeroAnim(String duration) {
    if (!mounted) return;
    if (isDialogOpen) return;
    isDialogOpen = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        isDialogOpen = false;
        return;
      }

      try {
                await showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: 'Call',
          barrierColor: Colors.black45,
          transitionDuration: Duration.zero,
          pageBuilder: (ctx, __, ___) {
            return Align(
              alignment: Alignment.center, // ✅ popup middle मध्ये
              child: Padding(
                padding: EdgeInsets.only(
                  bottom:
                      MediaQuery.of(ctx).viewInsets.bottom, // ✅ keyboard adjust
                  left: 16,
                  right: 16,
                ),
                child: FractionallySizedBox(
                  widthFactor: 0.9, // ✅ 90% screen width (popup feel)
                  heightFactor: 0.9, // ✅ 70% screen height
                  child: Material(
                    color: kwhite,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      child: LedsFromCall(
                        _incomingNumber,
                        duration,
                        duration,
                        0,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
       

        if (!mounted) return;

        if (!mounted) return;

        await showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: 'Call',
          barrierColor: Colors.black45,
          transitionDuration: Duration.zero,
          pageBuilder: (ctx, __, ___) {
            return Align(
              alignment: Alignment.center, // ✅ popup middle मध्ये
              child: Padding(
                padding: EdgeInsets.only(
                  bottom:
                      MediaQuery.of(ctx).viewInsets.bottom, // ✅ keyboard adjust
                  left: 16,
                  right: 16,
                ),
                child: FractionallySizedBox(
                  widthFactor: 0.9, 
                  heightFactor: 0.9, 
                  child: Material(
                    color: kwhite,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      child: LedsFromCall(
                        _incomingNumber,
                        duration,
                        duration,
                        0,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      } catch (e) {
        log("Dialog show failed: $e");
      } finally {
        isDialogOpen = false;
      }
    });
  }

  // ---- तुझं original method (नको असेल तर काढून टाक) ----
  // void showCallPopup(BuildContext context, String duration) { ... }

  // ---- Dummy: तुझं actual impl इथे ----
  // Future<void> fetchDashboardCount(WidgetRef ref) async {
  //   // your logic
  // }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final dashboard = ref.watch(dashboardCountProvider);
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          fetchDashboardCount(ref);
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: kwhite,
          drawer: CustomDrawer(),
          body: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: kOrange,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.only(
                  top: 50,
                  left: 20,
                  right: 20,
                  bottom: 30,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            child: const Icon(Icons.menu, color: Colors.white),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationScreen(),
                                ),
                              );
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.notifications,
                                color: Color(0xFF0C2D57),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "welcome_back".tr,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => PendingFollowUpsScreen(),
                                    ),
                                  );
                                },
                                child: StatCard(
                                  title: "pending_follow_ups".tr,
                                  value: "${dashboard?.pendingFollowups ?? 0}",
                                  icon: Icons.warning_amber_outlined,
                                  cardColor: const Color(0xFFFFEBEE),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DueTodayScreen(),
                                    ),
                                  );
                                },
                                child: StatCard(
                                  title: "due_today".tr,
                                  value: "${dashboard?.todayFollowups ?? 0}",
                                  icon: Icons.calendar_today_outlined,
                                  cardColor: const Color(0xFFE1F5FE),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => TowmorrowFollowUps(),
                                    ),
                                  );
                                },
                                child: StatCard(
                                  title: "tomorrow_follow_ups".tr,
                                  value: "${dashboard?.tomorrowFollowups ?? 0}",
                                  icon: Icons.report_problem_outlined,
                                  cardColor: const Color(0xFFE8F5E9),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => TodayFollowupsScreen(),
                                    ),
                                  );
                                },
                                child: StatCard(
                                  title: "total_leads".tr,
                                  value: "${dashboard?.totalLeads ?? 0}",
                                  icon: Icons.folder_open_outlined,
                                  cardColor: const Color(0xFFFFF3E0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Recent Activities
                        recentActivitiesSection(),
                        const SizedBox(height: 10),

                        // Upload Button
                        InkWell(
                          onTap: () {
                            showIntroUploadDialog(context);
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              alignment: Alignment.center,
                              height: 45,
                              width: 120,
                              decoration: BoxDecoration(
                                color: kOrange,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/upload.png",
                                    color: Colors.white,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    "Upload",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Auto Call Graph
                        AutoCallDashBoardGraf(),

                        const SizedBox(height: 100), // space for FAB
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating Button
          floatingActionButton: FloatingActionButton(
            backgroundColor: kOrange,
            onPressed: () {
              Navigator.of(context).push(_createRoute());
            },
            child: const Icon(Icons.dialpad, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void showIntroUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: kwhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: UploadIntroductionWidget(),
        );
      },
    );
  }

  Widget recentActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'recent_activities'.tr,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            activityCard(
              title: 'call_log'.tr,
              icon: Icons.call, // 👈 only call icon
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallHistoryScreen(""),
                  ),
                );
              },
            ),
            SizedBox(width: 10),
            activityCard(
              title: 'add_task'.tr,
              icon: Icons.loupe, // 👈 task icon
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget activityCard({
    required String title,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.teal[50],
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(radius: 12, child: Icon(icon, size: 15)),
                    SizedBox(width: 5),
                    Text(
                      '2+',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder:
          (context, animation, secondaryAnimation) => DialPadScreen(""),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0); // from bottom
        const end = Offset.zero;
        const curve = Curves.easeOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color cardColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top-left circular icon
          CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 224, 140, 140),
            radius: 14,
            child: Icon(icon, size: 16, color: cardColor),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C2D57),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class DialPadScreen extends ConsumerStatefulWidget {
  const DialPadScreen(this.mobile, {super.key});
  final mobile;

  @override
  ConsumerState<DialPadScreen> createState() => _DialPadScreenState();
}

class _DialPadScreenState extends ConsumerState<DialPadScreen> {
  final EventChannel _callEventChannel = const EventChannel(
    'com.example.crm_app/callEvents',
  );

  Timer? _timer;
  Timer? _callLogTimer;
  StreamSubscription<PhoneState?>? _phoneSub;

  int callSeconds = 0;
  bool isCalling = false;

  bool _isAppInitiatedCall = false; // app मधून केलेल्या कॉलसाठीच popup
  bool isDialogOpen = false; // re-entrancy gate
  bool _popupShownForThisCall = false; // per-call single popup
  DateTime? _lastEndedHandledAt; // duplicate ENDED debounce

  String enteredNumber = '';
  String _calledNumber = '';
  String _callStatus = 'Status: Waiting for call...';
  String _callDuration = '00:00:00';

  final List<String> buttons = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '*',
    '0',
    '#',
  ];

  @override
  void initState() {
    super.initState();
    enteredNumber = widget.mobile ?? '';

    // तुझे init calls
    branchApi(ref);
    scorceApi(ref);

    requestPermission();
    _listenToPhoneState();
    // listenToNativeCallEvents(); // वापरत असशील तर
  }

  // -------- Permissions --------
  Future<bool> requestPermission() async {
    final status = await Permission.phone.request();
    return switch (status) {
      PermissionStatus.denied ||
      PermissionStatus.restricted ||
      PermissionStatus.limited ||
      PermissionStatus.permanentlyDenied => false,
      PermissionStatus.provisional || PermissionStatus.granted => true,
    };
  }

  // -------- Dial / Make Call --------
  Future<void> _makeCall() async {
    setState(() {
      _callDuration = '00:00:00';
      _callStatus = 'Status: Waiting for call...';
      callSeconds = 0;
      _popupShownForThisCall = false; // reset per call
    });

    if (enteredNumber.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a number')));
      return;
    }

    final granted = await requestPermission();
    if (!granted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Permission denied')));
      return;
    }

    _callLogTimer?.cancel();
    _isAppInitiatedCall = true; // ✅ app-initiated

    await FlutterPhoneDirectCaller.callNumber(enteredNumber);
  }

  // -------- Phone state stream --------
  void _listenToPhoneState() {
    _phoneSub?.cancel();
    _phoneSub = PhoneState.stream.listen((PhoneState? event) async {
      if (event == null) return;

      if (event.status == PhoneStateStatus.CALL_STARTED) {
        // timer सुरू
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() {
            callSeconds++;
            _callDuration = _formatHMS(callSeconds);
          });
        });
        if (mounted) {
          setState(() {
            isCalling = true;
            _callStatus = 'Status: Call in progress...';
            // नवीन कॉल
            _popupShownForThisCall = false;
          });
        }
      } else if (event.status == PhoneStateStatus.CALL_INCOMING) {
        // heavy काही करू नये; फक्त log
        // print('Incoming...');
      } else if (event.status == PhoneStateStatus.CALL_ENDED) {
        // duplicate ENDED debounce (~1.2s)
        final now = DateTime.now();
        if (_lastEndedHandledAt != null &&
            now.difference(_lastEndedHandledAt!).inMilliseconds < 1200) {
          return;
        }
        _lastEndedHandledAt = now;

        _timer?.cancel();
        _timer = null;

        // Lead Status (safe)
        try {
          final leadStatusResponse = await ApiService()
              .postRequest(getLeadStatus, {"mobile": _normalize(enteredNumber)})
              .timeout(const Duration(seconds: 20));
          final message = leadStatusResponse?.data["message"] as String?;
          final leadData =
              leadStatusResponse?.data['lead'] as Map<String, dynamic>?;
          final notifier = ref.read(getAllLedsStatusProvider.notifier);
          notifier.state = [];
          if (message == "LeadStatus fetched" && leadData != null) {
            notifier.state = [GetLeadStatusUpdateModel.fromJson(leadData)];
          } else {
            Utils().showToastMessage(message ?? 'Failed to fetch lead status');
          }
        } catch (e) {
          // swallow
        }

        // call log retry + popup
        await _startCheckingCallLogWithRetry();

        if (mounted) {
          setState(() {
            isCalling = false;
          });
        }
      }
    });
  }

  // -------- CallLog retry + popup --------
  Future<void> _startCheckingCallLogWithRetry() async {
    if (!_isAppInitiatedCall) {
      // external call; popup नको
      return;
    }
    if (_popupShownForThisCall) return;

    const tries = 4;
    for (int i = 0; i < tries; i++) {
      final entry = await _findLatestMatchingEntry(
        dialed: _normalize(enteredNumber),
      );
      if (entry != null) {
        final secs = (entry.duration ?? 0).toInt();
        final formatted = _formatHMS(secs);
        _showCallPopupSafe(durationSeconds: secs, formatted: formatted);

        _isAppInitiatedCall = false;
        _popupShownForThisCall = true;

        if (mounted) {
          setState(() {
            _callDuration = formatted;
            _callStatus = 'Status: Call Ended';
          });
        }
        return;
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }

    // fallback — आपल्या timer वरून duration
    final fallback = _formatHMS(callSeconds);
    _showCallPopupSafe(durationSeconds: callSeconds, formatted: fallback);
    _isAppInitiatedCall = false;
    _popupShownForThisCall = true;

    if (mounted) {
      setState(() {
        _callDuration = fallback;
        _callStatus = 'Status: Call Ended';
      });
    }
  }

  Future<CallLogEntry?> _findLatestMatchingEntry({
    required String dialed,
  }) async {
    try {
      final entries = await CallLog.get();
      for (final e in entries) {
        final numStr = _normalize(e.number ?? '');
        if (numStr.isEmpty) continue;
        if (numStr.endsWith(dialed) || dialed.endsWith(numStr)) {
          return e;
        }
      }
    } catch (_) {}
    return null;
  }

  // -------- Popup (crash-safe + zero-anim) --------
  void _showCallPopupSafe({
    required int durationSeconds,
    required String formatted,
  }) {
    if (!mounted) return;
    if (isDialogOpen) return;
    isDialogOpen = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        isDialogOpen = false;
        return;
      }
      try {
        await showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: 'Call',
          barrierColor: Colors.black45,
          transitionDuration: Duration.zero,
          pageBuilder: (ctx, __, ___) {
            return Align(
              alignment: Alignment.center, // ✅ popup middle मध्ये
              child: Padding(
                padding: EdgeInsets.only(
                  bottom:
                      MediaQuery.of(ctx).viewInsets.bottom, // ✅ keyboard adjust
                  left: 16,
                  right: 16,
                ),
                child: FractionallySizedBox(
                  widthFactor: 0.9, // ✅ 90% screen width (popup feel)
                  heightFactor: 0.9, // ✅ 70% screen height
                  child: Material(
                    color: kwhite,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      child: LedsFromCall(
                        _normalize(enteredNumber),
                        durationSeconds,
                        formatted,
                        1,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      } catch (e) {
        log("Dialog show failed: $e");
      } finally {
        isDialogOpen = false;
      }
    });
  }

  // -------- Helpers --------
  String _normalize(String s) {
    final t = s.replaceAll(RegExp(r'[\s\-()]'), '');
    return t.startsWith('+91') ? t.substring(3) : t;
  }

  String _formatHMS(int seconds) {
    final d = Duration(seconds: seconds);
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}";
  }

  // -------- UI helpers (तुझ्या existing UI प्रमाणेच) --------
  void addNumber(String number) {
    if (!isCalling) {
      setState(() => enteredNumber += number);
    }
  }

  void deleteLastDigit() {
    if (!isCalling && enteredNumber.isNotEmpty) {
      setState(() {
        enteredNumber = enteredNumber.substring(0, enteredNumber.length - 1);
      });
    }
  }

  Future<void> pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      setState(() => enteredNumber = data!.text!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Number pasted from clipboard')),
      );
    }
  }

  Future<void> _startCall() async {
    final number = enteredNumber.trim();
    if (number.isNotEmpty) {
      _calledNumber = number;
      final permission = await Permission.contacts.request();
      if (permission.isGranted) {
        // Optional: contact name fetch
      }
      await FlutterPhoneDirectCaller.callNumber(number);
    }
  }

  void endCall() {
    _timer?.cancel();
    final duration = callSeconds;
    setState(() {
      isCalling = false;
      callSeconds = 0;
    });

    if (!isDialogOpen && mounted) {
      isDialogOpen = true;
      final TextEditingController feedbackController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Call Ended'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Call Duration: ${duration ~/ 60} min ${duration % 60} sec",
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: feedbackController,
                  decoration: const InputDecoration(labelText: 'Feedback'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  isDialogOpen = false;
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _callLogTimer?.cancel();
    _phoneSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String callTime =
        "${(callSeconds ~/ 60).toString().padLeft(2, '0')}:${(callSeconds % 60).toString().padLeft(2, '0')}";
    // final contactsState = ref.watch(contactsProvider);
    // final filteredContacts = contactsState.filteredContacts;
    // print(_callDuration);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // InkWell(
              //   onTap: () {
              //     // showCallPopup(context);
              //   },
              //   child: Text(_callDuration),
              // ),
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: Colors.black, size: 40),
                ),
              ),
              const SizedBox(height: 150),
              InkWell(
                onLongPress: () {
                  pasteFromClipboard();
                },
                child: TextField(
                  controller: TextEditingController(
                    text: enteredNumber.replaceFirst('+91', ''),
                  ),

                  enabled: false, // read-only
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(),
              ),
              // if (isCalling)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 8.0),
              //     child: Text(
              //       callTime,
              //       style: const TextStyle(fontSize: 20, color: Colors.grey),
              //     ),
              //   ),
              const SizedBox(height: 30),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  itemCount: buttons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 25,
                    crossAxisSpacing: 35,
                  ),
                  itemBuilder: (context, index) {
                    return DialButton(
                      text: buttons[index],
                      onTap: () => addNumber(buttons[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //  const SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      _navigateToContactList(context);
                    },
                    child: const Icon(Icons.contacts, size: 30),
                  ),
                  GestureDetector(
                    onTap: () {
                      print(enteredNumber);
                      String cleanedNumber = enteredNumber.replaceAll(
                        RegExp(r'[^0-9]'),
                        '',
                      );

                      // Remove country code if present
                      if (cleanedNumber.startsWith('91') &&
                          cleanedNumber.length > 10) {
                        cleanedNumber = cleanedNumber.substring(
                          cleanedNumber.length - 10,
                        );
                      }

                      if (cleanedNumber.length == 10) {
                        print('Calling $cleanedNumber...');
                        _makeCall();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter a valid 10-digit number',
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: Icon(
                        isCalling ? Icons.call_end : Icons.call,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  // const SizedBox(width: 30),
                  GestureDetector(
                    onTap: deleteLastDigit,
                    child: const Icon(Icons.backspace, size: 30),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToContactList(BuildContext context) async {
    final selectedNumber = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => ContactListScreen()),
    );

    if (selectedNumber != null) {
      print("Selected number: $selectedNumber");

      // Use the result (e.g., update UI)
      setState(() {
        enteredNumber = selectedNumber;
      });

      // OR use controller:
      // yourTextController.text = selectedNumber;
    }
  }
}

final contactsProvider = StateNotifierProvider<ContactsNotifier, ContactsState>(
  (ref) {
    return ContactsNotifier();
  },
);

class ContactListScreen extends ConsumerStatefulWidget {
  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends ConsumerState<ContactListScreen> {
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.contacts.status;
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
        _isLoading = false;
      });
      await ref.read(contactsProvider.notifier).loadContacts();
    } else {
      final result = await Permission.contacts.request();
      setState(() {
        _hasPermission = result.isGranted;
        _isLoading = false;
      });
      if (result.isGranted) {
        await ref.read(contactsProvider.notifier).loadContacts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Select Contact")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(title: Text("Select Contact")),
        body: Center(child: Text("Permission denied to read contacts")),
      );
    }

    final contactsState = ref.watch(contactsProvider);
    final filteredContacts = contactsState.filteredContacts;

    return Scaffold(
      appBar: AppBar(title: Text("Select Contact")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) {
                ref.read(contactsProvider.notifier).updateSearchQuery(query);
              },
              decoration: InputDecoration(
                labelText: 'Search contacts...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child:
                filteredContacts.isEmpty
                    ? Center(child: Text('No contacts found'))
                    : ListView.builder(
                      itemCount: filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = filteredContacts[index];
                        final number =
                            contact.phones.isNotEmpty
                                ? contact.phones.first.number
                                : 'No number';

                        return ListTile(
                          title: Text(contact.displayName),
                          subtitle: Text(number),
                          onTap: () {
                            Navigator.pop(context, number);
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class DialButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const DialButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[300],
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class ContactsState {
  final String searchQuery;
  final List<Contact> contacts;

  ContactsState({required this.searchQuery, required this.contacts});

  List<Contact> get filteredContacts {
    return contacts.where((contact) {
      final name = contact.displayName.toLowerCase();
      final phoneNumber =
          contact.phones.isNotEmpty ? contact.phones.first.number : '';
      return name.contains(searchQuery.toLowerCase()) ||
          phoneNumber.contains(searchQuery);
    }).toList();
  }

  ContactsState copyWith({String? searchQuery, List<Contact>? contacts}) {
    return ContactsState(
      searchQuery: searchQuery ?? this.searchQuery,
      contacts: contacts ?? this.contacts,
    );
  }
}

class ContactsNotifier extends StateNotifier<ContactsState> {
  ContactsNotifier() : super(ContactsState(searchQuery: '', contacts: []));

  Future<void> loadContacts() async {
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      state = state.copyWith(contacts: contacts);
    } catch (e) {
      // Optional: Handle errors if needed
      print('Failed to load contacts: $e');
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}
