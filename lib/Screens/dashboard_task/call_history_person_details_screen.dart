import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
// import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/api_service/urls.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/models/history/get_call_by_history_model.dart';
import 'package:flutter_application_1/models/history/mycalls_history_model.dart';
import 'package:flutter_application_1/utils/comman_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// UI Screen with Scaffold and AppBar
class GetCallHistoryByPersonScreen extends ConsumerStatefulWidget {
  const GetCallHistoryByPersonScreen(this.reciever, {super.key});
final String reciever;
  @override
  ConsumerState<GetCallHistoryByPersonScreen> createState() => _GetCallHistoryByPersonScreenState();
}

class _GetCallHistoryByPersonScreenState extends ConsumerState<GetCallHistoryByPersonScreen> {
  bool isLoading = false;
  bool isFetchingMore = false;
  int page = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    myHistoryCallApi(ref);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          !isFetchingMore) {
        page++;
        myHistoryCallApi(ref, isLoadMore: true);
      }
    });
  }

  Future<void> myHistoryCallApi(WidgetRef ref, {bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() {
        isFetchingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final response = await ApiService().getRequest("${getUserHistoryperson}${widget.reciever}?page=$page");

      if (response != null && response.data['status'] == true) {
        final data = response.data['data']['callHistory'] as List;
        final newCalls = data.map((json) => GetCallHistoryByPersonModel.fromJson(json)).toList();

        if (isLoadMore) {
          ref.read(getHistoryPerson.notifier).update((state) => [...state, ...newCalls]);
        } else {
          ref.read(getHistoryPerson.notifier).state = newCalls;
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
    final callList = ref.watch(getHistoryPerson);

    return RefreshIndicator(
      onRefresh: () async {
        page = 1;
        myHistoryCallApi(ref);
      },
      child: Scaffold(
        appBar: CustomAppBar(title: "Details "),
        body: isLoading
            ? Center(child: CircularProgressIndicator(color: kOrange))
            : callList.isEmpty
                ? Center(
                    child: Text(
                      "no_history_found".tr,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
                            final formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(call.date);
      
                            return Card(
                              color: kwhite,
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.call_made, color: Colors.green),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                     Text("${"name".tr}: ${call.name==""? "N/A" :call.name}"),
                                    Text("${"receiver".tr}: ${call.reciever}"),
                                    Text("${"call_duration".tr}: ${call.duration}"),
                                    Text("${"date".tr}: $formattedDate"),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (isFetchingMore)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(color: kOrange),
                        ),
                    ],
                  ),
      ),
    );
  }
}
