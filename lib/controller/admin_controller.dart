// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/model/device_model.dart';
import 'package:graduation_project/services/prefs.dart';
import 'package:graduation_project/shared/extensions.dart';
import 'package:graduation_project/utils/router.dart';

import '../model/user_model.dart';
import '../view/admin/admin_home.dart';
import '../view/admin/admin_logs.dart';
import '../view/admin/admin_settings.dart';

/*
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  // home logic
  void changePage(int i) {
    currentIndex.value = i;
  }

  Future<void> fetchAccessibleDevices() async {
    try {
      isLoading.value = true;

      final devicesSnapshot = await _firestore.collection('devices').get();

      if (currentUser.value != null) {
        final accessibleObjects = currentUser.value!.accessibleObjects;
        print("Accessible objects for current user: $accessibleObjects");

        final now = DateTime.now().microsecondsSinceEpoch;

        deviceState.value = devicesSnapshot.docs
            .where((doc) => accessibleObjects.contains(doc.data()['name']))
            .map((doc) {
          final data = doc.data();
          final lockUntil = data['lockUntil'] ?? 0;

          final isStillLocked = (lockUntil is int) && lockUntil > now;

          return DeviceModel.fromMap({
            'id': doc.id,
            ...data,
            'locked': isStillLocked,
          });
        }).toList();

        print("Devices retrieved: ${deviceState.map((d) => d.name).toList()}");

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

        print("Filtered devices: $deviceState");
      } else {
        print("Current user is null, cannot fetch accessible devices.");
      }
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

      final sortedIndices = selectedItems.toList()
        ..sort((a, b) => b.compareTo(a));
      final selectedDevices =
          sortedIndices.map((index) => deviceState[index]).toList();

      final userId = currentUser.value?.uid;
      if (userId != null) {
        WriteBatch batch = _firestore.batch();

        final updatedAccessibleObjects = currentUser.value!.accessibleObjects
            .where((object) =>
                !selectedDevices.any((device) => device.name == object))
            .toList();

        batch.update(
          _firestore.collection('users').doc(userId),
          {'accessibleObjects': updatedAccessibleObjects},
        );

        for (final device in selectedDevices) {
          final userMap = {
            'uid': userId,
            'username': currentUser.value!.name,
          };

          batch.update(
            _firestore.collection('devices').doc(device.id),
            {
              'assignedTo': FieldValue.arrayRemove([userMap]),
            },
          );
        }

        // Commit the batch
        await batch.commit();

        // Update the local state
        for (final index in sortedIndices) {
          deviceState.removeAt(index);
        }
        selectedItems.clear();
        isSelectionMode.value = false;

        // Update the current user's accessibleObjects
        currentUser.value = currentUser.value!
            .copyWith(accessibleObjects: updatedAccessibleObjects);
      }
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

  Future<void> updateDeviceMode(String deviceId, String newMode) async {
    try {
      await _firestore.collection('devices').doc(deviceId).update({
        'mode': newMode,
      });

      final index = deviceState.indexWhere((device) => device.id == deviceId);
      if (index != -1) {
        deviceState[index] = deviceState[index].copyWith(mode: newMode);
        deviceState.refresh();
      }
      logsController.addLog(LogEntry(
          id: currentUser.value!.uid,
          timestamp: DateTime.now(),
          action: 'Access Attempt',
          status: 'Success',
          details:
              '${currentUser.value!.name} has Opened ${deviceState[index].name}',
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
      final lockUntil =
          DateTime.now().microsecondsSinceEpoch + (duration * 1000);
      await _firestore.collection('devices').doc(deviceId).update({
        'locked': true,
        'lockUntil': lockUntil,
      });

      final index = deviceState.indexWhere((device) => device.id == deviceId);
      if (index != -1) {
        deviceState[index] = deviceState[index].copyWith(
          locked: true,
          lockUntil: lockUntil,
        );
        deviceState.refresh();
      }
      Future.delayed(Duration(seconds: duration), () async {
        await _firestore.collection('devices').doc(deviceId).update({
          'locked': false,
          'lockUntil': 0,
          'mode': 'closed',
        });

        final index = deviceState.indexWhere((device) => device.id == deviceId);
        if (index != -1) {
          deviceState[index] = deviceState[index].copyWith(
            locked: false,
            lockUntil: 0,
            mode: 'closed',
          );
          deviceState.refresh();
        }
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
  // settings logic
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

  void addTempObjectsToUser(String userId, List<String> doors) {
    if (tempSelectedGroups.containsKey(userId)) {
      tempSelectedGroups[userId]!.addAll(doors);
    } else {
      tempSelectedGroups[userId] = doors;
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

      WriteBatch batch = _firestore.batch();

      for (var entry in tempSelectedGroups.entries) {
        String userId = entry.key;
        List<String> doors = entry.value;

        UserModel user = users.firstWhere((user) => user.uid == userId);

        List<String> updatedAccessibleObjects =
            List.from(user.accessibleObjects);
        updatedAccessibleObjects.addAll(doors);

        batch.update(
          _firestore.collection('users').doc(userId),
          {'accessibleObjects': updatedAccessibleObjects},
        );

        await _database.ref('users/$userId').update({
          'accessibleObjects': updatedAccessibleObjects,
        });

        final devicesSnapshot = await _firestore
            .collection('devices')
            .where('name', whereIn: doors)
            .get();

        for (var deviceDoc in devicesSnapshot.docs) {
          final deviceRef = deviceDoc.reference;

          Map<String, String> userAssignment = {
            'uid': userId,
            'username': user.name,
          };

          batch.update(deviceRef, {
            'assignedTo': FieldValue.arrayUnion([userAssignment]),
          });
        }

        user.accessibleObjects = updatedAccessibleObjects;
      }

      await batch.commit();
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

  Future<void> removeObjectsFromUser(String userId, String door) async {
    try {
      isLoading.value = true;

      WriteBatch batch = _firestore.batch();

      tempSelectedGroups[userId]?.remove(door);
      if (tempSelectedGroups[userId]?.isEmpty ?? false) {
        tempSelectedGroups.remove(userId);
      }

      UserModel user = users.firstWhere((user) => user.uid == userId);
      user.accessibleObjects.remove(door);

      batch.update(
        _firestore.collection('users').doc(userId),
        {'accessibleObjects': user.accessibleObjects},
      );

      final devicesSnapshot = await _firestore
          .collection('devices')
          .where('name', isEqualTo: door)
          .get();

      final userMap = {
        'uid': userId,
        'username': user.name,
      };

      for (var deviceDoc in devicesSnapshot.docs) {
        batch.update(
          deviceDoc.reference,
          {
            'assignedTo': FieldValue.arrayRemove([userMap])
          },
        );
      }
      await batch.commit();

      print("Removed door $door from user $userId");

      fetchUsers();
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
      // await fetchUsers();
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

      WriteBatch batch = _firestore.batch();

      // Store user data in Firestore
      batch.set(_firestore.collection('users').doc(uid), newUser.toMap());

      final objectsnapshot = await _firestore
          .collection('devices')
          .where('name', whereIn: doors)
          .get();
      final userMap = {
        'uid': uid.trim(),
        'username': name.trim(),
      };

      for (var objectDoc in objectsnapshot.docs) {
        batch.update(
          objectDoc.reference,
          {
            'assignedTo': FieldValue.arrayUnion([userMap])
          },
        );
      }

      await batch.commit();
      fetchUsers();

      Future.delayed(const Duration(milliseconds: 200), () {
        Get.snackbar("Success", "User created successfully",
            colorText: Colors.white,
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
      });
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

      // Fetch users from Firestore
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      print("Fetched ${snapshot.docs.length} users");

      users.value = snapshot.docs.map((doc) {
        print("User data: ${doc.data()}");
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      if (users.isNotEmpty) {
        groupUsersByObjects();
      }

      filteredUsers.value = users;
      print("Users list updated: ${users.length} users");
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
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        Get.snackbar('Error', 'User not found');
        return;
      }

      final userData = userDoc.data();
      List<String> accessibleDoors =
          List<String>.from(userData?['accessibleObjects'] ?? []);

      WriteBatch batch = _firestore.batch();

      for (String door in accessibleDoors) {
        final devicesnapshot = await _firestore
            .collection('devices')
            .where('name', isEqualTo: door)
            .get();

        for (var deviceDoc in devicesnapshot.docs) {
          final userMap = {
            'uid': uid,
            'username': userData?['name'],
          };

          batch.update(
            deviceDoc.reference,
            {
              'assignedTo': FieldValue.arrayRemove([userMap]),
            },
          );
        }
      }

      batch.delete(_firestore.collection('users').doc(uid));

      await batch.commit();

      print("User deleted and devices updated successfully.");

      fetchUsers();
    } catch (e) {
      print("Error deleting user: $e");
      Get.snackbar('Error', 'Failed to delete user');
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
      status: 'Success',
      details: '${currentUser.value!.name} logged out',
      userName: currentUser.value!.name,
    ));
    Get.offNamed(AppRouter.roleSelectionRoute);
  }
  Future<void> fetchUser() async {
    try {
      isLoading.value = true;
      String? userId = _prefs.getString("uid");
      if (userId != null) {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(userId).get();
        if (doc.exists) {
          currentUser.value =
              UserModel.fromMap(doc.data() as Map<String, dynamic>);
          print("User data: ${currentUser.value?.toMap()}");
        } else {
          print("User not found");
        }
      } else {
        print("User ID not found in preferences");
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
      final devices = await _firestore.collection('devices').get();
      allObjects.value = devices.docs
          .map((device) => device.data()['name']?.toString() ?? 'not defined')
          .toList();
      allObjects.sort();
      print("Fetched objects: $allObjects");
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
    final devicesSnapshot = await _firestore.collection('devices').get();
    List<String> deviceIds = devicesSnapshot.docs
        .where((doc) => doors.contains(doc.data()['name']))
        .map((doc) => doc.id)
        .toList();

    return deviceIds;
  }
  @override
  void onInit() {
    super.onInit();
    fetchUser().then((_) async {
      await fetchAccessibleDevices();
    });
  }
}

*/

