// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/logs_controller.dart';
import 'package:graduation_project/model/device_model.dart';
import 'package:graduation_project/services/prefs.dart';

import '../model/logs_model.dart';
import '../model/user_model.dart';
import '../utils/router.dart';
import '../view/user/user_home.dart';
import '../view/user/user_settings.dart';

class UserController extends GetxController {
  final SharedPrefsService _prefs = SharedPrefsService.instance;
  SharedPrefsService get prefs => _prefs;
  final LogsController logsController = Get.find<LogsController>();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  RxInt currentIndex = 0.obs;
  RxList pages = const <Widget>[UserHomeScreen(), UserSettingsScreen()].obs;

  var deviceState = <DeviceModel>[].obs;
  var selectedItems = <int>{}.obs;
  var isSelectionMode = false.obs;

  var isLoading = false.obs;

  Future<bool> canOpenDoor(String targetDoorId) async {
    final devicesRef = _database.ref('devices');

    try {
      // Fetch all devices
      final allDevicesSnapshot = await devicesRef.get();

      if (allDevicesSnapshot.exists && allDevicesSnapshot.value is Map) {
        final allDevices =
            Map<String, dynamic>.from(allDevicesSnapshot.value as Map);

        // Check if the user has already locked another door
        for (var entry in allDevices.entries) {
          final doorId = entry.key;
          final device = Map<String, dynamic>.from(entry.value);

          if (device['locked'] == true &&
              device['lockedBy'] == currentUser.value?.uid) {
            // If the user has locked another door and it's not the target door, return false
            if (doorId != targetDoorId) {
              return false;
            }
          }
        }
      }

      // If no other door is locked by the user, return true
      return true;
    } catch (e) {
      print("Error checking if user can open door: $e");
      return false;
    }
  }

  void changePage(int i) {
    currentIndex.value = i;
  }

  void enableSelectionMode(int index) {
    isSelectionMode.value = true;
    selectedItems.add(index);
    update();
  }

  void toggleDeviceSelection(int index) {
    if (isSelectionMode.value) {
      if (selectedItems.contains(index)) {
        selectedItems.remove(index);
        // When no items are selected, disable selection mode.
        if (selectedItems.isEmpty) {
          isSelectionMode.value = false;
        }
      } else {
        selectedItems.add(index);
      }
      update();
    }
  }

