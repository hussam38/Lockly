import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/admin_controller.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/components.dart';
import 'package:graduation_project/utils/router.dart';
import 'package:graduation_project/view/admin/add_user_bottom_sheet_screen.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final AdminController adminController = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
    if (adminController.isUsersLoaded.value) {
      adminController.fetchUsers();
      adminController.isUsersLoaded.value = false;
    }
    adminController.userSearchQuery.value
        .addListener(adminController.filterUsers);
  }

  @override
  void dispose() {
    adminController.userSearchQuery.value.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Manage Users',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          actions: [
            IconButton(
              onPressed: () {
                Get.toNamed(AppRouter.groupUsersRoute,
                    arguments: adminController.users);
              },
              icon: const Icon(Icons.group),
            ),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: const AddUserBottomSheet(),
                    );
                  },
                );
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0.w),
          child: Column(
            children: [
              // Search field
              textFormComponent(
                controller: adminController.userSearchQuery.value,
                keyboardType: TextInputType.text,
                prefixIcon: Icons.search,
                width: double.infinity,
                onChanged: (value) {
                  adminController.userSearchQuery.value.text = value;
                  adminController.filterUsers();
                },
                validate: (value) => null,
                context: context,
                hintText: '',
                labelText: 'Search',
              ),
              SizedBox(height: 16.0.h),
              Expanded(
                child: Obx(() {
                  if (adminController.filteredUsers.isEmpty &&
                      adminController.userSearchQuery.value.text.isNotEmpty) {
                    return Center(
                      child: Text(
                        'Search not found',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  if (adminController.filteredUsers.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return RefreshIndicator(
                    onRefresh: () async => await adminController.fetchUsers(),
                    child: ListView.builder(
                      itemCount: adminController.filteredUsers.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        var user = adminController.filteredUsers[index];
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
                              user.name,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            subtitle: Text(
                              user.email,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
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
                                  onPressed: () {
                                    adminController.deleteUser(user.uid);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
