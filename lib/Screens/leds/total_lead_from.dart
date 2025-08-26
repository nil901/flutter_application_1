import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
import 'package:flutter_application_1/Screens/dashboard_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/due_today_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/pending_follow_ups_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/pending_from_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/today_followups_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/towmorrow_screen.dart';
import 'package:flutter_application_1/Screens/leds/total_lead_update_froms.dart';
import 'package:flutter_application_1/Screens/leds/update_Leds_from_screen.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/api_service/urls.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/global/utils.dart';
import 'package:flutter_application_1/models/leds_model/get_leds_by_model.dart';
import 'package:flutter_application_1/models/leds_model/get_pending_followups_model.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:flutter_application_1/utils/comman_app_bar.dart';
import 'package:flutter_application_1/utils/comman_dropdown.dart';
import 'package:flutter_application_1/utils/comman_textfiled.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_application_1/providers/tab_provider.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class TotalLeadFromScreen extends ConsumerStatefulWidget {
  const TotalLeadFromScreen(this.data, {super.key});
  final GetLedsByHistoryModel data;

  @override
  ConsumerState<TotalLeadFromScreen> createState() =>
      _TotalLeadFromScreenState();
}

class _TotalLeadFromScreenState extends ConsumerState<TotalLeadFromScreen> {
  @override
  void initState() {
    getLeadHistoryApi(ref, widget.data.leadId);
 
    }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedTabProvider);
    final tabTitles = ['${"details".tr}', '${"History".tr}', '${"Tasks".tr}'];
   String formatDate(String isoDate) {
  try {
    final DateTime parsedDate = DateTime.parse(isoDate);
    return DateFormat('dd MMM yyyy').format(parsedDate);
  } catch (e) {
    // You can log the error or handle it differently if needed
    return 'No Meeting Date'; // or return '';
  }
}
    final leadHistory = ref.watch(leadHistoryProvider);
    return Scaffold(
      appBar: CustomAppBar(title: "lead_details".tr),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(tabTitles.length, (index) {
              final isSelected = selectedTab == index;

              return GestureDetector(
                onTap: () {
                  ref.read(selectedTabProvider.notifier).state = index;
                },
                child: Container(
                  width:
                      MediaQuery.of(context).size.width /
                      3.5, // auto sizing with spacing
                  alignment: Alignment.center, // Center the text
                  decoration: BoxDecoration(
                    color: isSelected ? kOrange : kOrangeLight,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    tabTitles[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),
          // Tab content placeholder (you can update this as per selectedTab)
          if (selectedTab == 0)
            // Text("Details content here")
            Expanded(
              child: Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(12),
                    color: kwhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name and Edit Icon Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${widget.data.name}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              TotalLeadUpdateFromsScreen(
                                                widget.data,
                                              ),
                                    ), // Replace with your actual AddLeadPage widget
                                  );
                                },
                                child: Icon(Icons.edit, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Amount and Duration Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "₹ ${widget.data.estimatedBudget??0}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      "-- --",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "28 ${"days".tr}",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Divider(height: 30),

                          // Info Rows
                          infoRow(Icons.person, "${widget.data.name}"),
                          infoRow(Icons.phone, "${widget.data.mobile}"),
                         infoRow(Icons.location_on, widget.data.location ?? 'N/A'),

                          infoRow(
                            Icons.calendar_today,
                            "${formatDate(widget.data.meetingDate.toString())}${widget.data.meetingTime != null ? ' ${widget.data.meetingTime}' : ''}",
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: OtherDetailsScreen(data: widget.data)),
                ],
              ),
            )
          else if (selectedTab == 1)
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Name :${widget.data.name}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          SizedBox(width: 8),
                          // InkWell(
                          //   onTap: () {
                          //     showDialog(
                          //       context: context,
                          //       builder:
                          //           (context) =>
                          //               CallPopupDialog(data: widget.data),
                          //     );
                          //   },
                          //   child: CircleAvatar(
                          //     radius: 15,
                          //     backgroundColor: kOrange,
                          //     child: Icon(Icons.call, color: kwhite, size: 18),
                          //   ),
                          // ),

                          SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              Navigator.of(
                                context,
                              ).push(_createRoute(widget.data.mobile));
                            },
                            child: Icon(Icons.call, color: Colors.blue),
                          ),
                          SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              Utils().openWhatsApp(
                                context,
                                widget.data.mobile,
                                "${"hello".tr} ${widget.data.name}",
                              );
                            },
                            child: Image.asset(
                              'assets/images/whatsapp.png',
                              height: 28,
                              width: 40,
                            ),
                          ),
                        ],
                      ),

                       ListView.builder(
                      itemCount: leadHistory.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = leadHistory[index];
                        return Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: FollowUpTile(
                              dateTime: item.createdAt.toString(), // ✅ Now it's a String
                              meetingDate: item.meetingDate.toString(),
                              user: widget.data.name.toString(),
                              status: item.status ??0,
                              schedule: item.meetingTime,
                              remark: item.remark ?? 'N/A',
                            ),
                          ),
                        );
                      },
                    ),
                    ],
                  ),
                ),
              ),
            )
          else
            Text("Task content here"),
        ],
      ),
      floatingActionButton: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.blue,
        child: IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => CallPopupDialog(data: widget.data),
            );
          },
        ),
      ),
    );
  }

  Widget infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
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

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class FollowUpTile extends StatelessWidget {
//   final String dateTime;
//   final String user;
//   final int status;
//   final String schedule;
//   final String remark;
//   final String Time;
//   const FollowUpTile({
//     super.key,
//     required this.dateTime,
//     required this.user,
//     required this.status,
//     required this.schedule,
//     required this.remark,
//     required this.Time,
  
//   });

//   String formatMeetingDate(String isoDateString) {
//     try {
//       final dateTime = DateTime.parse(isoDateString.trim());
//       return DateFormat(
//         'dd-MMM',
//       ).format(dateTime.toLocal()); // Convert to local time
//     } catch (e) {
//       print('Error parsing date: $e');
//       return 'Invalid date';
//     }
//   }

//   // String get formattedSchedule => DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.parse(schedule));

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         /// Left side date and time
//         SizedBox(
//           width: 60,
//           child: Column(
//             children: [
//               Text(
//                 formatMeetingDate("${dateTime}"),
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 12, color: Colors.black),
//               ),
//                 Text(
//                 "${Time}",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 12, color: Colors.black),
//               ),
//             ],
//           ),
//         ),

