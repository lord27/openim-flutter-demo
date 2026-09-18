import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatVideoView extends StatelessWidget {
  const ChatVideoView({super.key, required this.message});
  final Message message;

  String get _durationStr {
    final seconds = message.videoElem?.duration ?? 0;
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = message.videoElem?.snapshotUrl ?? '';
    final boxWidth = 200.w;
    final boxHeight = 130.w;
    return Container(
      width: boxWidth,
      height: boxHeight,
      color: const Color(0xFF1B1B1B),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (snapshot.isNotEmpty)
            Image.network(
              snapshot,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.expand(),
            ),
          const Center(
            child: Icon(Icons.play_circle_fill, size: 44, color: Colors.white70),
          ),
          Positioned(
            right: 6.w,
            bottom: 6.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: Text(
                _durationStr,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
