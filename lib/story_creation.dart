// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'dart:math';

import 'package:f_widget_to_image/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class StoryCreation extends StatefulWidget {
  const StoryCreation({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StoryCreationState createState() => _StoryCreationState();
}

class _StoryCreationState extends State<StoryCreation> {
  // created
  WidgetsToImageController controller = WidgetsToImageController();
  // to save image bytes of widget
  Uint8List? bytes;

  // edit
  EditableItem? _activeItem;
  List<EditableItem> listEditableItem = [];

  // colors
  Color? colorBackground;

  final TextEditingController ctrText = TextEditingController();

  Offset _initPos = const Offset(0.0, 0.0),
      _currentPos = const Offset(0.0, 0.0);

  double _currentScale = 1.0, _currentRotation = 0.0;

  bool _inAction = false, showDelete = false;

  @override
  void initState() {
    super.initState();
    //listEditableItem = mockData;
  }

  @override
  void dispose() {
    super.dispose();
    ctrText.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final rn = Random();
              final pos = rn.nextInt(colorsList.length);
              setState(() {
                colorBackground = colorsList[pos];
              });
            },
            icon: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(0.25),
              child: Icon(
                Icons.circle,
                color: colorBackground,
              ),
            ),
          ),
          IconButton(
            onPressed: funAddText,
            icon: const Icon(Icons.text_fields),
          ),
          IconButton(
            onPressed: funOpenGalery,
            icon: const Icon(Icons.image),
          ),
        ],
      ),
      body: GestureDetector(
        onLongPressMoveUpdate: (_) {
          setState(() {
            showDelete = false;
          });
        },
        onScaleStart: (details) {
          if (_activeItem == null) return;

          _initPos = details.focalPoint;
          _currentPos = _activeItem!.position;
          _currentScale = _activeItem!.scale;
          _currentRotation = _activeItem!.rotation;
        },
        onScaleUpdate: (details) {
          if (_activeItem == null) return;
          final delta = details.focalPoint - _initPos;
          final left = (delta.dx / screen.width) + _currentPos.dx;
          final top = (delta.dy / screen.height) + _currentPos.dy;

          setState(() {
            _activeItem!.position = Offset(left, top);
            _activeItem!.rotation = details.rotation + _currentRotation;
            _activeItem!.scale =
                max(min(details.scale * _currentScale, 3), 0.2);
          });
        },
        child: Stack(
          children: [
            WidgetsToImage(
              controller: controller,
              child: Container(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
                    children: listEditableItem.map(_buildItemWidget).toList(),
                  ),
                ),
              ),
            ),
            /*  // to Eliminate
            if (_inAction)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.delete_forever),
                ),
              ), */
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () async {
                bytes = await controller.capture();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(bytes);
              },
              icon: const Icon(Icons.save),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItemWidget(EditableItem e) {
    final screen = MediaQuery.of(context).size;

    Widget widget = const SizedBox();
    if (e.type == 0) {
      switch (e.typeValue) {
        case 'assets':
          widget = Image.asset(e.value);
          break;
        case 'file':
          widget = Image.file(
            File(e.value),
            width: e.width,
            height: e.width,
          );
          break;
        case 'network':
          widget = Image.network(e.value);
          break;
        default:
      }
    }
    if (e.type == 1) {
      widget = Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          e.value,
          style: const TextStyle(color: Colors.black),
        ),
      );
    }

    return Positioned(
      top: e.position.dy * screen.height,
      left: e.position.dx * screen.width,
      child: Transform.scale(
        scale: e.scale,
        child: Transform.rotate(
          angle: e.rotation,
          child: Listener(
            onPointerDown: (details) {
              if (_inAction) return;
              _inAction = true;
              _activeItem = e;
              _initPos = details.position;
              _currentPos = e.position;
              _currentScale = e.scale;
              _currentRotation = e.rotation;
            },
            onPointerUp: (details) {
              _inAction = false;
            },
            child: widget,
          ),
        ),
      ),
    );
  }

  void funOpenGalery() async {
    // ignore: no_leading_underscores_for_local_identifiers
    final _size = MediaQuery.of(context).size;
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    File file = File(result.files.single.path!);
    const pos = Offset(0.0, 0.0);
    double w = _size.width;
    double h = _size.height;

    if (listEditableItem.isNotEmpty) {
      listEditableItem[0] = EditableItem()
        ..type = 0
        ..typeValue = 'file'
        ..scale = 0.8
        ..position = pos
        ..width = w
        ..height = h
        ..value = file.path;
    } else {
      listEditableItem.add(
        EditableItem()
          ..type = 0
          ..typeValue = 'file'
          ..scale = 0.8
          ..position = pos
          ..width = w
          ..height = h
          ..value = file.path,
      );
    }

    setState(() {
      _initPos = const Offset(0.1, 0.1);
      _currentPos = const Offset(0.1, 0.1);
    });
  }

  funAddText({bool clear = true}) {
    //final _size = MediaQuery.of(context).size;
    if (clear) ctrText.clear();

    showDialog(
        context: context,
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.black38,
            appBar: AppBar(
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.color_lens),
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: ctrText,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    listEditableItem.add(
                      EditableItem()
                        ..type = 1
                        ..typeValue = 'text'
                        ..scale = 1.0
                        ..position = const Offset(0.1, 0.1)
                        ..value = ctrText.text,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          );
        });
  }
}

//enum ItemType { Image, Text }

class EditableItem {
  Offset position = const Offset(0.1, 0.1);
  double scale = 1.0;
  double rotation = 0.0;
  double width = 100;
  double height = 100;
  String typeValue = 'assets';
  // ItemType type = ItemType.Image;
  int type = 0;
  String value = '';
}

final mockData = [
  EditableItem()
    ..type = 0 //ItemType.Image
    ..value = 'assets/icons/cancel.png',
  EditableItem()
    ..type = 1 //ItemType.Text
    ..value = 'Hello',
  EditableItem()
    ..type = 1 //ItemType.Text
    ..value = 'World',
];
