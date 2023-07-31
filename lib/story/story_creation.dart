import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../common/editable_item_model.dart';
import '../common/constants.dart';
import '../story/video_items.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:text_editor/text_editor.dart';
import 'package:video_player/video_player.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class StoryCreation extends StatefulWidget {
  final List<EditableItem>? listEditableItem;
  const StoryCreation({this.listEditableItem, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StoryCreationState createState() => _StoryCreationState();
}

class _StoryCreationState extends State<StoryCreation> {
  final _myBox = Hive.box('MyBox');

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

  bool _inAction = false, showDelete = false, _hasFile = false;

  VideoPlayerController? playerController;

  final fonts = [
    'OpenSans',
    'Billabong',
    'GrandHotel',
    'Oswald',
    'Quicksand',
    'BeautifulPeople',
    'BeautyMountains',
    'BiteChocolate',
    'BlackberryJam',
    'BunchBlossoms',
    'CinderellaRegular',
    'Countryside',
    'Halimun',
    'LemonJelly',
    'QuiteMagicalRegular',
    'Tomatoes',
    'TropicalAsianDemoRegular',
    'VeganStyle',
  ];

  @override
  void initState() {
    super.initState();
    //listEditableItem = mockData;
    listEditableItem = widget.listEditableItem ?? [];
    getData();
  }

  getData() {
    final color = _myBox.get(TableRowBox.colorBG.name);
    final List? list = _myBox.get(TableRowBox.eraser.name);

    if (list != null) {
      setState(() {
        listEditableItem = list.map((e) => EditableItem.fromJson(e)).toList();
      });
    }
    if (color != null) {
      setState(() {
        colorBackground = Color(color);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    ctrText.dispose();
    playerController?.pause();
    playerController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    /* SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]); */

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: decoration(),
                    child: Stack(
                      children: [
                        for (int i = 0; i < listEditableItem.length; i++)
                          _buildItemWidget(listEditableItem[i], i),
                      ],
                      //children: listEditableItem.map(_buildItemWidget).toList(),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 25,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    _button(
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _button(
                          child: CircleAvatar(
                            backgroundColor: Colors.black38,
                            child: Icon(
                              Icons.circle,
                              color: colorBackground,
                              size: 30,
                            ),
                          ),
                          onPressed: funChangeColorBg,
                        ),
                        const SizedBox(width: 10),
                        _button(
                          child: const Icon(
                            Icons.text_fields,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: funAddText,
                        ),
                      ],
                    ),
                  ],
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
        bottomNavigationBar: Container(
          height: 60,
          padding: const EdgeInsets.all(20.0).copyWith(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _hasFile ? funDeleteFile : funOpenGallery,
                icon: Icon(
                  _hasFile ? Icons.delete : Icons.image,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              MaterialButton(
                onPressed: () {
                  final list = listEditableItem.map((e) {
                    return e.toJson(e);
                  }).toList();
                  _myBox.put(TableRowBox.eraser.name, list);
                  _myBox.put(TableRowBox.colorBG.name, colorBackground?.value);
                  debugPrint('SAVED $list ${colorBackground?.value}');
                },
                child: const Icon(
                  Icons.open_in_browser_rounded,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () async {
                  bytes = await controller.capture();
                  _myBox.delete(TableRowBox.eraser.name);
                  _myBox.delete(TableRowBox.colorBG.name);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(bytes);
                },
                icon: const Icon(
                  Icons.save,
                  color: Colors.white,
                  size: 35,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemWidget(EditableItem e, [int? pos]) {
    final screen = MediaQuery.of(context).size;

    Widget widget = const SizedBox();
    if (e.type == 0) {
      switch (e.typeValue) {
        case ItemType.assets:
          widget = Image.asset(e.value);
          break;
        case ItemType.file:
          debugPrint(e.value);
          if (e.value.split(".").last.endsWith('mp4')) {
            playerController = VideoPlayerController.file(File(e.value));
            widget = VideoItems(
              videoPlayerController: playerController!,
            );
            break;
          }
          widget = Image.file(
            File(e.value),
            width: e.width,
            height: e.width,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'error',
              width: e.width,
              height: e.width,
            ),
          );

          break;
        case ItemType.network:
          widget = Image.network(e.value);
          break;
        default:
      }
    }
    if (e.type == 1) {
      var meta = e.metaData!;
      final st = (meta['style'] as TextStyle);
      final al = (meta['align'] as TextAlign);

      widget = GestureDetector(
        onTap: () {
          funAddText(
              strText: e.value,
              textStyle: st,
              position: pos,
              offset: e.position);
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          /* decoration: BoxDecoration(
            color: st.color?.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ), */
          child: Text(
            e.value,
            style: st,
            textAlign: al,
          ),
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

  void funChangeColorBg() {
    final rn = Random();
    final pos = rn.nextInt(colorsList.length);
    setState(() {
      colorBackground = colorsList[pos];
    });
  }

  void funDeleteFile() {
    listEditableItem.removeAt(0);
    setState(() => _hasFile = false);
    return;
  }

  void funOpenGallery() async {
    // ignore: no_leading_underscores_for_local_identifiers
    final _size = MediaQuery.of(context).size;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result == null) return;

    File file = File(result.files.single.path!);
    const pos = Offset(0.0, 0.0);
    double w = _size.width;
    double h = _size.height;

    if (listEditableItem.isNotEmpty) {
      var edit = EditableItem()
        ..type = 0
        ..typeValue = ItemType.file
        ..scale = 0.8
        ..position = pos
        ..width = w
        ..height = h
        ..value = file.path;
      listEditableItem[0] = edit;
      //listEditableItem.insert(0, edit);
    } else {
      listEditableItem.add(
        EditableItem()
          ..type = 0
          ..typeValue = ItemType.file
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
      _hasFile = true;
    });
  }

  funAddText(
      {String strText = '',
      TextStyle? textStyle,
      int? position,
      Offset? offset}) {
    showDialog(
      context: context,
      builder: (_) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black38,
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextEditor(
              fonts: fonts,
              paletteColors: colorsList,
              text: strText,
              textStyle: textStyle ?? const TextStyle(color: Colors.white),
              textAlingment: TextAlign.center,
              onEditCompleted: (style, align, text) {
                if (position != null) {
                  listEditableItem[position] = EditableItem()
                    ..type = 1
                    ..typeValue = ItemType.text
                    ..scale = 1.0
                    ..position = offset ?? const Offset(0.1, 0.1)
                    ..value = text
                    ..metaData = {
                      "style": style,
                      "align": align,
                      "color": style.color!.value,
                      "colorBG": style.backgroundColor!.value,
                      "family": style.fontFamily,
                      "sizeText": style.fontSize ?? 20.0,
                    };
                } else {
                  listEditableItem.add(
                    EditableItem()
                      ..type = 1
                      ..typeValue = ItemType.text
                      ..scale = 1.0
                      ..position = const Offset(0.1, 0.1)
                      ..value = text
                      ..metaData = {
                        "style": style,
                        "align": align,
                        "color": style.color!.value,
                        "colorBG": style.backgroundColor!.value,
                        "family": style.fontFamily,
                        "sizeText": style.fontSize ?? 20.0,
                      },
                  );
                }

                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
    );
  }

  decoration() => BoxDecoration(
        color: colorBackground,
        gradient: LinearGradient(
          colors: colorBackground == null
              ? [
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.white,
                ]
              : [
                  colorBackground!.withOpacity(0.25),
                  colorBackground!.withOpacity(0.5),
                  colorBackground!.withOpacity(0.75),
                  colorBackground!.withOpacity(1.0),
                  colorBackground!,
                ],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          stops: const [
            0.0,
            0.10,
            0.3,
            0.5,
            0.9,
          ],
        ),
      );

  /* funAddText({bool clear = true}) {
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
  } */
}

Widget _button(
        {required Widget child,
        void Function()? onPressed,
        double size = 35.0}) =>
    Container(
      decoration: BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),
      width: size,
      height: size,
      child: GestureDetector(
        onTap: onPressed,
        child: child,
      ),
    );

Uint8List imageFromBase64String(String base64String) {
  return base64Decode(base64String);
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
