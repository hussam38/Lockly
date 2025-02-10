import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:graduation_project/utils/values_manager.dart';
import '../../utils/asset_manager.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  List<Map<String, dynamic>> deviceState = [];
  Set<int> selectedItems = {};
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    deviceState = List.generate(
      10,
      (index) => {
        'online': index < 7,
        'value': false,
      },
    ).toList();
  }

  void _deleteSelectedItems() {
    setState(() {
      final sortedIndices = selectedItems.toList()
        ..sort((a, b) => b.compareTo(a));
      for (final index in sortedIndices) {
        deviceState.removeAt(index);
      }
      selectedItems.clear();
      isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          "My Devices",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0.w),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.add,
                size: 30.0,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFirstSection(),
                SizedBox(height: 20.h),
                Text(
                  "Devices",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                SizedBox(height: 20.h),
                Visibility(
                  visible: deviceState.isEmpty,
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.devices,
                          size: 100,
                          color: ColorManager.grey,
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          "No devices available",
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: deviceState.isNotEmpty,
                  child: SizedBox(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 1.0,
                        mainAxisSpacing: 1.0,
                      ),
                      itemCount: deviceState.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, i) {
                        final device = deviceState[i];
                        final isSelected = selectedItems.contains(i);
                        return GestureDetector(
                          onLongPress: () {
                            setState(() {
                              isSelectionMode = true;
                              selectedItems.add(i);
                            });
                          },
                          onTap: () {
                            setState(() {
                              if (isSelectionMode) {
                                if (isSelected) {
                                  selectedItems.remove(i);
                                  if (selectedItems.isEmpty) {
                                    isSelectionMode = false;
                                  }
                                } else {
                                  selectedItems.add(i);
                                }
                              }
                            });
                          },
                          child: Stack(
                            children: [
                              Card(
                                elevation: 10.0,
                                color: device['online']
                                    ? ColorManager.white
                                    : ColorManager.tabColor,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.door_back_door_rounded,
                                          color: ColorManager.grey,
                                          size: 45.w,
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          'Door ${i + 1}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.w),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Switch(
                                            value: device['value'],
                                            activeColor:
                                                ColorManager.primarycolor,
                                            onChanged: device['online']
                                                ? (bool value) {
                                                    setState(() {
                                                      device['value'] = value;
                                                    });
                                                  }
                                                : null,
                                          ),
                                        ),
                                        Visibility(
                                          visible: !device['online'],
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                bottom: AppSize.s16.w),
                                            child: Text(
                                              'Offline',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelectionMode)
                                Positioned(
                                  top: 8.0,
                                  right: 8.0,
                                  child: CircleAvatar(
                                    radius: 12.0,
                                    backgroundColor: isSelected
                                        ? Colors.red
                                        : Colors.transparent,
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 20.0,
                                            color: Colors.white,
                                          )
                                        : const Icon(
                                            Icons.circle_outlined,
                                            size: 20.0,
                                            color: Colors.blue,
                                          ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: isSelectionMode
          ? FloatingActionButton.extended(
              onPressed: _deleteSelectedItems,
              backgroundColor: Colors.red,
              clipBehavior: Clip.antiAlias,
              label: const Icon(Icons.delete),
            )
          : null,
    );
  }

  Widget buildFirstSection() {
    return SizedBox(
      height: 200.h,
      width: double.infinity,
      child: Card(
        elevation: 10.0,
        color: ColorManager.white,
        child: Padding(
          padding:  EdgeInsets.all(8.0.w),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  "Welcome to Home",
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(
                flex: 2,
                child: Image.asset(
                  AssetsManager.homeImage,
                  height: 200.h,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
