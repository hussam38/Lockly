import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/admin_controller.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/values_manager.dart';
import '../../utils/asset_manager.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AdminController adminController = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          "My Devices",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0.w),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.add,
                size: 30.0,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (adminController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Padding(
          padding: EdgeInsets.all(8.0.w),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildFirstSection(),
                  SizedBox(height: 20.h),
                  Text(
                    "Devices",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  SizedBox(height: 20.h),
                  Visibility(
                    visible: adminController.deviceState.isEmpty,
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.devices,
                            size: 100,
                            color: ColorManager.grey,
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            "No devices available",
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: adminController.deviceState.isNotEmpty,
                    child: SizedBox(
                      child: Obx(() {
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 1.0,
                            mainAxisSpacing: 1.0,
                          ),
                          itemCount: adminController.deviceState.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (ctx, i) {
                            final device = adminController.deviceState[i];
                            final isLocked = device.locked &&
                                DateTime.now().millisecondsSinceEpoch <
                                    device.lockUntil;

                            return Obx(() {
                              return GestureDetector(
                                onLongPress: () {
                                  adminController.enableSelectionMode(i);
                                },
                                onTap: () {
                                  adminController.toggleDeviceSelection(i);
                                },
                                child: Stack(
                                  children: [
                                    Card(
                                      elevation: 10.0,
                                      color: device.status == 'online'
                                          ? ColorManager.white
                                          : ColorManager.tabColor,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.door_back_door_rounded,
                                                color: ColorManager.grey,
                                                size: 45.w,
                                              ),
                                              SizedBox(height: 10.h),
                                              Text(
                                                device.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10.w),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Switch(
                                                  value:
                                                      device.mode == 'opened',
                                                  activeColor:
                                                      ColorManager.primarycolor,
                                                  onChanged: (device.status ==
                                                              'online' &&
                                                          !isLocked)
                                                      ? (bool value) async {
                                                          final newMode = value
                                                              ? 'opened'
                                                              : 'closed';
                                                          await adminController
                                                              .updateDeviceMode(
                                                                  device.id,
                                                                  newMode);
                                                          if (value) {
                                                            await adminController
                                                                .lockDevice(
                                                                    device.id,
                                                                    30);
                                                          }
                                                        }
                                                      : null,
                                                ),
                                              ),
                                              Visibility(
                                                visible: isLocked,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: AppSize.s16.w),
                                                  child: Text(
                                                    'Locked',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible:
                                                    device.status != 'online' &&
                                                        !isLocked,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: AppSize.s16.w),
                                                  child: Text(
                                                    'Offline',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (adminController.isSelectionMode.value)
                                      Positioned(
                                        top: 8.0,
                                        right: 8.0,
                                        child: CircleAvatar(
                                          radius: 12.0,
                                          backgroundColor: adminController
                                                  .selectedItems
                                                  .contains(i)
                                              ? Colors.red
                                              : Colors.transparent,
                                          child: adminController.selectedItems
                                                  .contains(i)
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 20.0,
                                                  color: Colors.white,
                                                )
                                              : const Icon(
                                                  Icons.circle_outlined,
                                                  size: 20.0,
                                                  color: Colors.blue,
                                                ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            });
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton: Obx(() {
        if (adminController.isSelectionMode.value) {
          return FloatingActionButton.extended(
            onPressed: () async {
              await adminController.deleteSelectedDevices();
            },
            backgroundColor: Colors.red,
            label: const Text("Delete"),
            icon: const Icon(Icons.delete),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget buildFirstSection() {
    return SizedBox(
      height: 200.h,
      width: double.infinity,
      child: Card(
        elevation: 10.0,
        color: ColorManager.white,
        child: Padding(
          padding: EdgeInsets.all(8.0.w),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  "Welcome to Home",
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(
                flex: 2,
                child: Image.asset(
                  AssetsManager.homeImage,
                  height: 200.h,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
