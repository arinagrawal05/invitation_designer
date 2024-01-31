import 'dart:async';
import 'dart:convert';
import 'package:card_render/text_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'detailpage.dart';

String backgroundUrl =
    "https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvdjEwNjQtMzYta3ZjNHNieHcuanBn.jpg";
EdgeInsets canvasMargin =
    const EdgeInsets.symmetric(vertical: 30, horizontal: 20);
double canvasHeight = 300;
double canvasWidth = double.infinity;

List<String> convertTextPropertiesListToStringList(
    List<TextProperties> textPropertiesList) {
  List<String> stringList = [];

  for (TextProperties textProperties in textPropertiesList) {
    Map<String, dynamic> jsonMap = {
      'text': textProperties.text,
      'fontSize': textProperties.fontSize,
      'color': textProperties.color,
      'fontfamily': textProperties.fontfamily,
      'position': {
        'dx': textProperties.position.dx,
        'dy': textProperties.position.dy,
      },
    };

    // Convert the map to a JSON string
    String jsonString = jsonEncode(jsonMap);
    stringList.add(jsonString);
  }

  return stringList;
}

Map<String, dynamic> jsonStringToMap(String jsonString) {
  try {
    return json.decode(jsonString);
  } catch (e) {
    // You can handle the error or return a default value as needed
    return {};
  }
}

List<TextProperties> convertDynamicListToTextPropertiesList(
    List<dynamic> dynamicList) {
  List<TextProperties> textPropertiesList = [];
  // List<Map<String, dynamic>> newl = dynamicList as List<Map<String, dynamic>>;
  for (int i = 0; i < dynamicList.length; i++) {
    dynamic item = jsonStringToMap(dynamicList[i]);

    if (
        // true
        item is Map<String, dynamic> &&
            item.containsKey('text') &&
            item.containsKey('fontSize') &&
            item.containsKey('fontfamily') &&
            item.containsKey('position') &&
            item['position'] is Map<String, dynamic> &&
            item['position'].containsKey('dx') &&
            item['position'].containsKey('dy')) {
      String text = item['text'] is String ? item['text'] : "Default Text";
      double fontSize = item['fontSize'] is double ? item['fontSize'] : 12.0;
      String fontcolor = item['color'] is String ? item['color'] : 12.0;
      String fontfamily =
          item['fontfamily'] is String ? item['fontfamily'] : "Roboto";
      double dx =
          item['position']['dx'] is double ? item['position']['dx'] : 0.0;
      double dy =
          item['position']['dy'] is double ? item['position']['dy'] : 0.0;

      textPropertiesList.add(TextProperties(
        text: text,
        fontSize: fontSize,
        color: fontcolor,
        fontfamily: fontfamily,
        position: Offset(dx, dy),
      ));
    } else {
      // Handle invalid data structure in dynamicList
    }
  }

  return textPropertiesList;
}

TextProperties convertJsonToTextProperties(Map<String, dynamic> json) {
  String text = json['text'] is String ? json['text'] : "Default Text";
  double fontSize =
      (json['fontSize'] is num) ? json['fontSize'].toDouble() : 12.0;
  String color = json['color'] is String ? json['color'] : "FFFFFF";
  String fontfamily =
      json['fontfamily'] is String ? json['fontfamily'] : "Roboto";
  double dx = (json['position']?['dx'] is num)
      ? json['position']['dx'].toDouble()
      : 0.0;
  double dy = (json['position']?['dy'] is num)
      ? json['position']['dy'].toDouble()
      : 0.0;

  return TextProperties(
    text: text,
    fontSize: fontSize,
    color: color,
    fontfamily: fontfamily,
    position: Offset(dx, dy),
  );
}

List<dynamic> dynamicList = [
  {
    'text': 'Hello',
    'fontSize': 18.0,
    'color': 'ff0000',
    'fontfamily': 'Arial',
    'position': {'dx': 20.0, 'dy': 30.0},
  },
  // {
  //   'text': 'Celebrare',
  //   'fontSize': 34.0,
  //   'color': '00ff00',
  //   'fontfamily': 'Helvetica',
  //   'position': {'dx': 10.0, 'dy': 80.0},
  // },
];

