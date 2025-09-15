import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';

String baseUrl = 'https://api.newpawanputradevelopers.com/api/';
// String baseUrl = 'https://realestate-crm-backend-b3op.onrender.com/api/';

// https://realestate-crm-backend-b3op.onrender.com/

String get loginEndPoint => '${baseUrl}auth/login-email';
String get forgotPasswordEndPoint => '${baseUrl}auth/send-otp';
String get resetPasswordEndPoint => '${baseUrl}auth/reset-password-with-otp';

String get columsApi =>
    '${baseUrl}dashboard/getLeadsCountByStatusForMobile/${AppPreference().getInt(PreferencesKey.member_Id)}';

String get sourceGet =>
    '${baseUrl}dashboard/getLeadsCountBySourceForMobile/${AppPreference().getInt(PreferencesKey.member_Id)}';

String get getAllBranch => '${baseUrl}branch/getAllBranch?page=1';
String get getAllLeds => '${baseUrl}lead/getLeads';
String get getAllMembers => '${baseUrl}team/getAllMembers';
String get getAllLocation => '${baseUrl}location/getAllLocations';
String get getAllProducts => '${baseUrl}product/getAllProducts';
String get getleadHistory => '${baseUrl}lead/getLeadHistoryByLeadId';
String get getleadIdTask => '${baseUrl}lead/getLeadListForTask';
String get location => '${baseUrl}location/getAllLocations?page=1';

String get createTask => '${baseUrl}task/createTask';
String get deleteTask => '${baseUrl}task/deleteTask/';
String get leadUpadteStatus => '${baseUrl}lead/updateLeadStatusAndMeetingDate/';
String get getAllSorce => '${baseUrl}source/getAllSource';
String get getAutoCallDashboardData => '${baseUrl}lead/getAutoCallDashboardData/';

String get getPendingFollowUps =>
    '${baseUrl}dashboard/getPendingFollowupsByMember/${AppPreference().getInt(PreferencesKey.member_Id)}';

String get getTowmarowFollowUps =>
    '${baseUrl}dashboard/getTomorrowFollowupsByMember/${AppPreference().getInt(PreferencesKey.member_Id)}?page=1';

String get getTodayFollowupsUps =>
    '${baseUrl}dashboard/getTodayFollowupsByMember/${AppPreference().getInt(PreferencesKey.member_Id)}?';

String get createLeads => '${baseUrl}lead/create';
String get updateLeads => '${baseUrl}lead/updateLeadForMobile';
String get getLeadStatus => '${baseUrl}lead/getLeadStatus';
String get createCallHistory => '${baseUrl}callHistory/createCallHistory';

String get getUserHistory =>
    '${baseUrl}callHistory/getCallHistoriesByMember/${AppPreference().getInt(PreferencesKey.member_Id)}?';

String get getUserHistoryperson =>
    '${baseUrl}callHistory/getCallHistoryByReciever/';

String get getAllLead =>
    '${baseUrl}dashboard/getTotalLeadsByMember/${AppPreference().getInt(PreferencesKey.member_Id)}?';

String get dashboardcard =>
    '${baseUrl}dashboard/getDashboardCardsDataByMember/${AppPreference().getInt(PreferencesKey.member_Id)}';

String get getTasksAssignedByMe =>
    '${baseUrl}task/getTasksAssignedByMe/${AppPreference().getInt(PreferencesKey.member_Id)}?page=1';

String get getTasksmemberByMe =>
    '${baseUrl}task/getTaskByMember/${AppPreference().getInt(PreferencesKey.member_Id)}?page=1';

String get getPerfromanceRepoart =>
    '${baseUrl}callHistory/getCallHistoryReportByMember/${AppPreference().getInt(PreferencesKey.member_Id)}?';  