import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/admin_controller.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/components.dart';
import 'package:graduation_project/view/admin/add_user_group_bottom_sheet.dart';

import '../../model/user_model.dart';

class GroupUsersScreen extends StatefulWidget {
  const GroupUsersScreen({super.key});

  @override
  State<GroupUsersScreen> createState() => _GroupUsersScreenState();
}

class _GroupUsersScreenState extends State<GroupUsersScreen> {
  final AdminController adminController = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    if (adminController.isObjectsLoaded.value) {
      adminController.fetchObjects();
      adminController.isObjectsLoaded.value = false;
    }

    if (adminController.groupedUsers.isEmpty) {
      adminController.fetchUsersAndGroupObjects();
    }

    adminController.groupSearchQuery.value
        .addListener(adminController.filterGroups);
  }

  @override
  void dispose() {
    adminController.groupSearchQuery.value.clear();
    adminController.filteredGroupedUsers.value = adminController.groupedUsers;
    debugPrint("Disposed From Group Users Screen");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Users Groups',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          elevation: 0.0,
          actions: [
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
                      child: AddUserToGroupBottomSheet(
                        allUsers: adminController.filteredUsers,
                        allDoors: adminController.allObjects,
                      ),
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
              // Search bar for filtering groups
              textFormComponent(
                controller: adminController.groupSearchQuery.value,
                keyboardType: TextInputType.text,
                prefixIcon: Icons.search,
                width: double.infinity,
                onChanged: (value) {
                  adminController.filterGroups();
                },
                validate: (value) => null,
                context: context,
                hintText: '',
                labelText: 'Search',
              ),
              SizedBox(height: 16.0.h),

              // Grouped users list
              Expanded(
                child: Obx(() {
                  if (adminController.isGroupsLoaded.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (adminController.filteredGroupedUsers.isEmpty) {
                    return Center(
                      child: Text(
                        'No groups found',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  List<String> sortedKeys =
                      adminController.filteredGroupedUsers.keys.toList()
                        ..sort();

                  return ListView.builder(
                    itemCount: sortedKeys.length,
                    itemBuilder: (context, index) {
                      String object = sortedKeys[index];
                      List<UserModel> users =
                          adminController.filteredGroupedUsers[object]!;
                      return ExpansionTile(
                        title: Text(
                          object,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        children: users.map((user) {
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
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 24.0,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  adminController.removeObjectsFromUser(
                                      user.uid, object);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
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
