import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 高德地图选点（JS API）：拖动地图使目标点对准中心大头针 → 「发送位置」
/// 底部提供「自行定位」与「高德导航」按钮。
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const _jsKey = 'f2b91ca61ca454dc710961b018f1a33a';
  static const _jsCode = '45bb1a284292c6a9bb854cbe66fff5e9';

  String _addr = '定位中…';
  double _lat = 39.909187;
  double _lng = 116.397451;
  late final WebViewController _web;

  String get _html => '''
<!doctype html>
<html><head>
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<style>
html,body,#map{width:100%;height:100%;margin:0;padding:0}
#pin{position:fixed;left:50%;top:50%;transform:translate(-50%,-100%);font-size:42px;
     color:#E5484D;text-shadow:0 2px 6px rgba(0,0,0,.4);pointer-events:none}
#tip{position:fixed;top:10px;left:50%;transform:translateX(-50%);background:rgba(0,0,0,.5);
     color:#fff;padding:4px 12px;border-radius:14px;font-size:12px;pointer-events:none;z-index:9}
</style>
<script>window._AMapSecurityConfig={securityJsCode:'$_jsCode'};</script>
<script src="https://webapi.amap.com/maps?v=2.0&key=$_jsKey&plugin=AMap.Geocoder,AMap.Geolocation"></script>
</head><body>
<div id="map"></div><div id="pin">📍</div><div id="tip">拖动地图选择位置</div>
<script>
var map = new AMap.Map('map', {zoom: 16, resizeEnable: true});
var geo = new AMap.Geocoder();
var busy = false;
function report(c){
  if (busy) return; busy = true;
  geo.getAddress([c.getLng(), c.getLat()], function(st, r){
    busy = false;
    var addr;
    if (st === 'complete' && r.regeocode && r.regeocode.formattedAddress) {
      addr = r.regeocode.formattedAddress;
    } else {
      addr = '经度:' + c.getLng().toFixed(6) + ' 纬度:' + c.getLat().toFixed(6);
    }
    AmapBridge.postMessage(JSON.stringify({lat: c.getLat(), lng: c.getLng(), addr: addr}));
  });
}
map.on('moveend', function(){ report(map.getCenter()); });
map.on('complete', function(){ report(map.getCenter()); });
function locate(){
  var tip = document.getElementById('tip');
  tip.textContent = '正在定位…';
  var g = new AMap.Geolocation({enableHighAccuracy: true, timeout: 8000});
  g.getCurrentPosition(function(st, r){
    if (st === 'complete' && r.position) {
      tip.textContent = '拖动地图选择位置';
      map.setZoomAndCenter(16, [r.position.lng, r.position.lat]);
    } else {
      tip.textContent = '定位失败，请检查定位权限';
      setTimeout(function(){ tip.textContent = '拖动地图选择位置'; }, 2000);
    }
  });
}
</script>
</body></html>
''';

  @override
  void initState() {
    super.initState();
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('AmapBridge', onMessageReceived: _onMessage)
      ..loadHtmlString(_html, baseUrl: 'https://appassets.androidplatform.net');
  }

  void _onMessage(JavaScriptMessage m) {
    try {
      final d = jsonDecode(m.message) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _lat = (d['lat'] as num).toDouble();
        _lng = (d['lng'] as num).toDouble();
        _addr = (d['addr'] as String?) ?? _addr;
      });
    } catch (_) {}
  }

  void _send() {
    Get.back(result: {'lat': _lat, 'lng': _lng, 'desc': _addr});
  }

  /// 跳转高德地图导航：优先拉起高德 App，失败走网页版
  Future<void> _openAmap() async {
    final native = Uri.parse(
        'androidamap://navi?sourceApplication=OpenIM&lat=$_lat&lon=$_lng&dev=0&style=2');
    try {
      if (await launchUrl(native, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {}
    final name = Uri.encodeComponent(_addr.isEmpty ? '所选位置' : _addr);
    final web = Uri.parse(
        'https://uri.amap.com/navigation?to=$_lng,$_lat,$name&mode=car&policy=1&src=OpenIM&coordinate=gaode&callnative=1');
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
            child: Text(StrRes.locationSend, style: Styles.ts_FFFFFF_14sp),
          ),
        ),
      ),
      backgroundColor: Styles.c_F8F9FA,
      body: Stack(
        children: [
          WebViewWidget(controller: _web),
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40.h),
                child: Icon(Icons.location_on,
                    color: const Color(0xFFE5484D), size: 44.w),
              ),
            ),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _addr,
                      style: Styles.ts_0C1C33_14sp,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(child: _locateBtn()),
                        SizedBox(width: 12.w),
                        Expanded(child: _navBtn()),
                      ],
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

  /// 自行定位：先确保运行时定位权限，再调 JS 定位。
  /// WebView 里 loadHtmlString 默认是 about:blank 非安全源，HTML5 定位会被
  /// 浏览器直接拒绝，因此 baseUrl 用 https 域名提供安全上下文。
  Future<void> _locate() async {
    try {
      final st = await Permission.locationWhenInUse.request();
      if (!st.isGranted) {
        IMViews.showToast('需要位置权限才能自行定位');
        return;
      }
    } catch (_) {}
    _web.runJavaScript('locate();');
  }

  Widget _locateBtn() {
    return GestureDetector(
      onTap: _locate,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 36.h,
        decoration: BoxDecoration(
          color: Styles.c_F0F2F6,
          borderRadius: BorderRadius.circular(4.r),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.my_location, size: 16.w, color: Styles.c_0089FF),
            SizedBox(width: 6.w),
            Text('自行定位', style: Styles.ts_0C1C33_14sp),
          ],
        ),
      ),
    );
  }

  Widget _navBtn() {
    return GestureDetector(
      onTap: _openAmap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 36.h,
        decoration: BoxDecoration(
          color: Styles.c_0089FF,
          borderRadius: BorderRadius.circular(4.r),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.navigation, size: 16.w, color: const Color(0xFFFFFFFF)),
            SizedBox(width: 6.w),
            Text('高德导航', style: Styles.ts_FFFFFF_14sp),
          ],
        ),
      ),
    );
  }
}
