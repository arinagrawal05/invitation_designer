import 'dart:io';
import 'dart:typed_data';

import 'package:card_render/card_model.dart';
import 'package:card_render/text_model.dart';
import 'package:card_render/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:uuid/uuid.dart';
import 'consts.dart';
// import 'homepage.dart';

class DetailPage extends StatefulWidget {
  final double aspectRatio;
  final String userid;
  final CardModel? model;

  const DetailPage(
      {super.key,
      required this.model,
      required this.aspectRatio,
      required this.userid});

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
  ScreenshotController screenshotController = ScreenshotController();

  List<TextProperties> undoStack = [];
  List<TextProperties> redoStack = [];
  // bool showGuidedLines = false;
  // Offset guidedLinesPosition = Offset.zero;
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

  void resetSelectionExcept(TextProperties selected) {
    for (var item in stackData) {
      if (item != selected) {
        item.resetSelection();
      }
    }
  }

  void resetAllSelection() {
    setState(() {
      for (var item in stackData) {
        item.resetSelection();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show alert dialog when back button is pressed
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Discard Changes?"),
              content: Text("Are you sure you want to exit?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Dismiss the dialog and don't exit
                  },
                  child: Text("Discard"),
                ),
                TextButton(
                  onPressed: () {
                    stringList =
                        convertTextPropertiesListToStringList(stackData);
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
                        "card_ratio": widget.aspectRatio,
                        "userid": widget.userid,
                        "bg_color": "FFFFFF",
                        "card_id": id,
                        "image_url": backgroundUrl,
                        "text_json_list": stringList,
                      }).then((value) {
                        Navigator.pop(context);
                      }).catchError((error) {});
                    }
                    Navigator.of(context).pop(true);
                    Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
      child: Scaffold(
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
                    position: const Offset(0.3, 0.5),
                    isSelected: false),
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
        appBar: AppBar(
          elevation: 0,
          actions: [
            appbarButton(
                child: Icon(
                  Icons.save,
                  color: Colors.white,
                  size: 20,
                ),
                onTap: () {
                  stringList = convertTextPropertiesListToStringList(stackData);
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
                    FirebaseFirestore.instance.collection("Cards").doc(id).set({
                      "card_ratio": widget.aspectRatio,
                      "userid": widget.userid,
                      "bg_color": "FFFFFF",
                      "card_id": id,
                      "image_url": backgroundUrl,
                      "text_json_list": stringList,
                    }).then((value) {
                      Navigator.pop(context);
                    }).catchError((error) {});
                  }
                }),
            SizedBox(
              width: 5,
            ),
            appbarButton(
                child: Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onTap: () async {
                  FirebaseFirestore.instance
                      .collection("Cards")
                      .doc(widget.model!.id)
                      .delete()
                      .then((value) {
                    Navigator.pop(context);
                  }).catchError((error) {});
                },
                color: Colors.red.shade600),
            SizedBox(
              width: 5,
            ),
            appbarButton(
                child: Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 20,
                ),
                onTap: () async {
                  resetAllSelection();
                  AppUtils.saveImage(screenshotController);
                }),
            SizedBox(
              width: 5,
            ),
            appbarButton(
                child: Text(
                  "Share",
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500, color: Colors.white),
                ),
                onTap: () async {
                  resetAllSelection();
                  AppUtils.shareImage(screenshotController);
                }),
            SizedBox(
              width: 5,
            ),
          ],
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
                      SizedBox(
                        height: 12,
                      ),
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

