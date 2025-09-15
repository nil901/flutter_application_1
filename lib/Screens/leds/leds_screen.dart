import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/api_service/urls.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/global/utils.dart';
import 'package:flutter_application_1/models/leds_model/branch_model.dart';
import 'package:flutter_application_1/models/leds_model/location_model.dart';
import 'package:flutter_application_1/models/leds_model/sorce_model.dart';
import 'package:flutter_application_1/models/products_model.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:flutter_application_1/utils/comman_app_bar.dart';
import 'package:flutter_application_1/utils/comman_dropdown.dart';
import 'package:flutter_application_1/utils/comman_textfiled.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddLeadPage extends ConsumerStatefulWidget {
  const AddLeadPage({super.key});

  @override
  ConsumerState<AddLeadPage> createState() => _AddLeadPageState();
}

class _AddLeadPageState extends ConsumerState<AddLeadPage> {
  BranchModel? selectedBranch;
  SourceModel? selectedSorce;
  String? selectedPriroty;
  String? selectConversionStatus;
  int? priorityId;
  int? statusId;
  int? conversionStatusId;
  String? selectStatus;
  String? materialType;
  ProductsModel? selectedProduct;
  LocationModel? selectedLocation;
  @override
  void initState() {
    scorceApi(ref);
    branchApi(ref);
    getAllLocationApi(ref);
    getAllProductsApi(ref);
    // TODO: implement initState
    super.initState();
  }

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
  bool _isLoading = false;
  bool isProductSet = false;
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
    print(contactDate); // Ex: 2025-04-29T09:15:30.123Z
    return Scaffold(
      appBar: CustomAppBar(title: "add_lead".tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            HintTextCustom(text: "status".tr),
            CommonDropdown<String>(
              hint: 'status'.tr,
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
            HintTextCustom(text: "meeting_date".tr),
            CommonTextField(
              controller: meetingTimeController,
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
                  // Current time for time part (this is used to keep the time when date is selected)
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

                  // Format for frontend: MM/dd/yyyy
                  final formattedDateForDisplay = DateFormat(
                    "MM/dd/yyyy",
                  ).format(fullDateTime);

                  // Format for backend: ISO 8601 format
                  final formattedDateForBackend = DateFormat(
                    "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                  ).format(fullDateTime.toUtc());

                  // Set text for display (user will see MM/dd/yyyy)
                  meetingTimeController.text = formattedDateForDisplay;
                  setState(() {
                    globalFormattedMeetingDate = formattedDateForBackend;
                  });
                  // Print formatted date for backend
                  print(
                    "Backend Date: $formattedDateForBackend",
                  ); // This is for your debug, or you can send this to backend
                }
              },
            ),
            HintTextCustom(text: "meeting_time".tr),
            CommonTextField(
              controller: meetingDateController,
              label: "meeting_time".tr,
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  final now = DateTime.now();
                  selectedDateTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                  final formattedTime = DateFormat.jm().format(
                    selectedDateTime!,
                  ); // "08:50 AM"
                  meetingDateController.text = formattedTime;
                  final isoTime = selectedDateTime?.toIso8601String();
                  print(selectedDateTime);
                }
              },
              readOnly: true,
              inputType: TextInputType.none,
            ),
            HintTextCustom(text: "metting_decprtion".tr),
            CommonTextField(
              controller: meetingDescController,
              label: "metting_decprtion".tr,
              // controller: phoneNumberController,
              // icon: Icons.phone,
              // inputType: TextInputType.phone,
            ),

            // Consumer(
            //   builder: (context, ref, child) {
            //     final productList = ref.watch(getAllProductsProvider);
            //     print("Chapter List Length: ${productList.length}");

