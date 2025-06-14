// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controller/logs_controller.dart';
import 'package:graduation_project/model/device_model.dart';
import 'package:graduation_project/services/prefs.dart';
import 'package:graduation_project/shared/extensions.dart';
import 'package:graduation_project/utils/router.dart';
import '../model/logs_model.dart';
import '../model/user_model.dart';
import '../view/admin/admin_home.dart';
import '../view/admin/admin_logs.dart';
import '../view/admin/admin_settings.dart';

class AdminController extends GetxController {
  final SharedPrefsService _prefs = SharedPrefsService.instance;
  SharedPrefsService get prefs => _prefs;

  final LogsController logsController = Get.find<LogsController>();

  RxInt currentIndex = 0.obs;
  RxList pages = const <Widget>[
    AdminHomeScreen(),
    AdminLogsScreen(),
    AdminSettingsScreen()
  ].obs;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var userSearchQuery = TextEditingController().obs;
  var groupSearchQuery = TextEditingController().obs;

  var users = <UserModel>[].obs;
  var filteredUsers = <UserModel>[].obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  var groupedUsers = <String, List<UserModel>>{}.obs;
  var filteredGroupedUsers = <String, List<UserModel>>{}.obs;
  var selectedGroups = <String, List<String>>{}.obs;
  var tempSelectedGroups = <String, List<String>>{}.obs;

  var selectedObjects = <String>[].obs;
  var userObjects = <String>[].obs;
  var allObjects = <String>[].obs;

  RxBool isLoading = false.obs;
  RxBool isUsersLoaded = true.obs;
  RxBool isObjectsLoaded = true.obs;
  RxBool isGroupsLoaded = false.obs;

  var deviceState = <DeviceModel>[].obs;
  var selectedItems = <int>{}.obs;
  var isSelectionMode = false.obs;

  final idController = TextEditingController();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final status = 'online'.obs;