  ClipRRect appbarButton(
      {Widget? child, void Function()? onTap, Color color = Colors.blue}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: color),
          child: child,
        ),
      ),
    );
  }

  Offset calculateGuidedLines(
      List<TextProperties> items, TextProperties activeItem) {
    double minDistance = double.infinity;
    Offset closestPosition = activeItem.position;

    for (TextProperties item in items) {
      if (item == activeItem) continue;

      double distanceX = (item.position.dx * canvasWidth) -
          (activeItem.position.dx * canvasWidth);
      double distanceY = (item.position.dy * canvasHeight) -
          (activeItem.position.dy * canvasHeight);

      if (distanceX.abs() < minDistance) {
        minDistance = distanceX.abs();
        closestPosition = Offset(item.position.dx, activeItem.position.dy);
      }

      if (distanceY.abs() < minDistance) {
        minDistance = distanceY.abs();
        closestPosition = Offset(activeItem.position.dx, item.position.dy);
      }
    }

    return closestPosition;
  }

  GestureDetector canvasBoard() {
    return GestureDetector(
      onScaleStart: (details) {
        if (activeItem == null) return;
        initPosition = details.focalPoint;
        currentPosition = activeItem!.position;
        // setState(() {
        //   activeItem!.isSelected = true;
        // });
      },
      // onScaleEnd: (details) {
      //   setState(() {
      //     showGuidedLines = false;
      //   });
      // },
      onScaleUpdate: (details) {
        if (activeItem == null) return;
        final delta = details.focalPoint - initPosition;
        final left = (delta.dx) + currentPosition.dx;
        final top = (delta.dy) + currentPosition.dy;

        activeItem!.position = Offset(left, top);
        // Offset guidedLinesPosition =
        //     calculateGuidedLines(stackData, activeItem!);
        // setState(() {
        //   activeItem!.position = Offset(left, top);
        //   showGuidedLines = true;
        //   this.guidedLinesPosition = guidedLinesPosition;
        // });
      },
      onTapUp: (details) async {
        // Check if tapped on an existing item
        // for (TextProperties item in stackData) {
        //   if (isTapInsideItem(details.localPosition, item)) {
        //     Tuple2<String, String> result =
        //         await textFormatDialog(context, item);
        //     if (result.action == "delete") {
        //       setState(() {
        //         stackData.remove(item);
        //       });
        //     } else if (result.action == "edit") {
        //       setState(() {
        //         stackData.remove(item);
        //         stackData.add(convertJsonToTextProperties(
        //             jsonStringToMap(result.property)));
        //       });
        //     }
        //     break;
        //   }
        // }
      },
      child: Container(
        // margin: canvasMargin,
        // height: canvasHeight,
        // width: canvasWidth,
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(10),
        //   image:
        //       //  imageBytes != null
        //       //     ?
        //       DecorationImage(
        //           image: NetworkImage(backgroundUrl), fit: BoxFit.cover),
        //   color: Colors.grey.shade300,
        // ),
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Stack(
            children: [
              // if (showGuidedLines) ...[
              //   // Horizontal guided line
              //   Positioned(
              //     left: 0,
              //     top: guidedLinesPosition.dy,
              //     right: 0,
              //     height: 1,
              //     child: Container(
              //       color: Colors.blue,
              //     ),
              //   ),

              //   // Vertical guided line
              //   Positioned(
              //     top: 0,
              //     left: guidedLinesPosition.dx,
              //     bottom: 0,
              //     width: 1,
              //     child: Container(
              //       color: Colors.blue,
              //     ),
              //   ),
              // ],

              Screenshot(
                controller: screenshotController,
                child: Container(
                  margin: canvasMargin,
                  // height: canvasHeight,
                  width: canvasWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image:
                        //  imageBytes != null
                        //     ?
                        DecorationImage(
                            image: NetworkImage(backgroundUrl),
                            fit: BoxFit.cover),
                    color: Colors.grey.shade300,
                  ),
                  child: Stack(
                    children: [
                      ...stackData.map(buildItemWidget).toList(),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 40,
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
            ],
          ),
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
          resetSelectionExcept(e);
          e.isSelected = true;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DottedBorder(
                color: e.isSelected ? Colors.grey.shade400 : Colors.transparent,
                // Border color
                strokeWidth: 1.5,
                strokeCap: StrokeCap.round,
                padding: EdgeInsets.only(
                  right: 10,
                  left: 10,
                ),
                dashPattern: [4, 3],
                borderType: BorderType.RRect,
                radius: Radius.circular(6),
                child: customText(e)),
            if (e.isSelected) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  optionButton(
                      icon: Icons.edit,
                      onPressed: () async {
                        // for (TextProperties item in stackData) {
                        // if (isTapInsideItem(details.localPosition, item)) {
                        Tuple2<String, String> result =
                            await textFormatDialog(context, e);
                        if (result.action == "delete") {
                          setState(() {
                            stackData.remove(e);
                          });
                        } else if (result.action == "edit") {
                          setState(() {
                            stackData.remove(e);
                            stackData.add(convertJsonToTextProperties(
                                jsonStringToMap(result.property)));
                          });
                        }
                        // break;
                        // }
                        // }
                      }),
                  optionButton(
                      icon: Icons.copy,
                      onPressed: () async {
                        duplicateItem(e);
                      }),
                  optionButton(
                      icon: Icons.delete_outline,
                      onPressed: () async {
                        setState(() {
                          stackData.remove(e);
                        });
                      }),
                ],
              )
            ]
            // : Container()
          ],
        ),
      ),
    );
  }

  IconButton optionButton({void Function()? onPressed, IconData? icon}) {
    return IconButton(onPressed: onPressed, icon: Icon(icon));
  }

  void duplicateItem(TextProperties original) {
    setState(() {
      // Create a new instance with the same properties as the original item
      TextProperties duplicatedItem = TextProperties(
        text: original.text,
        color: original.color,
        fontSize: original.fontSize,
        fontfamily: original.fontfamily,
        position: Offset(original.position.dx + 10,
            original.position.dy + 10), // Adjust the position
        isSelected: false, // Set isSelected to false for the duplicated item
      );

      // Add the duplicated item to the stackData
      stackData.add(duplicatedItem);
    });
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
