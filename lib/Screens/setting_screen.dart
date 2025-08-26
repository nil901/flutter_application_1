import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/comman_app_bar.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  Map<Permission, bool> permissionStatus = {
    Permission.phone: false,
    Permission.contacts: false,
    Permission.storage: false,
  };

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    for (var entry in permissionStatus.entries) {
      final status = await entry.key.status;
      permissionStatus[entry.key] = status.isGranted;
    }
    setState(() {});
  }

  Future<void> _togglePermission(Permission permission) async {
    if (await permission.isGranted) {
      openAppSettings();
    } else {
      final status = await permission.request();
      permissionStatus[permission] = status.isGranted;
      setState(() {});
    }
  }

  IconData _getIconForPermission(Permission permission) {
    switch (permission) {
      case Permission.phone:
        return Icons.phone;
      case Permission.contacts:
        return Icons.contacts;
      case Permission.storage:
        return Icons.folder;
      default:
        return Icons.security;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(title: "Setting"),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var entry in permissionStatus.entries)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _getIconForPermission(entry.key),
                    size: 28,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      entry.key.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Switch(
                    value: entry.value,
                    onChanged: (_) => _togglePermission(entry.key),
                    activeColor: Colors.orange,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: _loadPermissions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: Text("REFRESH", style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
