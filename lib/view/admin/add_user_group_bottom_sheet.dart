import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/model/user_model.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/view/admin/multi_user_selection.dart';

import '../../utils/components.dart';

class AddUserToGroupBottomSheet extends StatefulWidget {
  final List<UserModel> allUsers;
  final Function(UserModel, List<String>) onAddUser;
  final List<String> allDoors;

  const AddUserToGroupBottomSheet({
    super.key,
    required this.allUsers,
    required this.onAddUser,
    required this.allDoors,
  });

  @override
  _AddUserToGroupBottomSheetState createState() =>
      _AddUserToGroupBottomSheetState();
}

class _AddUserToGroupBottomSheetState extends State<AddUserToGroupBottomSheet> {
  Map<int, List<String>> selectedGroups = {};
  TextEditingController searchController = TextEditingController();
  List<UserModel> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = widget.allUsers;
    searchController.addListener(_filterUsers);
  }

  void _filterUsers() {
    setState(() {
      String searchText = searchController.text.toLowerCase();
      filteredUsers = widget.allUsers
          .where((user) =>
              user.name.toLowerCase().contains(searchText) ||
              user.email.toLowerCase().contains(searchText))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_filterUsers);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (context, scrollController) => SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: EdgeInsets.all(10.0.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20.0.w),
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Text(
                      'Add User to Group',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
                SizedBox(height: 16.0.h),
                textFormComponent(
                  controller: searchController,
                  keyboardType: TextInputType.text,
                  prefixIcon: Icons.search,
                  width: double.infinity,
                  onChanged: (value) {
                    _filterUsers();
                  },
                  validate: (value) {
                    return null;
                  },
                  context: context,
                  hintText: '',
                  labelText: 'Search',
                ),
                SizedBox(height: 16.0.h),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    controller: scrollController,
                    itemBuilder: (context, index) {
                      UserModel user = filteredUsers[index];
                      List<String> availableDoors = widget.allDoors
                          .where(
                              (door) => !user.accessibleObjects.contains(door))
                          .toList();
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0.h),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  Get.back();
                                },
                                leading: CircleAvatar(
                                  backgroundColor: ColorManager.primarycolor,
                                  child: Text(
                                    'U${index + 1}',
                                    style: TextStyle(color: ColorManager.white),
                                  ),
                                ),
                                title: Text(
                                  user.name,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () async {
                                    final selectedDoors =
                                        await showDialog<List<String>>(
                                      context: context,
                                      builder: (context) => MultiSelectDialog(
                                        items: availableDoors,
                                        initialSelectedItems:
                                            selectedGroups[user.uid] ?? [],
                                      ),
                                    );
                                    if (selectedDoors != null) {
                                      setState(() {
                                        // selectedGroups[user.uid] = selectedDoors;
                                      });
                                    }
                                  },
                                ),
                              ),
                              Wrap(
                                children:
                                    (selectedGroups[user.uid] ?? []).map((door) {
                                  return Padding(
                                    padding: EdgeInsets.all(5.0.w),
                                    child: Chip(
                                      label: Text(
                                        door,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                      onDeleted: () {
                                        setState(() {
                                          selectedGroups[user.uid]?.remove(door);
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                              const Divider(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.0.h),
                ElevatedButton(
                  onPressed: () {
                    selectedGroups.forEach((userId, groups) {
                      if (groups.isNotEmpty) {
                        UserModel user = widget.allUsers
                            .firstWhere((user) => user.uid == userId);
                        widget.onAddUser(user, groups);
                      }
                    });
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: 24.0.w, vertical: 12.0.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Add Selected Doors',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
