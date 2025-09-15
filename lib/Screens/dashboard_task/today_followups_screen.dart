import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
import 'package:flutter_application_1/Screens/dashboard_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/pending_from_screen.dart';
import 'package:flutter_application_1/Screens/leds/leds_screen.dart';
import 'package:flutter_application_1/Screens/leds/total_lead_from.dart';
import 'package:flutter_application_1/Screens/task/task_screen.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/api_service/urls.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/models/history/mycalls_history_model.dart';
import 'package:flutter_application_1/models/leds_model/get_leds_by_model.dart';
import 'package:flutter_application_1/models/leds_model/sorce_model.dart';
import 'package:flutter_application_1/utils/comman_app_bar.dart';
import 'package:flutter_application_1/utils/comman_dropdown.dart';
import 'package:flutter_application_1/utils/comman_search_textfiled.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

final isLoadingProvider = StateProvider<bool>((ref) => false);
Future<void> TodayFollowupsScreenAPi(
  WidgetRef ref,
  int page, {
  String? name,
  String? status,
  String? source,
  String? priority,
  String? fromDate,
  String? toDate,
}) async {
  ref.read(isLoadingProvider.notifier).state = true;

  try {
    final queryParams = [
      "page=$page",
      if (name != null && name.trim().isNotEmpty) "name=$name",
      if (status != null && status.trim().isNotEmpty) "status=$status",
      if (source != null && source.trim().isNotEmpty) "source=$source",
      if (priority != null && priority.trim().isNotEmpty) "prority=$priority",
      if (fromDate != null && fromDate.trim().isNotEmpty) "fromDate=$fromDate",
      if (toDate != null && toDate.trim().isNotEmpty) "toDate=$toDate",
    ].join("&");

    final response = await ApiService().getRequest("${getAllLead}$queryParams");
    print(response?.data);

    if (response?.statusCode == 200) {
      final data = response?.data['leads'] as List;
      final newLeads =
          data.map((json) => GetLedsByHistoryModel.fromJson(json)).toList();

      final currentLeads = ref.read(getAllLedsProvider);
      ref.read(getAllLedsProvider.notifier).state = [
        ...currentLeads,
        ...newLeads,
      ];
    }
  } catch (e) {
    print("Error fetching appointments: $e");
  } finally {
    ref.read(isLoadingProvider.notifier).state = false;
  }
}

class TodayFollowupsScreen extends ConsumerStatefulWidget {
  const TodayFollowupsScreen({super.key});

  @override
  ConsumerState<TodayFollowupsScreen> createState() =>
      _TodayFollowupsScreenState();
}

