import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

/// 位置消息气泡（contentType 109 locationElem）：
/// 上半部分地址信息，下半部分高德标准瓦片小地图（GCJ-02，中心定位 pin）。
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
            _MiniMapView(lat: lat, lng: lng, width: 220.w, height: 100.w),
          ],
        ),
      ),
    );
  }
}

/// 高德栅格瓦片小地图（style=7 标准图，无需 key；坐标为 GCJ-02）。
/// 3x3 瓦片网格按墨卡托投影定位，窗口裁剪，中心放定位 pin。
class _MiniMapView extends StatelessWidget {
  const _MiniMapView({
    Key? key,
    required this.lat,
    required this.lng,
    required this.width,
    required this.height,
  }) : super(key: key);

  final double lat;
  final double lng;
  final double width;
  final double height;

  static const int _zoom = 15;
  static const double _tile = 256;

  String _tileUrl(int x, int y) =>
      'https://wprd01.is.autonavi.com/appmaptile?x=$x&y=$y&z=$_zoom'
      '&lang=zh_cn&size=1&scl=1&style=7';

  @override
  Widget build(BuildContext context) {
    final n = math.pow(2, _zoom).toDouble();
    final latRad = lat * math.pi / 180.0;
    final xf = ((lng + 180.0) / 360.0 * n).clamp(0.0, n - 1.0);
    final yf = ((1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) / 2.0 * n)
        .clamp(0.0, n - 1.0);
    final worldX = xf * _tile;
    final worldY = yf * _tile;
    final centerIx = (worldX / _tile).floor();
    final centerIy = (worldY / _tile).floor();
    // 每块瓦片渲染为正方形：宽的一半
    final tilePx = width / 2;
    final scale = tilePx / _tile;
    // 让目标点落在窗口正中心
    final topLeftWorldX = worldX - width / (2 * scale);
    final topLeftWorldY = worldY - height / (2 * scale);

    final tiles = <Widget>[];
    for (var i = centerIx - 1; i <= centerIx + 1; i++) {
      for (var j = centerIy - 1; j <= centerIy + 1; j++) {
        if (i < 0 || j < 0 || i >= n || j >= n) continue;
        final left = (i * _tile - topLeftWorldX) * scale;
        final top = (j * _tile - topLeftWorldY) * scale;
        tiles.add(
          Positioned(
            left: left,
            top: top,
            child: Image.network(
              _tileUrl(i, j),
              width: tilePx,
              height: tilePx,
              fit: BoxFit.fill,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => Container(
                width: tilePx,
                height: tilePx,
                color: Styles.c_F0F2F6,
              ),
            ),
          ),
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(6.r)),
      child: Container(
        width: width,
        height: height,
        color: Styles.c_F0F2F6,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            ...tiles,
            Center(
              child: Icon(
                Icons.location_on,
                color: Styles.c_0089FF,
                size: 28.w,
                shadows: [
                  Shadow(blurRadius: 6, color: Colors.black.withOpacity(.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
