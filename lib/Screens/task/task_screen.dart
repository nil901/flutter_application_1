import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/task/update_task_screen.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/api_service/urls.dart';
import 'package:flutter_application_1/global/utils.dart';
import 'package:flutter_application_1/models/task_models/GetTasksAssignedByMeModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/Screens/task/add_task_screen.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/utils/comman_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final isLoadingProvider = StateProvider<bool>((ref) => false);

Future<void> taskAssignByMeApi(
  WidgetRef ref, {

  Function(bool)? setLoader,
  
}) async {
  if (setLoader != null) setLoader(true);
  ref.read(isLoadingProvider.notifier).state = true;
  try {
    final response = await ApiService().getRequest(getTasksmemberByMe);
    log("$getTasksmemberByMe");
    print(response?.data);
    if (response != null && response.statusCode == 200) {
      final data = response.data['data']['tasks'] as List;
      ref.read(getTasksAssignedByMeprovider.notifier).state =
          data.map((json) => GetTasksAssignedByMeModel.fromJson(json)).toList();
      ref.read(isLoadingProvider.notifier).state = false;
    }
  } catch (e) {
    ref.read(isLoadingProvider.notifier).state = false;

    print("Error fetching appointments: $e");
  } finally {
    ref.read(isLoadingProvider.notifier).state = false;

    if (setLoader != null) setLoader(false);
  }
}


String formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';
  
  final utcDate = DateTime.tryParse(dateStr);
  if (utcDate == null) return '';

  // ✅ Convert UTC to IST (UTC+5:30)
  final istDate = utcDate.toUtc().add(const Duration(hours: 5, minutes: 30));

  return DateFormat('dd/MM/yy').format(istDate);
}

final getTasksAssignedByMeprovider =
    StateProvider<List<GetTasksAssignedByMeModel>>((ref) => []);

class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  @override
  void initState() {
    Future.microtask(() => taskAssignByMeApi(ref, ));

    super.initState();
  }

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final assignTaskProvider = ref.watch(getTasksAssignedByMeprovider);
    final isLoading = ref.watch(isLoadingProvider);
    return Scaffold(
      appBar: CustomAppBar(title: "task_assigned_by_me".tr),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : assignTaskProvider.isEmpty
              ? Center(child: Text("no_tasks_assigned".tr))
              : Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                  itemCount: assignTaskProvider.length,
                  itemBuilder: (context, index) {
                    final task = assignTaskProvider[index];
              
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => UpdateTaskScreen(
                                                task: task,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.edit,
                                      size: 25,
                                      color: kOrange,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  InkWell(
                                    onTap: () async {
                                      try {
                                        final response = await ApiService()
                                            .deleteRequest(
                                              "${deleteTask}${task.id}",
                                            );
              
                                        print(
                                          "statusCode: ${response?.statusCode}",
                                        );
                                        print(
                                          "status: ${response?.data['status']}",
                                        );
                                        print(
                                          "message: ${response?.data['message']}",
                                        );
              
                                        if (response?.data["status"] ==
                                            true) {
                                          final responseData = response!.data;
              
                                          // state = const AsyncValue.data(null);
                                          // Utils().showToastMessage(
                                          //   response.data['message'] ?? 'Added successful',
                                          // );
              
                                          // Navigator.pop(context);
                                          if (selectedIndex == 0) {
                                            Future.microtask(
                                              () => taskAssignByMeApi(
                                                ref,
                                               
                                              ),
                                            );
                                          } else {
                                            Future.microtask(
                                              () => taskAssignByMeApi(
                                                ref,
                                           
                                              ),
                                            );
                                          }
              
                                          if (!context.mounted) return;
              
                                          // Navigator.pushReplacement(
                                          //   context,
                                          //   MaterialPageRoute(builder: (context) => const StackDashboard()),
                                          // );
                                        } else {
                                          // state = AsyncValue.error(
                                          //   response?.data['message'] ?? 'Invalid username or password',
                                          //   StackTrace.current,
                                          // );
                                        }
                                      } catch (e, stackTrace) {
                                        print("Login Error: $e");
              
                                        // state = AsyncValue.error(
                                        //   'Failed to login. Please try again.',
                                        //   stackTrace,
                                        // );
                                      }
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      size: 25,
                                      color: kOrange,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: kgreyText?.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 18,
                                      color: kOrange,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Start: ",
                                      style: TextStyle(
                                        color: kOrange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      formatDate(task.startDate.toString()) ?? "",
                                      style: TextStyle(color: kBlack),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: kgreyText?.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: kOrange,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "End: ",
                                      style: TextStyle(
                                        color: kOrange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      formatDate(task.endDate.toString()) ?? "",
                                      style: TextStyle(color: kBlack),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12),
              
                              /// Name Row
                              // Row(
                              //   children: [
                              //     Icon(
                              //       Icons.person,
                              //       size: 18,
                              //       color: kOrange,
                              //     ),
                              //     // SizedBox(width: 8),
                              //     // Text(
                              //     //   "User ID: ",
                              //     //   style: TextStyle(
                              //     //     color: kOrange,
                              //     //     fontWeight: FontWeight.w600,
                              //     //   ),
                              //     // ),
                              //     // Text(
                              //     //   "${task?.userId}",
                              //     //   style: TextStyle(color: kBlack),
                              //     // ),
                              //   ],
                              // ),
                              SizedBox(height: 12),
              
                              /// Title Row
                              Row(
                                children: [
                                  Icon(Icons.title, size: 18, color: kOrange),
                                  SizedBox(width: 8),
                                  Text(
                                    "Title: ",
                                    style: TextStyle(
                                      color: kOrange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      task?.title ?? "",
                                      style: TextStyle(color: kBlack),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
              
                              /// Description
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.description,
                                    size: 18,
                                    color: kOrange,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Description: ",
                                    style: TextStyle(
                                      color: kOrange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      task?.description ?? "",
                                      style: TextStyle(color: kBlack),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTask()),
          );
        },
        backgroundColor: kOrange,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