class AdminController extends GetxController {
  final SharedPrefsService _prefs = SharedPrefsService.instance;
  SharedPrefsService get prefs => _prefs;

  // final LogsController logsController = Get.find<LogsController>();

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

      // Sort and get the selected devices
      final sortedIndices = selectedItems.toList()
        ..sort((a, b) => b.compareTo(a));
      final selectedDevices =
          sortedIndices.map((index) => deviceState[index]).toList();

      final userId = currentUser.value?.uid;
      if (userId != null) {
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

          // Map<String, String> userMap = {
          //   'uid': userId,
          //   'username': currentUser.value!.name,
          // };

          // Fetch the assignedTo field for the device
          final snapshot = await deviceRef
              .child('assignedTo')
              .orderByChild('uid')
              .equalTo(userId)
              .once();

          // Check if snapshot.value is not null before accessing its entries
          if (snapshot.snapshot.value != null) {
            final updates = <String, dynamic>{};
            final entries = Map<String, dynamic>.from(
                snapshot.snapshot.value as Map<dynamic, dynamic>);

            final keysToRemove = entries.entries
                .where((entry) => entry.value['uid'] == userId)
                .map((entry) => entry.key)
                .toList();

            for (var key in keysToRemove) {
              updates['assignedTo/$key'] = null; // Removing the user entry
            }

            if (updates.isNotEmpty) {
              await deviceRef.update(updates);
            }
          }
        }

