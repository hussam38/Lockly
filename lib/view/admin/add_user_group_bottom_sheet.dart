import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/admin_controller.dart';
import 'package:graduation_project/model/user_model.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/view/admin/multi_user_selection.dart';

import '../../utils/components.dart';

class AddUserToGroupBottomSheet extends StatelessWidget {
  final List<UserModel> allUsers;
  // final Function(UserModel, List<String>) onAddUser;
  final List<String> allDoors;

   AddUserToGroupBottomSheet({
    super.key,
    required this.allUsers,
    // required this.onAddUser,
    required this.allDoors,
  });
  final AdminController adminController = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (context, scrollController) => SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: EdgeInsets.all(10.0.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                SizedBox(height: 16.0.h),
                _buildSearchField(adminController),
                SizedBox(height: 16.0.h),
                _buildUserList(
                  scrollController,
                  adminController,
                  allDoors,
                ),
                SizedBox(height: 16.0.h),
                _buildSaveButton(adminController, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.0.w),
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Text(
          'Add User to Group',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }

  Widget _buildSearchField(AdminController adminController) {
    return textFormComponent(
      controller: adminController.userSearchQuery.value,
      keyboardType: TextInputType.text,
      prefixIcon: Icons.search,
      width: double.infinity,
      onChanged: (value) => adminController.filterUsers(),
      validate: (value) => null,
      context: Get.context!,
      hintText: '',
      labelText: 'Search',
    );
  }

  Widget _buildUserList(
    ScrollController scrollController,
    AdminController adminController,
    List<String> allDoors,
  ) {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
          itemCount: adminController.filteredUsers.length,
          controller: scrollController,
          itemBuilder: (context, index) {
            UserModel user = adminController.filteredUsers[index];
            List<String> availableDoors = allDoors
                .where((door) => !user.accessibleObjects.contains(door))
                .toList();

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0.h),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _buildUserTile(user, availableDoors, adminController),
                    _buildSelectedDoors(user, adminController),
                    const Divider(),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildUserTile(
    UserModel user,
    List<String> availableDoors,
    AdminController adminController,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: ColorManager.primarycolor,
        child: Text(
          user.name[0].toUpperCase(),
          style: TextStyle(color: ColorManager.white),
        ),
      ),
      title: Text(
        user.name,
        style: Get.textTheme.labelSmall,
      ),
      trailing: IconButton(
        icon: const Icon(
          Icons.add,
          color: ColorManager.primarycolor,
        ),
        onPressed: () async {
          if (availableDoors.isEmpty) {
            Get.snackbar(
                "Info", "All objects are already assigned to this user.",
                backgroundColor: Colors.amberAccent,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM);
            return;
          }
          adminController.selectedObjects.value =
              List.from(adminController.tempSelectedGroups[user.uid] ?? []);

          final selectedDoors = await showDialog<List<String>>(
            context: Get.context!,
            builder: (context) => MultiSelectDialog(
              items: availableDoors,
              initialSelectedItems: adminController.selectedObjects.toList(),
              userId: user.uid,
            ),
          );

          // Update tempSelectedGroups after dialog selection
          if (selectedDoors != null) {
            adminController.tempSelectedGroups[user.uid] = selectedDoors;
          }
        },
      ),
    );
  }

  Widget _buildSelectedDoors(UserModel user, AdminController adminController) {
    return Obx(() {
      final selectedDoors = adminController.tempSelectedGroups[user.uid] ?? [];
      return Wrap(
        children: selectedDoors.map((door) {
          return Padding(
            padding: EdgeInsets.all(5.0.w),
            child: Chip(
              label: Text(
                door,
                style: Get.textTheme.labelSmall,
              ),
              onDeleted: () {
                adminController.removeTempObjectFromUser(user.uid, door);
              },
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildSaveButton(
    AdminController adminController,
    BuildContext context,
  ) {
    return Obx(() {
      return buttonComponent2(
          onPressed: () async {
            await adminController.addObjectsToUsers();
            await Future.delayed(const Duration(milliseconds: 500));
            Get.back();
          },
          child: adminController.isLoading.value
              ? CircularProgressIndicator(
                  color: ColorManager.white,
                  strokeWidth: 3.0,
                )
              : Text(
                  'Apply Changes',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: ColorManager.white,
                      ),
                ));
    });
  }
}
