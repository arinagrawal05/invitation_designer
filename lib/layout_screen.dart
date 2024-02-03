import 'package:card_render/detailpage.dart';
import 'package:card_render/layout_model.dart';
import 'package:card_render/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class ChooseLayout extends StatefulWidget {
  final String userid;

  const ChooseLayout({super.key, required this.userid});
  @override
  State<ChooseLayout> createState() => _ChooseLayoutState();
}

class _ChooseLayoutState extends State<ChooseLayout> {
  final List<CustomModel> models = [
    CustomModel(
      name: "Poster",
      height: 1680.0,
      width: 1200.0,
      color: Color.fromRGBO(255, 130, 63, 1),
      iconData: Ionicons.megaphone_outline,
    ),
    CustomModel(
      name: "Instagram  Story",
      height: 1920.0,
      width: 1080.0,
      color: Color.fromRGBO(243, 114, 132, 1),
      iconData: Ionicons.logo_instagram,
    ),
    CustomModel(
      name: "Invitation Card",
      height: 595.0,
      width: 420.0,
      color: Color.fromRGBO(59, 207, 211, 1),
      iconData: Ionicons.logo_facebook,
    ),
    CustomModel(
      name: "Facebook    Post",
      height: 1000.0,
      width: 1000.0,
      color: Color.fromRGBO(129, 139, 250, 1),
      iconData: Ionicons.logo_facebook,
    ),
    CustomModel(
      name: "Instagram    Post",
      height: 1080.0,
      width: 1080.0,
      color: Color.fromRGBO(254, 199, 108, 1),
      iconData: Ionicons.logo_instagram,
    ),
    CustomModel(
      name: "Facebook Cover",
      height: 510.0,
      width: 820.0,
      color: Color.fromRGBO(129, 139, 250, 1),
      iconData: Ionicons.logo_facebook,
    ),
    CustomModel(
      name: "Invoice    Memo",
      height: 867.0,
      width: 606.0,
      color: Color.fromRGBO(108, 185, 255, 1),
      iconData: Ionicons.document_outline,
    ),
    CustomModel(
      name: "YT Banners",
      height: 1440.0,
      width: 2560.0,
      color: Color.fromRGBO(40, 101, 148, 1),
      iconData: Ionicons.logo_youtube,
    ),
    CustomModel(
      name: "Bussiness Card",
      height: 1222.0,
      width: 1242.0,
      color: Color.fromRGBO(108, 99, 146, 1),
      iconData: Ionicons.card,
    ),
    CustomModel(
      name: "Youtube",
      height: 720.0,
      width: 1280.0,
      color: Color.fromRGBO(243, 114, 132, 1),
      iconData: Ionicons.logo_youtube,
    ),
    // Add more models as needed
  ];
  CustomModel selectedModel = CustomModel(
    name: "Poster",
    height: 1680.0,
    width: 1200.0,
    color: Colors.purple.shade400,
    iconData: Ionicons.megaphone_outline,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Choose Layout',
          style: GoogleFonts.montserrat(fontSize: 15),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              AppUtils.navigate(
                  DetailPage(
                      userid: widget.userid,
                      model: null,
                      aspectRatio: selectedModel.width / selectedModel.height),
                  context);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Ionicons.arrow_forward_circle,
                size: 30,
                color: Color.fromRGBO(243, 114, 132, 1),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            // margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            // width: MediaQuery.of(context).size.width * 0.60,
            constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.60,
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Card(
              // color: selectedModel.color.withAlpha(223),
              // borderOnForeground: true,
              elevation: 4,
              // margin: EdgeInsets.symmetric(horizontal: 100),
              // height: 200,
              // color: Colors.red,
              child: AspectRatio(
                aspectRatio: selectedModel.width / selectedModel.height,
                // child: Text("data"),
              ),
            ),
          ),
          Spacer(),
          Text(
            selectedModel.height.toInt().toString() +
                " x " +
                selectedModel.width.toInt().toString(),
            style: GoogleFonts.montserrat(color: Colors.grey),
          ),
          Container(
            // width: double.infinity,
            // height: 200,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(models.length, (index) {
                  return layoutCard(models[index]);
                }),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget layoutCard(CustomModel model) {
    double ratio = model.width / model.height;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedModel = model;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
        width: 130,
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: model.color),
          child: AspectRatio(
            aspectRatio: ratio,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                  border: selectedModel == model
                      ? Border.all(color: Colors.white, width: 1)
                      : Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(model.iconData, size: 25.0, color: Colors.white),
                  Spacer(),
                  Text(
                    model.name,
                    style: GoogleFonts.montserrat(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
