import 'package:card_render/card_model.dart';
import 'package:card_render/text_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'consts.dart';
// import 'homepage.dart';

class DetailPage extends StatefulWidget {
  final CardModel? model;

  const DetailPage({super.key, required this.model});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<dynamic> stringList = [];

  TextProperties? activeItem;
  Offset initPosition = const Offset(20, 20);
  Offset currentPosition = const Offset(20, 20);
  bool inAction = false;
  List<TextProperties> stackData = [];

  List<TextProperties> undoStack = [];
  List<TextProperties> redoStack = [];

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      setState(() {
        stringList = widget.model!.textList;
        stackData =
            convertDynamicListToTextPropertiesList(widget.model!.textList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          label: const Text("Add Text"),
          onPressed: () async {
            Tuple2<String, String> result = await textFormatDialog(
                context,
                TextProperties(
                    text: "Sample",
                    fontSize: 18,
                    color: "ffFF0000",
                    fontfamily: "Lato",
                    position: const Offset(0.3, 0.5)),
                isNew: true);
            if (result.action == "add") {
              Map<String, dynamic> jsonMap = jsonStringToMap(result.property);

              TextProperties properties = TextProperties.fromJson(jsonMap);

              setState(() {
                stackData.add(properties);
              });
            }
          },
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                canvasBoard(),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 40),
                          ),
                          onPressed: () {
                            stringList = convertTextPropertiesListToStringList(
                                stackData);
                            if (widget.model != null) {
                              FirebaseFirestore.instance
                                  .collection("Cards")
                                  .doc(widget.model!.id)
                                  .update({
                                "text_json_list": stringList.toList(),
                              }).then((value) {
                                Navigator.pop(context);
                              }).catchError((error) {});
                            } else {
                              var id = const Uuid().v4();
                              FirebaseFirestore.instance
                                  .collection("Cards")
                                  .doc(id)
                                  .set({
                                "card_id": id,
                                "image_url": backgroundUrl,
                                "text_json_list": stringList,
                              }).then((value) {
                                Navigator.pop(context);
                              }).catchError((error) {});
                            }
                          },
                          child: const Text("Save This Card")),
                      SizedBox(
                        height: 12,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 40),
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("Cards")
                                .doc(widget.model!.id)
                                .delete()
                                .then((value) {
                              Navigator.pop(context);
                            }).catchError((error) {});
                          },
                          child: const Text("Delete This Card"))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector canvasBoard() {
    return GestureDetector(
      onScaleStart: (details) {
        if (activeItem == null) return;
        initPosition = details.focalPoint;
        currentPosition = activeItem!.position;
      },
      onScaleUpdate: (details) {
        if (activeItem == null) return;
        final delta = details.focalPoint - initPosition;
        final left = (delta.dx) + currentPosition.dx;
        final top = (delta.dy) + currentPosition.dy;

        activeItem!.position = Offset(left, top);
      },
      onTapUp: (details) async {
        // Check if tapped on an existing item
        for (TextProperties item in stackData) {
          if (isTapInsideItem(details.localPosition, item)) {
            Tuple2<String, String> result =
                await textFormatDialog(context, item);
            if (result.action == "delete") {
              setState(() {
                stackData.remove(item);
              });
            } else if (result.action == "edit") {
              setState(() {
                stackData.remove(item);
                stackData.add(convertJsonToTextProperties(
                    jsonStringToMap(result.property)));
              });
            }
            break;
          }
        }
      },
      child: Container(
        margin: canvasMargin,
        height: canvasHeight,
        width: canvasWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image:
              //  imageBytes != null
              //     ?
              DecorationImage(
                  image: NetworkImage(backgroundUrl), fit: BoxFit.cover),
          color: Colors.grey.shade300,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      undo();
                    },
                    child: const Icon(Icons.undo),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      redo();
                    },
                    child: const Icon(Icons.redo),
                  ),
                ],
              ),
            ),
            ...stackData.map(buildItemWidget).toList(),
          ],
        ),
      ),
    );
  }

  void undo() {
    setState(() {
      if (stackData.isNotEmpty) {
        redoStack.add(stackData.removeLast());
      }
    });
  }

  void redo() {
    setState(() {
      if (redoStack.isNotEmpty) {
        stackData.add(redoStack.removeLast());
      }
    });
  }

  Widget buildItemWidget(TextProperties e) {
    return Positioned(
      top: e.position.dy,
      left: e.position.dx,
      child: Listener(
        onPointerDown: (details) {
          if (inAction) return;
          inAction = true;
          activeItem = e;
          initPosition = details.position;
          currentPosition = e.position;
        },
        onPointerUp: (details) {
          inAction = false;

          setState(() {
            activeItem = null;
          });
        },
        onPointerCancel: (details) {},
        onPointerMove: (details) {
          if (e.position.dy >= 0.8 &&
              e.position.dx >= 0.0 &&
              e.position.dx <= 1.0) {
            setState(() {});
          } else {
            setState(() {});
          }
        },
        child: customText(e),
      ),
    );
  }
}

List<String> fontFamilyList = [
  "Lato",
  "Montserrat",
  "Lobster",
  "Pacifico",
  "Spectral SC",
  "Dancing Script",
  "Oswald",
  "Bangers",
  "Turret Road",
  "Anton"
];

Container fontShowcase(String value) {
  return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(15),
      child: Text(value));
}

class Tuple2<T1, T2> {
  final T1 action;
  final T2 property;

  Tuple2(this.action, this.property);
}
