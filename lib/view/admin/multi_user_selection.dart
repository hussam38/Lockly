// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/admin_controller.dart';

class MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> initialSelectedItems;
  final String userId;

  const MultiSelectDialog(
      {super.key,
      required this.items,
      required this.initialSelectedItems,
      required this.userId});

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  final AdminController adminController = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    adminController.selectedObjects.value =
        List.from(widget.initialSelectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AlertDialog(
        title: const Text('Select Doors'),
        content: SingleChildScrollView(
          child: ListBody(
            children: widget.items.map((item) {
              return CheckboxListTile(
                value: adminController.selectedObjects.contains(item),
                title: Text(item),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (isChecked) {
                  if (isChecked == true) {
                    adminController.selectedObjects.add(item);
                    print(
                        "Added $item to selectedObjects: ${adminController.selectedObjects}");
                  } else {
                    adminController.selectedObjects.remove(item);
                    print(
                        "Removed $item from selectedObjects: ${adminController.selectedObjects}");
                  }
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              adminController.addTempObjectsToUser(
                widget.userId,
                adminController.selectedObjects.toList(),
              );
              Navigator.pop(context, adminController.selectedObjects.toList());
            },
            child: const Text('OK'),
          ),
        ],
      );
    });
  }
}
