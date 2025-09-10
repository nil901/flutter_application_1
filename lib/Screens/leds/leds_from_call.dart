import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
import 'package:flutter_application_1/Screens/dashboard_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/due_today_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/pending_follow_ups_screen.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/api_service/urls.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/global/utils.dart';
import 'package:flutter_application_1/models/leds_model/branch_model.dart';
import 'package:flutter_application_1/models/leds_model/location_model.dart';
import 'package:flutter_application_1/models/leds_model/sorce_model.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:flutter_application_1/utils/comman_dropdown.dart';
import 'package:flutter_application_1/utils/comman_textfiled.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LedsFromCall extends ConsumerStatefulWidget {
  const LedsFromCall(
    this.number,
    this.duration,
    this.status,
    this.formatDuration, {
    super.key,
  });
  final number;
  final duration;
  final formatDuration;
  final status;

  // final String? source;

  @override
  ConsumerState<LedsFromCall> createState() => _LedsFromCallState();
}

class _LedsFromCallState extends ConsumerState<LedsFromCall> {
  BranchModel? selectedBranch;
  SourceModel? selectedSorce;
  LocationModel? selectedLocation;
  String? selectedPriroty;
  int? priorityId;
  String? selectConversionStatus;

  int? statusId;
  int? conversionStatusId;
  String? selectStatus;
  String? materialType;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController industryController = TextEditingController();
  final TextEditingController fbProfileController = TextEditingController();
  final TextEditingController twitterProfileController =
      TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController addressController1 = TextEditingController();
  final TextEditingController addressController2 = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController meetingDateController = TextEditingController();
  final TextEditingController meetingTimeController = TextEditingController();
  final TextEditingController meetingDescController = TextEditingController();
  final TextEditingController fbCampaignController = TextEditingController();
  final TextEditingController estimatedBudgetController =
      TextEditingController();
  bool isSourceSet = false;
  bool isBranchSet = false;
  bool isLocationSet = false;
  Map<String, String> remarkOptions = {
    '1RK': '1RK',
    '2BHK': '2BHK',
    '3BHK': '3BHK',
    '4BHK': '4BHK',
    'Row House': 'Row House',
    'SHOP': 'SHOP',
  };
  @override
  void initState() {
    init();
    scorceApi(ref);
    branchApi(ref);
    getAllLocationApi(ref);
    super.initState();
  }

