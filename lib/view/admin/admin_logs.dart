import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller/logs_controller.dart';
import '../../model/logs_model.dart';
import '../../utils/style_manager.dart';

class AdminLogsScreen extends StatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  State<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends State<AdminLogsScreen> {
  final LogsController logsController = Get.find<LogsController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Logs"),
          centerTitle: false,
          elevation: 0.0,
          backgroundColor: Colors.white,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'custom') {
                  _showCustomDateRangePicker(context, logsController);
                } else if (value == 'anytime') {
                  logsController.setDateRange(null, null);
                } else {
                  final now = DateTime.now();
                  final start = now.subtract(_getDuration(value));
                  final startDate = DateTime(start.year, start.month,
                      start.day); // Midnight of start day
                  final endDate = DateTime(now.year, now.month, now.day - 1, 23,
                      59, 59, 999); // End of today
                  logsController.setDateRange(startDate, endDate);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem(value: 'anytime', child: Text('Anytime')),
                  const PopupMenuItem(
                      value: '1_day', child: Text('Last 1 Day')),
                  const PopupMenuItem(
                      value: '3_days', child: Text('Last 3 Days')),
                  const PopupMenuItem(
                      value: '1_week', child: Text('Last 1 Week')),
                  const PopupMenuItem(
                      value: '1_month', child: Text('Last 1 Month')),
                  const PopupMenuItem(
                      value: 'custom', child: Text('Custom Range')),
                ];
              },
            ),
          ],
        ),
        body: SafeArea(
          child: StreamBuilder<List<LogEntry>>(
            stream: logsController.logsStream, // Using the stream
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No logs available"));
              }

              // if (!logsController.hasLogsFetched.value) {
              //   logsController.logs.value = snapshot.data!;
              //   logsController.hasLogsFetched.value = true;
              //   logsController.applyFilters();
              // }
              final logs = snapshot.data!;
              logsController.logs.value = logs;
              logsController.hasLogsFetched.value = true;
              logsController.applyFilters();

              return Column(
                children: [
                  _buildSearchBar(logsController),
                  Obx(() => _buildFilterChips(logsController)),
                  _buildLogList(logsController),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(LogsController logsController) {
    return Padding(
      padding: EdgeInsets.all(16.0.w),
      child: TextField(
        decoration: InputDecoration(
          labelText: "Search",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0.w),
          ),
          prefixIcon: const Icon(Icons.search),
        ),
        onChanged: logsController.setSearchQuery,
      ),
    );
  }

  Widget _buildFilterChips(LogsController logsController) {
    final filterCounts = logsController.getFilterCounts();

    return Container(
      height: 50.0.h,
      padding: EdgeInsets.symmetric(vertical: 8.0.h),
      child: Obx(() {
        return ListView(
          scrollDirection: Axis.horizontal,
          children: filterCounts.keys.map((filter) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.w),
              child: ChoiceChip(
                label: Text("$filter (${filterCounts[filter]})"),
                selected: logsController.selectedFilter.value == filter,
                onSelected: (selected) {
                  if (selected) {
                    logsController.setFilter(filter);
                  }
                },
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildLogList(LogsController logsController) {
    return Obx(() {
      final groupedLogs = logsController.groupedLogs;

      if (groupedLogs.isEmpty) {
        return Expanded(
          child: Center(
            child: Text(
              "No logs available",
              style: Theme.of(Get.context!).textTheme.bodyLarge,
            ),
          ),
        );
      }

      return Expanded(
        child: ListView.builder(
          itemCount: groupedLogs.length,
          itemBuilder: (context, index) {
            final date = groupedLogs.keys.elementAt(index);
            final logsForDate = groupedLogs[date]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0.w),
                  child: Text(
                    date,
                    style: getBoldStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                ...logsForDate.map((log) {
                  String formattedDate =
                      DateFormat('yyyy-MM-dd kk:mm').format(log.timestamp);

                  return Padding(
                    padding: EdgeInsets.all(16.0.w),
                    child: Card(
                      elevation: 2.0,
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            const Icon(Icons.event_note, color: Colors.blue),
                            SizedBox(width: 8.0.w),
                            Expanded(
                              child: Text(
                                "Action: ${log.action}",
                                style: getBoldStyle(
                                    fontSize: 14, color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: log.status == "Success"
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    SizedBox(width: 8.0.w),
                                    Expanded(
                                      child: Text(
                                        "Status: ${log.status}",
                                        style: getRegularStyle(
                                            fontSize: 12, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0.h),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        color: Colors.grey),
                                    SizedBox(width: 8.0.w),
                                    Expanded(
                                      child: Text(
                                        "Date: $formattedDate",
                                        style: getRegularStyle(
                                            fontSize: 12, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0.h),
                                Row(
                                  children: [
                                    const Icon(Icons.info, color: Colors.grey),
                                    SizedBox(width: 8.0.w),
                                    Expanded(
                                      child: Text(
                                        "Details: ${log.details}",
                                        style: getRegularStyle(
                                            fontSize: 12, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0.h),
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        color: Colors.grey),
                                    SizedBox(width: 8.0.w),
                                    Expanded(
                                      child: Text(
                                        "User: ${log.userName}",
                                        style: getRegularStyle(
                                            fontSize: 12, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      );
    });
  }

  Future<void> _showCustomDateRangePicker(
      BuildContext context, LogsController logsController) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      logsController.setDateRange(picked.start, picked.end);
    }
  }

  Duration _getDuration(String value) {
    switch (value) {
      case '1_day':
        return const Duration(days: 1);
      case '3_days':
        return const Duration(days: 3);
      case '1_week':
        return const Duration(days: 7);
      case '1_month':
        return const Duration(days: 30);
      default:
        return const Duration();
    }
  }
}
