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
    if(adminController.isObjectsLoaded.value){
      adminController.fetchObjects();
      adminController.isObjectsLoaded.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Devices'),
      ),
      body: Obx(
        () => ListView.builder(
            itemCount: adminController.allObjects.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final user = adminController.allObjects[index];
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
                    user,
                    style: Theme.of(context).textTheme.labelMedium,
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
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
