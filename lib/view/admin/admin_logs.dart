import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/utils/style_manager.dart';
import 'package:intl/intl.dart';

class AdminLogsScreen extends StatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  _AdminLogsScreenState createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends State<AdminLogsScreen> {
  final List<LogEntry> logs = [
    const LogEntry(
      timestamp: "2025-01-28 12:00:00",
      action: "Login",
      status: "Success",
      details: "Hussam logged in",
      userName: "Hussam",
      object: "door",
    ),
    const LogEntry(
      timestamp: "2025-01-28 12:05:00",
      action: "Logout",
      status: "Success",
      details: "Abdellah logged out",
      userName: "Abdellah",
      object: "lamp",
    ),
    const LogEntry(
      timestamp: "2025-01-27 12:10:00",
      action: "Access Attempt",
      status: "Failed",
      details: "Gemy failed to access",
      userName: "Gemy",
      object: "door",
    ),
    const LogEntry(
      timestamp: "2025-01-27 12:00:00",
      action: "Login",
      status: "Success",
      details: "Bedo logged in",
      userName: "Bedo",
      object: "door",
    ),
    const LogEntry(
      timestamp: "2024-11-03 12:05:00",
      action: "Logout",
      status: "Success",
      details: "Mahmoud logged out",
      userName: "Mahmoud",
      object: "lamp",
    ),
    const LogEntry(
      timestamp: "2024-11-05 12:10:00",
      action: "Access Attempt",
      status: "Failed",
      details: "Diaa failed to access",
      userName: "Diaa",
      object: "door",
    ),
    const LogEntry(
      timestamp: "2024-02-26 12:00:00",
      action: "Login",
      status: "Success",
      details: "Ghoniem logged in",
      userName: "Ghoniem",
      object: "door",
    ),
    const LogEntry(
      timestamp: "2023-11-19 12:05:00",
      action: "Logout",
      status: "Success",
      details: "Tamer logged out",
      userName: "Tamer",
      object: "lamp",
    ),
  ];

  String searchQuery = "";
  String selectedFilter = "All";
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _getFilteredLogs();
    final groupedLogs = _groupLogsByDate(filteredLogs);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Logs"),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleDateFilter(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'anytime',
                  child: Text('Anytime'),
                ),
                const PopupMenuItem<String>(
                  value: '1_day',
                  child: Text('Last 1 Day'),
                ),
                const PopupMenuItem<String>(
                  value: '3_days',
                  child: Text('Last 3 Days'),
                ),
                const PopupMenuItem<String>(
                  value: '1_week',
                  child: Text('Last 1 Week'),
                ),
                const PopupMenuItem<String>(
                  value: '1_month',
                  child: Text('Last 1 Month'),
                ),
                const PopupMenuItem<String>(
                  value: 'custom',
                  child: Text('Custom Range'),
                ),
              ];
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(_getFilterCounts()),
            _buildLogList(groupedLogs),
          ],
        ),
      ),
    );
  }

  void _handleDateFilter(String value) async {
    DateTime now = DateTime.now();
    switch (value) {
      case 'anytime':
        setState(() {
          startDate = null;
          endDate = null;
        });
        break;
      case '1_day':
        setState(() {
          startDate = now.subtract(const Duration(days: 1));
          endDate = now;
        });
        break;
      case '3_days':
        setState(() {
          startDate = now.subtract(const Duration(days: 3));
          endDate = now;
        });
        break;
      case '1_week':
        setState(() {
          startDate = now.subtract(const Duration(days: 7));
          endDate = now;
        });
        break;
      case '1_month':
        setState(() {
          startDate = now.subtract(const Duration(days: 30));
          endDate = now;
        });
        break;
      case 'custom':
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null) {
          setState(() {
            startDate = picked.start;
            endDate = picked.end;
          });
        }
        break;
    }
  }

  List<LogEntry> _getFilteredLogs() {
    return logs.where((log) {
      final logDate = DateTime.parse(log.timestamp);
      final matchesSearchQuery = log.details.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter = selectedFilter == "All" || log.action == selectedFilter;
      final matchesDateRange = (startDate == null || logDate.isAfter(startDate!)) &&
          (endDate == null || logDate.isBefore(endDate!));
      return matchesSearchQuery && matchesFilter && matchesDateRange;
    }).toList();
  }

  Map<String, List<LogEntry>> _groupLogsByDate(List<LogEntry> logs) {
    final Map<String, List<LogEntry>> groupedLogs = {};
    for (var log in logs) {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.parse(log.timestamp));
      if (groupedLogs.containsKey(date)) {
        groupedLogs[date]!.add(log);
      } else {
        groupedLogs[date] = [log];
      }
    }
    return groupedLogs;
  }

  Map<String, int> _getFilterCounts() {
    return {
      "All": logs.length,
      "Login": logs.where((log) => log.action == "Login").length,
      "Logout": logs.where((log) => log.action == "Logout").length,
      "Access Attempt": logs.where((log) => log.action == "Access Attempt").length,
      "Admin Action": logs.where((log) => log.action == "Admin Action").length,
      "Notification": logs.where((log) => log.action == "Notification").length,
      "Error": logs.where((log) => log.action == "Error").length,
    };
  }

  Widget _buildSearchBar() {
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
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterChips(Map<String, int> filterCounts) {
    return Container(
      height: 50.0.h,
      padding: EdgeInsets.symmetric(vertical: 8.0.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filterCounts.keys.map((filter) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w),
            child: ChoiceChip(
              label: Text("$filter (${filterCounts[filter]})"),
              selected: selectedFilter == filter,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogList(Map<String, List<LogEntry>> groupedLogs) {
    if (groupedLogs.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            "No logs available",
            style: Theme.of(context).textTheme.bodyLarge,
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
              ...logsForDate.map((log) => Padding(
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
                            style: getBoldStyle(fontSize: 14, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0.w),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.check_circle, color: log.status == "Success" ? Colors.green : Colors.red),
                                    SizedBox(width: 8.0.w),
                                    Expanded(
                                      child: Text(
                                        "Status: ${log.status}",
                                        style: getRegularStyle(fontSize: 12, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0.h),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, color: Colors.grey),
                                    SizedBox(width: 8.0.w),
                                    Expanded(
                                      child: Text(
                                        "Timestamp: ${log.timestamp}",
                                        style: getRegularStyle(fontSize: 12, color: Colors.black),
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
                                        style: getRegularStyle(fontSize: 12, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0.h),
                                Row(
                                  children: [
                                    const Icon(Icons.person, color: Colors.grey),
                                    SizedBox(width: 8.0.w),
                                    Expanded(
                                      child: Text(
                                        "User: ${log.userName}",
                                        style: getRegularStyle(fontSize: 12, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0.h),
                                Row(
                                  children: [
                                    const Icon(Icons.devices, color: Colors.grey),
                                    SizedBox(width: 8.0.w),
                                    Expanded(
                                      child: Text(
                                        "Object: ${log.object}",
                                        style: getRegularStyle(fontSize: 12, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}

class LogEntry {
  final String timestamp;
  final String action;
  final String status;
  final String details;
  final String userName;
  final String object;

  const LogEntry({
    required this.timestamp,
    required this.action,
    required this.status,
    required this.details,
    required this.userName,
    required this.object,
  });
}
