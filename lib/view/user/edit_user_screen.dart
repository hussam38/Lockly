import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/services/helpers.dart';
import 'package:graduation_project/utils/components.dart';
import 'package:image_picker/image_picker.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  XFile? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      Get.snackbar('Error', 'Error picking image: $e');
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Save changes
      // You can add your logic to save the changes here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path))
                        : null,
                    child: _imageFile == null
                        ? const Icon(Icons.add_a_photo, size: 50)
                        : null,
                  ),
                ),
                SizedBox(height: 16.0.h),
                SizedBox(
                  height: size.width * .25.h,
                  child: textFormComponent(
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: Icons.lock,
                      onChanged: (value) {
                        _passwordController.text = value;
                      },
                      validate: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        } else if (value.length < 8) {
                          return 'Password must be at least 6 characters long';
                        } else if (!isStrongPassword(value)) {
                          return 'password must be Strong';
                        }
                        return null;
                      },
                      context: context,
                      hintText: 'e.g Gg@12345',
                      labelText: 'Password',
                      isPassword: true,
                      suffixIcon: Icons.visibility,
                      width: double.infinity),
                ),
                SizedBox(height: 16.0.h),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
