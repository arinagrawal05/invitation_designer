import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

class AppUtils {
  static void userAddToFirebase(User userDetails) {
    FirebaseFirestore.instance
        .collection("Users")
        .where("userid", isEqualTo: userDetails.uid)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(userDetails.uid)
            .set({
          "name": userDetails.displayName ?? "",
          "email": userDetails.email ?? "",
          "phone": userDetails.phoneNumber ?? "",
          "userimg": userDetails.photoURL ?? "",
          "userid": userDetails.uid,
          // "creationTime": userDetails.metadata.creationTime ?? "",
          // "lastSignInTime": userDetails.metadata ?? "",
          "userHashCode": userDetails.hashCode ?? "",
          "timestamp": DateTime.now(),
        });
      } else {
        print("this is existing user");
      }
    });
  }

  static void navigate(Widget page, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void navigatedirect(Widget page, BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void shareImage(ScreenshotController screenshotController) async {
    Uint8List? capturedImageBytes = await screenshotController.capture();
    if (capturedImageBytes != null) {
      File tempFile = await saveImageToFile(capturedImageBytes);
      await shareImagee(tempFile.path);
    }
  }

  static Future<void> shareImagee(String imagePath) async {
    await Share.shareFiles([imagePath],
        text: 'Here is my Invitation Card made By my Invitation Maker');
  }

  static Future<void> saveImageToGallery(Uint8List imageBytes) async {
    final result = await ImageGallerySaver.saveImage(imageBytes);
    print('Image saved to gallery: $result');
  }

  static Future<File> saveImageToFile(Uint8List imageBytes) async {
    // Get the app's temporary directory
    Directory tempDir = await getTemporaryDirectory();

    // Create a temporary file in the app's temporary directory
    File tempFile =
        File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png');
    await tempFile.writeAsBytes(imageBytes);

    return tempFile;
  }

  static void saveImage(ScreenshotController screenshotController) async {
    Uint8List? capturedImageBytes = await screenshotController.capture();

    if (capturedImageBytes != null) {
      // Save image to gallery
      await saveImageToGallery(capturedImageBytes);
      print('Screenshot saved to gallery');
    } else {
      print('Failed to capture screenshot');
    }
  }
}
