import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/dashboard_screen.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/api_service/urls.dart';
import 'package:flutter_application_1/global/utils.dart';
import 'package:flutter_application_1/models/history/get_call_by_history_model.dart';
import 'package:flutter_application_1/models/history/mycalls_history_model.dart';
import 'package:flutter_application_1/models/lead_history_model.dart';
import 'package:flutter_application_1/models/lead_task_model.dart';
import 'package:flutter_application_1/models/leds_model/branch_model.dart';
import 'package:flutter_application_1/models/leds_model/get_all_leds_model.dart';
import 'package:flutter_application_1/models/leds_model/get_leads_status_model.dart';
import 'package:flutter_application_1/models/leds_model/get_leds_by_model.dart';
import 'package:flutter_application_1/models/leds_model/get_pending_followups_model.dart';
import 'package:flutter_application_1/models/leds_model/location_model.dart';
import 'package:flutter_application_1/models/leds_model/sorce_model.dart';
import 'package:flutter_application_1/models/task_models/all_members_model.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, AsyncValue<void>>((
  ref,
) {
  return LoginNotifier();
});

class LoginNotifier extends StateNotifier<AsyncValue<void>> {
  LoginNotifier() : super(const AsyncValue.data(null));

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    state = const AsyncValue.loading();

    try {
      final response = await ApiService().postRequest("${loginEndPoint}", {
        "email": email,
        "password": password,
      });

      print("statusCode: ${response?.statusCode}");
      print("status: ${response?.data['status']}");
      print("message: ${response?.data['message']}");

      if (response?.statusCode == 200) {
        final responseData = response!.data;

        state = const AsyncValue.data(null);
        Utils().showToastMessage(
          response.data['message'] ?? 'Login successful',
        );

        if (!context.mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StackDashboard()),
        );
      } else {
        state = AsyncValue.error(
          response?.data['message'] ?? 'Invalid username or password',
          StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      print("Login Error: $e");
      state = AsyncValue.error(
        'Failed to login. Please try again.',
        stackTrace,
      );
    }
  }
}

final branchProvider = StateProvider<List<BranchModel>>((ref) => []);
final scorceProvider = StateProvider<List<SourceModel>>((ref) => []);
final locationProvider = StateProvider<List<LocationModel>>((ref) => []);
final leadHistoryProvider = StateProvider<List<LeadHistoryManageModel>>(
  (ref) => [],
);
final myHistoryProvider = StateProvider<List<MyCallHistoryModel>>((ref) => []);
final getAllLedsProvider = StateProvider<List<GetLedsByHistoryModel>>(
  (ref) => [],
);
final getAllLedsStatusProvider = StateProvider<List<GetLeadStatusUpdateModel>>(
  (ref) => [],
);
final getPendingFollowUprovider =
    StateProvider<List<GetPendingFollowsByMember>>((ref) => []);
final getAllLedsUprovider = StateProvider<List<getAllLeadsModel>>((ref) => []);
final getleadIdUprovider = StateProvider<List<LeadIdTaskModel>>((ref) => []);
final getALlMembers = StateProvider<List<GetAllMembersModel>>((ref) => []);
final getHistoryPerson = StateProvider<List<GetCallHistoryByPersonModel>>(
  (ref) => [],
);

Future<void> getLeadIdTaskApi(WidgetRef ref) async {
  // print("helowwckxckdnkdfn");
  try {
    final response = await ApiService().getRequest("${getleadIdTask}");
    log("----------------------------${response?.data['data']}");
    if (response != null && response.statusCode == 200) {
      final data = response.data['data'] as List;

      print(data);

      ref.read(getleadIdUprovider.notifier).state =
          data.map((json) => LeadIdTaskModel.fromJson(json)).toList();
    } else {}
  } catch (e) {
    print("Error fetching appointments: $e");
    throw Exception("Failed to load data");
  }
}

Future<void> getLeadHistoryApi(WidgetRef ref, id) async {
  // print("helowwckxckdnkdfn");
  try {
    final response = await ApiService().getRequest("${getleadHistory}/$id");
    log("----------------------------${response?.data['data']}");
    if (response != null && response.statusCode == 200) {
      final data = response.data['leadHistory'] as List;

      print(data);

      ref.read(leadHistoryProvider.notifier).state =
          data.map((json) => LeadHistoryManageModel.fromJson(json)).toList();
    } else {}
  } catch (e) {
    print("Error fetching appointments: $e");
    throw Exception("Failed to load data");
  }
}

Future<void> getAllLocationApi(WidgetRef ref) async {
  // print("helowwckxckdnkdfn");
  try {
    final response = await ApiService().getRequest(getAllLocation);
    print(response?.data['data']);
    if (response != null && response.data['status'] == true) {
      final data = response.data['data'] as List;

      print(data);

      ref.read(locationProvider.notifier).state =
          data.map((json) => LocationModel.fromJson(json)).toList();
    } else {}
  } catch (e) {
    print("Error fetching appointments: $e");
    throw Exception("Failed to load data");
  }
}

Future<void> getAllMembersApi(WidgetRef ref) async {
  // print("helowwckxckdnkdfn");
  try {
    final response = await ApiService().getRequest(getAllMembers);
    print(response?.data['data']);
    if (response != null && response.data['status'] == true) {
      final data = response.data['data'] as List;

      print(data);

      ref.read(getALlMembers.notifier).state =
          data.map((json) => GetAllMembersModel.fromJson(json)).toList();
    } else {}
  } catch (e) {
    print("Error fetching appointments: $e");
    throw Exception("Failed to load data");
  }
}

