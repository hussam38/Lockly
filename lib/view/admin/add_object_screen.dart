import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/admin_controller.dart';
import 'package:graduation_project/utils/components.dart';

import '../../utils/colors.dart';

class AddObjectScreen extends StatelessWidget {
  AddObjectScreen({super.key});
  var formKey = GlobalKey<FormState>();
  AdminController adminController = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Object'),
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.all(12.0.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.width * .25.h,
                    child: textFormComponent(
                      context: context,
                      controller: adminController.idController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.numbers,
                      validate: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an object id';
                        }
                        if (value.length != 6) {
                          return 'Object id must be 6 digits';
                        }
                        return null;
                      },
                      labelText: 'Enter object id',
                      hintText: '',                   
                    ),
                  ),
                  SizedBox(
                    height: size.width * .25.h,
                    child: textFormComponent(
                        context: context,
                        controller: adminController.nameController,
                        keyboardType: TextInputType.text,
                        prefixIcon: Icons.person,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an object name';
                          }
                          return null;
                        },
                        labelText: 'Enter object name',
                        hintText: ''),
                  ),
                  SizedBox(
                    height: size.width * .25.h,
                    child: textFormComponent(
                      context: context,
                      controller: adminController.locationController,
                      keyboardType: TextInputType.text,
                      prefixIcon: Icons.location_city,
                      validate: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an object location';
                        }
                        return null;
                      },
                      labelText: 'Enter object name',
                      hintText: 'office, lab, etc.',
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
                          value: adminController.status.value,
                          items: ["online", "offline"]
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) adminController.status.value = val;
                          },
                          decoration:
                              const InputDecoration(labelText: "Status"),
                        ),
                      ),
                    ),
                  ),
                  buttonComponent2(
                    child: !adminController.isLoading.value
                        ? Text(
                            'Submit',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    color: ColorManager.white,
                                    fontSize: 20.0.w),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              color: ColorManager.white,
                              strokeWidth: 2.0,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  ColorManager.primarycolor),
                            ),
                          ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        adminController.submitDoor();
                        Get.back();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
