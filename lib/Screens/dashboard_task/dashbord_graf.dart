import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/Screens/dashboard_task/due_today_screen.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/api_service/urls.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Global provider to store lead stats
final leadStatsProvider = StateProvider<Map<String, int>>(
  (ref) => {
    "fresh": 0,
    "interested": 0,
    "callback": 0,
    "noRequirement": 0,
    "followup": 0,
    "callNotReceived": 0,
  },
);

class LeadStats {
  static int fresh = 0;
  static int interested = 0;
  static int callback = 0;
  static int noRequirement = 0;
  static int followup = 0;
  static int callNotReceived = 0;

  static void updateFromJson(Map<String, dynamic> json) {
    fresh = json["fresh"] ?? 0;
    interested = json["interested"] ?? 0;
    callback = json["callback"] ?? 0;
    noRequirement = json["noRequirement"] ?? 0;
    followup = json["followup"] ?? 0;
    callNotReceived = json["callNotReceived"] ?? 0;
  }
}

class AutoCallDashBoardGraf extends ConsumerStatefulWidget {
  const AutoCallDashBoardGraf({super.key});

  @override
  ConsumerState<AutoCallDashBoardGraf> createState() =>
      _AutoCallDashBoardGrafState();
}

class _AutoCallDashBoardGrafState extends ConsumerState<AutoCallDashBoardGraf> {
  Future<void> _fetchData(int page) async {
    ref.read(isLoadingProvider.notifier).state = true;

    try {
      final response = await ApiService().getRequest("${columsApi}");

      if (response?.statusCode == 200) {
        final rawData = response?.data as Map<String, dynamic>;
        print(response?.data);
        // Update global values
        LeadStats.updateFromJson(rawData);
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Map<String, int> leadSourceData = {};
  Future<void> fetchLeadSourcePieData() async {
    final url = '$sourceGet';

    try {
      final response = await Dio().get(url);

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);

        // Remove 'total' and only keep sources
        data.remove('total');

        // Cast to Map<String, int>
        leadSourceData = data.map((key, value) => MapEntry(key, value as int));
        setState(() {});
      }
    } catch (e) {
      print('Error fetching pie chart data: $e');
    }
  }

  @override
  void initState() {
    _fetchData(1);
    fetchLeadSourcePieData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final total = leadSourceData.values.fold(0, (a, b) => a + b);
    return Column(
      children: [
        // Bar Chart Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("${LeadStats.interested.toDouble()}"),
            Column(
              children: [
                SizedBox(
                  height: 100,
                  width: 30,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.center,
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: LeadStats.interested.toDouble(),
                              color: Colors.green,
                              width: 20,
                            ),
                          ],
                        ),
                      ],
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text("Interested"),
              ],
            ),

            Column(
              children: [
                SizedBox(
                  height: 100,
                  width: 30,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.center,
                      barGroups: [
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: LeadStats.followup.toDouble(),
                              color: Colors.purple,
                              width: 20,
                            ),
                          ],
                        ),
                      ],
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text("Follow Up"),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Lead By Source",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 10),

Container(
  height: 400,
  width: 400,
  child: PieChart(
    PieChartData(
      sections: leadSourceData.entries.map((entry) {
        return PieChartSectionData(
          value: entry.value.toDouble(),
          color: getColorForSource(entry.key),
          title: '', // 🔴 text हटवलं
          radius: 150,
          titleStyle: const TextStyle(), // 🔴 काहीच style नाही
          borderSide: BorderSide.none, // 🔴 बाहेरची line काढली
        );
      }).toList(),
      sectionsSpace: 0, // 🔴 section मध्ये gap काढला
      centerSpaceRadius: 0,
    ),
  ),
),


        const SizedBox(height: 20),

        // Legend
       Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text("Source name", style: TextStyle(color: Colors.grey.shade700)),
    const SizedBox(height: 8),

    ...leadSourceData.entries.map((entry) {
      final percent = (entry.value / total) * 100;

      return LegendItem(
        color: getColorForSource(entry.key),
        label: entry.key,
        percentage: '${percent.toStringAsFixed(1)}%',  // ✅ Correct % here
      );
    }).toList(),
          ],
        ),
      ],
    );
  }

  Color getColorForSource(String key) {
    print(key);
    switch (key.toLowerCase()) {
      case 'facebook':
        return Colors.blue.shade700;
      case '99 acres':
        return Colors.orange;
      case 'reference':
        return Colors.green;
      case 'banner':
        return Colors.purple;
      case 'agent':
        return Colors.purple;
         case 'instagram':
        return Colors.pink;
        case 'whatsapp':
        return Colors.lightGreen;
        
      default:
        return Colors.black;
    }
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final percentage;

  const LegendItem({super.key, required this.color, required this.label,required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Text(label),
        SizedBox(width: 10,),
        Text(percentage.toString()),
      ],
    );
  }
}
