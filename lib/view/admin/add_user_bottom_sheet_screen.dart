import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/admin_controller.dart';
import 'package:graduation_project/services/helpers.dart';
import 'package:graduation_project/shared/extensions.dart';
import 'package:graduation_project/utils/components.dart';

import '../../controller/auth_controller.dart';

class AddUserBottomSheet extends StatefulWidget {
  const AddUserBottomSheet({super.key});

  @override
  _AddUserBottomSheetState createState() => _AddUserBottomSheetState();
}

class _AddUserBottomSheetState extends State<AddUserBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final AdminController adminController = Get.find<AdminController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    if (adminController.isObjectsLoaded.value) {
      adminController.fetchObjects();
      adminController.isObjectsLoaded.value = false;
    }
    adminController.selectedObjects.clear();
  }

  @override
  void dispose() {
    adminController.selectedObjects.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: EdgeInsets.all(12.0.w),
        child: Form(
          key: _formKey,
          child: SizedBox(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New User',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 12.0.w),
                  SizedBox(
                    height: size.width * .25.h,
                    child: textFormComponent(
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      prefixIcon: Icons.person,
                      onSaved: (value) {
                        nameController.text = value.orEmpty();
                      },
                      context: context,
                      labelText: 'Name',
                      hintText: 'e.g. hussam959',
                      validate: (value) {
                        if (value!.isEmpty) {
                          return "name can't be empty";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: size.width * .25.h,
                    child: textFormComponent(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_rounded,
                      onSaved: (value) {
                        emailController.text = value.orEmpty();
                      },
                      context: context,
                      hintText: 'e.g. name@mail.com',
                      labelText: 'Email',
                      isPassword: false,
                      validate: (value) {
                        if (value!.isEmpty) {
                          return "email can't be empty";
                        } else if (!isValidEmail(value)) {
                          return "please enter a valid email";
                        }
                        return null;
                      },
                    ),
                  ),
                  Obx(
                    () => SizedBox(
                      height: size.width * .25.h,
                      child: textFormComponent(
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        onSaved: (value) {
                          passwordController.text = value.orEmpty();
                        },
                        prefixIcon: Icons.lock,
                        suffixIcon: authController.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        onSuffixPressed:
                            authController.togglePasswordVisibility,
                        isPassword: !authController.isPasswordVisible.value,
                        context: context,
                        hintText: 'e.g. Gg@123456',
                        labelText: 'Password',
                        validate: (value) {
                          if (value!.isEmpty) {
                            return "password can't be empty";
                          } else if (value.length < 8) {
                            return "password must be at least 8 characters";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Obx(
                    () => Padding(
                      padding: const EdgeInsets.only(
                        right: 8.0,
                      ),
                      child: SizedBox(
                        height: size.width * .25.h,
                        child: DropdownButtonFormField<String>(
                          value: adminController.role.value,
                          items: ["admin", "user"]
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) adminController.role.value = val;
                          },
                          decoration: const InputDecoration(labelText: "Role"),
                        ),
                      ),
                    ),
                  ),
                  // select objects
                  const Text('Select Objects'),
                  Obx(
                    () => Wrap(
                      spacing: 8.0,
                      children: adminController.allObjects.map((object) {
                        return FilterChip(
                          label: Text(object),
                          selected:
                              adminController.selectedObjects.contains(object),
                          onSelected: (bool selected) {
                            if (selected) {
                              adminController.selectedObjects.add(object);
                            } else {
                              adminController.selectedObjects.remove(object);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 12.0.w),
                  // button
                  Obx(
                    () => ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (adminController.selectedObjects.isEmpty) {
                            Get.snackbar(
                                "Error", "Please select at least one door",
                                backgroundColor: Colors.red,
                                colorText: Colors.white);
                            return;
                          }
                          await adminController.createUser(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            doors: adminController.selectedObjects.toList(),
                            role: adminController.role.value,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 10.0,
                        padding: EdgeInsets.symmetric(
                            horizontal: 32.0.w, vertical: 12.0.w),
                        textStyle: Theme.of(context).textTheme.labelMedium,
                      ),
                      child: !adminController.isLoading.value
                          ? const Text('Add User')
                          : const CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