            //     return CommonDropdown<ProductsModel>(
            //       hint: "select_branch".tr,
            //       value: selectedProduct,
            //       items: productList,
            //       getLabel: (district) => district.name,
            //       onChanged: (ProductsModel? value) {
            //         setState(() {
            //           selectedProduct = value;
            //         });
            //       },
            //     );
            //   },
            // ),
            if (statusId != 3 && statusId != 5)
              HintTextCustom(text: "remark".tr),
            if (statusId != 3 && statusId != 5)
              Consumer(
                builder: (context, ref, child) {
                  final productList = ref.watch(getAllProductsProvider);

                  return CommonDropdown<ProductsModel>(
                    hint: "remark",
                    value: selectedProduct,
                    items: productList,
                    getLabel: (item) => item.name,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedProduct = value;
                        });
                        print("Selected Product: ${selectedProduct?.name}");
                      }
                    },
                  );
                },
              ),

            HintTextCustom(text: "name".tr),

            CommonTextField(
              label: "name".tr,
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
                final sorce = ref.watch(scorceProvider);

                print("Chapter List Length: ${sorce.length}");

                return CommonDropdown<SourceModel>(
                  hint: "select_source".tr,
                  value: selectedSorce,
                  items: sorce,
                  getLabel: (district) => district.name,
                  onChanged: (SourceModel? value) {
                    setState(() {
                      selectedSorce = value;
                    });
                  },
                );
              },
            ),

            HintTextCustom(text: "location".tr),

            Consumer(
              builder: (context, ref, child) {
                final locationList = ref.watch(locationProvider);

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
                      print("sdsd${selectedLocation?.name}");
                    }
                  },
                );
              },
            ),

            // HintTextCustom(text: "position".tr),
            // CommonTextField(
            //   controller: positionController,
            //   label: "position".tr,
            //   // controller: phoneNumberController,
            //   // icon: Icons.phone,
            //   // inputType: TextInputType.,
            // ),
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

            HintTextCustom(text: "reference".tr),
            CommonTextField(
              label: "enter_your_reference_name".tr,
              controller: referenceController,
              // controller: phoneNumberController,
              // icon: Icons.phone,
              // inputType: TextInputType.phone,
            ),
            HintTextCustom(text: "Branch".tr),
            Consumer(
              builder: (context, ref, child) {
                final chapterList = ref.watch(branchProvider);

                print("Chapter List Length: ${chapterList.length}");

                return CommonDropdown<BranchModel>(
                  hint: "select_branch".tr,
                  value: selectedBranch,
                  items: chapterList,
                  getLabel: (district) => district.name,
                  onChanged: (BranchModel? value) {
                    setState(() {
                      selectedBranch = value;
                    });
                  },
                );
              },
            ),

            HintTextCustom(text: "conversation_status".tr),
            CommonDropdown<String>(
              hint: 'conversation_status'.tr,
              value: selectConversionStatus,
              items: ['Open', 'Won', 'Lost'],
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
                if (nameController.text.isEmpty) {
                  Utils().showToastMessage("Please enter name");
                  return;
                }
                // if(emailController.text.isEmpty){
                //   Utils().showToastMessage("Please enter email");
                //   return; }else if(!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(emailController.text)){
                //   Utils().showToastMessage("Please enter valid email");
                //   return; }
                if (mobileController.text.isEmpty) {
                  Utils().showToastMessage("Please enter mobile number");
                  return;
                } else if (!RegExp(
                  r"^\d{10}$",
                ).hasMatch(mobileController.text)) {
                  Utils().showToastMessage("Please enter valid mobile number");

                  // if(websiteController.text.isEmpty){
                  //   Utils().showToastMessage("Please enter website");
                  //   return; }else if(!RegExp(r"^(https?:\/\/)?([a-zA-Z0-9.-]+)\.[a-zA-Z]{2,}").hasMatch(websiteController.text)){
                  //   Utils().showToastMessage("Please enter valid website");
                  //   return; }
                  // if(positionController.text.isEmpty){
                  //   Utils().showToastMessage("Please enter position");
                  //   return; }
                  // if(industryController.text.isEmpty){
                  //   Utils().showToastMessage("Please enter industry");
                  //   return; }

                  if (stateController.text.isEmpty) {
                    Utils().showToastMessage("Please enter state");
                    return;
                  }
                  if (cityController.text.isEmpty) {
                    Utils().showToastMessage("Please enter city");
                    return;
                  }
                }
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
                  "branch": selectedBranch?.name,
                  //0: Lower, 1:Mid, 2:Important, 3:High Prority and Urgent
                  "prority": priorityId,
                  //0:Fresh, 1:Interested, 2:Callback, 3:No Requirement, 4:Followup, 5:Call Not Recieved
                  "status": statusId,
                  //0:Open, 1:Won, 2:Lost
                  "conversionStatus": conversionStatusId,
                  "contactDate": contactDate,
                  "meetingDate": globalFormattedMeetingDate,
                  "meetingTime": meetingTimeController.text,
                  "meetingDescription": meetingDescController.text,
                  "description": "Nothing",
                  "fbCampaignName": fbCampaignController.text,
                  "isDeleted": false,
                  "flatType": selectedProduct?.name,
                  "estimatedBudget": estimatedBudgetController.text,
                  "location": selectedLocation?.name,
                };
                log("${data}");
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  final response = await ApiService().postRequest(createLeads, {
                    "name": nameController.text,
                    "email": emailController.text,
                    // "email": "test@gmail.com",
                    "mobile": mobileController.text,
                    "source": selectedSorce?.name,
                    "website": websiteController.text,
                    "createdBy": AppPreference().getInt(
                      PreferencesKey.member_Id,
                    ),
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
                    "meetingDate": globalFormattedMeetingDate,
                    "meetingTime": meetingTimeController.text,
                    "meetingDescription": meetingDescController.text,
                    "description": "Nothing",
                    "fbCampaignName": fbCampaignController.text,
                    "isDeleted": false,
                    "estimatedBudget": estimatedBudgetController.text,
                  });

                  print("statusCode: ${response?.statusCode}");
                  print("status: ${response?.data['status']}");
                  print("message: ${response?.data['message']}");

                  if (response?.statusCode == 200) {
                    final responseData = response!.data;

                    // state = const AsyncValue.data(null);
                    Utils().showToastMessage(
                      response.data['message'] ?? 'Added successful',
                    );
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
