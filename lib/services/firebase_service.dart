import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a new user
  Future<UserModel> registerUser({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String role,
  }) async {
    try {
      // Check if user exists
      final existingUser = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (existingUser.docs.isNotEmpty) {
        throw Exception('User with this phone number already exists');
      }

      // Create new user
      final docRef = _firestore.collection('users').doc();
      final userId = docRef.id;

      final user = UserModel(
        id: userId,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        role: role,
        createdAt: DateTime.now(),
      );

      await docRef.set(user.toJson());

      return user;
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  // Login user by phone number
  Future<UserModel> loginUser(String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('User not found. Please register first.');
      }

      final userData = querySnapshot.docs.first.data();
      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Get user by ID
  Future<UserModel> getUserById(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();

      if (!docSnapshot.exists) {
        throw Exception('User not found');
      }

      return UserModel.fromJson(docSnapshot.data()!);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;

      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }
}