  bool isUpdated = true;
  void init() {
    final leadList = ref.read(getAllLedsStatusProvider);

    if (leadList.isNotEmpty) {
      nameController.text = leadList[0].name ?? '';
      emailController.text = leadList[0].email ?? '';
      mobileController.text = widget.number ?? '';
      websiteController.text = leadList[0].website ?? '';
      websiteController.text = leadList[0].website ?? '';
      positionController.text = leadList[0].position ?? '';
      industryController.text = leadList[0].industry ?? '';
      fbProfileController.text = leadList[0].fbProfile ?? '';
      twitterProfileController.text = leadList[0].twitterProfile ?? '';
      stateController.text = leadList[0].state ?? '';
      cityController.text = leadList[0].city ?? '';
      commentController.text = leadList[0].comment ?? '';
      addressController1.text = leadList[0].address ?? '';
      addressController2.text = leadList[0].address ?? '';
      referenceController.text = leadList[0].reference ?? '';
      final rawDateString = leadList[0].meetingDate;
      if (rawDateString != null && rawDateString.isNotEmpty) {
        try {
          final parsedDate = DateTime.parse(rawDateString);
          final formattedDateForDisplay = DateFormat(
            "dd/MM/yyyy",
          ).format(parsedDate.toLocal());
          formattedDateForBackendGlobal = DateFormat(
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
          ).format(parsedDate.toUtc());
          meetingDateController.text = formattedDateForDisplay;
        } catch (e) {
          meetingDateController.text = '';
          formattedDateForBackendGlobal = null;
          print("Invalid meeting date format from API");
        }
      }
      meetingTimeController.text = leadList[0].meetingTime ?? '';
      meetingDescController.text = leadList[0].meetingDescription ?? '';
      fbCampaignController.text = leadList[0].fbCampaignName ?? '';
      final estimatedBudget = leadList[0]?.estimatedBudget;
      estimatedBudgetController.text =
          estimatedBudget != null ? estimatedBudget.toString() : '';

      selectedRemark = leadList[0]?.flatType?.toString();

      selectedBranch = null;
      selectedSorce = null;
      selectedLocation = null;
      selectStatus = null;
      statusId = null;
      selectedPriroty = null;
      priorityId = null;
      selectConversionStatus = null;
      conversionStatusId = null;
      // bool isBranchSet = false;

      final int? statusIdFromData = leadList[0].conversionStatus;
      final int? Priority = leadList[0].prority;
      final int? status = leadList[0].status;

      if (status != null) {
        final matchingStatus =
            statusIdMap.entries
                .firstWhere(
                  (entry) => entry.value == status,
                  orElse: () => const MapEntry('Interested', 1),
                )
                .key;
        setState(() {
          selectStatus = matchingStatus;
          statusId = status;
        });
        debugPrint('Set status to: $selectStatus');
      }

      if (Priority != null) {
        final matchingStatus =
            statusPriorityMap.entries
                .firstWhere(
                  (entry) => entry.value == Priority,
                  orElse: () => const MapEntry('Mid', 1),
                )
                .key;
        setState(() {
          selectedPriroty = matchingStatus;
          priorityId = Priority;
        });
        debugPrint('Set priorityId to: $selectedPriroty');
      }
      if (statusIdFromData != null) {
        final matchingStatus =
            conversionStatusMap.entries
                .firstWhere(
                  (entry) => entry.value == statusIdFromData,
                  orElse: () => const MapEntry('ss', 0),
                )
                .key;
        setState(() {
          selectConversionStatus = matchingStatus;
          conversionStatusId = statusIdFromData;
        });
        debugPrint('Set conversionStatus to: $selectConversionStatus');
      }
    } else {
      selectedBranch = null;
      selectedSorce = null;
      selectedLocation = null;
      selectStatus = null;
      statusId = null;
      selectedPriroty = null;
      priorityId = null;
      selectConversionStatus = null;
      conversionStatusId = null;
      bool isBranchSet = false;
      nameController.text = '';
      emailController.text = '';
      mobileController.text = '';
      websiteController.text = '';
      websiteController.text = '';
      positionController.text = '';
      industryController.text = '';
      fbProfileController.text = '';
      twitterProfileController.text = '';
      stateController.text = '';
      cityController.text = '';
      commentController.text = '';
      addressController1.text = '';
      addressController2.text = '';
      referenceController.text = '';
      meetingDateController.text = '';
      meetingTimeController.text = '';
      meetingDescController.text = '';
      fbCampaignController.text = '';
      estimatedBudgetController.text = '';
      selectedBranch = null;
      selectedSorce = null;
      selectedLocation = null;
      selectStatus = null;
      statusId = null;
      selectedPriroty = null;
      priorityId = null;
      selectConversionStatus = null;
      conversionStatusId = null;
      selectedRemark = null;
      // bool isBranchSet = false;
    }
  }

  String? formattedDateForBackendGlobal;