Widget customText(TextProperties properties) {
  return Text(
    properties.text,
    style: GoogleFonts.getFont(properties.fontfamily).copyWith(
        color: Color(int.parse("0x${properties.color}")),
        fontSize: properties.fontSize),
  );
}

bool isTapInsideItem(Offset tapPosition, TextProperties item) {
  double textWidth = getWidthOfText(item);
  double textHeight = getHeightOfText(item);

  double left = item.position.dx;
  double top = item.position.dy;
  double right = left + textWidth * 2;
  double bottom = top + textHeight * 2; // Adjusted to include text height

  return tapPosition.dx >= left &&
      tapPosition.dx <= right &&
      tapPosition.dy >= top &&
      tapPosition.dy <= bottom;
}

double getWidthOfText(TextProperties item) {
  final textStyle = TextStyle(
    fontSize: item.fontSize,
    fontFamily: item.fontfamily,
  );

  final textSpan = TextSpan(text: item.text, style: textStyle);
  final textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();

  return textPainter.width;
}

double getHeightOfText(TextProperties item) {
  final textStyle = TextStyle(
    fontSize: item.fontSize,
    fontFamily: item.fontfamily,
  );

  final textSpan = TextSpan(text: item.text, style: textStyle);
  final textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();

  return textPainter.height;
}

Future<Tuple2<String, String>> textFormatDialog(
    BuildContext context, TextProperties properties,
    {bool isNew = false}) async {
  Completer<String> actioncompleter = Completer<String>();

  Completer<String> inputCompleter = Completer<String>();

  TextEditingController controller =
      TextEditingController(text: properties.text);

  String selectedFontFamily = properties.fontfamily;
  Color selectedColor = Color(int.parse("0x${properties.color}"));
  double selectedFontSize = properties.fontSize;
  Offset currentPosition = properties.position;

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        // title: const Text('Edit Font Properties'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'Enter Text'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                            value: selectedFontSize,
                            min: 14,
                            max: 74,
                            activeColor: Colors.black,
                            inactiveColor: Colors.black.withOpacity(0.4),
                            onChanged: (input) {
                              setState(() {
                                selectedFontSize = input;
                              });
                            }),
                      ),
                      fontShowcase(selectedFontSize.toInt().toString())
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DropdownButton<String>(
                          value: selectedFontFamily,
                          onChanged: (String? value) {
                            setState(() {
                              selectedFontFamily = value!;
                            });
                          },
                          items: fontFamilyList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          hint: const Text('Font Family'),
                        ),
                      ],
                    ),
                  ),
                  ColorPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    pickerAreaHeightPercent: 0.8,
                  ),
                ],
              ),
            );
          },
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        // actionsPadding: const EdgeInsets.all(30),
        actions: isNew
            ? <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        child: const Text('Add This Text'),
                        onPressed: () {
                          actioncompleter.complete("add");
                          inputCompleter.complete('{'
                              '"text": "${controller.text}",'
                              '"fontSize": $selectedFontSize,'
                              '"color": "${colorToHex(selectedColor)}",'
                              '"fontfamily": "$selectedFontFamily",'
                              '"position": {'
                              '"dx": 0.5,'
                              '"dy": 0.1'
                              '}'
                              '}');

                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                )
              ]
            : <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                        onPressed: () {
                          actioncompleter.complete("delete");
                          inputCompleter.complete('{'
                              '"text": "${controller.text}",'
                              '"fontSize": $selectedFontSize,'
                              '"color": "${colorToHex(selectedColor)}",'
                              '"fontfamily": "$selectedFontFamily"'
                              '"position": {'
                              '"dx": "${currentPosition.dx}",'
                              ' "dy": ${currentPosition.dy}"'
                              '}'
                              '}');
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        child: const Text('Apply Changes'),
                        onPressed: () {
                          actioncompleter.complete("edit");
                          inputCompleter.complete('{'
                              '"text": "${controller.text}",'
                              '"fontSize": $selectedFontSize,'
                              '"color": "${colorToHex(selectedColor)}",'
                              '"fontfamily": "$selectedFontFamily",'
                              '"position": {'
                              '"dx": "${currentPosition.dx}",'
                              ' "dy": "${currentPosition.dy}"'
                              '}'
                              '}');
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                )
              ],
      );
    },
  );
  return Tuple2<String, String>(
    await actioncompleter.future,
    await inputCompleter.future,
  );
  // return actioncompleter.future;
}
