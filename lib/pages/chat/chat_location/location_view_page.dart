import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 高德地图查看位置（JS API）：显示单个 Marker + InfoWindow + 高德导航按钮
class LocationViewPage extends StatefulWidget {
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
  State<LocationViewPage> createState() => _LocationViewPageState();
}

class _LocationViewPageState extends State<LocationViewPage> {
  static const _jsKey = 'f2b91ca61ca454dc710961b018f1a33a';
  static const _jsCode = '45bb1a284292c6a9bb854cbe66fff5e9';

  late final WebViewController _web;
  bool _loaded = false;

  String get _html => '''
<!doctype html>
<html><head>
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<style>
html,body,#map{width:100%;height:100%;margin:0;padding:0}
</style>
<script>window._AMapSecurityConfig={securityJsCode:'$_jsCode'};</script>
<script src="https://webapi.amap.com/maps?v=2.0&key=$_jsKey&plugin=AMap.Geocoder"></script>
</head><body>
<div id="map"></div>
<script>
var map = new AMap.Map('map', {zoom: 16, resizeEnable: true, center: [LNG, LAT]});
var marker = new AMap.Marker({
  position: [LNG, LAT],
  map: map,
  title: '位置',
});
var info = new AMap.InfoWindow({
  content: '<div style="padding:6px 10px;font-size:13px;max-width:220px">ADDR</div>',
  offset: new AMap.Pixel(0, -34),
});
info.open(map, [LNG, LAT]);
map.on('complete', function(){ AmapBridge.postMessage('MAP_READY'); });
</script>
</body></html>
'''
      .replaceAll('LNG', widget.longitude.toStringAsFixed(6))
      .replaceAll('LAT', widget.latitude.toStringAsFixed(6))
      .replaceAll('ADDR', _escapeHtml(widget.description));

  static String _escapeHtml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll("'", '&#39;')
      .replaceAll('"', '&quot;')
      .replaceAll('\n', '<br>');

  @override
  void initState() {
    super.initState();
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('AmapBridge', onMessageReceived: (_) {
        if (!_loaded && mounted) setState(() => _loaded = true);
      })
      ..loadHtmlString(_html);
  }

  /// 跳转高德地图导航：优先拉起高德 App，失败走网页版
  Future<void> _openAmap() async {
    final native = Uri.parse(
        'androidamap://navi?sourceApplication=OpenIM&lat=${widget.latitude}&lon=${widget.longitude}&dev=0&style=2');
    try {
      if (await launchUrl(native, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {}
    final name = Uri.encodeComponent(
        widget.description.isEmpty ? '好友共享的位置' : widget.description);
    final web = Uri.parse(
        'https://uri.amap.com/navigation?to=${widget.longitude},${widget.latitude},$name&mode=car&policy=1&src=OpenIM&coordinate=gaode&callnative=1');
    try {
      final ok = await launchUrl(web, mode: LaunchMode.externalApplication);
      if (!ok) IMViews.showToast('未找到可打开高德地图的方式');
    } catch (e) {
      IMViews.showToast('跳转高德地图失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrRes.location,
        right: GestureDetector(
          onTap: _openAmap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: EdgeInsets.only(right: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Styles.c_0089FF,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.navigation, size: 14.w, color: const Color(0xFFFFFFFF)),
                SizedBox(width: 4.w),
                Text('导航', style: Styles.ts_FFFFFF_14sp),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Styles.c_F8F9FA,
      body: Stack(
        children: [
          WebViewWidget(controller: _web),
          if (!_loaded)
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          if (widget.description.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Styles.c_surface,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: SafeArea(
                  top: false,
                  child: Text(
                    widget.description,
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
