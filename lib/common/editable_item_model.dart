import 'dart:convert';
import 'dart:io';

import 'package:f_widget_to_image/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class EditableItem {
  Offset position = const Offset(0.1, 0.1);
  double scale = 1.0;
  double rotation = 0.0;
  double width = 100;
  double height = 100;
  //String typeValue = 'assets';
  ItemType typeValue = ItemType.assets;
  int type = 0;
  String value = '';
  Map<String, dynamic>? metaData;

  EditableItem();

  factory EditableItem.fromJson(Map json) {
    EditableItem model = EditableItem()
      ..position =
          Offset(json['position'][0] ?? 0.1, json['position'][1] ?? 0.1)
      ..scale = json['scale'] ?? 1.0
      ..rotation = json['rotation'] ?? 0.0
      ..width = json['width'] ?? 100.0
      ..height = json['height'] ?? 100.0
      ..typeValue = ItemType.values.elementAt(json['typeValue'] ?? 0)
      ..type = json['type'] ?? 0
      ..value = json['value'] ?? ''
      ..metaData = {
        "style": json['metaData']?['style'] ??
            TextStyle(
              color: Color(json['metaData']?['color'] ?? 0),
              backgroundColor: Color(json['metaData']?['colorBG'] ?? 0),
              fontFamily: json['metaData']?['family'] ?? 'Billabong',
              fontSize: json['metaData']?['sizeText'] ?? 20.0,
            ),
        "align": json['metaData']?['align'] ?? TextAlign.center,
        "base64": json['metaData']?['base64'],
      };
    return model;
  }

  Map<String, dynamic> toJson(EditableItem item) {
    final ttt = item.metaData?['style'] ?? const TextStyle();
    return {
      "position": [item.position.dx, item.position.dy],
      "scale": item.scale,
      "rotation": item.rotation,
      "width": item.width,
      "height": item.height,
      "typeValue": item.typeValue.index,
      "type": item.type,
      "value": item.value,
      "metaData": {
        "color": item.metaData?['color'] ?? ttt.color.value,
        "colorBG": item.metaData?['colorBG'] ?? ttt.backgroundColor.value,
        "family": item.metaData?['family'] ?? ttt.fontFamily,
        "sizeText": item.metaData?['sizeText'] ?? ttt.fontSize,
        "base64": /* item.typeValue == ItemType.file
            ? fileToBase64(File(item.value))
            : */
            null,
        //"style": item.metaData?['style'],
        //"align": item.metaData?['align'],
      },
    };
  }
}

String fileToBase64(File fileData) {
  List<int> imageBytes = fileData.readAsBytesSync();
  //print(imageBytes);
  String base64Image = base64Encode(imageBytes);
  return base64Image;
}
