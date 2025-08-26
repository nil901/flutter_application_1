import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
import 'package:flutter_application_1/Screens/dashboard_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/call_history_person_details_screen.dart';
// import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/api_service/urls.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/models/history/mycalls_history_model.dart';
import 'package:flutter_application_1/utils/comman_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// UI Screen with Scaffold and AppBar
class CallHistoryScreen extends ConsumerStatefulWidget {
  const CallHistoryScreen(this.isdate, {super.key});
  final String isdate;
  @override
  ConsumerState<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends ConsumerState<CallHistoryScreen> {
  bool isLoading = false;
  bool isFetchingMore = false;
  int page = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    myHistoryCallApi(ref);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isFetchingMore) {
        page++;
        myHistoryCallApi(ref, isLoadMore: true);
      }
    });
  }

  void logFormattedJson(dynamic data) {
    try {
      final encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(data);
      log(prettyJson);
    } catch (e) {
      log('Invalid JSON data: $e');
    }
  }

  Future<void> myHistoryCallApi(
    WidgetRef ref, {
    bool isLoadMore = false,
  }) async {
    if (isLoadMore) {
      setState(() {
        isFetchingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
      });
    }
    print("${getUserHistory}dateFilter=${widget.isdate}&page=1");
    try {
      final response = await ApiService().getRequest(
        widget.isdate.isNotEmpty
            ? "${getUserHistory}dateFilter=${widget.isdate}&page=1"
            : "${getUserHistory}page=$page",
      );
      logFormattedJson("${response?.data}");
      if (response != null && response.data['status'] == true) {
        final data = response.data['data']['callHistories'] as List;
        final newCalls =
            data.map((json) => MyCallHistoryModel.fromJson(json)).toList();
        if (isLoadMore) {
          ref
              .read(myHistoryProvider.notifier)
              .update((state) => [...state, ...newCalls]);
        } else {
          ref.read(myHistoryProvider.notifier).state = newCalls;
        }
      }
    } catch (e) {
      print("Error fetching call history: $e");
    } finally {
      setState(() {
        isLoading = false;
        isFetchingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callList = ref.watch(myHistoryProvider);

    return RefreshIndicator(
      onRefresh: () async {
        page = 1;
        myHistoryCallApi(ref);
      },
      child: Scaffold(
        appBar: CustomAppBar(title: "call_logs".tr),
        body:
            isLoading
                ? Center(child: CircularProgressIndicator(color: kOrange))
                : callList.isEmpty
                ? Center(
                  child: Text(
                    "no_history_found".tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: callList.length,
                        itemBuilder: (context, index) {
                          final call = callList[index];
                          final formattedDate = DateFormat(
                            'dd-MM-yyyy hh:mm a',
                          ).format(call.date);

                          return Card(
                            color: kwhite,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            GetCallHistoryByPersonScreen(
                                              call.reciever,
                                            ),
                                  ),
                                );
                              },
                              leading: Icon(
                                call.status == 1
                                    ? Icons.call_made
                                    : Icons.call_received,
                                color:
                                    call.status == 1
                                        ? Colors.green
                                        : Colors.red,
                              ),
                              title: Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  "${"name".tr}: ${call.name.isEmpty ? "N/A" : call.name}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${"receiver".tr}: ${call.reciever}"),
                                  Text(
                                    "${"call_duration".tr}: ${call.duration}",
                                  ),
                                  Text("${"date".tr}: $formattedDate"),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.green,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.call,
                                        size: 15,
                                        color: kwhite,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          _createRoute(
                                            call.reciever.toString(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Icon(
                                    Icons.forward_rounded,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
                    if (isFetchingMore)
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(color: kOrange),
                      ),
                  ],
                ),
      ),
    );
  }
}

Route _createRoute(mobile) {
  print("poad ssdjnsjdnsjdn${mobile}");
  return PageRouteBuilder(
    pageBuilder:
        (context, animation, secondaryAnimation) =>
            DialPadScreen(mobile.toString()),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