//         /// Timeline & circle
//         Column(
//           children: [
//             Container(
//               width: 15,
//               height: 15,
//               decoration: BoxDecoration(
//                 color: getStatusColor(status),
//                 shape: BoxShape.circle,
//               ),
//             ),
//             Container(width: 1, height: 60, color: Colors.grey),
//           ],
//         ),
//         const SizedBox(width: 10),

//         /// Right side content
//         Expanded(
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 RichText(
//                   text: TextSpan(
//                     style: const TextStyle(fontSize: 13, color: Colors.black),
//                     children: [
//                       const TextSpan(text: "User : "),
//                       TextSpan(
//                         text: user,
//                         style: const TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 2),
            
//                 RichText(
//                   text: TextSpan(
//                     style: const TextStyle(fontSize: 13),
//                     children: [
//                       TextSpan(
//                         text: "Status : ",
//                         style: TextStyle(color: Colors.black),
//                       ),
            
//                       TextSpan(
//                         text: getStatusLabel(status),
//                         style: TextStyle(color: getStatusColor(status)),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 Text(
//                   "Schedule : ${schedule}",
//                   style: const TextStyle(fontSize: 13, color: Colors.grey),
//                 ),
//                 SizedBox(height: 2),
            
//                 RichText(
//                   text: TextSpan(
//                     style: const TextStyle(fontSize: 13),
//                     children: [
//                       const TextSpan(
//                         text: "Remark : ",
//                         style: TextStyle(color: Colors.black),
//                       ),
//                       TextSpan(
//                         text: remark,
//                         style: const TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   String getStatusLabel(int? status) {
//     if (status == null) return "Unknown"; // If status is null, return "Unknown"
//     switch (status) {
//       case 0:
//         return "Fresh";
//       case 1:
//         return "Interested";
//       case 2:
//         return "Callback";
//       case 3:
//         return "No Requirement";
//       case 4:
//         return "Followup";
//       case 5:
//         return "Call Not Received";
//       default:
//         return "Unknown";
//     }
//   }
// }

// Color getStatusColor(int? status) {
//   switch (status) {
//     case 1:
//       return Colors.orange; // Interested
//     case 2:
//       return Colors.green; // Callback (received)
//     case 3:
//       return Colors.red; // No Requirement
//     case 5:
//       return Colors.yellow; // Call Not Received
//     default:
//       return Colors.black; // Default color
//   }
// }

class OtherDetailsScreen extends StatelessWidget {
  final GetLedsByHistoryModel data;

  OtherDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final details = {
      '${"added_by".tr}': '${AppPreference().getString(PreferencesKey.name)}',
      '${"source".tr}': data.source ?? 'N/A',
      '${"reference".tr}': data.reference ?? 'N/A',
      '${"description".tr}': data.meetingDescription ?? 'N/A',
    };

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: details.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      entry.value.isEmpty ? 'N/A' : entry.value,
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),
                 // if (entry.key == '${"description".tr}')
                    // TextButton(
                    //   onPressed: () {
                    //     // Handle see more
                    //   },
                    //   child: Text(
                    //     '${"see_more".tr}',
                    //     style: const TextStyle(color: Colors.blue),
                    //   ),
                    // ),
                ],
              ),
              Divider(
                height: 20,
                color: Colors.grey[300],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}


