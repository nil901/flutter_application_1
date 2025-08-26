import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
import 'package:flutter_application_1/Screens/dashboard_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/pending_from_screen.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/api_service/urls.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/global/utils.dart';
import 'package:flutter_application_1/models/leds_model/branch_model.dart';
import 'package:flutter_application_1/models/leds_model/get_pending_followups_model.dart';
import 'package:flutter_application_1/models/leds_model/sorce_model.dart';
import 'package:flutter_application_1/utils/comman_app_bar.dart';
import 'package:flutter_application_1/utils/comman_dropdown.dart';
import 'package:flutter_application_1/utils/comman_search_textfiled.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final currentPageProvider = StateProvider<int>((ref) => 1);
final hasMoreDataProvider = StateProvider<bool>((ref) => true);
final isLoadingProvider = StateProvider<bool>((ref) => false);

Future<void> dueFollowUpsApi(
  WidgetRef ref, {
  bool isRefresh = false,
  String? search,
  String? source,
  String? priority,
  String? status,
  String? conversionStatus,
  DateTime? fromDate,
  DateTime? toDate,
}) async {
  final notifier = ref.read(isLoadingProvider.notifier);
  final leadsNotifier = ref.read(getPendingFollowUprovider.notifier);
  final pageNotifier = ref.read(currentPageProvider.notifier);
  final hasMoreNotifier = ref.read(hasMoreDataProvider.notifier);

  if (notifier.state) return;
  notifier.state = true;

  try {
    int page = isRefresh ? 1 : ref.read(currentPageProvider);

    // Build query parameters
    final queryParams = [
      "page=$page",
      if (search != null && search.trim().isNotEmpty)
        "name=${Uri.encodeQueryComponent(search.trim())}",
      if (source != null && source.trim().isNotEmpty)
        "source=${Uri.encodeQueryComponent(source.trim())}",
      if (priority != null && priority.trim().isNotEmpty)
        "prority=${Uri.encodeQueryComponent(priority.trim())}",
      if (status != null && status.trim().isNotEmpty)
        "status=${Uri.encodeQueryComponent(status.trim())}",
      if (conversionStatus != null && conversionStatus.trim().isNotEmpty)
        "conversionStatus=${Uri.encodeQueryComponent(conversionStatus.trim())}",
      if (fromDate != null)
        "fromDate=${DateFormat('yyyy-MM-dd').format(fromDate)}",
      if (toDate != null) "toDate=${DateFormat('yyyy-MM-dd').format(toDate)}",
    ].join("&");

    final response = await ApiService().getRequest(
      "$getTodayFollowupsUps?$queryParams",
    );

    if (response != null && response.statusCode == 200) {
      final List<dynamic> data = response.data['leads'] ?? [];

      final leads =
          data.map((json) => GetPendingFollowsByMember.fromJson(json)).toList();

      if (isRefresh) {
        leadsNotifier.state = leads;
        pageNotifier.state = 2;
        hasMoreNotifier.state = leads.length == 10;
      } else {
        final existingIds = leadsNotifier.state.map((e) => e.id).toSet();
        final newLeads =
            leads.where((lead) => !existingIds.contains(lead.id)).toList();

        leadsNotifier.state = [...leadsNotifier.state, ...newLeads];

        if (newLeads.length < 10) {
          hasMoreNotifier.state = false;
        } else {
          pageNotifier.state++;
        }
      }

      print("Page: $page, Total: ${leadsNotifier.state.length}");
    } else {
      hasMoreNotifier.state = false;
      print("API returned status: ${response?.statusCode}");
    }
  } catch (e, stack) {
    hasMoreNotifier.state = false;
    print("Error fetching due followups: $e\n$stack");
  }

  notifier.state = false;
}

class DueTodayScreen extends ConsumerStatefulWidget {
  const DueTodayScreen({super.key});

  @override
  ConsumerState<DueTodayScreen> createState() => _DueTodayScreenState();
}

