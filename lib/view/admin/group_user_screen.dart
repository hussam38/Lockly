import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/model/user_model.dart';
import 'package:graduation_project/shared/extensions.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/components.dart';
import 'package:graduation_project/view/admin/add_user_group_bottom_sheet.dart';

class GroupUsersScreen extends StatefulWidget {
  const GroupUsersScreen({super.key});

  @override
  _GroupUsersScreenState createState() => _GroupUsersScreenState();
}

class _GroupUsersScreenState extends State<GroupUsersScreen> {
  TextEditingController searchController = TextEditingController();
  List<UserModel> filteredUsers = [];
  Map<String, List<UserModel>> groupedUsers = {};
  final List<String> allDoors = ["door1", "door2", "door3"];

  @override
  void initState() {
    super.initState();
    filteredUsers = Get.arguments as List<UserModel>;
    groupedUsers = _groupUsersByObjects(filteredUsers);
    searchController.addListener(_filterGroups);
  }

  void _filterGroups() {
    setState(() {
      String searchText = searchController.text.toLowerCase();

      groupedUsers = _groupUsersByObjects(filteredUsers)
          .map((key, value) {
            final filteredList = value
                .where((user) => key.toLowerCase().contains(searchText))
                .toList();
            return MapEntry(key, filteredList);
          })
          .entries
          .where((entry) => entry.value.isNotEmpty)
          .toMap();
    });
  }

  void _addUser(UserModel user, List<String> groups) {
    setState(() {
      for (var group in groups) {
        if (!groupedUsers.containsKey(group)) {
          groupedUsers[group] = [];
        }
        groupedUsers[group]!.add(user);
        user.accessibleObjects.add(group); 
      }
      _filterGroups();
    });
  }

  void _deleteUser(int userId, String groupKey) {
    setState(() {
      // Remove the user only from the specific group
      if (groupedUsers.containsKey(groupKey)) {
        groupedUsers[groupKey]?.removeWhere((user) => user.uid == userId);

        // Remove the group if it's now empty
        if (groupedUsers[groupKey]?.isEmpty ?? false) {
          groupedUsers.remove(groupKey);
        }
      }

      // Update the filtered list without affecting other groups
      for (var user in filteredUsers) {
        if (user.uid == userId) {
          user.accessibleObjects.remove(groupKey);
        }
      }

      // Re-filter the groups to update the UI
      _filterGroups();
    });
  }

  Map<String, List<UserModel>> _groupUsersByObjects(List<UserModel> users) {
    Map<String, List<UserModel>> groupedUsers = {};
    for (var user in users) {
      for (var object in user.accessibleObjects) {
        if (!groupedUsers.containsKey(object)) {
          groupedUsers[object] = [];
        }
        groupedUsers[object]!.add(user);
      }
    }
    return groupedUsers;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
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
                        onAddUser: _addUser,
                        allUsers: filteredUsers,
                        allDoors: allDoors,
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
              textFormComponent(
                controller: searchController,
                keyboardType: TextInputType.text,
                prefixIcon: Icons.search,
                width: double.infinity,
                onChanged: (value) {
                  searchController.text = value;
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
                  itemCount: groupedUsers.keys.length,
                  itemBuilder: (context, index) {
                    List<String> sortedKeys = groupedUsers.keys.toList()
                      ..sort();
                    String object = sortedKeys[index];
                    List<UserModel> users = groupedUsers[object]!;
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
                                _deleteUser(user.uid as int, object);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_filterGroups);
    searchController.dispose();
    super.dispose();
  }
}
