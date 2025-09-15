import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
import 'package:flutter_application_1/Screens/dashboard_task/due_today_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/pending_follow_ups_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/today_followups_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/towmorrow_screen.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/api_service/urls.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/global/utils.dart';
import 'package:flutter_application_1/models/leds_model/branch_model.dart';
import 'package:flutter_application_1/models/leds_model/get_leds_by_model.dart';
import 'package:flutter_application_1/models/leds_model/get_pending_followups_model.dart';
import 'package:flutter_application_1/models/leds_model/location_model.dart';
import 'package:flutter_application_1/models/leds_model/sorce_model.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:flutter_application_1/utils/comman_app_bar.dart';
import 'package:flutter_application_1/utils/comman_dropdown.dart';
import 'package:flutter_application_1/utils/comman_textfiled.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TotalLeadUpdateFromsScreen extends ConsumerStatefulWidget {
  const TotalLeadUpdateFromsScreen(this.data, {super.key});
  final GetLedsByHistoryModel data;

  @override
  ConsumerState<TotalLeadUpdateFromsScreen> createState() =>
      _TotalLeadUpdateFromsScreenState();
}

class _TotalLeadUpdateFromsScreenState
    extends ConsumerState<TotalLeadUpdateFromsScreen> {
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
  bool isLocationSet = false;
  bool isbranchSet = false;
  String? prevMeetingDate;
  String? selectedRemark;
  String? formattedDateForBackendGlobal;
  @override
  void initState() {
    super.initState();

    print("Widget Data: ${widget.data}");
    scorceApi(ref);
    getAllLocationApi(ref);
    branchApi(ref); // fetch branches

    //  final sorceList = ref.read(scorceProvider);

    //     // Match from widget.data.source to the list
    //  final matchedSorce = sorceList.firstWhere(
    //   (e) {
    //     final fromList = e.name.toLowerCase().trim();
    //     final fromData = widget.data.source?.toLowerCase().trim();
    //     log('Comparing source: list="$fromList" vs data="$fromData"');
    //     return fromList == fromData;
    //   },
    //   orElse: () {
    //     log('No matching source found. Returning default.');
    //     return SourceModel(id: '', name: ''); // or handle differently
    //    // return sorceList.isNotEmpty ? sorceList.first : null; // or handle differently
    //   },
    // );

    // log('Matched source: ${matchedSorce.name}');
    setState(() {
      nameController.text = widget.data.name ?? "";
      emailController.text = widget.data.email ?? "";
      mobileController.text = widget.data.mobile ?? "";
      websiteController.text = widget.data.website ?? "";
      positionController.text = widget.data.position ?? "";
      industryController.text = widget.data.industry ?? "";
      fbProfileController.text = widget.data.fbProfile ?? "";
      twitterProfileController.text = widget.data.twitterProfile ?? "";
      stateController.text = widget.data.state ?? "";
      cityController.text = widget.data.city ?? "";
      commentController.text = widget.data.comment ?? "";
      addressController1.text = widget.data.address ?? "";
      addressController2.text = widget.data.address ?? "";
      referenceController.text = widget.data.reference ?? "";
      meetingDateController.text = widget.data.meetingDate.toString() ?? "";
      print(meetingDateController.text);
      meetingTimeController.text = widget.data.meetingTime ?? '';
      meetingDescController.text = widget.data.meetingDescription ?? "";
      fbCampaignController.text = widget.data.fbCampaignName ?? "";
      estimatedBudgetController.text =
          widget.data.estimatedBudget?.toString() ?? "";

      // selectedSorce = matchedSorce;
    });

    init();
  }

  LocationModel? selectedLocation;
  void init() {
    // selectedBranch = null;
    //selectedSorce = null;
    selectStatus = null;
    statusId = null;
    selectedPriroty = null;
    priorityId = null;
    selectConversionStatus = null;
    conversionStatusId = null;
    bool isBranchSet = false;

    final int? statusIdFromData = widget.data.conversionStatus;
    final int? Priority = widget.data.prority;
    final int? status = widget.data.status;
    final barnch = widget.data.branch?.toString().toLowerCase().trim();
    // if (barnch != null) {
    //   final branchList = ref.read(branchProvider);
    //   if (branchList.isNotEmpty) {
    //     final matchedBranch = branchList.firstWhere(
    //       (e) => e.id.toString().toLowerCase().trim() == barnch,
    //       orElse: () => BranchModel(id: '', name: ''),
    //     );
    //     setState(() {
    //       selectedBranch = matchedBranch;
    //       isBranchSet = true;
    //     });
    //   }
    // }
    // setState(() {
    //   // selectedSorce = null;
    //   isSourceSet = false;
    // });

    //   final sorceList = ref.read(scorceProvider);

    // final sourceFromData = widget.data.source?.toString().toLowerCase().trim();
    // // final sorceList = ref.read(scorceProvider);

    // if (sourceFromData != null && sorceList.isNotEmpty) {
    //   final match = sorceList.firstWhere(
    //     (element) => element.name.toLowerCase().trim() == sourceFromData,
    //     orElse: () => SourceModel(id: '', name: ''),
    //   );

    //   if (match.id.isNotEmpty) {
    //     setState(() {
    //       selectedSorce = match;
    //       isSourceSet = true;
    //     });
    //   }
    // }

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
    // if (sorceList.isNotEmpty) {
    //   final matchedSorce = sorceList.firstWhere(
    //     (e) {
    //       final fromList = e.name.toLowerCase().trim();
    //       final fromData = widget.data.source?.toLowerCase().trim();
    //       log('Comparing source: list="$fromList" vs data="$fromData"');
    //       return fromList == fromData;
    //     },
    //     orElse: () {
    //       log('No matching source found. Returning default.');
    //       return SourceModel(id: '', name: ''); // or handle differently
    //     },
    //   );
    //   setState(() {
    //     selectedSorce = matchedSorce;
    //   });
    // }
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
  }

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
    'Hot ': 1,
    // 'Call Back': 2,
    'Warm ': 0,
    'Cold ': 2,
    // 'High Prority and Urgent': 3,
  };
  Map<String, int> statusIdMap = {
    'Interested': 1,
    'Call Back': 2,
    'No Requirement': 3,
    'Follow Up': 4,
    'Call-not-Received': 5,
  };
  Map<String, int> conversionStatusMap = {'Open': 0, 'Won': 1, 'Lost': 2};
  String? globalFormattedMeetingDate;
  @override
  Widget build(BuildContext context) {
    String contactDate = DateTime.now().toUtc().toIso8601String();
    // print(contactDate); // Ex: 2025-04-29T09:15:30.123Z
    return Scaffold(
      appBar: CustomAppBar(title: "update_lead".tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
             HintTextCustom(text: "status".tr),
            CommonDropdown<String>(
              hint: 'select_status'.tr,
              value: selectStatus,
              items: statusIdMap.keys.toList(),
              getLabel: (value) => value,
              onChanged: (newValue) {
                setState(() {
                  selectStatus = newValue;
                  statusId = statusIdMap[newValue!];
                  print('Selected Status ID: $statusId');
                });
              },
              backgroundColor: Colors.white,
              iconColor: Colors.black,
              borderRadius: 10,
              borderColor: Colors.black,
            ),
            InkWell(
              onTap: () {
                // final sorceList = ref.read(scorceProvider);

                final int? statusIdFromData = widget.data.conversionStatus;

                if (statusIdFromData != null) {
                  final matchingStatus =
                      conversionStatusMap.entries
                          .firstWhere(
                            (entry) => entry.value == statusIdFromData,
                            orElse: () => const MapEntry('Open', 0),
                          )
                          .key;

                  setState(() {
                    selectConversionStatus = matchingStatus;
                    conversionStatusId = statusIdFromData;
                  });

                  debugPrint(
                    'Set conversionStatus to: $selectConversionStatus',
                  );
                }
              },
              child: HintTextCustom(text: "Name"),
            ),

            CommonTextField(
              label: "enter_your_name".tr,
              controller: nameController,
              // icon: Icons.phone,
              //  inputType: TextInputType.phone,
            ),
            // SizedBox(height: ,)
            HintTextCustom(text: "email".tr),
            CommonTextField(
              label: "enter_your_email".tr,
              controller: emailController,
              // icon: Icons.phone,
              inputType: TextInputType.emailAddress,
            ),
            HintTextCustom(text: "mobile".tr),
            CommonTextField(
              label: "enter_your_mobile".tr,
              controller: mobileController,
              // icon: Icons.phone,
              inputType: TextInputType.phone,
            ),
            //const SizedBox(height: 20),
            HintTextCustom(text: "source".tr),
            Consumer(
              builder: (context, ref, child) {
                final sorceList = ref.watch(scorceProvider);

                if (!isSourceSet &&
                    widget.data.source != null &&
                    sorceList.isNotEmpty) {
                  final sourceFromData =
                      widget.data.source.toString().toLowerCase().trim();

                  final match = sorceList.firstWhere(
                    (element) =>
                        element.name.toLowerCase().trim() == sourceFromData,
                    orElse: () => SourceModel(id: '', name: ''),
                  );
                  print(match.name);

                  if (match.id.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        selectedSorce = match;
                        isSourceSet = true;
                      });
                    });
                  }
                }

                return CommonDropdown<SourceModel>(
                  hint: "select_source".tr,
                  value: selectedSorce,
                  items: sorceList,
                  getLabel: (item) => item.name,
                  onChanged: (value) {
                    setState(() {
                      selectedSorce = value;
                    });
                  },
                );
              },
            ),

            HintTextCustom(text: "state".tr),
            CommonTextField(
              controller: stateController,
              label: "enter_your_state".tr,

              // inputType: TextInputType.phone,
            ),
            HintTextCustom(text: "city".tr),
            CommonTextField(
              controller: cityController,
              label: "enter_your_city".tr,
              // controller: phoneNumberController,
              // icon: Icons.phone,
              // inputType: TextInputType.phone,
            ),
            HintTextCustom(text: "comment".tr),
            CommonTextField(
              controller: commentController,
              label: "enter_your_comment".tr,
              // controller: phoneNumberController,
              // icon: Icons.phone,
              // inputType: TextInputType.phone,
            ),
            HintTextCustom(text: "address".tr),
            CommonTextField(
              controller: addressController1,
              label: "enter_your_address".tr,
              // controller: phoneNumberController,
              // icon: Icons.phone,
              // inputType: TextInputType.phone,
            ),


            HintTextCustom(text: "branch".tr),
            Consumer(
              builder: (context, ref, child) {
                final branchList = ref.watch(branchProvider);

                if (!isbranchSet &&
                    widget.data.branch != null &&
                    branchList.isNotEmpty) {
                  final branchFromData =
                      widget.data.branch.toString().toLowerCase().trim();

                  final match = branchList.firstWhere(
                    (element) =>
                        element.name.toLowerCase().trim() == branchFromData,
                    orElse: () => BranchModel(id: '', name: ''),
                  );

                  if (match.id.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        // 👇 Ensure selectedBranch is exactly from branchList
                        selectedBranch = branchList.firstWhere(
                          (e) => e.id == match.id,
                        );
                        isbranchSet = true;
                      });
                    });
                  }
                }

                return CommonDropdown<BranchModel>(
                  hint: "select_branch".tr,
                  value: selectedBranch,
                  items: branchList,
                  getLabel: (item) => item.name,
                  onChanged: (value) {
                    setState(() {
                      selectedBranch = value;
                    });
                  },
                );
              },
            ),

            HintTextCustom(text: "prority".tr),
            CommonDropdown<String>(
              hint: 'select_prority'.tr,
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
           
            HintTextCustom(text: "conversation_status".tr),
            CommonDropdown<String>(
              hint: 'select_conversation_status'.tr,
              value: selectConversionStatus,
              items: conversionStatusMap.keys.toList(),
              getLabel: (value) => value,
              onChanged: (newValue) {
                setState(() {
                  selectConversionStatus = newValue;
                  conversionStatusId = conversionStatusMap[newValue!];
                  print('Selected Conversion Status ID: $conversionStatusId');
                });
              },
              backgroundColor: Colors.white,
              iconColor: Colors.black,
              borderRadius: 10,
              borderColor: Colors.black,
            ),

            HintTextCustom(text: "meeting_date".tr),

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
                  });

                  print("Frontend Display Date: $formattedDateForDisplay");
                  print("Backend Date: $formattedDateForBackendGlobal");
                }
              },
            ),

            HintTextCustom(text: "meeting_time".tr),

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
                  });

                  print("Frontend Time: $formattedTimeForDisplay");
                  print("Backend Time: $formattedTimeForBackend");
                }
              },
            ),

            HintTextCustom(text: "location".tr),

            Consumer(
              builder: (context, ref, child) {
                final locationList = ref.watch(locationProvider);

                // Get the location string from widget.data safely
                final sourceFromData =
                    widget.data.location?.toString().trim() ?? '';

                // Only try to set location if it hasn't been set and valid data exists
                if (!isLocationSet &&
                    sourceFromData.isNotEmpty &&
                    locationList.isNotEmpty) {
                  // Try to match the location from the list
                  final match = locationList.firstWhere(
                    (element) => element.name == sourceFromData,
                    orElse:
                        () => LocationModel(id: '', name: '', locationId: 0),
                  );

                  print("Matched Source: ${match.name}");

                  // If a match is found, set the selected location
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
            HintTextCustom(text: "meeting_description".tr),
            CommonTextField(
              controller: meetingDescController,
              label: "meeting_description".tr,
              // controller: phoneNumberController,
              // icon: Icons.phone,
              // inputType: TextInputType.phone,
            ),
            HintTextCustom(text: "fb_compaingn_name".tr),
            CommonTextField(
              controller: fbCampaignController,
              label: "fb_compaingn_name".tr,
              // controller: phoneNumberController,
              // icon: Icons.phone,
              // inputType: TextInputType.phone,
            ),
            HintTextCustom(text: "estimated_budget".tr),
            CommonTextField(
              controller: estimatedBudgetController,
              label: "estimated_budget".tr,
              // controller: phoneNumberController,
              // icon: Icons.phone,
              inputType: TextInputType.number,
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: () async {
                var data = {
                  "name": nameController.text,
                  "email": emailController.text,
                  // "email": "test@gmail.com",
                  "mobile": mobileController.text,
                  "source": selectedSorce?.name,
                  "website": websiteController.text,
                  "createdBy": AppPreference().getInt(PreferencesKey.member_Id),
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
                  "branch": selectedBranch?.id,
                  //0: Lower, 1:Mid, 2:Important, 3:High Prority and Urgent
                  "prority": priorityId,
                  //0:Fresh, 1:Interested, 2:Callback, 3:No Requirement, 4:Followup, 5:Call Not Recieved
                  "status": statusId,
                  //0:Open, 1:Won, 2:Lost
                  "conversionStatus": conversionStatusId,
                  "contactDate": contactDate,
                  "meetingDate": formattedDateForBackendGlobal,
                  "location": selectedLocation?.name,
                  "meetingTime": meetingTimeController.text,
                  "meetingDescription": meetingDescController.text,
                  "description": "Nothing",
                  "fbCampaignName": fbCampaignController.text,
                  "isDeleted": false,
                  "estimatedBudget": estimatedBudgetController.text,
                };
                log("${data}");
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  final response = await ApiService().putRequest(
                    '${updateLeads}/${widget.data.leadId}',
                    {
                      "name": nameController.text,
                      "email": emailController.text,
                      // "email": "test@gmail.com",
                      "mobile": mobileController.text,
                      "source": selectedSorce?.name,
                      "website": websiteController.text,
                      // "createdBy": AppPreference().getInt(
                      //   PreferencesKey.member_Id,
                      // ),
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
                      "branch": selectedBranch?.id,
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
                      "estimatedBudget": estimatedBudgetController.text,
                      // "isStatusUpdated": true,
                    },
                  );

                  print("statusCode: ${response?.statusCode}");
                  print("status: ${response?.data['status']}");
                  print("message: ${response?.data['message']}");

                  if (response?.statusCode == 200) {
                    final responseData = response!.data;
                    try {
                      // Filter values
                      // final name = _searchController.text.trim();
                      // final sourceParam = selectedSorce?.name ?? '';
                      // final from =
                      //     fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : '';
                      // final to = toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : '';

                      // Query string
                      final queryParams = [
                        "page=1",
                        "name=",
                        "source=",
                        "fromDate=",
                        "toDate=",
                      ].join("&");

                      // API Call
                      final response = await ApiService().getRequest(
                        "${getAllLead}$queryParams",
                      );

                      if (response?.statusCode == 200) {
                        final data = response?.data['leads'] as List;
                        final newLeads =
                            data
                                .map(
                                  (json) =>
                                      GetLedsByHistoryModel.fromJson(json),
                                )
                                .toList();

                        final currentLeads = ref.read(getAllLedsProvider);
                        if (1 == 1) {
                          ref.read(getAllLedsProvider.notifier).state =
                              newLeads;
                        } else {
                          ref.read(getAllLedsProvider.notifier).state = [
                            ...currentLeads,
                            ...newLeads,
                          ];
                        }

                        if (newLeads.isEmpty) {
                          //  hasMoreData = false;
                        }
                      }
                    } catch (e) {
                      print("Error: $e");
                    } finally {
                      //  ref.read(isLoadingProvider.notifier).state = false;
                    }
                    // state = const AsyncValue.data(null);
                    Utils().showToastMessage(
                      response.data['message'] ?? 'update_scucessfully'.tr,
                    );
                    dueFollowUpsApi(ref);

                    pendingFollowUpsApi(ref);
                    // TodayFollowupsScreenAPi(ref,1);
                    twoMarrowFollowUpsApi(ref);
                    Navigator.pop(context);
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
                  print(" $e");
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
                          "submit".tr,
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
