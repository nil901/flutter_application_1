import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/models/leds_model/sorce_model.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:flutter_application_1/utils/comman_app_bar.dart';
import 'package:flutter_application_1/utils/comman_dashboard_screen.dart';
import 'package:flutter_application_1/utils/comman_dropdown.dart';
import 'package:flutter_application_1/utils/comman_textfiled.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AutoCallDashBoard extends ConsumerStatefulWidget {
  const AutoCallDashBoard({super.key});

  @override
  ConsumerState<AutoCallDashBoard> createState() => _AutoCallDashBoardState();
}

class _AutoCallDashBoardState extends ConsumerState<AutoCallDashBoard> {
  String selected = "Select Source";
  final List<String> options = ["Select Source", "Option 2", "Option 3"];

  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  bool isLoading = false;

  int totalCalls = 0;
  int connectedCalls = 0;
  int unconnectedCalls = 0;

  int totalLeads = 0;
  int freshLeads = 0;
  int doneCalls = 0;
  int failedCalls = 0;

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }
  SourceModel? selectedSorce;

  Future<void> fetchData() async {
    // if (fromDateController.text.isEmpty ||
    //     toDateController.text.isEmpty 
    //     ) {
    //   Get.snackbar("Validation", "Please select source and both dates");
    //   return;
    // }

    setState(() {
      isLoading = true;
    });

  String url;

final memberId = AppPreference().getInt(PreferencesKey.member_Id);
final fromDate = fromDateController.text;
final toDate = toDateController.text;
final source = selectedSorce?.name;

// दोन्ही डेट्स खाली असल्यास
if (fromDate.isEmpty || toDate.isEmpty) {
  url = 'https://api.newpawanputradevelopers.com/api/lead/getAutoCallDashboardData/$memberId';
} else {
  // जर source null नसेल तर ते parameter मध्ये जोडा
  final queryParams = [
    'fromDate=$fromDate',
    'toDate=$toDate',
    if (source != null && source.isNotEmpty) 'source=$source',
  ].join('&');

  url = 'https://api.newpawanputradevelopers.com/api/lead/getAutoCallDashboardData/$memberId?$queryParams';
}

print(url);
    try {
      final response = await ApiService().getRequest(url);
      if (response?.statusCode == 200) {
        final data = response?.data;
        print("${data}");
        setState(() {
          totalLeads = data['totalLeads'] ?? 0;
          freshLeads = data['freshLeads'] ?? 0;
          doneCalls = data['doneCalls'] ?? 0;
          failedCalls = data['failedCalls'] ?? 0;
        });
      }
    } catch (e) {
      print("API Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
     Future.microtask(() => scorceApi(ref));
    fetchData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "auto_call_dashboard".tr),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HintTextCustom(text: "From Date"),
            CommonTextField(
              label: 'From Date',
              controller: fromDateController,
              icon: Icons.calendar_today,
              readOnly: true,
              onTap: () => _selectDate(context, fromDateController),
            ),
            HintTextCustom(text: "To Date"),
            CommonTextField(
              label: 'To Date',
              controller: toDateController,
              icon: Icons.calendar_today,
              readOnly: true,
              onTap: () => _selectDate(context, toDateController),
            ),

            // const SizedBox(height: 10),
              HintTextCustom(text: "select_source".tr),
              Consumer(
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
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  fetchData();
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: 150,
                  decoration: BoxDecoration(
                    color: kOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),

            isLoading
                ? const Center(
                  child: Column(
                    children: [
                      SizedBox(height: 100),

                      CircularProgressIndicator(),
                    ],
                  ),
                )
                : CustomerSegmentationCard(
                  total: totalLeads,
                  fresh: freshLeads,
                  done: doneCalls,
                  failed: failedCalls,
                ),
          ],
        ),
      ),
    );
  }
}

class CustomerSegmentationCard extends StatelessWidget {
  final int total;
  final int fresh;
  final int done;
  final int failed;

  const CustomerSegmentationCard({
    super.key,
    required this.total,
    required this.fresh,
    required this.done,
    required this.failed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 50.0,
              lineWidth: 10.0,
              percent: 1.0,
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: Colors.grey.shade200,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Total", style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    "$total",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              progressColor: Colors.orange,
              animation: true,
              animationDuration: 1200,
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Customer Segmentation",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _buildSegmentRow("Fresh Leads", "$fresh", Colors.orange),
                  _buildSegmentRow("Done", "$done", Colors.yellow.shade700),
                  _buildSegmentRow("Failed", "$failed", Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
