import 'package:flutter/material.dart';

class PollWidget extends StatefulWidget {
  const PollWidget({super.key});

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  final ctrTitle = TextEditingController();

  @override
  void dispose() {
    ctrTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        width: size.width,
        height: size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Column(
          children: [
            Container(
              height: 60,
              width: size.width,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.0),
                  topRight: Radius.circular(14.0),
                ),
              ),
              child: TextField(
                controller: ctrTitle,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Title Poll',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  errorBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
