import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/admin_controller.dart';
import '../../utils/colors.dart';

class ManageDevicesScreen extends StatefulWidget {
  const ManageDevicesScreen({super.key});

  @override
  State<ManageDevicesScreen> createState() => _ManageDevicesScreenState();
}

class _ManageDevicesScreenState extends State<ManageDevicesScreen> {
  final AdminController adminController = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    adminController.fetchObjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Devices'),
      ),
      body: Obx(
        () => adminController.allObjects.isEmpty
            ? const Center(
                child: Text(
                  'No devices available.',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: adminController.allObjects.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final deviceName = adminController.allObjects[index];
                  final device = adminController.deviceState
                      .firstWhereOrNull((d) => d.name == deviceName);

                  final status = device?.status ?? 'unknown';
                  return Card(
                    elevation: 5.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0.w),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: ColorManager.primarycolor,
                        radius: 20.0,
                        child: Text(
                          'U${index + 1}',
                          style: TextStyle(color: ColorManager.white),
                        ),
                      ),
                      title: Text(
                        deviceName,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      subtitle: Text(
                        'Status: $status',
                        style: TextStyle(
                          color: status == 'online' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              size: 24.0.w,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              final deviceId = await adminController
                                  .fetchObjectsIds([deviceName]);
                              if (deviceId.isNotEmpty) {
                                await adminController
                                    .deleteDevice(deviceId.first);
                                await adminController.fetchObjects();
                              } else {
                                Get.snackbar("Error",
                                    "Device ID not found for $deviceName.",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM);
                              }
                            },
                          ),
                        ],
                      ),
                      onLongPress: () async {
                        final deviceIds =
                            await adminController.fetchObjectsIds([deviceName]);
                        if (deviceIds.isEmpty) {
                          Get.snackbar(
                              "Error", "Device ID not found for $deviceName.",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM);
                          return;
                        }
                        final deviceId = deviceIds.first;

                        Get.dialog(
                          AlertDialog(
                            title: const Text('Change Device Status'),
                            content: Text('Set status for "$deviceName":'),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  await adminController.updateDeviceStatus(
                                      deviceId, 'online');
                                  await adminController.fetchObjects();
                                  Get.back();
                                },
                                child: const Text('Online'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await adminController.updateDeviceStatus(
                                      deviceId, 'offline');
                                  await adminController.fetchObjects();
                                  Get.back();
                                },
                                child: const Text('Offline'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
