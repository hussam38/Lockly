import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/model/user_model.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/components.dart';
import 'package:graduation_project/utils/router.dart';
import 'package:graduation_project/view/admin/add_user_bottom_sheet_screen.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  TextEditingController searchController = TextEditingController();
  List<UserModel> filteredUsers = [];
  List<UserModel> usermodel = [
    UserModel(
      uid: 1.toString(),
      name: "Hussam",
      email: "Hussam@gmail.com",
      password: "123456",
      accessibleObjects: ["door1", "door2", "door3"],
            role: 'user'

    ),
    UserModel(
      uid: 2.toString(),
      name: "Bedo",
      email: "Bedo@gmail.com",
      password: "123456",
      accessibleObjects: ["door1", "door2"],
            role: 'user'

    ),
    UserModel(
      uid: 3.toString(),
      name: "Gemy",
      email: "Gemy@gmail.com",
      password: "123456",
      accessibleObjects: ["door3"],
            role: 'user'

    ),
    UserModel(
      uid: 4.toString(),
      name: "Della",
      email: "Della@gmail.com",
      password: "123456",
      accessibleObjects: ["door1", "door3"],
            role: 'user'

    ),
    UserModel(
      uid: 5.toString(),
      name: "Diaa",
      email: "Diaa@gmail.com",
      password: "123456",
      accessibleObjects: ["door2", "door3"],
            role: 'user'

    ),
    UserModel(
      uid: 6.toString(),
      name: "Mahmoud",
      email: "Mahmoud@gmail.com",
      password: "123456",
      accessibleObjects: ["door1"],
            role: 'user'

    ),
    UserModel(
      uid: 7.toString(),
      name: "omar",
      email: "omar@gmail.com",
      password: "123456",
      accessibleObjects: ["door2"],
      role: 'user'
    ),
  ];

  @override
  void initState() {
    super.initState();
    filteredUsers = usermodel;
    searchController.addListener(_filterUsers);
  }

  void _filterUsers() {
    setState(() {
      filteredUsers = usermodel
          .where((element) => element.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _addUser(UserModel user) {
    setState(() {
      usermodel.add(user);
      _filterUsers();
    });
  }

  void _deleteUser(int id) {
    usermodel.removeWhere((user) => user.uid == id);
    _filterUsers();
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
            'Manage Users',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          elevation: 0.0,
          actions: [
            IconButton(
              onPressed: () {
                Get.toNamed(AppRouter.groupUsersRoute, arguments: usermodel);
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
                      child: AddUserBottomSheet(
                        onAddUser: _addUser,
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
              // search field
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
                  itemCount: filteredUsers.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
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
                          filteredUsers[index].name,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        subtitle: Text(
                          filteredUsers[index].email,
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
                                _deleteUser(filteredUsers[index].uid as int);
                              },
                            ),
                          ],
                        ),
                      ),
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
    searchController.removeListener(_filterUsers);
    searchController.dispose();
    super.dispose();
  }
}
