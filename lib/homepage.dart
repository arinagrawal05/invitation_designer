import 'package:card_render/card_model.dart';
import 'package:card_render/detailpage.dart';
import 'package:card_render/google_sign.dart';
import 'package:card_render/text_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'consts.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  User? myuser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthMethods.getCurrentUser().then((value) {
      setState(() {
        myuser = value;
      });
    });

    // User user = AuthMethods().getCurrentUser();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          label: Text("Add Card${myuser!.uid}"),
          onPressed: () {
            print(myuser!.uid);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DetailPage(
                        model: null,
                      )),
            );
          }),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Cards')
              .where("userid", isEqualTo: myuser!.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const CircularProgressIndicator();
            // } else
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  // var document = snapshot.data!.docs[index];
                  return showcanvasBoard(context,
                      CardModel.fromFirestore(snapshot.data!.docs[index]));
                  // MyCardWidget(
                  //   model: CardModel.fromFirestore(snapshot.data!.docs[index]),
                  // );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

GestureDetector showcanvasBoard(BuildContext context, CardModel model) {
  List<TextProperties> list =
      convertDynamicListToTextPropertiesList(model.textList);
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailPage(
                  model: model,
                )),
      );
    },
    child: Container(
      margin: canvasMargin,
      height: canvasHeight,
      width: canvasWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
            image: NetworkImage(model.imageUrl), fit: BoxFit.cover),
        color: Colors.grey.shade300,
      ),
      child: Stack(
        children: list.map((textProperties) {
          return Positioned(
            left: textProperties.position.dx,
            top: textProperties.position.dy,
            child: customText(textProperties),
          );
        }).toList(),
      ),
    ),
  );
}
