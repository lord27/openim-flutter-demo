import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class ChatCardView extends StatelessWidget {
  const ChatCardView({super.key, required this.message, this.onTap});
  final Message message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = message.cardElem;
    final name = card?.nickname ?? '';
    final faceURL = card?.faceURL ?? '';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200.w,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F6),
          borderRadius: BorderRadius.circular(6.w),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.w),
              child: faceURL.isNotEmpty
                  ? Image.network(
                      faceURL,
                      width: 40.w,
                      height: 40.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallback(name),
                    )
                  : _fallback(name),
            ),
            8.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0C1C33)),
                  ),
                  Text(
                    StrRes.toolboxCard,
                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF8E9AB0)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback(String name) {
    return Container(
      width: 40.w,
      height: 40.w,
      color: const Color(0xFF3370FF),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name.characters.first : '?',
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
      ),
    );
  }
}
