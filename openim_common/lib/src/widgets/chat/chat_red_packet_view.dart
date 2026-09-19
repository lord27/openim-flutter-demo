import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

/// 红包消息气泡（自定义消息 customType 914）。
class ChatRedPacketView extends StatelessWidget {
  const ChatRedPacketView({
    Key? key,
    required this.isISend,
    required this.message,
    this.onTapView,
  }) : super(key: key);

  final bool isISend;
  final Message message;
  final Function()? onTapView;

  RedPacketInfo? get _info {
    final data = message.customElem?.data;
    if (null == data || data.isEmpty) return null;
    try {
      final map = json.decode(data) as Map<String, dynamic>;
      if (map['customType'] != CustomMessageType.redPacket) return null;
      final payload = map['data'];
      if (payload is! Map) return null;
      return RedPacketInfo.fromMap(payload);
    } catch (e) {
      return null;
    }
  }

  bool _opened(String id) => DataSp.getOpenedRedPackets().contains(id);

  @override
  Widget build(BuildContext context) {
    final info = _info;
    if (null == info) return const SizedBox.shrink();

    final opened = _opened(info.id);
    final bgColor = opened ? Styles.c_FFF3E0 : Styles.c_FA5151;
    final titleColor = opened ? Styles.c_8E9AB0 : Styles.c_FFE6B0;

    return GestureDetector(
      onTap: onTapView,
      child: Container(
        width: 200.w,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: opened ? Styles.c_E8EAEF : Styles.c_FFE6B0,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_giftcard,
                size: 22.w,
                color: opened ? Styles.c_8E9AB0 : Styles.c_C93B32,
              ),
            ),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    info.displayGreeting.isNotEmpty
                        ? info.displayGreeting
                        : StrRes.redPacket,
                    style: TextStyle(color: titleColor, fontSize: 14.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.verticalSpace,
                  Text(
                    opened ? StrRes.redPacketOpened : StrRes.openRedPacket,
                    style: TextStyle(
                      color: opened ? Styles.c_8E9AB0 : Styles.c_FFE6B0,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
