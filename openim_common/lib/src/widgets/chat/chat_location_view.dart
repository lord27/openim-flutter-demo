import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

/// 位置消息气泡（contentType 109 locationElem）
class ChatLocationView extends StatelessWidget {
  const ChatLocationView({
    Key? key,
    required this.isISend,
    required this.message,
    this.onTapView,
  }) : super(key: key);
  final bool isISend;
  final Message message;
  final Function()? onTapView;

  @override
  Widget build(BuildContext context) {
    final elem = message.locationElem;
    final description =
        (elem?.description?.isNotEmpty ?? false) ? elem!.description! : StrRes.toolboxLocation;
    final lat = elem?.latitude ?? 0;
    final lng = elem?.longitude ?? 0;
    return GestureDetector(
      onTap: onTapView,
      child: Container(
        width: 220.w,
        decoration: BoxDecoration(
          color: Styles.c_surface,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Styles.c_0089FF, size: 20.w),
                  6.horizontalSpace,
                  Expanded(
                    child: Text(
                      description,
                      style: Styles.ts_0C1C33_14sp,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 60.w,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Styles.c_F0F2F6,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(6.r),
                  bottomRight: Radius.circular(6.r),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                children: [
                  Icon(Icons.map_outlined, color: Styles.c_8E9AB0, size: 16.w),
                  6.horizontalSpace,
                  Expanded(
                    child: Text(
                      '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
                      style: Styles.ts_8E9AB0_12sp,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Styles.c_8E9AB0, size: 16.w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
