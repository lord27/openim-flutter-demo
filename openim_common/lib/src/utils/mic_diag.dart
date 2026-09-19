import 'package:flutter/services.dart';

/// 麦克风诊断：查询当前正在录音的会话 + 设备信息（用于静音问题定位 ROM）
class MicDiag {
  static const MethodChannel _ch = MethodChannel('openim/mic_diag');

  static Future<List<Map<String, String>>> activeRecordings() async {
    try {
      final res = await _ch.invokeMethod<List<dynamic>>('activeRecordings');
      return (res ?? [])
          .map((e) => Map<String, String>.from(e as Map)
              .map((k, v) => MapEntry(k, '$v')))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// 当前占用麦克风的包名列表
  static Future<List<String>> occupiedBy() async {
    final list = await activeRecordings();
    return list.map((e) => e['pkg'] ?? '').where((p) => p.isNotEmpty).toList();
  }

  /// 设备品牌/型号/系统 API 级别
  static Future<Map<String, String>> deviceInfo() async {
    try {
      final res = await _ch.invokeMethod<Map<dynamic, dynamic>>('deviceInfo');
      return (res ?? {}).map((k, v) => MapEntry('$k', '$v'));
    } catch (_) {
      return {};
    }
  }
}