Future<void> getAllLedsApi(WidgetRef ref) async {
  // print("helowwckxckdnkdfn");
  log("----------------------------${getAllLeds}");
  try {
    final response = await ApiService().getRequest(getAllLeds);
    if (response != null && response.statusCode == 200) {
      final data = response.data['leads'] as List;
      ref.read(getPendingFollowUprovider.notifier).state =
          data.map((json) => GetPendingFollowsByMember.fromJson(json)).toList();
    } else {}
  } catch (e) {
    print("Error fetching appointments: $e");
    throw Exception("Failed to load data");
  }
}

Future<void> branchApi(WidgetRef ref) async {
  try {
    final response = await ApiService().getRequest(getAllBranch);
    print(response?.data['data']);
    if (response != null && response.data['status'] == true) {
      final data = response.data['data']['branch'] as List;

      print(data);

      ref.read(branchProvider.notifier).state =
          data.map((json) => BranchModel.fromJson(json)).toList();
    } else {}
  } catch (e) {
    print("Error fetching appointments: $e");
    throw Exception("Failed to load data");
  }
}

Future<void> scorceApi(WidgetRef ref) async {
  // print("helowwckxckdnkdfn");
  try {
    final response = await ApiService().getRequest(getAllSorce);
    print(response?.data['data']);
    if (response != null && response.data['status'] == true) {
      final data = response.data['data']['source'] as List;

      print(data);

      ref.read(scorceProvider.notifier).state =
          data.map((json) => SourceModel.fromJson(json)).toList();
    } else {}
  } catch (e) {
    print("Error fetching appointments: $e");
    throw Exception("Failed to load data");
  }
}

// Future<List<StartExamModel>> StartExpamApi(WidgetRef ref, context, cName,
//     {time, practice}) async {
//   // log("StartExpamApi called with cName: $startPractice");
//   var startPracticeody = {
//     "student_id": AppPreference().getString(PreferencesKey.student_id),
//     "chapter_name": cName
//   };
//   log("${startPracticeody}");
//   log("StartExpamApi called with time: $startPractice");
//   try {
//     final response = await ApiService().postRequest(startPractice, {
//       "student_id": AppPreference().getString(PreferencesKey.student_id),
//       "chapter_name": cName
//     });

//     if (response != null) {
//       if (response.data['status'] == "success") {
//         final data = response.data['questions'] as List;
//         if (data.isEmpty) {
//           throw Exception("No questions found for this chapter.");
//         }
//         final hospitals =
//             data.map((json) => StartExamModel.fromJson(json)).toList();
//         ref.read(startExamProvider.notifier).state = hospitals;
//         if (practice == true) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => StartExamScreen()),
//           );
//         } else {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => OnlineExamScreen(time)),
//           );
//         }

//         return hospitals;
//       } else {
//         // Show error message if API response has an error status
//         throw Exception(response.data['message'] ?? "Something went wrong.");
//       }
//     } else {
//       throw Exception("No response from server.");
//     }
//   } catch (e) {
//     print("Error fetching questions: $e");

//     // Show an error message in a Snackbar
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(e.toString()),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//   return [];
// }

// Future<List<StartExamModel>> onlineExpamd(
//     WidgetRef ref, context, cName, endpoint,
//     {time, practice}) async {
//   try {
//     final response = await ApiService().getRequest(
//       "${baseUrl + endpoint}",
//     );

//     if (response != null) {
//       if (response.data['status'] == "success") {
//         final data = response.data['questions'] as List;
//         if (data.isEmpty) {
//           throw Exception("No questions found for this chapter.");
//         }
//         final hospitals =
//             data.map((json) => StartExamModel.fromJson(json)).toList();
//         ref.read(startExamProvider.notifier).state = hospitals;

//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => OnlineExamScreen(time)),
//         );

//         return hospitals;
//       } else {
//         // Show error message if API response has an error status
//         throw Exception(response.data['message'] ?? "Something went wrong.");
//       }
//     } else {
//       throw Exception("No response from server.");
//     }
//   } catch (e) {
//     print("Error fetching questions: $e");

//     // Show an error message in a Snackbar
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(e.toString()),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//   return [];
// }

// Future<List<BannarModel>> bannarAPi(
//   WidgetRef ref,
// ) async {
//   try {
//     final response = await ApiService().getRequest(
//       "https://peacexperts.org/ccc-demo/ccc-admin/api-banners",
//     );

//     if (response != null) {
//       if (response.data['status'] == true) {
//         final data = response.data['data'] as List;
//         if (data.isEmpty) {
//           throw Exception("No questions found for this chapter.");
//         }
//         final bannar =
//             data.map((json) => BannarModel.fromJson(json)).toList();
//         ref.read(bannarProvider.notifier).state = bannar;

//         return bannar;
//       } else {
//         // Show error message if API response has an error status
//         throw Exception(response.data['message'] ?? "Something went wrong.");
//       }
//     } else {
//       throw Exception("No response from server.");
//     }
//   } catch (e) {
//     print("Error fetching questions: $e");
//   }
//   return [];
// }
