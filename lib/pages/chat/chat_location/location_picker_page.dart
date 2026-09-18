import 'dart:async';

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

/// 高德地图选点：拖动地图让目标点对准中心大头针 → 「发送位置」
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const _defaultTarget = LatLng(39.909187, 116.397451);
  LatLng _target = _defaultTarget;
  String _address = '';
  bool _userMoved = false;
  bool _movingByCode = false;
  bool _locating = false;
  AMapController? _controller;
  AMapFlutterLocation? _client;

  @override
  void initState() {
    super.initState();
    _fixLocation();
  }

  @override
  void dispose() {
    try {
      _client?.stopLocation();
      
    } catch (_) {}
    super.dispose();
  }

  Future<void> _fixLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      AMapFlutterLocation.updatePrivacyShow(true, true);
      AMapFlutterLocation.updatePrivacyAgree(true);
      final client = AMapFlutterLocation();
      client.setLocationOption(
        AMapLocationOption(
          needAddress: true,
          onceLocation: true,
          locationMode: AMapLocationMode.Hight_Accuracy,
        ),
      );
      _client = client;
      final loc = await client
          .onLocationChanged()
          .first
          .timeout(const Duration(seconds: 8));
      final lat = (loc['latitude'] as num?)?.toDouble();
      final lng = (loc['longitude'] as num?)?.toDouble();
      if (lat != null && lng != null && mounted) {
        final addr = (loc['address'] ?? loc['formattedAddress'] ?? '').toString();
        setState(() {
          _address = addr;
          _target = LatLng(lat, lng);
          _userMoved = false;
        });
        _movingByCode = true;
        _controller?.moveCamera(
          CameraUpdate.newLatLngZoom(_target, 16),
          animated: true,
        );
      }
    } catch (e) {
      // 定位失败仍可手动选点
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _send() {
    final desc = (!_userMoved && _address.isNotEmpty)
        ? _address
        : '经度:${_target.longitude.toStringAsFixed(6)} 纬度:${_target.latitude.toStringAsFixed(6)}';
    Get.back(result: {
      'lat': _target.latitude,
      'lng': _target.longitude,
      'desc': desc,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrRes.toolboxLocation,
        right: GestureDetector(
          onTap: _send,
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: EdgeInsets.only(right: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Styles.c_0089FF,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              StrRes.locationSend,
              style: Styles.ts_FFFFFF_14sp,
            ),
          ),
        ),
      ),
      backgroundColor: Styles.c_F8F9FA,
      body: Stack(
        children: [
          AMapWidget(
            privacyStatement: AMapPrivacyStatement(
              hasContains: true,
              hasShow: true,
              hasAgree: true,
            ),
            initialCameraPosition: CameraPosition(target: _target, zoom: 16),
            onMapCreated: (c) => _controller = c,
            onCameraMoveEnd: (pos) {
              if (_movingByCode) {
                _movingByCode = false;
                return;
              }
              setState(() {
                _userMoved = true;
                _target = pos.target;
              });
            },
          ),
          // 中心大头针
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 34.h),
                child: Icon(
                  Icons.location_on,
                  color: const Color(0xFFE5484D),
                  size: 44.w,
                ),
              ),
            ),
          ),
          // 底部信息条
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Styles.c_surface,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (!_userMoved && _address.isNotEmpty)
                            ? _address
                            : '经度:${_target.longitude.toStringAsFixed(6)} 纬度:${_target.latitude.toStringAsFixed(6)}',
                        style: Styles.ts_0C1C33_14sp,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    12.horizontalSpace,
                    GestureDetector(
                      onTap: _fixLocation,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Styles.c_F0F2F6,
                          shape: BoxShape.circle,
                        ),
                        child: _locating
                            ? SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Styles.c_0089FF,
                                ),
                              )
                            : Icon(Icons.my_location,
                                color: Styles.c_0089FF, size: 18.w),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
