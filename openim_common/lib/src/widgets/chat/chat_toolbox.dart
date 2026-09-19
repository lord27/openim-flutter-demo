import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class ChatToolBox extends StatelessWidget {
  const ChatToolBox({
    super.key,
    this.onTapAlbum,
    this.onTapCall,
    this.onTapVideo,
    this.onTapFile,
    this.onTapCard,
    this.onTapEmoji,
    this.onTapLocation,
    this.onTapRedPacket,
    this.onTapCamera,
  });
  final Function()? onTapAlbum;
  final Function()? onTapCall;
  final Function()? onTapVideo;
  final Function()? onTapFile;
  final Function()? onTapCard;
  final Function()? onTapEmoji;
  final Function()? onTapLocation;
  final Function()? onTapRedPacket;
  final Function()? onTapCamera;

  @override
  Widget build(BuildContext context) {
    final items = [
      if (onTapEmoji != null)
        ToolboxItemInfo(
          text: StrRes.toolboxEmoji,
          icon: ImageRes.openEmoji,
          onTap: onTapEmoji,
        ),
      ToolboxItemInfo(
        text: StrRes.toolboxAlbum,
        icon: ImageRes.toolboxAlbum,
        onTap: () => Permissions.photos(onTapAlbum),
      ),
      if (onTapVideo != null)
        ToolboxItemInfo(
          text: StrRes.toolboxVideo,
          icon: ImageRes.toolboxCamera,
          onTap: onTapVideo,
        ),
      if (onTapCamera != null)
        ToolboxItemInfo(
          text: StrRes.toolboxCamera,
          iconData: Icons.photo_camera,
          onTap: () => Permissions.camera(onTapCamera),
        ),
      if (onTapCard != null)
        ToolboxItemInfo(
          text: StrRes.toolboxCard,
          icon: ImageRes.toolboxCard,
          onTap: onTapCard,
        ),
      if (onTapFile != null)
        ToolboxItemInfo(
          text: StrRes.toolboxFile,
          icon: ImageRes.toolboxFile,
          onTap: onTapFile,
        ),
      if (onTapLocation != null)
        ToolboxItemInfo(
          text: StrRes.toolboxLocation,
          icon: ImageRes.toolboxLocation1,
          onTap: onTapLocation,
        ),
      if (onTapRedPacket != null)
        ToolboxItemInfo(
          text: StrRes.toolboxRedPacket,
          iconData: Icons.card_giftcard,
          iconColor: Styles.c_FA5151,
          onTap: onTapRedPacket,
        ),
      if (onTapCall != null)
        ToolboxItemInfo(
          text: StrRes.toolboxCall,
          icon: ImageRes.toolboxCall,
          onTap: () => Permissions.cameraAndMicrophone(onTapCall),
        ),
    ];

    return Container(
      color: Styles.c_F0F2F6,
      height: 224.h,
      child: GridView.builder(
        itemCount: items.length,
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 6.h,
          bottom: 6.h,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 78.w / 105.h,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 2.h,
        ),
        itemBuilder: (_, index) {
          final item = items.elementAt(index);
          return _buildItemView(
            icon: item.icon,
            iconData: item.iconData,
            iconColor: item.iconColor,
            text: item.text,
            onTap: item.onTap,
          );
        },
      ),
    );
  }

  Widget _buildItemView({
    required String text,
    String? icon,
    IconData? iconData,
    Color? iconColor,
    Function()? onTap,
  }) =>
      Column(
        children: [
          if (null != iconData)
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 58.w,
                height: 58.h,
                decoration: BoxDecoration(
                  color: Styles.c_FFFFFF,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  iconData,
                  size: 30.w,
                  color: iconColor ?? Styles.c_0089FF,
                ),
              ),
            )
          else
            icon!.toImage
              ..width = 58.w
              ..height = 58.h
              ..onTap = onTap,
          10.verticalSpace,
          text.toText..style = Styles.ts_0C1C33_12sp,
        ],
      );
}

class ToolboxItemInfo {
  String text;
  String? icon;
  IconData? iconData;
  Color? iconColor;
  Function()? onTap;

  ToolboxItemInfo({
    required this.text,
    this.icon,
    this.iconData,
    this.iconColor,
    this.onTap,
  });
}
