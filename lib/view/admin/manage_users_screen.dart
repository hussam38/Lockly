import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/view/admin/add_bottom_sheet_screen.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Users',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: ListView.builder(
          itemCount: 10,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return Card(
              elevation: 5.0,
              margin: EdgeInsets.symmetric(vertical: 8.0.w),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    'U${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  'User ${index + 1}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                subtitle: Text(
                  'user${index + 1}@example.com',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {},
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: const AddUserBottomSheet(),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