  bool _isLoading = false;
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    websiteController.dispose();
    positionController.dispose();
    industryController.dispose();
    fbProfileController.dispose();
    twitterProfileController.dispose();
    stateController.dispose();
    cityController.dispose();
    commentController.dispose();
    addressController1.dispose();
    addressController2.dispose();
    referenceController.dispose();
    meetingDateController.dispose();
    meetingTimeController.dispose();
    meetingDescController.dispose();
    fbCampaignController.dispose();
    estimatedBudgetController.dispose();
    super.dispose();
  }

  DateTime? selectedDateTime;
  Map<String, int> statusPriorityMap = {
    'Hot': 1,
    // 'Call Back': 2,
    'Warm': 0,
    'Cold': 2,
  };
  Map<String, int> statusIdMap = {
    'Interested': 1,
    'Call Back': 2,
    'No Requirement': 3,
    'Follow Up': 4,
    'Call-not-Received': 5,
  };
  String? prevStatusKey;
  int? prevStatusId;
  String? prevMeetingDate;

  void updateIsUpdated() {
    final bool statusChanged = prevStatusId != statusId;
    final bool dateChanged = prevMeetingDate != formattedDateForBackendGlobal;

    if (statusChanged && !dateChanged) {
      isUpdated = true;
    } else if (!statusChanged && dateChanged) {
      isUpdated = false;
    } else if (statusChanged && dateChanged) {
      if (statusId == 3 || statusId == 5) {
        isUpdated = true;
      } else {
        isUpdated = false;
      }
    } else {
      isUpdated = false;
    }

    print("✅ isUpdated: $isUpdated");
  }

  String? selectedStatus;
  String? selectedRemark;
  Map<String, int> conversionStatusMap = {'Open': 0, 'Won': 1, 'Lost': 2};
  String? globalFormattedMeetingDate;
  @override
  Widget build(BuildContext context) {
    final leadList = ref.read(getAllLedsStatusProvider);
    print("leadList: ${leadList.map((e) => e.branch)}");
    final showDateTimeAndRemark =
        selectStatus == "Interested" ||
        selectStatus == "Call Back" ||
        selectStatus == "Follow Up";

    final showRemarkOnly = selectStatus == "No Requirement";
    final showOnlyContactDetails = selectStatus == "Call-not-Received";

    String contactDate = DateTime.now().toUtc().toIso8601String();
    print(contactDate); // Ex: 2025-04-29T09:15:30.123Z
    mobileController.text = widget.number;
    return Container(
      width: 400,
      //height: 700,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top bar with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'you_just_called'.tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Call info
            Center(
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.orange,
                child: Icon(Icons.check, color: Colors.white, size: 30),
              ),
            ),
            //SizedBox(height: 8),
            Center(
              child: Text(
                '${widget.number}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                '00:${widget.duration}',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            HintTextCustom(text: "status".tr),
            CommonDropdown<String>(
              hint: 'status'.tr,
              value: selectStatus,
              items: statusIdMap.keys.toList(),
              getLabel: (value) => value,
              onChanged: (newValue) {
                setState(() {
                  print("Selected Status: $newValue");

                  prevStatusKey = selectStatus;
                  prevStatusId = statusId;

                  selectStatus = newValue;
                  statusId = statusIdMap[newValue];
                  print('Selected Status ID: $statusId');

                  updateIsUpdated(); // 💡 Call logic after update
                });
              },
              backgroundColor: Colors.white,
              iconColor: Colors.black,
              borderRadius: 10,
              borderColor: Colors.black,
            ),

            HintTextCustom(text: "prority".tr),
            CommonDropdown<String>(
              hint: "select_prority".tr,
              value: selectedStatus,
              items: statusPriorityMap.keys.toList(),
              getLabel: (item) => item,
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                  priorityId = statusPriorityMap[value];
                });

                print("Selected: $selectedStatus → Priority ID: $priorityId");
              },
              backgroundColor: Colors.white,
              iconColor: Colors.black,
              borderColor: Colors.blue,
            ),

            if (statusId != 3 && statusId != 5)
              HintTextCustom(text: "meeting_date".tr),
            if (statusId != 3 && statusId != 5)
              CommonTextField(
                controller: meetingDateController,
                label: "meeting_date".tr,
                inputType: TextInputType.none,
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    final now = DateTime.now();
                    final fullDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      now.hour,
                      now.minute,
                      now.second,
                      now.millisecond,
                    );

                    final formattedDateForDisplay = DateFormat(
                      "dd/MM/yyyy",
                    ).format(fullDateTime);
                    final formattedDateForBackend = DateFormat(
                      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                    ).format(fullDateTime.toUtc());

                    setState(() {
                      prevMeetingDate = formattedDateForBackendGlobal;
                      meetingDateController.text = formattedDateForDisplay;
                      formattedDateForBackendGlobal = formattedDateForBackend;

                      updateIsUpdated(); // 💡 Call logic after update
                    });

                    print("Frontend Display Date: $formattedDateForDisplay");
                    print("Backend Date: $formattedDateForBackendGlobal");
                  }
                },
              ),

            if (statusId != 3 && statusId != 5)
              HintTextCustom(text: "meeting_time".tr),
            if (statusId != 3 && statusId != 5)
              CommonTextField(
                controller: meetingTimeController,
                label: "meeting_time".tr,
                inputType: TextInputType.none,
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    final now = DateTime.now();
                    final fullTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                    final formattedTimeForDisplay = DateFormat(
                      "hh:mm a",
                    ).format(fullTime); // e.g. 04:30 PM
                    final formattedTimeForBackend = DateFormat(
                      "HH:mm:ss",
                    ).format(fullTime); // e.g. 16:30:00

                    setState(() {
                      meetingTimeController.text = formattedTimeForDisplay;
                      // formattedMeetingTimeBackendGlobal = formattedTimeForBackend;
                      // print("ksjdksjdksd"+   meetingTimeController.text);
                      // Optional: isUpdated logic if time matters
                      if (statusId == 3 || statusId == 5) {
                        isUpdated = true;
                      } else {
                        isUpdated = false;
                      }
                    });

                    print("Frontend Time: $formattedTimeForDisplay");
                    print("Backend Time: $formattedTimeForBackend");
                  }
                },
              ),

            if (statusId != 3 && statusId != 5)
              HintTextCustom(text: "remark".tr),
            if (statusId != 3 && statusId != 5)
              CommonDropdown<String>(
                hint: 'select_remark'.tr,
                value: selectedRemark,
                items: remarkOptions.keys.toList(),
                getLabel: (value) => value,
                onChanged: (newValue) {
                  setState(() {
                    selectedRemark = newValue;
                  });
                },
                backgroundColor: Colors.white,
                iconColor: Colors.black,
                borderRadius: 10,
                borderColor: Colors.black,
              ),
            if (statusId != 3 && statusId != 5)
              HintTextCustom(text: "metting_decprtion".tr),
            if (statusId != 3 && statusId != 5)
              CommonTextField(
                controller: meetingDescController,
                label: "metting_decprtion".tr,
                // controller: phoneNumberController,
                // icon: Icons.phone,
                // inputType: TextInputType.phone,
              ),

            SizedBox(height: 16),
            // if (statusId != 3 && statusId != 5)
            Text(
              "Contact Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            //if (statusId != 3 && statusId != 5)
            CommonTextField(
              label: "enter_your_name".tr,
              controller: nameController,
              // icon: Icons.phone,
              //  inputType: TextInputType.phone,
            ),
            //if (statusId != 3 && statusId != 5)
            HintTextCustom(text: "source".tr),
            //if (statusId != 3 && statusId != 5)
            Consumer(
              builder: (context, ref, child) {
                final sorceList = ref.watch(scorceProvider);
                if (!isSourceSet &&
                    leadList.isNotEmpty &&
                    leadList[0].source != null &&
                    leadList[0].source.toString().trim().isNotEmpty &&
                    sorceList.isNotEmpty) {
                  final sourceFromData =
                      leadList[0].source.toString().toLowerCase().trim();

                  final match = sorceList.firstWhere(
                    (element) =>
                        element.name.toLowerCase().trim() == sourceFromData,
                    orElse: () => SourceModel(id: '', name: ''),
                  );

                  print("Matched Source: ${match.name}");

                  if (match.id.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          selectedSorce = match;
                          isSourceSet = true;
                        });
                      }
                    });
                  }
                }
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
            if (statusId != 3 && statusId != 5)
              HintTextCustom(text: "location".tr),
            if (statusId != 3 && statusId != 5)
              Consumer(
                builder: (context, ref, child) {
                  final locationList = ref.watch(locationProvider);

                  if (!isLocationSet &&
                      leadList.isNotEmpty &&
                      leadList[0].location != null &&
                      leadList[0].location.toString().trim().isNotEmpty &&
                      locationList.isNotEmpty) {
                    final sourceFromData =
                        leadList[0].location.toString().trim();

                    final match = locationList.firstWhere(
                      (element) => element.name == sourceFromData,
                      orElse:
                          () => LocationModel(id: '', name: '', locationId: 0),
                    );

                    print("Matched Source: ${match.name}");

                    if (match.id.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            selectedLocation = match;
                            isLocationSet = true;
                          });
                        }
                      });
                    }
                  }

                  return CommonDropdown<LocationModel>(
                    hint: "select_location".tr,
                    value: selectedLocation,
                    items: locationList,
                    getLabel: (item) => item.name,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedLocation = value;
                        });
                      }
                    },
                  );
                },
              ),
            //if (statusId != 3 && statusId != 5)
            HintTextCustom(text: "mobile".tr),
            //if (statusId != 3 && statusId != 5)
            CommonTextField(
              label: "enter_your_mobile".tr,
              controller: mobileController,
              inputType: TextInputType.phone,
            ),
            if (statusId != 3 && statusId != 5)
              HintTextCustom(text: "estimated_budget".tr),
            if (statusId != 3 && statusId != 5)
              CommonTextField(
                controller: estimatedBudgetController,
                label: "estimated_budget".tr,
                // controller: phoneNumberController,
                // icon: Icons.phone,
                inputType: TextInputType.number,
              ),
            InkWell(
              onTap: () async {
                final now = DateTime.now();
                final formatted = DateFormat(
                  "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                ).format(now);

                // if (!_isAppInitiatedCall) {
                //   print("External call ended — API call skipped.");
                //   return;
                // }
                print("meetingDate: ${meetingDateController.text}");
                print("meetingTime: ${meetingTimeController.text}");
                if (nameController.text.isEmpty) {
                  Utils().showToastMessage("enter_your_name".tr);
                  return;
                }
                // String email = emailController.text.trim();

                // if (email.isNotEmpty) {
                //   bool isValidEmail = RegExp(
                //     r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                //   ).hasMatch(email);

                //   if (!isValidEmail) {
                //     Utils().showToastMessage("enter_your_email".tr);
                //     return;
                //   }
                // }

                if (mobileController.text.isEmpty) {
                  Utils().showToastMessage("enter_your_mobile".tr);
                  return;
                }
                final leadList = ref.read(getAllLedsStatusProvider);

                var data = {
                  "name": nameController.text,
                  "email": emailController.text,
                  // "email": "test@gmail.com",
                  "mobile": mobileController.text,
                  "source": selectedSorce?.name,
                  "website": websiteController.text,
                  //  "createdBy": AppPreference().getInt(PreferencesKey.member_Id),
                  "position": positionController.text,
                  "industry": industryController.text,
                  "fbProfile": fbProfileController.text,
                  // "fbProfile": "Alen here",
                  "twitterProfile": twitterProfileController.text,
                  "state": stateController.text,
                  "city": cityController.text,
                  "comment": commentController.text,
                  "address": addressController1.text,
                  "reference": referenceController.text,
                  "branch": selectedBranch?.name,
                  //0: Lower, 1:Mid, 2:Important, 3:High Prority and Urgent
                  "prority": priorityId,
                  //0:Fresh, 1:Interested, 2:Callback, 3:No Requirement, 4:Followup, 5:Call Not Recieved
                  "status": statusId,
                  //0:Open, 1:Won, 2:Lost
                  "conversionStatus": conversionStatusId,
                  "contactDate": contactDate,
                  "meetingDate": formattedDateForBackendGlobal,
                  "meetingTime": meetingTimeController.text,
                  "meetingDescription": meetingDescController.text,
                  "description": "Nothing",
                  "fbCampaignName": fbCampaignController.text,
                  "isDeleted": false,
                  //"remark": meetingDescController.text,
                  "estimatedBudget": estimatedBudgetController.text,
                  "flatType": selectedRemark,
                  "location": selectedLocation?.name,
                  // "isStatusUpdated": isUpdated,
                };
                log("${data}");

                try {
                  setState(() {
                    _isLoading = true;
                  });
                  final body = {
                    "name": nameController.text,
                    "email": emailController.text,
                    "mobile": mobileController.text,
                    "source": selectedSorce?.name,
                    "website": websiteController.text,
                    "createdBy": AppPreference().getInt(
                      PreferencesKey.member_Id,
                    ),
                    "position": positionController.text,
                    "industry": industryController.text,
                    "fbProfile": fbProfileController.text,
                    "twitterProfile": twitterProfileController.text,
                    "state": stateController.text,
                    "city": cityController.text,
                    "comment": meetingDescController.text,
                    "address": addressController1.text,
                    "reference": referenceController.text,
                    "branch": selectedBranch?.name,
                    "prority": priorityId,
                    //  "remark": meetingDescController.text,
                    "status": statusId,
                    "conversionStatus": conversionStatusId,
                    "contactDate": contactDate,
                    "meetingDate": formattedDateForBackendGlobal,
                    "meetingTime": meetingTimeController.text,
                    "meetingDescription": meetingDescController.text,
                    "description": "Nothing",
                    "fbCampaignName": fbCampaignController.text,
                    "isDeleted": false,
                    "estimatedBudget": estimatedBudgetController.text,
                    "flatType": selectedRemark,
                    "location": selectedLocation?.name,
                  };

                  final url =
                      leadList.isEmpty
                          ? createLeads
                          : "${updateLeads}/${leadList[0].leadId}";
                  log(url);
                  final response =
                      leadList.isEmpty
                          ? await ApiService().postRequest(url, body)
                          : await ApiService().putRequest(url, data);

                  print("statusCode: ${response?.statusCode}");
                  print("status: ${response?.data['status']}");
                  print("message: ${response?.data['message']}");
                  log("${response?.data}");
                  if (response?.statusCode == 200) {
                    final responseData = response!.data;
                    dueFollowUpsApi(ref, isRefresh: true);

                    // state = const AsyncValue.data(null);
                    Utils().showToastMessage(
                      response.data['message'] ?? 'Added successful',
                    );
                    final memberId = AppPreference().getInt(
                      PreferencesKey.member_Id,
                    );
                    setState(() {
                      isUpdated = true;
                    });
                    try {
                      final callHistoryResponse = await ApiService()
                          .postRequest(createCallHistory, {
                            "memberId": memberId,
                            "caller":
                                "${AppPreference().getString(PreferencesKey.mobile_no)}",
                            "reciever": mobileController.text,
                            "duration": widget.status,
                            "date": formatted,
                            'status': widget.formatDuration,
                            'name': nameController.text,
                          })
                          .timeout(
                            const Duration(seconds: 20),
                            onTimeout: () {
                              throw TimeoutException(
                                "Call history API timed out",
                              );
                            },
                          );
                      widget.duration == "0:00";
                      if (!mounted) return;
                      // Utils().showToastMessage(
                      //   callHistoryResponse?.data['message'] ??
                      //       'Call History Added/Failed',
                      // );
                    } catch (e) {
                      print("Call History Error: $e");
                      if (mounted) {
                        Utils().showToastMessage(
                          "Call history save failed: ${e.toString()}",
                        );
                      }
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                    // Navigator.pop(context);
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }

                    if (!context.mounted) return;

                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const StackDashboard()),
                    // );
                  } else {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }

                    // state = AsyncValue.error(
                    //   response?.data['message'] ?? 'Invalid username or password',
                    //   StackTrace.current,
                    // );
                  }
                  dueFollowUpsApi(ref, isRefresh: true);
                  fetchDashboardCount(ref);
                  pendingFollowUpsApi(ref, isRefresh: true);
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
              child: Container(
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: kwhite)
                        : Text(
                          "Submit",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: kwhite,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
