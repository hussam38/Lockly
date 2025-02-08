import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/services/helpers.dart';
import 'package:graduation_project/utils/components.dart';

import '../../utils/colors.dart';

class AddUserBottomSheet extends StatefulWidget {
  const AddUserBottomSheet({super.key});

  @override
  _AddUserBottomSheetState createState() => _AddUserBottomSheetState();
}

class _AddUserBottomSheetState extends State<AddUserBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _selectedObjects = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.all(16.0.w),
      child: Form(
        key: _formKey,
        child: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New User',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16.0.h),
              // user name
              SizedBox(
                height: size.width * .25.h,
                child: textFormComponent(
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  prefixIcon: Icons.person,
                  onChanged: (value) {
                    nameController.text = value;
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
              // email
              SizedBox(
                height: size.width * .25.h,
                child: textFormComponent(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_rounded,
                  onChanged: (value) {
                    emailController.text = value;
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
              // password
              SizedBox(
                height: size.width * .25.h,
                child: textFormComponent(
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (value) {
                    passwordController.text = value;
                  },
                  prefixIcon: Icons.lock,
                  suffixIcon: Icons.visibility,
                  context: context,
                  hintText: 'e.g. Gg@123456',
                  labelText: 'Password',
                  isPassword: true,
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
              // select objects
              const Text('Select Objects'),
              Wrap(
                spacing: 8.0,
                children: ['Object 1', 'Object 2', 'Object 3'].map((object) {
                  return FilterChip(
                    label: Text(object),
                    selected: _selectedObjects.contains(object),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedObjects.add(object);
                        } else {
                          _selectedObjects.remove(object);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0.h),
              // button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    _formKey.currentState!.save();
                    Get.back();
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 10.0,
                  padding: EdgeInsets.symmetric(
                      horizontal: 32.0.w, vertical: 12.0.w),
                  textStyle: Theme.of(context).textTheme.labelMedium,
                ),
                child: !isLoading
                    ? const Text('Add User')
                    : CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(ColorManager.black),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
