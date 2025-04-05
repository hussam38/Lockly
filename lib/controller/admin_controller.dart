// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/services/prefs.dart';
import 'package:graduation_project/shared/extensions.dart';
import 'package:graduation_project/utils/router.dart';

import '../model/user_model.dart';
import '../view/admin/admin_home.dart';
import '../view/admin/admin_logs.dart';
import '../view/admin/admin_settings.dart';

class AdminController extends GetxController {
  final SharedPrefsService _prefs = SharedPrefsService.instance;
  SharedPrefsService get prefs => _prefs;

  RxInt currentIndex = 0.obs;
  RxList pages = const <Widget>[
    AdminHomeScreen(),
    AdminLogsScreen(),
    AdminSettingsScreen()
  ].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var userSearchQuery = TextEditingController().obs;
  var groupSearchQuery = TextEditingController().obs;

  var users = <UserModel>[].obs;
  var filteredUsers = <UserModel>[].obs;

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

  var deviceState = <Map<String, dynamic>>[].obs;
  var selectedItems = <int>{}.obs;
  var isSelectionMode = false.obs;

  // home logic
  void changePage(int i) {
    currentIndex.value = i;
  }

  void fetchUserObjects() {}

  // logs logic

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

      fetchUsers();
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
    Get.offNamed(AppRouter.roleSelectionRoute);
  }

  void fetchUser() async {
    try {
      isLoading.value = true;
      String? userId = _prefs.getString("uid");
      if (userId != null) {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(userId).get();
        if (doc.exists) {
          UserModel user =
              UserModel.fromMap(doc.data() as Map<String, dynamic>);
          print("User data: ${user.toMap()}");
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
    fetchUser();
  }
}
