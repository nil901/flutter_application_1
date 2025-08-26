import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/call_logs_history.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

import '../api_service/api_service.dart';
import '../api_service/urls.dart';
import '../utils/comman_app_bar.dart';

class PerfromanceRepoartScreen extends ConsumerStatefulWidget {
  const PerfromanceRepoartScreen({super.key});

  @override
  ConsumerState<PerfromanceRepoartScreen> createState() =>
      _PerfromanceRepoartScreenState();
}

class _PerfromanceRepoartScreenState
    extends ConsumerState<PerfromanceRepoartScreen> {
  bool isLoading = false;

  int totalCalls = 0;
  int connectedCalls = 0;
  int unconnectedCalls = 0;
  String latestCallTime = "";
  String firstCallTime = "";
  String totalTalkTime = "";
  // String unconnectedCalls = "";

  String selectedFilter = "lastWeek"; // default filter

  final Map<String, String> filters = {
    "today": "Today",
    "lastWeek": "Last Week",
    "thisMonth": "This Month",
  };

  @override
  void initState() {
    super.initState();
    fetchData();
    myDashobardCountAPi(ref);
  }

  int todayFollowUps = 0;
  int pendingFollowUps = 0;
  int dueToday = 0;
  int tomorrowFollowUps = 0;
  int totalFollowUps = 0;
  bool isDialogOpen = false;

  bool _isAppInitiatedCall = false;
  @override
  Future<void> myDashobardCountAPi(WidgetRef ref) async {
    setState(() {
      isLoading = true;
    });
    // print("helowwckxckdnkdfn");
    try {
      final response = await ApiService().getRequest(dashboardcard);
      print(response?.data);
      if (response?.statusCode == 200) {
        // final data = response?.data['leads'] as List;
        print(response?.data['todayFollowups']);
        setState(() {
          todayFollowUps = response?.data['todayFollowups'] ?? 0;
          pendingFollowUps = response?.data['pendingFollowups'] ?? 0;
          // dueToday = response?.data['dueToday'] ?? 0;
          tomorrowFollowUps = response?.data['tomorrowFollowups'] ?? 0;
          totalFollowUps = response?.data['totalLeads'] ?? 0;
          firstCallTime = response?.data['firstCallTime'] ?? "";
          latestCallTime = response?.data['latestCallTime'] ?? "";
        });
        //  log("${data}");

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching appointments: $e");
      throw Exception("Failed to load data");
    }
  }
  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final url =
        '${getPerfromanceRepoart}dateFilter=$selectedFilter';

    try {
      final response = await ApiService().getRequest(url);
      if (response?.statusCode == 200) {
        final data = response?.data['data'];
        setState(() {
          totalCalls = data['totalCalls'] ?? 0;
          connectedCalls = data['connectedCalls'] ?? 0;
          unconnectedCalls = data['unconnectedCalls'] ?? 0;
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

  List<BarChartGroupData> getBarChartData() {
    return [
      BarChartGroupData(
        x: 0,
        barsSpace: 8,
        barRods: [
          BarChartRodData(
            toY: totalCalls.toDouble(),
            color: Colors.blue,
            width: 12,
            borderRadius: BorderRadius.circular(2),
          ),
          BarChartRodData(
            toY: connectedCalls.toDouble(),
            color: Colors.red,
            width: 12,
            borderRadius: BorderRadius.circular(2),
          ),
          BarChartRodData(
            toY: unconnectedCalls.toDouble(),
            color: Colors.orange,
            width: 12,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    ];
  }

  Widget _buildLegend(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 5),
        Text(title),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "performance_report".tr),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FILTER DROPDOWN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  "user_call_history_details".tr,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: selectedFilter,
                  items: filters.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedFilter = value;
                      });
                      fetchData();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            AspectRatio(
              aspectRatio: 1.3,
              child: BarChart(
                BarChartData(
                  maxY: (totalCalls + 10).toDouble(),
                  barGroups: getBarChartData(),
                  alignment: BarChartAlignment.center,
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) =>
                            Text(value.toInt().toString()),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() == 0) {
                            return  Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                "${AppPreference().getString(PreferencesKey.name)}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                          return const Text("");
                        },
                      ),
                    ),
                    topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Legend
            Center(
              child: Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  _buildLegend("total_calls".tr, Colors.blue),
                  _buildLegend("connected_calls".tr, Colors.red),
                  _buildLegend("not_connected_calls".tr, Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // User Call Detail Box
        CallReportCard(
          userName: "${AppPreference().getString(PreferencesKey.name)}",
          totalCalls: totalCalls,
          connectedCalls: connectedCalls,
          notConnectedCalls: 14,
          talkTime: totalTalkTime,
          firstCallTime: firstCallTime,
          lastCallTime: latestCallTime,
          selectedFilter: selectedFilter,
        ),

            SizedBox(height: 10,),
            CallSummaryCard(
              userName: "${AppPreference().getString(PreferencesKey.name)}",
              firstCallTime: firstCallTime,
              lastCallTime: latestCallTime,
              freshLeads: todayFollowUps,
              todayFollowup: tomorrowFollowUps,
              pendingFollowup: pendingFollowUps,
            ),

          ],
        ),
      ),
    );
  }
}



class CallReportCard extends StatefulWidget {
  final String userName;
  final int totalCalls;
  final int connectedCalls;
  final int notConnectedCalls;
  final String talkTime;
  final String firstCallTime;
  final String lastCallTime;
  final String selectedFilter;

  const CallReportCard({
    super.key,
    required this.userName,
    required this.totalCalls,
    required this.connectedCalls,
    required this.notConnectedCalls,
    required this.talkTime,
    required this.firstCallTime,
    required this.lastCallTime,
    required this.selectedFilter,
  });

  @override
  State<CallReportCard> createState() => _CallReportCardState();
}

class _CallReportCardState extends State<CallReportCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        children: [
          // Header
           Row(
            children: [
              Expanded(
                  child: Text("user_name".tr,
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  child: Text("total_calls".tr,
                      style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(width: 30),
            ],
          ),
          const Divider(),

          // Main Row
          Row(
            children: [
              Expanded(child: Text(widget.userName)),
              Expanded(child: Text(widget.totalCalls.toString())),
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.remove_circle : Icons.add_circle,
                  color: isExpanded ? Colors.red : Colors.green,
                ),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ),
            ],
          ),

          // Expanded Details
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${"connected_calls".tr}: ${widget.connectedCalls}"),
                  Text("${"not_connected_calls".tr}: ${widget.notConnectedCalls}"),
                  Text("${"total_talks_time".tr}: ${widget.talkTime}"),
                  Text("${"first_call".tr}: ${widget.firstCallTime}"),
                  Text("${"last_call".tr}: ${widget.lastCallTime}"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                       Text("${"Action".tr}: "),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CallHistoryScreen(widget.selectedFilter)));
                        },
                        child: Container( 
                          alignment: Alignment.center,
                          height: 35,
                          width: 110,
                          decoration: BoxDecoration( 
                            borderRadius: BorderRadius.circular(10),
                            color: kOrange
                          ),
                          child: Text("${"Call_History_List".tr}",style: TextStyle(fontSize: 15,color: kwhite)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}



class CallSummaryCard extends StatelessWidget {
  final String userName;
  final String firstCallTime;
  final String lastCallTime;

  final int freshLeads;
  final int todayFollowup;
  final int pendingFollowup;

  const CallSummaryCard({
    super.key,
    required this.userName,
    required this.firstCallTime,
    required this.lastCallTime,
    required this.freshLeads,
    required this.todayFollowup,
    required this.pendingFollowup,
  });

  Widget _buildRow(String title, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              Text(count.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 10),
              const Icon(Icons.add_circle, color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
            child: Row(
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text("${"first_call".tr}: $firstCallTime"),
                const SizedBox(width: 10),
                Text("${"last_call".tr}: $lastCallTime"),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          _buildRow("fresh_leads".tr, freshLeads),
          _buildRow("tomorrow_follow_ups".tr, todayFollowup),
          _buildRow("pending_follow_ups".tr, pendingFollowup),
        ],
      ),
    );
  }
}
