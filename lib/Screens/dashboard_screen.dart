import 'dart:async';
import 'dart:developer';
import 'package:call_log/call_log.dart';
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

class _StackDashboardState extends ConsumerState<StackDashboard> {
  bool isLoading = false;

  // int todayFollowUps = 0;
  // int pendingFollowUps = 0;
  // int dueToday = 0;
  // int tomorrowFollowUps = 0;
  // int totalFollowUps = 0;
  bool isDialogOpen = false;

  bool _isAppInitiatedCall = false;
  @override
  static const platform = MethodChannel('com.example.call_tracker');

  String _callStatus = '';
  String _incomingNumber = '';
  String _duration = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => fetchDashboardCount(ref));
    // fetchDashboardCount(ref);

    _startCallTracking("00:00:00");

    initializeCallHandler();
  }

  bool _isIncomingCallRinging = false;
  void initializeCallHandler() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onCallRinging':
          final number = call.arguments['number'] ?? 'Unknown';
          final direction = call.arguments['direction'] ?? 'unknown';
          log("Incoming call ringing from: $number, direction: $direction");

          setState(() {
            _callStatus = '$number';
            _incomingNumber = number;
            _isIncomingCallRinging = true;
          });
          break;

        case 'onCallStarted':
          // Optionally reset or handle here
          break;

        case 'onCallEnded':
          final number = call.arguments['number'] ?? 'Unknown';
          final durationMillis = call.arguments['duration'] ?? 0;
          // final direction = call.arguments['direction'] ?? 'unknown';

          log("Call Arguments: ${call.arguments}");
          log("isIncomingCallRinging: $_isIncomingCallRinging");

          if (_isIncomingCallRinging) {
            final callDurationSeconds = (durationMillis / 1000).round();

            String formatDuration(int seconds) {
              final duration = Duration(seconds: seconds);
              String twoDigits(int n) => n.toString().padLeft(2, '0');
              final hours = twoDigits(duration.inHours);
              final minutes = twoDigits(duration.inMinutes.remainder(60));
              final secs = twoDigits(duration.inSeconds.remainder(60));
              return "$hours:$minutes:$secs";
            }

            final formattedDuration = formatDuration(callDurationSeconds);

            // Show notification, call API etc.
            try {
              //  await _startCheckingCallLog(formattedDuration);
              // await showCallEndedNotification(
              //   _incomingNumber,
              //   formattedDuration,
              // );
            } catch (e) {
              print("Call log check failed: $e");
            }

            if (mounted) {
              try {
                final leadStatusResponse = await ApiService()
                    .postRequest(getLeadStatus, {"mobile": _incomingNumber})
                    .timeout(const Duration(seconds: 20));

                final message = leadStatusResponse?.data["message"] as String?;
                final leadData =
                    leadStatusResponse?.data['lead'] as Map<String, dynamic>?;
                final notifier = ref.read(getAllLedsStatusProvider.notifier);
                notifier.state = [];

                if (message == "LeadStatus fetched" && leadData != null) {
                  final leadStatus = GetLeadStatusUpdateModel.fromJson(
                    leadData,
                  );
                  notifier.state = [leadStatus];
                  Utils().showToastMessage('Call from $number ended. $message');
                } else {
                  // Utils().showToastMessage(
                  //   message ?? 'Failed to fetch lead status',
                  // );
                }
              } catch (e) {
                print("Lead Status Error: $e");
                Utils().showToastMessage(
                  "Lead status fetch failed: ${e.toString()}",
                );
              }

              // _startCallTracking(formattedDuration);
              _startCheckingCallLog(formattedDuration);
              //     FlutterOverlayWindow.showOverlay(
              //   alignment: OverlayAlignment.center,
              //   height: 200,
              //   width: 300,
              //   enableDrag: true,
              //   overlayTitle: "Call Popup",
              //   overlayContent: "Call Ended",
              //   flag: OverlayFlag.defaultFlag,
              //   visibility: NotificationVisibility.visibilityPublic,

              //   // entryPoint: 'overlayMain', // Important!
              // );
            }
          } else {
            print(
              "Skipping outgoing call notification or not incoming ringing call.",
            );
          }

          // // Reset the flag after call ended
          // _isIncomingCallRinging = false;

          break;

        default:
          print("Unhandled platform method: ${call.method}");
          break;
      }
    });
  }

  // static const platform = MethodChannel('com.example.calltracker/channel');

  Future<void> launchAppFromBackground() async {
    try {
      await platform.invokeMethod('launchAppFromBackground');
    } catch (e) {
      print("Error launching app: $e");
    }
  }

  Future<void> _startCallTracking(formattedDuration) async {
    try {
      final result = await platform.invokeMethod('startCallTracking');
      if (!result) {
        setState(() {
          _callStatus = 'Permission denied or error starting call tracking';
          print("sd,snfkdnfdkfn");
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _callStatus = 'Failed to start call tracking: ${e.message}';
      });
    }
  }

  PhoneStateStatus status = PhoneStateStatus.NOTHING;
  Stream<PhoneStateStatus>? phoneStateStream;

  Future<void> _startCheckingCallLog(duration) async {
    final now = DateTime.now();
    final formattedDate = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
    ).format(now);

    showCallPopup(context, duration);
  }

  void showCallPopup(BuildContext context, String duration) {
    if (isDialogOpen) return;
    isDialogOpen = true;
    _isIncomingCallRinging = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: kwhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: LedsFromCall(_incomingNumber, duration, duration, 0),
        );
      },
    ).then((_) {
      isDialogOpen = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

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
  final EventChannel _callEventChannel = EventChannel(
    'com.example.crm_app/callEvents',
  );
  Timer? _timer;
  int callSeconds = 0;
  bool isCalling = false;
  bool _hasCallStarted = false;
  bool _isCallEnded = false;
  bool isDialogOpen = false;
  String enteredNumber = '';
  String _calledNumber = '';
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

  String _callStatus = 'Status: Waiting for call...';
  @override
  void initState() {
    enteredNumber = widget.mobile;
    super.initState();
    branchApi(ref);
    scorceApi(ref);
    requestPermission();
    _listenToPhoneState();
    // listenToNativeCallEvents();
  }

  String _callDuration = '0';
  bool _isAppInitiatedCall = false;

  Timer? _callLogTimer;
  Future<void> _makeCall() async {
    setState(() {
      _callDuration = '0';
      _callStatus = 'Status: Waiting for call...';
    });

    if (enteredNumber.isNotEmpty) {
      var status = await Permission.phone.request();
      if (status.isGranted) {
        _callLogTimer?.cancel();

        _isAppInitiatedCall = true; // ✅ flag set

        await FlutterPhoneDirectCaller.callNumber(enteredNumber);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Permission denied')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a number')));
    }
  }

  PhoneStateStatus status = PhoneStateStatus.NOTHING;
  Stream<PhoneStateStatus>? phoneStateStream;

  // @override
  // void initState() {
  //   super.initState();

  // }

  Future<bool> requestPermission() async {
    var status = await Permission.phone.request();

    return switch (status) {
      PermissionStatus.denied ||
      PermissionStatus.restricted ||
      PermissionStatus.limited ||
      PermissionStatus.permanentlyDenied => false,
      PermissionStatus.provisional || PermissionStatus.granted => true,
    };
  }

  void _listenToPhoneState() async {
    PhoneState.stream.listen((PhoneState? event) async {
      if (event == null) return;

      if (event.status == PhoneStateStatus.CALL_STARTED) {
        print(' Call Started');
      } else if (event.status == PhoneStateStatus.CALL_INCOMING) {
        print(' Call In Progress');
        setState(() {
          isCalling = true;
          _callDuration = '0';
          _callStatus = 'Status: Call in progress...';
        });
        String formatDuration(Duration duration) {
          String twoDigits(int n) => n.toString().padLeft(2, '0');
          final hours = twoDigits(duration.inHours);
          final minutes = twoDigits(duration.inMinutes.remainder(60));
          final seconds = twoDigits(duration.inSeconds.remainder(60));
          return "$hours:$minutes:$seconds";
        }

        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            callSeconds++;
            final duration = Duration(seconds: callSeconds);
            _callDuration = formatDuration(duration);
          });
        });
        print("Call started ${_callDuration}");
      } else if (event.status == PhoneStateStatus.CALL_ENDED) {
        print('Call Ended');

        try {
          /// Lead Status API
          final leadStatusResponse = await ApiService()
              .postRequest(getLeadStatus, {
                "mobile": enteredNumber.replaceAll(' ', ''),
              })
              .timeout(
                const Duration(seconds: 20),
                onTimeout: () {
                  throw TimeoutException("Lead status API timed out");
                },
              );

          final message = leadStatusResponse?.data["message"] as String?;
          final leadData =
              leadStatusResponse?.data['lead'] as Map<String, dynamic>?;

          final notifier = ref.read(getAllLedsStatusProvider.notifier);
          notifier.state = [];

          if (message == "LeadStatus fetched" && leadData != null) {
            final leadStatus = GetLeadStatusUpdateModel.fromJson(leadData);
            notifier.state = [leadStatus];
            // Utils().showToastMessage(message ?? 'Lead Status Updated');
          } else {
            Utils().showToastMessage(message ?? 'Failed to fetch lead status');
          }
        } catch (e) {
          print("Lead Status Error: $e");
          //Utils().showToastMessage("Lead status fetch failed: ${e.toString()}");
        }

        await _startCheckingCallLog();

        // Hide loading if used
        // setState(() => isLoading = false);
      }
    });
  }

  void _onCallEnded() {
    // Call झाल्यावर काय करायचं ते इथे लिहा
    print("✅ Call Ended - API hitting...");
    // Example: तू API call करू शकतोस किंवा Popup वगैरे दाखवू शकतोस
    // ApiService.instance.hitYourApi();
  }

  Future<void> _startCheckingCallLog() async {
    _callLogTimer?.cancel();
    _callLogTimer = null;

    // if (!mounted) return;
    // setState(() {
    //   _callStatus = 'Status: Checking Call Log...';
    // });

    Iterable<CallLogEntry> entries = await CallLog.get();

    String formatDuration(int seconds) {
      final duration = Duration(seconds: seconds);
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = twoDigits(duration.inHours);
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final secs = twoDigits(duration.inSeconds.remainder(60));
      return "$hours:$minutes:$secs";
    }

    if (entries.isNotEmpty) {
      for (var entry in entries) {
        if (entry.number == enteredNumber) {
          final formattedDuration = formatDuration(entry.duration!.toInt());

          if (!mounted) return;
          // setState(() {
          //   _callDuration = formattedDuration;
          // });

          final now = DateTime.now();
          final formatted = DateFormat(
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
          ).format(now);

          if (!_isAppInitiatedCall) {
            print("External call ended — API call skipped.");
            return;
          }

          _isAppInitiatedCall = false;

          final memberId = AppPreference().getInt(PreferencesKey.member_Id);

          // try {
          //   final callHistoryResponse = await ApiService()
          //       .postRequest(createCallHistory, {
          //         "memberId": memberId,
          //         "caller":
          //             "${AppPreference().getString(PreferencesKey.mobile_no)}",
          //         "reciever": enteredNumber.replaceAll(' ', ''),
          //         "duration": formattedDuration,
          //         "date": formatted,
          //         'status': 1,
          //         'name': "",
          //       })
          //       .timeout(
          //         const Duration(seconds: 20),
          //         onTimeout: () {
          //           throw TimeoutException("Call history API timed out");
          //         },
          //       );

          //   if (!mounted) return;
          //   // Utils().showToastMessage(
          //   //   callHistoryResponse?.data['message'] ??
          //   //       'Call History Added/Failed',
          //   // );
          // } catch (e) {
          //   print("Call History Error: $e");
          //   if (mounted) {
          //     Utils().showToastMessage(
          //       "Call history save failed: ${e.toString()}",
          //     );
          //   }
          // }

          if (mounted) {
            showCallPopup(context, entry.duration ?? 0, formattedDuration);
          }

          if ((entry.duration ?? 0) > 0) {
            if (!mounted) return;
            setState(() {
              _callDuration = formattedDuration;
              _callStatus = 'Status: Call Ended';
            });
            _callLogTimer?.cancel();
            _callLogTimer = null;
          } else {
            print("📟 Call duration is 0, but popup shown.");
          }

          return;
        }
      }
    }
  }

  @override
  void dispose() {
    _callLogTimer?.cancel();
    super.dispose();
  }

  void showCallPopup(BuildContext context, duration, formatduration) {
    /// _startCheckingCallLog();
    // if (isDialogOpen) return; // If dialog is already open, do nothing
    showDialog(
      context: context,

      barrierDismissible: false, // Dialog बाहेर click केल्यावर बंद होणार नाही
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: kwhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: LedsFromCall(enteredNumber, duration, formatduration, 1),
        );
      },
    );
  }

  BranchModel? selectedBranch;
  SourceModel? selectedSorce;
  String? selectLower;
  String? selectStatus;
  String? materialType;
  TextEditingController contactNameController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController companydetailsNameController = TextEditingController();
  TextEditingController referanceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController enterFacebookCompaignController =
      TextEditingController();

  Widget _buildDropdown(String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(),
        ),
        items: [],
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void addNumber(String number) {
    if (!isCalling) {
      setState(() {
        enteredNumber += number;
      });
    }
  }

  void deleteLastDigit() {
    if (!isCalling && enteredNumber.isNotEmpty) {
      setState(() {
        enteredNumber = enteredNumber.substring(0, enteredNumber.length - 1);
      });
    }
  }

  Future<void> _startCall() async {
    String number = enteredNumber;
    if (number.isNotEmpty) {
      _calledNumber = number;

      final permission = await Permission.contacts.request();
      if (permission.isGranted) {
        // Optional: Get contact name
      }

      await FlutterPhoneDirectCaller.callNumber(number);
    }
  }

  void endCall() {
    _timer?.cancel();
    int duration = callSeconds;

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

  Future<void> pasteFromClipboard() async {
    ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        enteredNumber = clipboardData.text!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Number pasted from clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String callTime =
        "${(callSeconds ~/ 60).toString().padLeft(2, '0')}:${(callSeconds % 60).toString().padLeft(2, '0')}";
    // final contactsState = ref.watch(contactsProvider);
    // final filteredContacts = contactsState.filteredContacts;
    // print(_callDuration);
    return Scaffold(
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