  Future<void> updateInfo({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final uid = currentUser.value?.uid;
      if (uid == null) return;
      // Update in Firebase Auth if needed
      if (email.isNotEmpty && email != currentUser.value!.email) {
        await _auth.currentUser?.verifyBeforeUpdateEmail(email);
      }
      if (password.isNotEmpty) {
        await _auth.currentUser?.updatePassword(password);
      }
      // Update in database
      await _database.ref('users/$uid').update({
        'name': username,
        'email': email,
      });
      // Update local user
      currentUser.value =
          currentUser.value!.copyWith(name: username, email: email);
      await fetchUser();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update info: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

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

  Future<void> submitDoor() async {
    isLoading.value = true;
    final id = idController.text.trim();
    final name = nameController.text.trim();
    final location = locationController.text.trim();

    if (id.length != 6 || !RegExp(r'^\d{6}$').hasMatch(id)) {
      Get.snackbar("Error", "Door ID must be exactly 6 digits.");
      return;
    }
    if (name.isEmpty || location.isEmpty) {
      Get.snackbar("Error", "Name and location are required.");
      return;
    }

    final doorData = DeviceModel(
      id: id,
      name: name,
      status: status.value,
      location: location,
      createdAt: DateTime.now(),
      assignedTo: [],
      mode: 'closed',
    );
    final doorRef = _database.ref('devices/$id');

    try {
      final snapshot = await doorRef.get();

      if (snapshot.exists) {
        Get.snackbar("Duplicate", "A door with this ID already exists.",
            backgroundColor: Colors.yellow,
            snackPosition: SnackPosition.BOTTOM);
        isLoading.value = false;
        return;
      }
      await doorRef.set(doorData.toMap());
      await fetchObjects();
      Get.snackbar("Success", "Door added Successfully",
          backgroundColor: Colors.green, snackPosition: SnackPosition.BOTTOM);
      idController.clear();
      nameController.clear();
      locationController.clear();
      status.value = 'online';
    } catch (e) {
      Get.snackbar("Error", "Failed to add door: $e");
    } finally {
      isLoading.value = false;
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

  void groupUsersByObjects() {
    Map<String, List<UserModel>> grouped = {};
    for (var user in users) {
      for (var object in user.accessibleObjects) {
        if (!grouped.containsKey(object)) {
          grouped[object] = [];
        }
        grouped[object]!.add(user);
      }
    }
    groupedUsers.value = grouped; // populate them
    filteredGroupedUsers.value = grouped; // initiate them
  }

  void filterGroups() {
    String searchText = groupSearchQuery.value.text.toLowerCase();

    if (searchText.isEmpty) {
      filteredGroupedUsers.value = groupedUsers;
      return;
    }

    Map<String, List<UserModel>> filtered = groupedUsers
        .map((key, value) {
          final filteredList = value
              .where((user) =>
                  user.name.toLowerCase().contains(searchText) ||
                  key.toLowerCase().contains(searchText))
              .toList();
          return MapEntry(key, filteredList);
        })
        .entries
        .where((entry) => entry.value.isNotEmpty)
        .toMap();

    filteredGroupedUsers.value = filtered;
  }

  void addTempObjectsToUser(String userId, List<String> doorIds) {
    if (tempSelectedGroups.containsKey(userId)) {
      final existing = tempSelectedGroups[userId]!;
      tempSelectedGroups[userId] =
          {...existing, ...doorIds}.toList(); // remove duplicates
    } else {
      tempSelectedGroups[userId] = doorIds.toSet().toList(); // safe insert
    }
  }

  void removeTempObjectFromUser(String userId, String door) {
    tempSelectedGroups[userId]?.remove(door);

    tempSelectedGroups[userId] = List.from(tempSelectedGroups[userId] ?? []);

    if (tempSelectedGroups[userId]?.isEmpty ?? false) {
      tempSelectedGroups.remove(userId);
    }
  }

  Future<void> addObjectsToUsers() async {
    try {
      isLoading.value = true;

      // Iterate through each selected group
      for (var entry in tempSelectedGroups.entries) {
        String userId = entry.key;
        List<String> doors = entry.value;

        // Find the user by ID
        UserModel user = users.firstWhere((user) => user.uid == userId);

        // Update the list of accessible objects (doors)
        List<String> updatedAccessibleObjects =
            List.from(user.accessibleObjects);
        updatedAccessibleObjects.addAll(doors);

        // Update the user's accessibleObjects in Firebase Realtime Database
        await _database.ref('users/$userId').update({
          'accessibleObjects': updatedAccessibleObjects,
        });

        // Update the devices' 'assignedTo' in Firebase Realtime Database
        for (String door in doors) {
          // Fetch the door's unique ID using its name
          final deviceSnapshot = await _database
              .ref('devices')
              .orderByChild('name')
              .equalTo(door)
              .get();

          if (deviceSnapshot.exists) {
            final deviceId = deviceSnapshot.children.first.key;
            final deviceRef = _database.ref('devices/$deviceId');

            // Fetch the current assignedTo list from the device
            final assignedToSnapshot =
                await deviceRef.child('assignedTo').get();
            Map<String, dynamic> assignedToData = {};

            if (assignedToSnapshot.exists) {
              assignedToData = Map<String, dynamic>.from(
                  assignedToSnapshot.value as Map<dynamic, dynamic>);
            }

            // Add the user to the assignedTo list
            assignedToData[userId] = {
              'uid': userId,
              'username': user.name,
            };

            // Update the device's assignedTo field in Firebase
            await deviceRef.update({
              'assignedTo': assignedToData,
            });
          } else {
            print("Device with name $door not found.");
          }
        }

        // Update the local user object in your app state
        user.accessibleObjects = updatedAccessibleObjects;
      }

      // Refresh user data
      await fetchUsers();
      await fetchUser();
      await fetchAccessibleDevices();
      tempSelectedGroups.clear();
    } catch (e) {
      print("Error applying changes: $e");
      Get.snackbar(
        "Error",
        "Failed to apply changes: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeObjectsFromUser(String userId, String doorName) async {
    try {
      isLoading.value = true;

      // Find the user and remove the door from their accessible objects
      UserModel user = users.firstWhere((user) => user.uid == userId);
      user.accessibleObjects.remove(doorName);

      // Update the user's accessibleObjects in Realtime Database
      await _database.ref('users/$userId').update({
        'accessibleObjects': user.accessibleObjects,
      });

      // Find the device by its name to get its unique ID
      final deviceSnapshot = await _database
          .ref('devices')
          .orderByChild('name')
          .equalTo(doorName)
          .get();

      if (deviceSnapshot.exists) {
        final deviceId = deviceSnapshot.children.first.key;
        final deviceRef = _database.ref('devices/$deviceId');

        // Fetch the current assignedTo list from the device
        final assignedToSnapshot = await deviceRef.child('assignedTo').get();
        Map<String, dynamic> assignedToData = {};

        if (assignedToSnapshot.exists) {
          assignedToData = Map<String, dynamic>.from(
              assignedToSnapshot.value as Map<dynamic, dynamic>);
        }

        // Remove the user from the assignedTo list
        assignedToData.remove(userId);

        // Update the device's assignedTo field in Firebase
        await deviceRef.update({
          'assignedTo': assignedToData,
        });

        print("Removed user $userId from door $doorName");
      } else {
        print("Device with name $doorName not found.");
      }

      // Refresh the users and devices data
      await fetchUsers();
      await fetchAccessibleDevices();
    } catch (e) {
      print("Error removing door: $e");
      Get.snackbar(
        "Error",
        "Failed to remove door: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUsersAndGroupObjects() async {
    try {
      isGroupsLoaded.value = true;
      await fetchUsers();
      groupUsersByObjects();
    } catch (e) {
      print("Error fetching users and grouping objects: $e");
      Get.snackbar(
        'Error',
        'Failed to fetch users and group objects',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGroupsLoaded.value = false;
    }
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required List<String> doors,
  }) async {
    try {
      isLoading.value = true;

      // Create user with Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user ID
      String uid = userCredential.user!.uid;

      // Create user model
      UserModel newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        accessibleObjects: doors,
        role: 'user',
      );

      // Store user data in Realtime Database
      await _database.ref('users/$uid').set(newUser.toMap());
      await _database.ref('users/$uid/mustChangePasswd').set(true);

      // Loop through the list of doors to assign user to devices
      for (String door in doors) {
        // Fetch the door's unique ID using its name
        final deviceSnapshot = await _database
            .ref('devices')
            .orderByChild('name')
            .equalTo(door)
            .get();

        if (deviceSnapshot.exists) {
          final deviceId = deviceSnapshot.children.first.key;
          final deviceRef = _database.ref('devices/$deviceId');

          // Fetch the current 'assignedTo' list
          final assignedToSnapshot = await deviceRef.child('assignedTo').get();
          Map<String, dynamic> assignedToData = {};

          if (assignedToSnapshot.exists) {
            assignedToData = Map<String, dynamic>.from(
                assignedToSnapshot.value as Map<dynamic, dynamic>);
          }

          // Add the new user to the 'assignedTo' list
          assignedToData[uid] = {
            'uid': uid.trim(),
            'username': name.trim(),
          };

          // Update the 'assignedTo' field in Firebase
          await deviceRef.update({
            'assignedTo': assignedToData,
          });
        } else {
          print("Device with name $door not found.");
        }
      }

      // Refresh users data
      await fetchUsers();

      // Show success message
      Future.delayed(const Duration(milliseconds: 200), () {
        Get.snackbar("Success", "User created successfully",
            colorText: Colors.white,
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
      });

      // Close the current screen
      Get.back();
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred!";
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already in use.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password is too weak.";
      }
      Get.snackbar(
        "Error",
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUsers() async {
    try {
      isLoading(true);

      // Fetch users from Realtime Database
      DataSnapshot snapshot = await _database.ref('users').get();

      if (snapshot.exists) {
        print("Fetched ${snapshot.children.length} users");

        users.value = snapshot.children.map((child) {
          // Ensure the value is cast to Map<String, dynamic>
          final userData = Map<String, dynamic>.from(child.value as Map);
          print("User data: $userData");

          return UserModel.fromMap(userData);
        }).toList();

        if (users.isNotEmpty) {
          groupUsersByObjects();
        }

        filteredUsers.value = users;
        print("Users list updated: ${users.length} users");
      } else {
        print("No users found.");
      }
    } catch (e) {
      print("Error fetching users: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch users: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      isLoading(true);

      // Fetch user data from Realtime Database
      final userSnapshot = await _database.ref('users/$uid').get();
      if (!userSnapshot.exists) {
        Get.snackbar('Error', 'User not found');
        return;
      }

      // Safely cast user data to Map<String, dynamic>
      final userData = Map<String, dynamic>.from(
          userSnapshot.value as Map<dynamic, dynamic>);
      List<String> accessibleDoors =
          List<String>.from(userData['accessibleObjects'] ?? []);

      // Update the 'assignedTo' field for each door
      for (String door in accessibleDoors) {
        // Fetch the door's data
        final deviceSnapshot = await _database
            .ref('devices')
            .orderByChild('name')
            .equalTo(door)
            .get();

        if (deviceSnapshot.exists) {
          for (var device in deviceSnapshot.children) {
            final deviceRef = device.ref;

            // Fetch the current 'assignedTo' list
            final assignedToSnapshot =
                await deviceRef.child('assignedTo').get();

            if (assignedToSnapshot.exists) {
              final assignedToData = Map<String, dynamic>.from(
                  assignedToSnapshot.value as Map<dynamic, dynamic>);

              // Remove only the user being deleted
              assignedToData.remove(uid);

              // Update the 'assignedTo' field in the database
              await deviceRef.update({
                'assignedTo': assignedToData,
              });
            }
          }
        }
      }

      // Remove the user from the users list
      await _database.ref('users/$uid').remove();

      print("User deleted and devices updated successfully.");
      fetchUsers();
    } catch (e) {
      print("Error deleting user: $e");
      Get.snackbar('Error', 'Failed to delete user');
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    try {
      isLoading.value = true;

      // Reference to the device in the database
      final deviceRef = _database.ref('devices/$deviceId');

      // Fetch the device data
      final deviceSnapshot = await deviceRef.get();
      if (!deviceSnapshot.exists) {
        Get.snackbar("Error", "Device not found.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Get the assignedTo list from the device
      final deviceData = Map<String, dynamic>.from(deviceSnapshot.value as Map);
      final assignedToData = Map<String, dynamic>.from(
          deviceData['assignedTo'] ?? <String, dynamic>{});

      // Remove the device from each user's accessibleObjects
      for (String userId in assignedToData.keys) {
        final userRef = _database.ref('users/$userId');

        // Fetch the user's data
        final userSnapshot = await userRef.get();
        if (userSnapshot.exists) {
          final userData = Map<String, dynamic>.from(
              userSnapshot.value as Map<dynamic, dynamic>);
          List<String> accessibleObjects =
              List<String>.from(userData['accessibleObjects'] ?? []);

          // Remove the device from the user's accessibleObjects
          accessibleObjects.removeWhere((door) => door == deviceData['name']);

          // Update the user's accessibleObjects in the database
          await userRef.update({
            'accessibleObjects': accessibleObjects,
          });
        }
      }

      // Delete the device from the database
      await deviceRef.remove();
      await fetchObjects();

      // Remove the device from the local state
      deviceState.removeWhere((device) => device.id == deviceId);

      Get.snackbar("Success", "Device deleted successfully.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print("Error deleting device: $e");
      Get.snackbar("Error", "Failed to delete device: ${e.toString()}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDeviceStatus(String deviceId, String newStatus) async {
    try {
      await _database.ref('devices/$deviceId').update({'status': newStatus});
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update status: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void filterUsers() {
    if (userSearchQuery.value.text.isEmpty) {
      filteredUsers.value = users;
    } else {
      filteredUsers.value = users
          .where((user) => user.name
              .toLowerCase()
              .contains(userSearchQuery.value.text.toLowerCase()))
          .toList();
    }
  }

  void logout() async {
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

  Future<void> fetchObjects() async {
    try {
      isLoading.value = true;
      DatabaseReference devicesRef = _database.ref('devices');
      DataSnapshot snapshot = await devicesRef.get();
      if (snapshot.exists) {
        // If data exists, map the device names
        List<String> devicesList = [];
        Map<dynamic, dynamic> devicesData =
            snapshot.value as Map<dynamic, dynamic>;
        devicesData.forEach((key, value) {
          // Ensure the device has a valid name
          String? deviceName = value['name']?.toString();
          if (deviceName != null && deviceName.isNotEmpty) {
            devicesList.add(deviceName);
          }
        });
        // Sort the devices list
        devicesList.sort();
        allObjects.value = devicesList;
        print("Fetched objects: $allObjects");
      } else {
        print("No devices found in Realtime Database.");
        allObjects.clear(); // Clear the list if no devices are found
      }
    } catch (e) {
      print("Error fetching objects: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch objects: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<String>> fetchObjectsIds(List<String> doors) async {
    try {
      // Reference to the 'devices' node in Realtime Database
      DatabaseReference devicesRef = _database.ref('devices');

      // Fetch all devices data from Realtime Database
      DataSnapshot snapshot = await devicesRef.get();

      List<String> deviceIds = [];

      if (snapshot.exists) {
        // Map the data from the snapshot
        Map<dynamic, dynamic> devicesData =
            snapshot.value as Map<dynamic, dynamic>;

        // Iterate through the devices and match the door names
        devicesData.forEach((key, value) {
          String deviceName = value['name']?.toString() ?? '';

          // If the door name is in the list of doors, add its ID to the result list
          if (doors.contains(deviceName)) {
            deviceIds.add(key.toString()); // Add the device ID (key)
          }
        });
      }

      return deviceIds;
    } catch (e) {
      print("Error fetching device IDs: $e");
      return [];
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

  @override
  void onClose() {
    idController.dispose();
    nameController.dispose();
    locationController.dispose();
    super.onClose();
  }
}
