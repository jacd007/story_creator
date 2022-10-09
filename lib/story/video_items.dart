// ignore: import_of_legacy_library_into_null_safe
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:video_player/video_player.dart';

class VideoItems extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool looping, autoplay, muteVolume;
  final double? aspectRatio;
  final EdgeInsetsGeometry? padding;

  const VideoItems({
    super.key,
    required this.videoPlayerController,
    this.looping = true,
    this.autoplay = true,
    this.muteVolume = true,
    this.aspectRatio,
    this.padding,
  });

  @override
  // ignore: library_private_types_in_public_api
  _VideoItemsState createState() => _VideoItemsState();
}

class _VideoItemsState extends State<VideoItems> {
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    widget.videoPlayerController.setVolume(widget.muteVolume ? 0.0 : 1.0);
    final aspectRatio = widget.videoPlayerController.value.aspectRatio;

    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: widget.aspectRatio ?? aspectRatio,
      autoInitialize: true,
      autoPlay: widget.autoplay,
      looping: widget.looping,
      showOptions: false,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.grey, fontFamily: 'bold'),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(8.0),
      child: Chewie(
        controller: _chewieController,
      ),
    );
  }
}
