import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
import 'package:flutter_application_1/Screens/auth/login_screen.dart';
import 'package:flutter_application_1/Screens/auth/privacy_policy_screen.dart';
import 'package:flutter_application_1/Screens/auto_call_dashbard/auto_call_dashbaord.dart';
import 'package:flutter_application_1/Screens/call_logs_history.dart';
import 'package:flutter_application_1/Screens/dashboard_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_task/today_followups_screen.dart';
import 'package:flutter_application_1/Screens/setting_screen.dart';
import 'package:flutter_application_1/Screens/task/task_screen.dart';
import 'package:flutter_application_1/Screens/task_managment_screen.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../Screens/perfromance_repoart.dart';

class CustomDrawer extends ConsumerStatefulWidget {
  const CustomDrawer({super.key});

  @override
  ConsumerState<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends ConsumerState<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    final drawerColor = kwhite;
    return Drawer(
      child: Container(
        color: drawerColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: kOrange),
              accountName: Text(
                "${AppPreference().getString(PreferencesKey.name)}",
                style: TextStyle(fontSize: 18),
              ),
              accountEmail: Text(
                "${AppPreference().getString(PreferencesKey.email_id)}",
              ),
              // currentAccountPicture: CircleAvatar(
              //   backgroundImage: NetworkImage(
              //     'https://randomuser.me/api/portraits/women/44.jpg',
              //   ),
              // ),
            ),
            drawerItem(
              icon: Icons.home,
              title: "dashboard".tr,
              onTap: () {
                Navigator.pop(context); // Close the drawer before navigating
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => DashBoardScreen()),
                // );
              },
            ),
            drawerItem(
              icon: Icons.call,
              title: "auto_call_dashboard".tr,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AutoCallDashBoard()),
                );
              },
            ),
            drawerItem(
              icon: Icons.work,
              title: "leads".tr,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TodayFollowupsScreen(),
                  ),
                );
              },
            ),
            // Task Management Section
            drawerItem(
              icon: Icons.add,
              title: "add_task".tr,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskScreen()),
                );
              },
            ),
            drawerItem(
              icon: Icons.assignment,
              title: "task_management".tr,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskManagmentScreen(),
                  ),
                );
              },
            ),
            drawerItem(
              icon: Icons.calendar_today,
              title: "call_logs".tr,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallHistoryScreen(" "),
                  ),
                );
              },
            ),

            // Custom Menu Section
            drawerItem(
              icon: Icons.analytics,
              title: "performance_report".tr,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfromanceRepoartScreen(),
                  ),
                );
              },
            ),

            // Checklist Section
            // drawerItem(
            //   icon: Icons.playlist_add,
            //   title: "create_check_list".tr,
            //   onTap: () {
            //     // Navigator.push(context, MaterialPageRoute(builder: (context) => CreateChecklistScreen()));
            //   },
            // ),
            // drawerItem(
            //   icon: Icons.checklist,
            //   title: "fill_check_list".tr,
            //   onTap: () {
            //     // Navigator.push(context, MaterialPageRoute(builder: (context) => FillChecklistScreen()));
            //   },
            // ),
            // drawerItem(
            //   icon: Icons.fact_check,
            //   title: "check_list_report".tr,
            //   onTap: () {
            //     // Navigator.push(context, MaterialPageRoute(builder: (context) => ChecklistReportScreen()));
            //   },
            // ),
            drawerItem(
              icon: Icons.fact_check,
              title: "setting",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PermissionsScreen()),
                );
              },
            ),
            drawerItem(
              icon: Icons.fact_check,
              title: "Privacy Policy",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            drawerItem(
              icon: Icons.logout,
              title: "logout",
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/Images/logout_person.svg',
                              height: 200,
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Are_you_sure_want_to_Logout?".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 20),
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // No Button Action
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    minimumSize: Size(double.infinity, 50),
                                  ),
                                  child: Text(
                                    "no".tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                OutlinedButton(
                                  onPressed: () async {
                                    await AppPreference()
                                        .clearSharedPreferences();

                                    // Reload preferences if needed
                                    await AppPreference()
                                        .initialAppPreference();

                                    if (!context.mounted) return;

                                    final container = ProviderScope.containerOf(
                                      context,
                                      listen: false,
                                    );
                                    container.invalidate(getHistoryPerson);
                                    container.invalidate(branchProvider);
                                    container.invalidate(locationProvider);
                                    container.invalidate(leadHistoryProvider);
                                    container.invalidate(myHistoryProvider);
                                    container.invalidate(getAllLedsProvider);
                                    container.invalidate(myHistoryProvider);

                                    container.invalidate(
                                      getAllLedsStatusProvider,
                                    );
                                    container.invalidate(
                                      getPendingFollowUprovider,
                                    );
                                    container.invalidate(getAllLedsUprovider);
                                    container.invalidate(getALlMembers);
                                    // container.invalidate(
                                    //   dashboardCountProvider,
                                    // );

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginPage(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: kOrange, width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    minimumSize: Size(double.infinity, 50),
                                  ),
                                  child: Text(
                                    "yes".tr,
                                    style: TextStyle(
                                      color: kOrange,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {}

  Widget drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: kOrange),
      title: Text(title, style: TextStyle(color: Colors.black87, fontSize: 16)),
      onTap: onTap,
    );
  }
}
