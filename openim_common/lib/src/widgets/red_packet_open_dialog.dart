import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

/// 拆红包弹窗。展示领取金额，关闭时把红包 id 写入本地已领取记录。
class RedPacketOpenDialog {
  static Future<void> show(BuildContext context, RedPacketInfo info) =>
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => _RedPacketOpenDialog(info: info),
      );
}

class _RedPacketOpenDialog extends StatelessWidget {
  const _RedPacketOpenDialog({required this.info});
  final RedPacketInfo info;

  Future<void> _markOpened() async {
    final list = DataSp.getOpenedRedPackets();
    if (!list.contains(info.id)) {
      list.add(info.id);
      await DataSp.putOpenedRedPackets(list);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myID = OpenIM.iMManager.userInfo.userID ?? '';
    final amount = info.grabbedAmount(myID);
    final from = info.senderName?.isNotEmpty == true
        ? info.senderName!
        : (info.senderID ?? '');
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          _markOpened();
          Get.back();
        },
        child: Container(
          width: 280.w,
          decoration: BoxDecoration(
            color: Styles.c_FA5151,
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (from.isNotEmpty)
                Text(
                  sprintf(StrRes.redPacketFrom, [from]),
                  style: TextStyle(color: Styles.c_FFE6B0, fontSize: 14.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              16.verticalSpace,
              Text(
                '¥${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Styles.c_FFE6B0,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              20.verticalSpace,
              Text(
                info.displayGreeting,
                style: TextStyle(color: Styles.c_FFE6B0, fontSize: 13.sp),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              24.verticalSpace,
              Text(
                StrRes.redPacketOpened,
                style: TextStyle(
                  color: Styles.c_FFFFFF_opacity70,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
