import 'package:card_render/google_sign.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class BoardingScreen extends StatefulWidget {
  const BoardingScreen({super.key});

  @override
  _BoardingScreenState createState() => _BoardingScreenState();
}

class _BoardingScreenState extends State<BoardingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<ThemeProvider>(context, listen: true);
    // ThemeMode current = provider.getCurrentThemes();

    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      height: 150,
                    ),
                    Center(
                      child: Text(
                        "Create Your Invitation Today",
                        style: GoogleFonts.montserrat(fontSize: 22),
                      ),
                    ),
                    SizedBox(
                      height: 250,
                    ),
                    socialtile("Sign with google", "assets/google_logo.png",
                        () {
                      // navigateslide(
                      // Bottomnavbar(contactList: contactList), context);

                      // final FirebaseAuth auth = FirebaseAuth.instance;
                      AuthMethods().signInWithGoogle(context);
                    }, context),
                  ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget socialtile(String name, logourl, ontap, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: ontap,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 0.5,
                blurRadius: 0.5,
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                height: 30,
                width: 30,
                child: Image.asset(logourl),
              ),
              const SizedBox(
                width: 13,
              ),
              Text(
                name,
                style: GoogleFonts.montserrat(fontSize: 19),
              )
            ],
          ),
        ),
      ),
    );
  }
}
