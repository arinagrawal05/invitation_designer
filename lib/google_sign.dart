import 'package:card_render/boarding.dart';
import 'package:card_render/homepage.dart';
import 'package:card_render/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static Future<User?> getCurrentUser() async {
    try {
      // Get the current user from FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;

      // Check if the user is signed in
      if (user != null) {
        // Access the display name
        User? thisUser = user;

        // Return the display name
        return thisUser;
      } else {
        // User is not signed in
        print("User is not signed in");
        return null;
      }
    } catch (e) {
      print("Error retrieving user display name: $e");
      return null;
    }
  }

  signInWithGoogle(BuildContext context) async {
    // final userProvider = Provider.of<UserDataProvider>(context, listen: false);

    print("Google auth clicked");
    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();
    print("Google auth clicked 1.5");
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    print("Google auth clicked 2");

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    print("Google auth clicked 3${credential.token}");

    UserCredential result = await auth.signInWithCredential(credential);

    User userDetails = result.user!;

    if (result != null) {
      print("${userDetails.metadata.creationTime}is a creation time");
      print(
          "google data userid(auth uid) set! ${googleSignInAuthentication.idToken}");
      print("${userDetails.displayName} Success ");
      AppUtils.userAddToFirebase(userDetails);
      // notesProvider.setuserid(userDetails.uid);
      // userProvider.setUserData(
      //     userDetails.uid,
      //     userDetails.displayName ?? "",
      //     userDetails.email ?? "",
      //     userDetails.phoneNumber ?? "",
      //     userDetails.photoURL ?? "");
      // setprefab(
      //   true,
      //   userDetails.uid,
      //   userDetails.displayName ?? "",
      //   userDetails.email ?? "",
      //   userDetails.photoURL ?? "",
      //   userDetails.phoneNumber ?? "",
      // );

      // ignore: use_build_context_synchronously
      AppUtils.navigatedirect(const Homepage(), context);
    } else {
      print("its disgusting not happening");
    }
  }

  void signOut(BuildContext context) async {
    print("User GoogleSign out !!");
    AppUtils.navigatedirect(const BoardingScreen(), context);
    // setprefab(false, "userid", "", "", "", "");
    await _googleSignIn.signOut();
    await auth.signOut();
  }
}
