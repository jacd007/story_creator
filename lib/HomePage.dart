import 'package:f_widget_to_image/story_creation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WidgetsToImageController controller = WidgetsToImageController();
  // to save image bytes of widget
  Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (_) => StoryCreation(
                /* onCompleted: (file) {
                // here code
              }, */
                ),
          ),
        )
            .then((value) {
          if (value != null)
            setState(() {
              bytes = value;
            });
        }),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          const Divider(),
          if (bytes != null)
            Container(
              color: Colors.black12,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height,
                maxWidth: MediaQuery.of(context).size.width,
              ),
              child: Image.memory(bytes!),
            ),
        ],
      ),
    );
  }
}
