// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import '../story/story_creation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final loading = StreamController<int>.broadcast();
  // to save image bytes of widget
  Uint8List? bytes;
  File? filed;
  bool bloc = false;
  Color? colorDown;

  // ignore: unused_field
  final _myBox = Hive.openBox('MyBox');

  @override
  void dispose() {
    loading.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 19, 24),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),
            if (bytes == null)
              const Center(
                child: Text(
                  'Not found file!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontFamily: 'bold',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (bytes != null)
              GestureDetector(
                onLongPress: funDownLoadAlter,
                child: Container(
                  color: Colors.black12,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height,
                    maxWidth: MediaQuery.of(context).size.width,
                  ),
                  child: Image.memory(bytes!),
                ),
              ),
            const Divider(),
            //const PollWidget(),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            /* if (filed != null)
              FloatingActionButton(
                backgroundColor: Colors.green,
                child: const Icon(Icons.share),
                onPressed: () async {
                  await Share.share('here ${filed?.path}', subject: 'View');
                },
              ), */
            const SizedBox(width: 20),
            if (bytes != null)
              FloatingActionButton(
                onPressed: funDownLoad,
                backgroundColor: Colors.redAccent,
                child: StreamBuilder<int>(
                    stream: loading.stream,
                    initialData: 0,
                    builder: (context, snap) {
                      if (snap.data == -1) {
                        return const CircularProgressIndicator();
                      }

                      return Icon(
                        Icons.download,
                        color: colorDown,
                      );
                    }),
              ),
            const SizedBox(width: 20),
            FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (_) => const StoryCreation(),
                ),
              )
                  .then((value) {
                if (value != null) {
                  setState(() => bytes = value);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  funDownLoad() async {
    //final status = await Permission.manageExternalStorage.request();

    if (bloc) return;
    bool check = false;

    loading.add(-1);
    setState(() => bloc = true);
    await Future.delayed(const Duration(seconds: 2));
    // /*if (status.isGranted){
    try {
      final file = await createFileFromUint8List(bytes!, 'png');
      filed = file;
      debugPrint('COMPLETED $file');
      check = true;
    } on Exception catch (e) {
      debugPrint('$e');
    }
    //}*/

    setState(() => bloc = false);
    loading.add(0);
    setState(() => colorDown = check ? Colors.green : Colors.black);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => colorDown = null);
  }

  static Future<File> createFileFromUint8List(Uint8List bytes, String ext,
      [String auxName = '']) async {
    final dir2 = await getApplicationDocumentsDirectory();
    Directory dir1 = await DownloadsPathProvider.downloadsDirectory ?? dir2;
    final epoch = DateTime.now().millisecondsSinceEpoch.toString();
    File file = File("${dir1.path}/$auxName$epoch.$ext");
    File f = await file.writeAsBytes(bytes);
    return f;
  }

  funDownLoadAlter() async {
    if (bloc) return;
    bool check = false;

    loading.add(-1);
    setState(() => bloc = true);
    await Future.delayed(const Duration(seconds: 2));

    try {
      final dir1 = await getApplicationDocumentsDirectory();
      final epoch = DateTime.now().millisecondsSinceEpoch.toString();
      File file = File("${dir1.path}/$epoch.png");
      File f = await file.writeAsBytes(bytes!);
      filed = f;
      debugPrint('COMPLETED $f');
      check = true;
    } on Exception catch (e) {
      debugPrint('$e');
    }

    setState(() => bloc = false);
    loading.add(0);
    setState(() => colorDown = check ? Colors.green : Colors.black);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => colorDown = null);
  }
}
