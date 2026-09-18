import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatFileView extends StatelessWidget {
  const ChatFileView({super.key, required this.message});
  final Message message;

  String get _name => message.fileElem?.fileName ?? '未知文件';

  String get _size {
    final size = message.fileElem?.fileSize ?? 0;
    if (size <= 0) return '';
    const units = ['B', 'KB', 'MB', 'GB'];
    var value = size.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    final text = unit == 0 || value >= 100
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '$text ${units[unit]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220.w,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F6),
        borderRadius: BorderRadius.circular(6.w),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFF3370FF),
              borderRadius: BorderRadius.circular(4.w),
            ),
            alignment: Alignment.center,
            child: Text(
              'FILE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          8.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0C1C33)),
                ),
                if (_size.isNotEmpty)
                  Text(
                    _size,
                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF8E9AB0)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