class _DueTodayScreenState extends ConsumerState<DueTodayScreen> {
  // bool isLoading = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
 Future.microtask(() => dueFollowUpsApi(ref, isRefresh: true));
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    Future.microtask(() => dueFollowUpsApi(ref, isRefresh: true));
        Future.microtask(() => scorceApi(ref,));
  }

  void _scrollListener() {
    final isLoading = ref.read(isLoadingProvider);
    final hasMore = ref.read(hasMoreDataProvider);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isLoading &&
        hasMore) {
      Future.microtask(() =>  dueFollowUpsApi(ref,));
    }
    
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  SourceModel? selectedSorce;
  DateTime? fromDate;
  DateTime? toDate;
  bool _showFilters = false;

  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final pendingProvider = ref.watch(getPendingFollowUprovider);
    final isLoading = ref.watch(isLoadingProvider);

    return RefreshIndicator(
      onRefresh: () => dueFollowUpsApi(ref, isRefresh: true),

      child: Scaffold(
        appBar: CustomAppBar(title: "todays_follow_ups".tr),
        body: Column(
          children: [
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
                          dueFollowUpsApi(
                            ref,
                            isRefresh: true,
                            search: _searchController.text,
                            source: selectedSorce?.name,
                            fromDate: fromDate,
                            toDate: toDate,
                          );
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
                    onSearch:
                        () => setState(
                          () => dueFollowUpsApi(
                            ref,
                            isRefresh: true,
                            search: _searchController.text,
                            source: selectedSorce?.name,
                            fromDate: fromDate,
                            toDate: toDate,
                          ),
                        ),
                  ),
                  const SizedBox(height: 5),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                          dueFollowUpsApi(
                            ref,
                            isRefresh: true,
                            search: _searchController.text,
                            source: selectedSorce?.name,
                            fromDate: fromDate,
                            toDate: toDate,
                          );
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
              child: Column(
                children: [
                  isLoading
                      ? Center(child: CircularProgressIndicator(color: kOrange))
                      : pendingProvider.isEmpty
                      ? Center(child: Text("no_data_found".tr))
                      : Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: pendingProvider.length,
                          itemBuilder: (context, index) {
                            var data = pendingProvider[index];
                            // final String rawDate = "2025-04-26T14:25:12.146Z";
                            final DateTime parsedDate = DateTime.parse(
                              data.contactDate.toString(),
                            );
                            final String formattedDate = DateFormat(
                              'MMMM d, y',
                            ).format(parsedDate); // Output: April 26, 2025

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Material(
                                elevation: 1,
                                borderRadius: BorderRadius.circular(15),

                                child: Container(
                                  decoration: BoxDecoration(
                                    color: kwhite,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              // height: 25,
                                              // width: 100,
                                              decoration: BoxDecoration(
                                                color: kgreyText?.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time,
                                                      size: 18,
                                                      color: kOrange,
                                                    ),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      "${formattedDate}",
                                                      style: TextStyle(
                                                        color: kgreyText,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Spacer(),
                                            InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  _createRoute(data.mobile),
                                                );
                                              },
                                              child: Icon(
                                                Icons.call,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            InkWell(
                                              onTap: () {
                                                Utils().openWhatsApp(
                                                  context,
                                                  data.mobile,
                                                  "${"hello".tr} ${data.name}",
                                                );
                                              },
                                              child: Image.asset(
                                                'assets/images/whatsapp.png',
                                                height: 18,
                                                width: 18,
                                              ),
                                            ),

                                            SizedBox(width: 10),
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            PendingFromScreen(
                                                              data,
                                                            ),
                                                  ),
                                                );
                                              },
                                              child: Icon(
                                                Icons.remove_red_eye_outlined,
                                                color: kOrange,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              size: 22,
                                              color: kOrange,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              data.name,
                                              style: TextStyle(
                                                color: kBlack,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.smartphone,
                                              size: 18,
                                              color: kOrange,
                                            ),
                                            SizedBox(width: 6),
                                            Text("${data.mobile}"),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.call,
                                              size: 18,
                                              color: kOrange,
                                            ),
                                            SizedBox(width: 6),
                                            Text("${data.meetingDescription}"),
                                          ],
                                        ),
                                        SizedBox(height: 6),

                                        //  Row(
                                        //   children: [

                                        //     SizedBox(width: 6),
                                        //     Text("Share"),
                                        //   ],
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                ],
              ),
            ),
          ],
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
}

class CardDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(15),

        child: Container(
          decoration: BoxDecoration(
            color: kwhite,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      // height: 25,
                      // width: 100,
                      decoration: BoxDecoration(
                        color: kgreyText?.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, size: 18, color: kOrange),
                            SizedBox(width: 6),
                            Text(
                              "June 12, 2023",
                              style: TextStyle(
                                color: kgreyText,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(),
                    Image.asset(
                      'assets/images/whatsapp.png',
                      height: 18,
                      width: 18,
                    ),

                    SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        //                    Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => PendingFromScreen()),
                        // );
                      },
                      child: Icon(
                        Icons.remove_red_eye_outlined,
                        color: kOrange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 22, color: kOrange),
                    SizedBox(width: 6),
                    Text(
                      "ddsdd",
                      style: TextStyle(
                        color: kBlack,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.smartphone, size: 18, color: kOrange),
                    SizedBox(width: 6),
                    Text("9834705267"),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.call, size: 18, color: kOrange),
                    SizedBox(width: 6),
                    Text("Last call: switch off"),
                  ],
                ),
                SizedBox(height: 6),

                //  Row(
                //   children: [

                //     SizedBox(width: 6),
                //     Text("Share"),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
