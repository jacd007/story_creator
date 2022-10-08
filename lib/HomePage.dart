import 'dart:async';
import 'dart:io';

import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:f_widget_to_image/story/poll_widget.dart';
import 'package:f_widget_to_image/story/story_creation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final loading = StreamController<int>.broadcast();
  // to save image bytes of widget
  Uint8List? bytes;
  bool bloc = false;
  Color? colorDown;

  @override
  void dispose() {
    loading.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 19, 24),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
            Container(
              color: Colors.black12,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height,
                maxWidth: MediaQuery.of(context).size.width,
              ),
              child: Image.memory(bytes!),
            ),
          const Divider(),
          //const PollWidget(),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
    );
  }

  funDownLoad() async {
    /* var status = await Permission.storage.status;
    if (status.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      return;
    } */

    // You can can also directly ask the permission about its status.
    /* if (await Permission.location.isRestricted) {
      // The OS restricts access, for example because of parental controls.
      return;
    } */

    if (bloc) return;
    bool _check = false;

    loading.add(-1);
    setState(() => bloc = true);
    await Future.delayed(const Duration(seconds: 2));
    try {
      final date = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      //var appDocDir = await getDownloadsDirectory();
      //var appDocDir = await getExternalStorageDirectory();
      var appDocDir = await DownloadsPathProvider.downloadsDirectory;
      final filePath = "${appDocDir?.absolute ?? ''}/$date.png";
      final file = File(filePath);
      await file.create(recursive: true);
      file.writeAsBytes(bytes!);
      debugPrint('COMPLETED');
      _check = true;
    } on Exception catch (_) {}
    setState(() => bloc = false);
    loading.add(0);
    setState(() => colorDown = _check ? Colors.green : Colors.black);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => colorDown = null);
  }
}