  Future<void> deleteSelectedDevices() async {
    try {
      isLoading.value = true;

      // Validate currentUser
      final userId = currentUser.value?.uid;
      if (userId == null) {
        throw Exception("Current user is not logged in.");
      }

      // Validate selectedItems
      if (selectedItems.isEmpty) {
        throw Exception("No devices selected for deletion.");
      }

      // Validate deviceState
      if (deviceState.isEmpty) {
        throw Exception("Device state is empty. No devices to delete.");
      }

      // Ensure all selected indices are valid
      final sortedIndices = selectedItems.toList()
        ..sort((a, b) => b.compareTo(a));
      for (final index in sortedIndices) {
        if (index < 0 || index >= deviceState.length) {
          throw RangeError(
              "Invalid index $index. Valid range is 0 to ${deviceState.length - 1}.");
        }
      }

      // Get the selected devices
      final selectedDevices =
          sortedIndices.map((index) => deviceState[index]).toList();

      // Reference to the users and devices nodes in Realtime Database
      DatabaseReference userRef = _database.ref('users/$userId');
      DatabaseReference devicesRef = _database.ref('devices');

      // Update the accessibleObjects list of the current user
      final updatedAccessibleObjects = currentUser.value!.accessibleObjects
          .where((object) =>
              !selectedDevices.any((device) => device.name == object))
          .toList();

      // Update user data in Realtime Database
      await userRef.update({
        'accessibleObjects': updatedAccessibleObjects,
      });

      // Remove the selected devices from the 'assignedTo' field
      for (final device in selectedDevices) {
        final deviceRef = devicesRef.child(device.id);

        // Fetch the assignedTo field for the device
        final snapshot = await deviceRef.child('assignedTo').get();

        if (snapshot.exists) {
          final assignedToData = Map<String, dynamic>.from(
              snapshot.value as Map<dynamic, dynamic>);

          // Remove the user from the assignedTo list
          assignedToData.remove(userId);

          if (assignedToData.isEmpty) {
            // If no users are left, clear the assignedTo field instead of deleting the device
            await deviceRef.update({
              'assignedTo': {},
            });
            print("Device ${device.id} has no users assigned.");
          } else {
            // Otherwise, update the assignedTo field
            await deviceRef.update({
              'assignedTo': assignedToData,
            });
          }
        }
      }

      // Update the local state
      for (final device in selectedDevices) {
        deviceState.removeWhere((d) => d.id == device.id);
      }

      isSelectionMode.value = false;
      selectedItems.clear();

      // Update the current user's accessibleObjects locally
      currentUser.value = currentUser.value!
          .copyWith(accessibleObjects: updatedAccessibleObjects);

      print("Selected devices deleted successfully.");
    } catch (e) {
      print("Error deleting selected devices: $e");
      Get.snackbar(
        "Error",
        "Failed to delete selected devices: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAccessibleDevices() async {
    try {
      isLoading.value = true;

      final devicesSnapshot = await _database.ref('devices').get();

      if (currentUser.value != null) {
        final accessibleObjects = currentUser.value!.accessibleObjects;
        print("Accessible objects for current user: $accessibleObjects");

        final now = DateTime.now().microsecondsSinceEpoch;

        if (devicesSnapshot.exists) {
          deviceState.value = devicesSnapshot.children.where((doc) {
            final data =
                Map<String, dynamic>.from(doc.value as Map<dynamic, dynamic>);
            return accessibleObjects.contains(data['name']);
          }).map((doc) {
            final data =
                Map<String, dynamic>.from(doc.value as Map<dynamic, dynamic>);
            final lockUntil = data['lockUntil'] ?? 0;

            // Check if the lock has expired
            final isStillLocked = (lockUntil is int) && lockUntil > now;

            // If the lock has expired, reset the locked state
            if (!isStillLocked) {
              _database.ref('devices/${doc.key}').update({
                'locked': false,
                'lockUntil': 0,
                'lockedBy': null,
                'mode': 'closed', // Reset mode to 'closed'
              });
            }

            return DeviceModel.fromMap({
              'id': doc.key ?? '',
              'name': data['name'] ?? '',
              'status': data['status'] ?? 'unknown',
              'mode': isStillLocked
                  ? data['mode']
                  : 'closed', // Reset mode if unlocked
              'assignedTo': data['assignedTo'] ?? {},
              'locked': isStillLocked,
              'lockUntil': lockUntil,
              'lockedBy': isStillLocked ? data['lockedBy'] : null,
            });
          }).toList();

          print(
              "Devices retrieved: ${deviceState.map((d) => d.name).toList()}");

          deviceState.sort((a, b) {
            final aStatus = a.status.toLowerCase();
            final bStatus = b.status.toLowerCase();

            if (aStatus == 'online' && bStatus != 'online') {
              return -1;
            } else if (aStatus != 'online' && bStatus == 'online') {
              return 1;
            }

            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
          deviceState.refresh();

          print("Filtered devices: $deviceState");
        } else {
          print("No devices found.");
        }
      } else {
        print("Current user is null, cannot fetch accessible devices.");
      }
      startDeviceListeners();
    } catch (e) {
      print("Error fetching devices: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch devices: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDeviceMode(String deviceId, String newMode) async {
    try {
      final userId = currentUser.value?.uid;
      if (userId == null) {
        throw Exception("Current User isn't logged in.");
      }
      await _database.ref('devices/$deviceId').update({
        'mode': newMode,
        'lockedBy': newMode == 'opened' ? userId : null,
        'locked': newMode == 'opened' ? true : false,
      });

      // Find the device in the local state and update its mode
      final index = deviceState.indexWhere((device) => device.id == deviceId);
      if (index != -1) {
        deviceState[index] = deviceState[index].copyWith(
          mode: newMode,
          locked: newMode == 'opened',
          lockedBy: newMode == 'opened' ? userId : null,
        );
        deviceState.refresh();
      }

      // Log the action
      logsController.addLog(LogEntry(
          id: currentUser.value!.uid,
          timestamp: DateTime.now(),
          action: 'Access Attempt',
          status: 'Success',
          details:
              '${currentUser.value!.name} has ${newMode == 'opened' ? 'opened' : 'closed'} ${deviceState[index].name}',
          userName: currentUser.value!.name));
    } catch (e) {
      print("Error updating device mode: $e");
      Get.snackbar(
        "Error",
        "Failed to update device mode: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> lockDevice(String deviceId, int duration) async {
    try {
      final userId = currentUser.value?.uid;
      if (userId == null) {
        throw Exception("Current User isn't logged in.");
      }

      final lockUntil =
          DateTime.now().microsecondsSinceEpoch + (duration * 1000);

      // lock for the current user.
      await _database.ref('devices/$deviceId').update({
        'locked': true,
        'lockUntil': lockUntil,
        'lockedBy': userId,
      });

      final index = deviceState.indexWhere((device) => device.id == deviceId);
      if (index != -1) {
        deviceState[index] = deviceState[index].copyWith(
          locked: true,
          lockUntil: lockUntil,
          lockedBy: userId,
        );
        deviceState.refresh();
      }

      // Automatically unlock after the duration
      Future.delayed(Duration(seconds: duration), () async {
        await unlockDevice(deviceId);
      });
    } catch (e) {
      print("Error locking/unlocking door: $e");
      Get.snackbar(
        "Error",
        "Failed to lock/unlock the door: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> unlockDevice(String deviceId) async {
    try {
      await _database.ref('devices/$deviceId').update({
        'locked': false,
        'lockUntil': 0,
        'mode': 'closed',
        'lockedBy': null,
      });

      final index = deviceState.indexWhere((device) => device.id == deviceId);
      if (index != -1) {
        deviceState[index] = deviceState[index].copyWith(
          locked: false,
          lockUntil: 0,
          mode: 'closed',
          lockedBy: null,
        );
        deviceState.refresh();
      }
    } catch (e) {
      print("Error unlocking door: $e");
      Get.snackbar("Error", "Failed to unlock the door: ${e.toString()}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void startDeviceListeners() {
    _database.ref('devices').onChildChanged.listen((event) {
      final deviceId = event.snapshot.key;
      final deviceData = Map<String, dynamic>.from(
          event.snapshot.value as Map<dynamic, dynamic>);

      // Find the device and update it based on changes in Firebase
      final index = deviceState.indexWhere((device) => device.id == deviceId);
      if (index != -1) {
        final updatedDevice = DeviceModel.fromMap({
          'id': deviceId ?? '',
          'name': deviceData['name'] ?? '',
          'status': deviceData['status'] ?? 'unknown',
          'mode': deviceData['mode'] ?? 'closed',
          'locked': deviceData['locked'] ?? false,
          'lockUntil': deviceData['lockUntil'] ?? 0,
          'lockedBy': deviceData['lockedBy'],
        });

        deviceState[index] = updatedDevice;
        deviceState.refresh();
      }
    });

    _database.ref('devices').onChildRemoved.listen((event) {
      final deviceId = event.snapshot.key;

      deviceState.removeWhere((d) => d.id == deviceId);
      deviceState.refresh();
    });
  }

  void listenToCurrentUserChanges() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _database.ref('users/$uid').onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        currentUser.value = currentUser.value?.copyWith(
          accessibleObjects: List<String>.from(data['accessibleObjects'] ?? []),
        );

        // Refetch accessible devices when user's access changes
        fetchAccessibleDevices();
      }
    });
  }

  Future<void> logout() async {
    await _prefs.clear();
    await _auth.signOut();
    await logsController.addLog(LogEntry(
      id: currentUser.value!.uid,
      timestamp: DateTime.now(),
      action: 'Logout',
      status: 'SUCCESS',
      details: '${currentUser.value!.name} logged out',
      userName: currentUser.value!.email,
    ));
    Get.offNamed(AppRouter.roleSelectionRoute);
  }

  Future<void> fetchUser() async {
    try {
      isLoading.value = true;
      String? userId = _prefs.getString("uid");

      if (userId != null) {
        // Reference to the users node in Realtime Database
        DatabaseReference userRef = _database.ref('users/$userId');

        // Get the user data from Realtime Database
        DataSnapshot snapshot = await userRef.get();

        if (snapshot.exists) {
          // If data exists, map it to the UserModel
          currentUser.value = UserModel.fromMap(
              Map<String, dynamic>.from(snapshot.value as Map));
          print("User data: ${currentUser.value?.toMap()}");
        } else {
          print("User not found");
          Get.snackbar(
            "Error",
            "User not found in Realtime Database.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        print("User ID not found in preferences");
        Get.snackbar(
          "Error",
          "User ID is not stored in preferences.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Error fetching user: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch user: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchUser().then((_) async {
      await fetchAccessibleDevices();
    });
    listenToCurrentUserChanges();
  }
}
