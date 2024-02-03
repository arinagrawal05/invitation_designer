import 'package:card_render/card_model.dart';
import 'package:card_render/detailpage.dart';
import 'package:card_render/google_sign.dart';
import 'package:card_render/layout_screen.dart';
import 'package:card_render/text_model.dart';
import 'package:card_render/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import 'consts.dart';

class Homepage extends StatefulWidget {
  final User user;

  const Homepage({super.key, required this.user});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // User user = AuthMethods().getCurrentUser();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          label: Text("Create New"),
          icon: Icon(Icons.add),
          onPressed: () {
            AppUtils.navigate(ChooseLayout(userid: widget.user.uid), context);
          }),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hey " + widget.user.displayName!.split(" ")[0] + ",",
                          style: GoogleFonts.montserrat(
                              fontSize: 26, fontWeight: FontWeight.w400),
                        ),
                        Text(
                          "Create Your Invitation Today",
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    Spacer(),
                    // CircleAvatar(
                    //   backgroundImage: NetworkImage(widget.user.photoURL!),
                    // ),
                    IconButton(
                        onPressed: () {
                          AuthMethods().signOut(context);
                        },
                        icon: Icon(
                          Ionicons.log_in_outline,
                          size: 35,
                        ))
                  ],
                ),
              ),
              Divider(thickness: 0.3),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Cards")
                    .where("userid", isEqualTo: widget.user.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 200),
                        child: Text(
                          "Create Your First Card Now",
                          style: GoogleFonts.montserrat(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ),
                    );
                  } else {}
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(38.0),
                      child: const CircularProgressIndicator(
                          strokeCap: StrokeCap.round, color: Colors.grey),
                    ));
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var document = snapshot.data!.docs[index];
                        // return Text("data");
                        return showcanvasBoard(widget.user.uid, context,
                            CardModel.fromFirestore(document));
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

GestureDetector showcanvasBoard(
    String userid, BuildContext context, CardModel model) {
  List<TextProperties> list =
      convertDynamicListToTextPropertiesList(model.textList);
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailPage(
                  userid: userid,
                  model: model,
                  aspectRatio: model.aspectRatio,
                )),
      );
    },
    child: Container(
      margin: canvasMargin,
      // height: canvasHeight,
      // width: canvasWidth,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
              image: NetworkImage(model.imageUrl), fit: BoxFit.cover),
          color: Color(int.parse("0xff${model.bgColor}"))),
      child: AspectRatio(
        aspectRatio: model.aspectRatio,
        child: Stack(
          fit: StackFit.passthrough,
          children: list.map((textProperties) {
            return Positioned(
              left: textProperties.position.dx,
              top: textProperties.position.dy,
              child: customText(textProperties),
            );
          }).toList(),
        ),
      ),
    ),
  );
}
