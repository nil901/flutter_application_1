import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
import 'package:flutter_application_1/Screens/task/task_screen.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/api_service/urls.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/global/utils.dart';
import 'package:flutter_application_1/models/lead_task_model.dart';
import 'package:flutter_application_1/models/leds_model/branch_model.dart';
import 'package:flutter_application_1/models/leds_model/get_all_leds_model.dart';
import 'package:flutter_application_1/models/leds_model/get_pending_followups_model.dart';
import 'package:flutter_application_1/models/leds_model/sorce_model.dart';
import 'package:flutter_application_1/models/task_models/all_members_model.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:flutter_application_1/utils/comman_app_bar.dart';
import 'package:flutter_application_1/utils/comman_dropdown.dart';
import 'package:flutter_application_1/utils/comman_textfiled.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddTask extends ConsumerStatefulWidget {
  const AddTask({super.key});
  
  // final GetPendingFollowsByMember data;

  @override
  ConsumerState<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends ConsumerState<AddTask> {
  BranchModel? selectedBranch;
  SourceModel? selectedSorce;
  String? selectedPriroty;
  String? selectConversionStatus;
  int? priorityId;
  int? statusId;
  int? conversionStatusId;
  String? selectStatus;
  String? materialType;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  bool _isLoading = false;
  final TextEditingController meetingDateController = TextEditingController();
  final TextEditingController meetingTimeController = TextEditingController();
  final TextEditingController meetingDescController = TextEditingController();

  bool isSourceSet = false;

  @override
  void initState() {
    super.initState();
    getLeadIdTaskApi(ref);
    getAllMembersApi(ref);
    // print("Widget Data: ${widget.data}");
    scorceApi(ref);
    branchApi(ref); // fetch branches
  }

  LeadIdTaskModel? selectedLead;
  GetAllMembersModel? assignedTo;
  GetAllMembersModel? taskObserver;

  DateTime? selectedDateTime;
  Map<String, int> statusPriorityMap = {
    'Mid': 1,
    // 'Call Back': 2,
    'Lower': 0,
    'Important': 2,
    'High Prority and Urgent': 3,
  };
  Map<String, int> statusIdMap = {
    'Interested': 1,
    'Call Back': 2,
    'No Requirement': 3,
    'Follow Up': 4,
    'Call-not-Received': 5,
  };

  void init(){
    
  }
  bool isActive = false;
  Map<String, int> conversionStatusMap = {'Open': 0, 'Won': 1, 'Lost': 2};
  String? globalFormattedMeetingDate;
  @override
  Widget build(BuildContext context) {
     final chapterList = ref.watch(getAllLedsUprovider);
     print(chapterList.length);
    String contactDate = DateTime.now().toUtc().toIso8601String();
    print(contactDate); // Ex: 2025-04-29T09:15:30.123Z
    return Scaffold(
      appBar: CustomAppBar(title: "add_task".tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            InkWell(
              onTap: () {
                getAllMembersApi(ref);
              
              },
              child: HintTextCustom(text: "add_title".tr),
            ),

            CommonTextField(
              label: "enter_title".tr,
              controller: nameController,
              // icon: Icons.phone,
              //  inputType: TextInputType.phone,
            ),

            // SizedBox(height: ,)

            //const SizedBox(height: 20),
            HintTextCustom(text: "lead".tr),
            Consumer(
              builder: (context, ref, child) {
                final chapterList = ref.watch(getleadIdUprovider);
  
                print("Chapter List Length: ${chapterList.length}");

                return CommonDropdown<LeadIdTaskModel>(
                  hint: "select_leads".tr,
                  value: selectedLead,
                  items: chapterList,
                  getLabel: (district) => district.name,
                  onChanged: (LeadIdTaskModel? value) {
                    setState(() {
                      selectedLead = value;
                    });
                  },
                );
              },
            ),
            HintTextCustom(text: "task_assigned_to".tr),
            Consumer(
              builder: (context, ref, child) {
                final chapterList = ref.watch(getALlMembers);

                print("Chapter List Length: ${chapterList.length}");

                return CommonDropdown<GetAllMembersModel>(
                  hint: "select_assigned_to".tr,
                  value: assignedTo,
                  items: chapterList,
                  getLabel: (district) => district.firstName,
                  onChanged: (GetAllMembersModel? value) {
                    setState(() {
                      assignedTo = value;
                    });
                  },
                );
              },
            ),
            HintTextCustom(text: "task_observer".tr),

            Consumer(
              builder: (context, ref, child) {
                final chapterList = ref.watch(getALlMembers);

                print("Chapter List Length: ${chapterList.length}");

                return CommonDropdown<GetAllMembersModel>(
                  hint: "select_task_observer".tr,
                  value: taskObserver,
                  items: chapterList,
                  getLabel: (district) => district.firstName,
                  onChanged: (GetAllMembersModel? value) {
                    setState(() {
                      taskObserver = value;
                    });
                  },
                );
              },
            ),

            HintTextCustom(text: "prority".tr),
            CommonDropdown<String>(
              hint: 'select_priority'.tr,
              value: selectedPriroty,
              items: statusPriorityMap.keys.toList(),
              getLabel: (value) => value,
              onChanged: (newValue) {
                setState(() {
                  selectedPriroty = newValue;
                  // selectStatus = newValue;
                  priorityId = statusPriorityMap[newValue!];
                  print('Selected Priority ID: $priorityId');
                });
              },
              backgroundColor: Colors.white,
              iconColor: Colors.black,
              borderRadius: 10,
              borderColor: Colors.black,
            ),

            HintTextCustom(text: "start_date".tr),

            CommonTextField(
              controller: startDateController,
              label: "start_date".tr,
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    final selectedDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                    final iso8601 = selectedDateTime.toIso8601String();
                    startDateController.text = iso8601;
                    print("Start Date: $iso8601");
                  }
                }
              },
              readOnly: true,
              inputType: TextInputType.none,
            ),

            HintTextCustom(text: "end_date".tr),
            CommonTextField(
              controller: endDateController,
              label: "end_date".tr,
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    final selectedDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                    final iso8601 = selectedDateTime.toIso8601String();
                    endDateController.text = iso8601;
                    print("End Date: $iso8601");
                  }
                }
              },
              readOnly: true,
              inputType: TextInputType.none,
            ),

            HintTextCustom(text: "description".tr),
            CommonTextField(
              controller: meetingDescController,
              label: "description".tr,
              // controller: phoneNumberController,
              // icon: Icons.phone,
              // inputType: TextInputType.phone,
            ),

            //SizedBox(height: 10),
            InkWell(
              onTap: () {
                setState(() {
                  isActive = !isActive;
                });
              },
              child: Row(
                children: [
                  Checkbox(
                    value: isActive,
                    activeColor: kOrange,
                    onChanged: (value) {
                      setState(() {
                        isActive = value!;
                      });
                    },
                  ),
                  Text(
                    "active_task".tr,
                    style: TextStyle(
                      color: kBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            InkWell(
              onTap: () async {
                if(nameController.text.isEmpty) {
                  Utils().showToastMessage("Please enter name");
                  return;
                }
                if(startDateController.text.isEmpty) {
                  Utils().showToastMessage("Please select start date");
                  return;
                } 
                if(endDateController.text.isEmpty) {
                  Utils().showToastMessage("Please select end date");
                  return;
                }
                if(assignedTo == null) {
                  Utils().showToastMessage("Please select assigned to");
                  return;
                }
                if(taskObserver == null) {
                  Utils().showToastMessage("Please select task observer");
                  return;
                }
                // if(selectedLead == null) {
                //   Utils().showToastMessage("Please select lead");
                //   return;
                // }
                if(priorityId == null) {
                  Utils().showToastMessage("Please select priority");
                  return;
                }
                if(meetingDescController.text.isEmpty) {
                  Utils().showToastMessage("Please enter description");
                  return;
                }
                // if(!isActive) {
                //   Utils().showToastMessage("Please select active task");
                //   return;
                // }

                try {
                  setState(() {
                    _isLoading = true;
                  });
                  final response = await ApiService()
                      .postRequest(createTask, {
                        "title": nameController.text,
                      //  "userId": AppPreference().getInt(PreferencesKey.member_Id),
                        "startDate": startDateController.text,
                        "endDate": endDateController.text,
                        "assignedTo": "${AppPreference().getInt(PreferencesKey.member_Id)}",
                        "observer": "${AppPreference().getInt(PreferencesKey.member_Id)}",
                        "priority": priorityId,
                        "leadId": selectedLead?.leadId,
                        "description": meetingDescController.text,
                        "isActive": isActive,
                      });

                  print("statusCode: ${response?.statusCode}");
                  print("status: ${response?.data['status']}");
                  print("message: ${response?.data['message']}");

                  if (response?.data["status"] == true) {
                    final responseData = response!.data;

                    // state = const AsyncValue.data(null);
                    Utils().showToastMessage(
                      response.data['message'] ?? 'Added successful',
                    );
                    taskAssignByMeApi(ref);

                    Navigator.pop(context);
                    setState(() {
                      _isLoading = false;
                    });
                    if (!context.mounted) return;

                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const StackDashboard()),
                    // );
                  } else {
                    setState(() {
                      _isLoading = false;
                    });
                    // state = AsyncValue.error(
                    //   response?.data['message'] ?? 'Invalid username or password',
                    //   StackTrace.current,
                    // );
                  }
                } catch (e, stackTrace) {
                  print("Login Error: $e");
                  setState(() {
                    _isLoading = false;
                  });
                  // state = AsyncValue.error(
                  //   'Failed to login. Please try again.',
                  //   stackTrace,
                  // );
                }
              },
              child:  Container(
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:_isLoading ?CircularProgressIndicator() :Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kwhite,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

//   // Common Dropdown Widget
//   Widget buildDropdown(String hint) {
//     return DropdownButtonFormField<String>(
//       decoration: InputDecoration(border: OutlineInputBorder()),
//       hint: Text(hint),
//       items: [],
//       onChanged: (value) {},
//     );
//   }
// }