        // Update the local state
        for (final index in sortedIndices) {
          deviceState.removeAt(index);
        }
        selectedItems.clear();
        isSelectionMode.value = false;

        // Update the current user's accessibleObjects locally
        currentUser.value = currentUser.value!
            .copyWith(accessibleObjects: updatedAccessibleObjects);
      }
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

      // Fetch devices from Realtime Database
      final devicesSnapshot = await _database.ref('devices').get();

      if (currentUser.value != null) {
        final accessibleObjects = currentUser.value!.accessibleObjects;
        print("Accessible objects for current user: $accessibleObjects");

        final now = DateTime.now().microsecondsSinceEpoch;

        // Check if the snapshot has any data
        if (devicesSnapshot.exists) {
          deviceState.value = devicesSnapshot.children.where((doc) {
            // Safely cast to Map<String, dynamic>
            final data =
                Map<String, dynamic>.from(doc.value as Map<dynamic, dynamic>);
            return accessibleObjects.contains(data['name']);
          }).map((doc) {
            final data =
                Map<String, dynamic>.from(doc.value as Map<dynamic, dynamic>);
            final lockUntil = data['lockUntil'] ?? 0;

            final isStillLocked = (lockUntil is int) && lockUntil > now;

            // Ensure 'id' and other fields are valid when creating the model
            return DeviceModel.fromMap({
              'id': doc.key ?? '',
              'name': data['name'] ?? '',
              'status': data['status'] ?? 'unknown',
              'mode': data['mode'] ?? 'closed',
              'locked': isStillLocked,
              'lockUntil': lockUntil,
              // Add any other necessary fields with default values if missing
            });
          }).toList();

          print(
              "Devices retrieved: ${deviceState.map((d) => d.name).toList()}");

          // Sorting the devices by status and name
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

          print("Filtered devices: $deviceState");
        } else {
          print("No devices found.");
        }
      } else {
        print("Current user is null, cannot fetch accessible devices.");
      }
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
      // Update the mode in Realtime Database
      await _database.ref('devices/$deviceId').update({
        'mode': newMode,
      });

      // Find the device in the local state and update its mode
      final index = deviceState.indexWhere((device) => device.id == deviceId);
      if (index != -1) {
        deviceState[index] = deviceState[index].copyWith(mode: newMode);
        deviceState.refresh();
      }

      // Log the action
      // logsController.addLog(LogEntry(
      //     id: currentUser.value!.uid,
      //     timestamp: DateTime.now(),
      //     action: 'Access Attempt',
      //     status: 'Success',
      //     details:
      //         '${currentUser.value!.name} has Opened ${deviceState[index].name}',
      //     userName: currentUser.value!.name));
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
      final lockUntil =
          DateTime.now().microsecondsSinceEpoch + (duration * 1000);

      // Update the lock status and lockUntil timestamp in the Realtime Database
      await _database.ref('devices/$deviceId').update({
        'locked': true,
        'lockUntil': lockUntil,
      });

      // Update the local device state
      final index = deviceState.indexWhere((device) => device.id == deviceId);
      if (index != -1) {
        deviceState[index] = deviceState[index].copyWith(
          locked: true,
          lockUntil: lockUntil,
        );
        deviceState.refresh();
      }

      // Automatically unlock after the duration
      Future.delayed(Duration(seconds: duration), () async {
        await _database.ref('devices/$deviceId').update({
          'locked': false,
          'lockUntil': 0,
          'mode': 'closed',
        });

        // Update the local device state
        final index = deviceState.indexWhere((device) => device.id == deviceId);
        if (index != -1) {
          deviceState[index] = deviceState[index].copyWith(
            locked: false,
            lockUntil: 0,
            mode: 'closed',
          );
          deviceState.refresh();
        }
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

  void addTempObjectsToUser(String userId, List<String> doors) {
    if (tempSelectedGroups.containsKey(userId)) {
      tempSelectedGroups[userId]!.addAll(doors);
    } else {
      tempSelectedGroups[userId] = doors;
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
          // Assuming you store devices under 'devices' node in Realtime Database
          final deviceRef = _database.ref('devices/$door');

          // Fetch the current assignedTo list from the device
          final deviceSnapshot = await deviceRef.get();
          List<Map<String, String>> assignedToList = [];

          // Check if the device snapshot exists and has the 'assignedTo' key
          if (deviceSnapshot.exists && deviceSnapshot.value != null) {
            var deviceData = deviceSnapshot.value as Map<dynamic, dynamic>;
            var assignedToData = deviceData['assignedTo'];

            // If 'assignedTo' exists, safely convert it to a list
            if (assignedToData != null && assignedToData is Map) {
              assignedToData.forEach((key, value) {
                if (value != null && value is Map) {
                  assignedToList.add(Map<String, String>.from(value));
                }
              });
            }
          }

          // Assign the user to the device (preserving existing users)
          Map<String, String> userAssignment = {
            'uid': userId,
            'username': user.name,
          };

          // Add the user to the list of assigned users (if not already assigned)
          if (!assignedToList
              .any((assignedUser) => assignedUser['uid'] == userId)) {
            assignedToList.add(userAssignment);
          }

          // Update the device's 'assignedTo' list in Firebase
          await deviceRef.update({
            'assignedTo':
                Map.fromIterable(assignedToList, key: (e) => e['uid']!),
          });
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

  Future<void> removeObjectsFromUser(String userId, String door) async {
    try {
      isLoading.value = true;

      // Remove door from the tempSelectedGroups map
      tempSelectedGroups[userId]?.remove(door);
      if (tempSelectedGroups[userId]?.isEmpty ?? false) {
        tempSelectedGroups.remove(userId);
      }

      // Find the user and remove the door from their accessible objects
      UserModel user = users.firstWhere((user) => user.uid == userId);
      user.accessibleObjects.remove(door);

      // Update the user's accessibleObjects in Realtime Database
      await _database.ref('users/$userId').update({
        'accessibleObjects': user.accessibleObjects,
      });

      // Remove the user from the assigned devices
      final deviceRef = _database.ref('devices/$door');
      final deviceSnapshot = await deviceRef.get();

      if (deviceSnapshot.exists) {
        var deviceData = deviceSnapshot.value as Map<dynamic, dynamic>;
        var assignedToData = deviceData['assignedTo'];

        // Check if 'assignedTo' exists and is a Map
        if (assignedToData != null && assignedToData is Map) {
          // Remove the user from the 'assignedTo' list
          assignedToData.remove(userId);

          // Update the device's 'assignedTo' field in Firebase
          await deviceRef.update({
            'assignedTo': assignedToData,
          });

          print("Removed user $userId from door $door");
        }
      }

      // Refresh the users and devices data
      await fetchUsers();
      await fetchUser();
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
      // await fetchUsers();
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

      // Loop through the list of doors to assign user to devices
      for (String door in doors) {
        final deviceRef = _database.ref('devices/$door');
        final userMap = {
          'uid': uid.trim(),
          'username': name.trim(),
        };

        await deviceRef.update({
          'assignedTo': {
            uid: userMap,
          },
        });
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

      // Initialize a list of updates for devices
      List<Future<void>> deviceUpdates = [];

      for (String door in accessibleDoors) {
        // Fetch devices assigned to the door
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

            // Safely extract the list of users assigned to this device
            List<dynamic> assignedToList = [];
            if (assignedToSnapshot.exists && assignedToSnapshot.value != null) {
              assignedToList = assignedToSnapshot.value is Iterable
                  ? List<dynamic>.from(assignedToSnapshot.value as Iterable)
                  : [];
            }

            // Remove the user from the assignedTo list
            assignedToList.removeWhere((userMap) => userMap['uid'] == uid);

            // Update the device record in the database
            deviceUpdates.add(deviceRef.update({
              'assignedTo': assignedToList,
            }));
          }
        }
      }

      // Remove the user from the users list
      await _database.ref('users/$uid').remove();

      // Wait for all device updates to complete
      await Future.wait(deviceUpdates);

      print("User deleted and devices updated successfully.");
      fetchUsers();
    } catch (e) {
      print("Error deleting user: $e");
      Get.snackbar('Error', 'Failed to delete user');
    } finally {
      isLoading(false);
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
    // await logsController.addLog(LogEntry(
    //   id: currentUser.value!.uid,
    //   timestamp: DateTime.now(),
    //   action: 'Logout',
    //   status: 'Success',
    //   details: '${currentUser.value!.name} logged out',
    //   userName: currentUser.value!.name,
    // ));
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

      // Reference to the 'devices' node in Realtime Database
      DatabaseReference devicesRef = _database.ref('devices');

      // Fetch all devices data from Realtime Database
      DataSnapshot snapshot = await devicesRef.get();

      if (snapshot.exists) {
        // If data exists, map the device names
        List<String> devicesList = [];
        Map<dynamic, dynamic> devicesData =
            snapshot.value as Map<dynamic, dynamic>;

        devicesData.forEach((key, value) {
          String deviceName = value['name']?.toString() ?? 'not defined';
          devicesList.add(deviceName);
        });

        // Sort the devices list
        devicesList.sort();

        allObjects.value = devicesList;
        print("Fetched objects: $allObjects");
      } else {
        print("No devices found in Realtime Database.");
        Get.snackbar(
          "Error",
          "No devices found.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
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
  }
}