class _TodayFollowupsScreenState extends ConsumerState<TodayFollowupsScreen> {
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  bool isFetchingMore = false;
  bool isLoading = false;
  @override
  bool hasMoreData = true;
  TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    _speech = stt.SpeechToText();
    super.initState();
    Future.microtask(() => scorceApi(ref));

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !isFetchingMore &&
          hasMoreData) {
        isFetchingMore = true;
        currentPage++;
        _fetchData(currentPage).then((_) {
          isFetchingMore = false;
        });
      }
    });
    Future.microtask(() => _fetchData(currentPage));
  }

  Future<void> _fetchData(int page) async {
    ref.read(isLoadingProvider.notifier).state = true;

    try {
      // Filter values
      final name = _searchController.text.trim();
      final sourceParam = selectedSorce?.name ?? '';
      final from =
          fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : '';
      final to = toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : '';

      // Query string
      final queryParams = [
        "page=$page",
        if (name.isNotEmpty) "name=$name",
        if (sourceParam.isNotEmpty) "source=$sourceParam",
        if (from.isNotEmpty) "fromDate=$from",
        if (to.isNotEmpty) "toDate=$to",
      ].join("&");

      // API Call
      final response = await ApiService().getRequest(
        "${getAllLead}$queryParams",
      );

      if (response?.statusCode == 200) {
        final data = response?.data['leads'] as List;
        final newLeads =
            data.map((json) => GetLedsByHistoryModel.fromJson(json)).toList();

        final currentLeads = ref.read(getAllLedsProvider);
        if (page == 1) {
          ref.read(getAllLedsProvider.notifier).state = newLeads;
        } else {
          ref.read(getAllLedsProvider.notifier).state = [
            ...currentLeads,
            ...newLeads,
          ];
        }

        if (newLeads.isEmpty) {
          hasMoreData = false;
        }
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  SourceModel? selectedSorce;
  DateTime? fromDate;
  DateTime? toDate;
  // String? selectedSource;

  // final List<String> sourceList = [
  //   'Facebook',
  //   'Instagram',
  //   'Google',
  //   'Referral',
  // ];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = "";

  void _startListening() async {
    bool available = await _speech.initialize();

    if (available) {
      setState(() {
        _isListening = true;
        _spokenText = "";
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _spokenText = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _showMicDialog() {
    _startListening();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Speak Now"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic, size: 48, color: Colors.red),
              SizedBox(height: 10),
              Text(_spokenText),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _stopListening();
                Navigator.of(context).pop();
              },
              child: Text("Done"),
            ),
          ],
        );
      },
    ).then(
      (_) => _stopListening(),
    ); // Ensure we stop listening when dialog closes
  }

  bool _showFilters = false;
  @override
  Widget build(BuildContext context) {
    final callList = ref.watch(getAllLedsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        _fetchData(currentPage);
      },
      child: Scaffold(
        appBar: CustomAppBar(title: "total_follow_ups".tr),
        drawer: const Drawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddLeadPage(),
              ), // Replace with your actual AddLeadPage widget
            );
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            //  Icon(Icons.search, color: kOrange, size: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 Toggle Button
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.search, color: kOrange, size: 30),
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                        if (!_showFilters) {
                          // clear filters when hiding
                          _searchController.clear();
                          selectedSorce = null;
                          fromDate = null;
                          toDate = null;
                          _fetchData(1); // Reset data
                        }
                      });
                    },
                  ),
                ),

                // 🌐 Filter Section (toggle)
                if (_showFilters) ...[
                  // Search Text Field
                  CommonSearchTextField(
                    controller: _searchController,
                    onSearch: () => setState(() => _fetchData(1)),
                  ),
                  const SizedBox(height: 5),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final sorceList = ref.watch(scorceProvider);

                              return CommonDropdown<SourceModel>(
                                hint: "select_source".tr,
                                value: selectedSorce,
                                items: sorceList,
                                getLabel: (item) => item.name,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedSorce = value;
                                    });
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Date Pickers Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        // From Date
                        Expanded(
                          child: Container(
                            height: 45,
                            margin: EdgeInsets.only(right: 8),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: TextFormField(
                                readOnly: true,
                                controller: TextEditingController(
                                  text:
                                      fromDate != null
                                          ? DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(fromDate!)
                                          : '',
                                ),
                                decoration: InputDecoration(
                                  hintText: 'From Date',
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: fromDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => fromDate = picked);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),

                        // To Date
                        Expanded(
                          child: Container(
                            height: 45,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: TextFormField(
                                readOnly: true,
                                controller: TextEditingController(
                                  text:
                                      toDate != null
                                          ? DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(toDate!)
                                          : '',
                                ),
                                decoration: InputDecoration(
                                  hintText: 'To Date',
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: toDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => toDate = picked);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _fetchData(1);
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: 90,
                        decoration: BoxDecoration(
                          color: kOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "GO".tr,
                          style: TextStyle(color: kwhite, fontSize: 16),
                        ),
                      ),
                    ),
                  ),

                  // Search Button
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton.icon(
                  //     icon: Icon(Icons.search),
                  //     label: Text("Search"),
                  //     onPressed: () {
                  //       setState(() {
                  //         _fetchData(1);
                  //       });
                  //     },
                  //   ),
                  // ),
                ],
              ],
            ),

            Expanded(
              child:
                  isLoading
                      ? Center(child: CircularProgressIndicator(color: kOrange))
                      : callList.isEmpty
                      ? Text("no_data_found".tr)
                      : ListView.builder(
                        controller: _scrollController,
                        itemCount: callList.length,
                        itemBuilder:
                            (context, index) => InkWell(
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => TotalLeadFromScreen(
                                            callList[index],
                                          ),
                                    ),
                                  ),
                              child: LeadCard(callList[index]),
                            ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeadCard extends ConsumerWidget {
  const LeadCard(this.data, {super.key});
  final GetLedsByHistoryModel data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      child: Card(
        color: kwhite,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${data.name ?? ''}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(_createRoute(data.mobile));
                    },
                    child: Icon(Icons.call, color: Colors.blue),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      _sendSms(context, data.mobile);
                    },
                    child: Icon(Icons.sms, color: Colors.amber),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      _openWhatsApp(context, data.mobile, "hello_follow_up".tr);
                    },
                    child: Image.asset(
                      'assets/images/whatsapp.png',
                      height: 18,
                      width: 18,
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(radius: 12, child: Text("1")),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoRow(
                    icon: "assets/images/user.png",
                    label: "${data.name ?? ''}",
                  ),
                  InfoRow(
                    icon: "assets/images/global-search.png",
                    label: "${data.source ?? ''}",
                  ),
                ],
              ),
              //   InfoRow(icon: "assets/images/man.png", label: "${data.position ?? '-jbhb'}"),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoRow(
                    icon: "assets/images/calendar.png",
                    label:
                        "${formatDate(data.meetingDate?.toString() ?? '')} ${data.meetingTime}",
                  ),
                  InfoRow(
                    icon: "assets/images/residential.png",
                    label: "${data.flat?.toString() ?? '------------'}",
                  ),
                ],
              ),
              SizedBox(height: 5),
              InfoRow(
                icon: "assets/images/cityscape.png",
                label:
                    data.location != null &&
                            data.location.toString().trim().isNotEmpty
                        ? data.location.toString()
                        : '------------',
              ),
              SizedBox(height: 5),
              InfoRow(
                icon: "assets/images/check-list.png",
                label: "${getStatusLabel(data.status?.toInt() ?? -1)}",
                labelColor: getStatusColor(data.status?.toInt()),
              ),

              SizedBox(height: 5),
              Row(
                children: [
                  Image.asset("assets/images/svg.png", height: 15, width: 15),
                  SizedBox(width: 2),
                  Text(
                    "${_getPriorityLabel(data.prority)}",
                    style: TextStyle(color: Colors.teal),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Route _createRoute(mobile) {
    return PageRouteBuilder(
      pageBuilder:
          (context, animation, secondaryAnimation) => DialPadScreen(mobile),
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

  void _openWhatsApp(BuildContext context, phoneNumber, msg) async {
    if (phoneNumber.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("फोन नंबर उपलब्ध नाही")));
      return;
    }

    final message = '''
नमस्कार 👋

*गजानन रेसिडेन्सी - 2 आणि 3 BHK फ्लॅट्स @ पाथर्डी फाटा, नाशिक*

✅ प्रधानमंत्री आवास योजना अंतर्गत ₹1.80 लाखांपर्यंत सबसिडी
✅ कार्पेट: 796.64 चौ.फुट | बिल्टअप: 1190 चौ.फुट
✅ सुविधा: जिम, पार्किंग, सोलर लाईट्स, लायब्ररी

📹 साइट व्हिडिओ: https://youtube.com/@newpawanputragroup
📍 लोकेशन: https://g.co/kgs/yCntVNb

आपल्याला अधिक माहिती हवी असल्यास कृपया संपर्क करा. 🙏
''';

    final url = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("WhatsApp उघडता आले नाही")));
    }
  }

  // void _openWhatsApp(BuildContext context, phoneNumber, msg) async {
  //   final url = Uri.parse(
  //     "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(msg)}",
  //   );

  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url, mode: LaunchMode.externalApplication);
  //   } else {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Could not open WhatsApp")));
  //   }
  // }

  void _sendSms(BuildContext context, phoneNumber) async {
    final message = '''
नमस्कार 👋

*गजानन रेसिडेन्सी - 2 आणि 3 BHK फ्लॅट्स @ पाथर्डी फाटा, नाशिक*

✅ प्रधानमंत्री आवास योजना अंतर्गत ₹1.80 लाखांपर्यंत सबसिडी
✅ कार्पेट: 796.64 चौ.फुट | बिल्टअप: 1190 चौ.फुट
✅ सुविधा: जिम, पार्किंग, सोलर लाईट्स, लायब्ररी

📹 साइट व्हिडिओ: https://youtube.com/@newpawanputragroup
📍 लोकेशन: https://g.co/kgs/yCntVNb

आपल्याला अधिक माहिती हवी असल्यास कृपया संपर्क करा. 🙏
''';
    final smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': "${message}"},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open SMS app")));
    }
  }

  String getStatusLabel(int? status) {
    if (status == null) return "Unknown"; // If status is null, return "Unknown"
    switch (status) {
      case 0:
        return "Fresh";
      case 1:
        return "Interested";
      case 2:
        return "Callback";
      case 3:
        return "No Requirement";
      case 4:
        return "Followup";
      case 5:
        return "Call Not Received";
      default:
        return "Unknown";
    }
  }

  String _getPriorityLabel(int? priority) {
    if (priority == null) return "Unknown";
    switch (priority) {
      case 0:
        return "Warm";
      case 1:
        return "Hot";
      case 2:
        return "Cold";
      // case 3:
      //   return "High Priority and Urgent";
      default:
        return "Unknown";
    }
  }
}

Color getStatusColor(int? status) {
  switch (status) {
    case 1:
      return Colors.orange; // Interested
    case 2:
      return Colors.green; // Callback (received)
    case 3:
      return Colors.red; // No Requirement
    case 5:
      return Colors.yellow; // Call Not Received
    default:
      return Colors.black; // Default color
  }
}

class InfoRow extends StatelessWidget {
  final String icon;
  final String label;
  final Color? labelColor;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(icon, height: 15, width: 15),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: labelColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
