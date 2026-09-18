import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

/// 查看位置消息：地图 + 标记点
class LocationViewPage extends StatelessWidget {
  const LocationViewPage({
    super.key,
    required this.latitude,
    required this.longitude,
    this.description = '',
  });
  final double latitude;
  final double longitude;
  final String description;

  @override
  Widget build(BuildContext context) {
    final target = LatLng(latitude, longitude);
    return Scaffold(
      appBar: TitleBar.back(title: description.isEmpty ? StrRes.toolboxLocation : description),
      backgroundColor: Styles.c_F8F9FA,
      body: Stack(
        children: [
          AMapWidget(
            privacyStatement: AMapPrivacyStatement(
              hasContains: true,
              hasShow: true,
              hasAgree: true,
            ),
            initialCameraPosition: CameraPosition(target: target, zoom: 16),
            markers: {
              Marker(
                position: target,
                onTap: (_) => IMViews.showToast(description),
              ),
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Styles.c_surface,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: SafeArea(
                top: false,
                child: Text(
                  description.isEmpty
                      ? '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}'
                      : description,
                  style: Styles.ts_0C1C33_14sp,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
