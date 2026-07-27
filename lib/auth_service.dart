import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Sign In existing user
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Sign in successful
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occured during login"; // Return error message
    }
  }

  // 2. Register new user and save profile information
  Future<String?> signUpUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String medicalConditions,
  }) async{
    try {
      // Create user account in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      //Save custom info in Firestore using generated User ID (UID)
      String uid = credential.user!.uid;
      await _db.collection('users').doc(uid).set({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
        'medicalConditions': medicalConditions.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Sign up successful
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred during sign up";
    } catch (e) {
      return "Error:$e";
    }
  }
}