class CallPopupDialog extends ConsumerStatefulWidget {
  final GetLedsByHistoryModel data;

  const CallPopupDialog({super.key, required this.data});

  @override
  ConsumerState<CallPopupDialog> createState() => _CallPopupDialogState();
}

class _CallPopupDialogState extends ConsumerState<CallPopupDialog> {
  bool _isLoading = false;
  String? selectConversionStatus;
  DateTime? selectedDateTime;
  String? selectedPriroty;
  int? priorityId;
  Map<String, int> conversionStatusMap = {
    'Interested': 0,
    'Call Back': 1,
    'Not Interested': 2,
    'follow up': 3,
    'call-not-received': 4,
  };
  Map<String, int> statusPriorityMap = {
    'Mid': 1,
    // 'Call Back': 2,
    'Lower': 0,
    'Important': 2,
    'High Prority and Urgent': 3,
  };
  final TextEditingController meetingDateController = TextEditingController();
  final TextEditingController meetingexstimatedateController =
      TextEditingController();

  String contactDate = DateTime.now().toUtc().toIso8601String();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kwhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // align left
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "you_just_called".tr,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.check, color: Colors.white, size: 30),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.data.mobile}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("${widget.data.name}"),
                      Text("00:00:00"),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              HintTextCustom(text: "${"select_feedback_status".tr}"),
              CommonDropdown<String>(
                hint: '${"select_feedback_status".tr}',
                value: selectConversionStatus,
                items: [
                  'Interested',
                  'Call Back',
                  'Not Interested',
                  'follow up',
                  'call-not-received',
                ],
                getLabel: (value) => value,
                onChanged: (newValue) {
                  setState(() {
                    selectConversionStatus = newValue;
                    // conversionStatusId = conversionStatusMap[newValue!];
                    // print('Selected Conversion Status ID: $conversionStatusId');
                  });
                },
                backgroundColor: Colors.white,
                iconColor: Colors.black,
                borderRadius: 10,
                borderColor: Colors.black,
              ),

              SizedBox(height: 10),
              // _buildDropdown("Select Priority")
              HintTextCustom(text: "${"select_next_meeting_date".tr}"),
              SizedBox(height: 5),
              CommonTextField(
                controller: meetingDateController,
                label: "${"select_next_meeting_date".tr}",
                onTap: () async {
                  FocusScope.of(
                    context,
                  ).requestFocus(FocusNode()); // Keyboard hide

                  // Pick Date
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    // Pick Time
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      // Combine both
                      selectedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );

                      // Format: dd-MM-yyyy hh:mm:ss a
                      final formattedDateTime = DateFormat(
                        'dd-MM-yyyy hh:mm:ss a',
                      ).format(selectedDateTime!);

                      setState(() {
                        meetingDateController.text = formattedDateTime;
                      });

                      print("Selected DateTime: $formattedDateTime");
                    }
                  }
                },
                readOnly: true,
                inputType: TextInputType.none,
              ),

              _buildTextField("Remark", maxLines: 3),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.center, // button aligned to left
                child: InkWell(
                  onTap: () async {
                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      final response = await ApiService().putRequest(
                        '${leadUpadteStatus}/${widget.data.leadId}',
                        {
                          "status": selectConversionStatus,
                          "comment": meetingDateController.text,
                          "meetingDate": meetingDateController.text,
                        },
                      );

                      print("statusCode: ${response?.statusCode}");
                      print("status: ${response?.data['status']}");
                      print("message: ${response?.data['message']}");

                      if (response?.statusCode == 200) {
                        final responseData = response!.data;
                        dueFollowUpsApi(ref,isRefresh: true);
                        pendingFollowUpsApi(ref,isRefresh: true);
                        TodayFollowupsScreenAPi(ref, 1);
                        twoMarrowFollowUpsApi(ref ,);
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
                    width: 200,
                    height: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: kOrange,
                    ),
                    child:
                        _isLoading
                            ? CircularProgressIndicator()
                            : Text(
                              "submit".tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: kwhite,
                              ),
                            ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text("${"faching_recording_file_please_wait".tr}"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        items: [],
        onChanged: (val) {},
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: hint,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
