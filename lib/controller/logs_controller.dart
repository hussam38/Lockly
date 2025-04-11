// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/model/logs_model.dart';

class LogsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var logs = <LogEntry>[].obs;
  var filteredLogs = <LogEntry>[].obs;
  var groupedLogs = <String, List<LogEntry>>{}.obs;

  var isLoading = false.obs;
  var hasLogsFetched = false.obs;
  var searchQuery = ''.obs;
  var selectedFilter = 'All'.obs;
  DateTime? startDate;
  DateTime? endDate;

  Stream<List<LogEntry>> get logsStream {
    return _firestore
        .collection('logs')
        .orderBy('timestamp', descending: true)
        .snapshots() 
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => LogEntry.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> addLog(LogEntry log) async {
    try {
      isLoading.value = true;
      final logRef = _firestore.collection('logs').doc();
      await logRef.set(log.toMap());
      applyFilters();
    } catch (e) {
      print("Error adding log: $e");
      Get.snackbar(
        "Error",
        "Failed to add log: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    final filtered = logs.where((log) {
      final logDate = log.timestamp;

      final matchesSearchQuery =
          log.details.toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchesFilter =
          selectedFilter.value == "All" || log.action == selectedFilter.value;

      final matchesDateRange =
          (startDate == null || !logDate.isBefore(startDate!)) &&
              (endDate == null || !logDate.isAfter(endDate!));

      return matchesSearchQuery && matchesFilter && matchesDateRange;
    }).toList();

    // Debug: print info to verify filter behavior
    print("Applying filters:");
    print(" - Start: $startDate");
    print(" - End: $endDate");
    print(" - Search: ${searchQuery.value}");
    print(" - Filter: ${selectedFilter.value}");
    print(" - Logs before filter: ${logs.length}");
    print(" - Logs after filter: ${filtered.length}");

    filteredLogs.value = filtered;

    groupLogsByDate(filteredLogs);
  }

  void groupLogsByDate(List<LogEntry> logs) {
    final Map<String, List<LogEntry>> grouped = {};
    for (var log in logs) {
      final date = log.timestamp.toIso8601String().split('T').first;
      if (grouped.containsKey(date)) {
        grouped[date]!.add(log);
      } else {
        grouped[date] = [log];
      }
    }
    groupedLogs.value = grouped;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilters();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate = start;
    endDate = end;
    applyFilters();
  }

  Map<String, int> getFilterCounts() {
    return {
      "All": logs.length,
      "Login": logs.where((log) => log.action == "Login").length,
      "Logout": logs.where((log) => log.action == "Logout").length,
      "Access Attempt":
          logs.where((log) => log.action == "Access Attempt").length,
      "Admin Action": logs.where((log) => log.action == "Admin Action").length,
      "Notification": logs.where((log) => log.action == "Notification").length,
      "Error": logs.where((log) => log.action == "Error").length,
    };
  }
}
