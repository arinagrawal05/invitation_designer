import 'dart:async';
import 'dart:core';
import 'package:card_render/boarding.dart';
import 'package:card_render/google_sign.dart';
import 'package:card_render/homepage.dart';
import 'package:card_render/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  initState() {
    super.initState();
    // navigatedirect("pagename", context);
    AuthMethods.getCurrentUser().then((value) {
      navigate(value);
    });
  }

  navigate(User? user) {
    Timer(const Duration(seconds: 2), () {
      if (user != null) {
        AppUtils.navigatedirect(
          Homepage(),
          context,
        );
      } else {
        AppUtils.navigatedirect(
          const BoardingScreen(),
          context,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // margin: EdgeInsets.symmetric(
        //   vertical: MediaQuery.of(context).size.height * 0.15,
        // ),
        child: Center(
          child: Text(
            "Invitation App",
            style: GoogleFonts.montserrat(fontSize: 30),
          ),
        ),
      ),
    );
  }
}
