import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

typedef RecordFc = Function(int sec, String path);

class VoiceRecord {
  static const _dir = "voice";
  static const _ext = ".m4a";

  /// 采集源轮换：某一路被占用/无效时自动换下一路（会话内记忆）。
  /// 只保留全机型安全的采集源：CAMCORDER/UNPROCESSED 等在部分 OEM 上
  /// 会让 AudioRecord 抛原生异常直接闪退，不得加入。
  static const List<AndroidAudioSource> _sources = [
    AndroidAudioSource.mic,
    AndroidAudioSource.defaultSource,
    AndroidAudioSource.voiceCommunication,
  ];
  static const List<String> _sourceNames = [
    'MIC',
    'DEFAULT',
    'VOICE_COMM',
  ];
  static int _srcIdx = 0;

  static String get currentSourceName => _sourceNames[_srcIdx];

  /// 切换到下一采集源；返回 true 表示已绕回第一个（即全部尝试过）
  static bool cycleSource() {
    _srcIdx = (_srcIdx + 1) % _sources.length;
    return _srcIdx == 0;
  }

  String _path = '';
  int _startTimestamp = 0;
  final int _tag;
  final RecordFc onFinished;
  final RecordFc onInterrupt;
  final Function(String reason)? onError;
  final int maxRecordSec;
  final Function(int duration)? onDuration;

  /// 实时振幅回调（0.0~1.0，约 100ms 一次），用于录音 HUD 音波动画；
  /// 若全程接近 0，说明麦克风确实没有采集到数据。
  final Function(double amp)? onAmplitude;

  final _audioRecorder = AudioRecorder();
  Timer? _timer;
  Timer? _ampTimer;
  double _maxAmp = 0;
  double _maxDb = -160;

  /// 本次录音期间出现过的最大振幅（0~1），用于静音诊断
  double get lastMaxAmplitude => _maxAmp;

  /// 本次录音期间的最大真实电平（dBFS，如 -160 静音 / -20 正常说话）
  double get lastMaxDb => _maxDb;

  /// dBFS -> 0.0~1.0。
  /// 插件返回的 Amplitude.current 是 dBFS 负值（-160 静音，0 满刻度），
  /// 早期版本直接 clamp(0,1) 会把负数全部压成 0，导致音波永远不动。
  static double dbToLevel(double db) {
    if (!db.isFinite) return 0.0;
    return (1 + db / 60.0).clamp(0.0, 1.0).toDouble();
  }

  VoiceRecord({
    required this.maxRecordSec,
    required this.onInterrupt,
    required this.onFinished,
    this.onDuration,
    this.onAmplitude,
    this.onError,
  }) : _tag = _now();

  /// 开始录音。返回 false = 无麦克风权限或启动失败，未真正开始。
  Future<bool> start() async {
    try {
      if (!await _audioRecorder.hasPermission()) return false;
      var path = (await getApplicationDocumentsDirectory()).path;
      _path = '$path/$_dir/$_tag$_ext';
      // 目录必须存在：MediaRecorder.setOutputFile 不会创建父目录，
      // 父目录缺失时 prepare() 直接抛 IOException（录音整体起不来）
      final dir = Directory('$path/$_dir');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      // 不预创建空文件：删除旧残留，避免 MediaRecorder 对已存在文件的边界问题
      final file = File(_path);
      if (await file.exists()) {
        await file.delete();
      }
      debugPrint(
          'voice rec start: src=${_sourceNames[_srcIdx]} path=$_path');
      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          // 语音消息场景：16k 单声道 + 64kbps（约 8KB/s），
          // 兼容性明显好于 44.1k/128k，VOICE_COMMUNICATION 源下尤其稳
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 64000,
          androidConfig: AndroidRecordConfig(audioSource: _sources[_srcIdx]),
        ),
        path: _path,
      );
      _startTimestamp = _now();
      _maxAmp = 0;
      _maxDb = -160;
      _timer?.cancel();
      _timer = null;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        final duration = ((_now() - _startTimestamp) ~/ 1000);
        onDuration?.call(duration);
        if (duration >= maxRecordSec) {
          await stop(isInterrupt: true);
          onInterrupt(maxRecordSec, _path);
        }
      });
      // 振幅轮询：驱动音波动画 + 静音诊断
      _ampTimer?.cancel();
      _ampTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
        try {
          final a = await _audioRecorder.getAmplitude();
          final db = a.current; // dBFS，-160=静音/无数据，0=满刻度
          if (db.isFinite && db > _maxDb) _maxDb = db;
          final v = dbToLevel(db);
          if (v > _maxAmp) _maxAmp = v;
          onAmplitude?.call(v);
        } catch (_) {}
      });
      return true;
    } catch (e) {
      debugPrint('voice rec start error: $e');
      return false;
    }
  }

  /// 停止并回调 onFinished。
  stop({bool isInterrupt = false}) async {
    _timer?.cancel();
    _timer = null;
    _ampTimer?.cancel();
    _ampTimer = null;
    final recording = await _audioRecorder.isRecording();
    if (recording) {
      await _audioRecorder.stop();
    }
    await dispose();
    if (!recording || isInterrupt) return;
    final sec = (_now() - _startTimestamp) ~/ 1000;
    final f = File(_path);
    final len = await f.exists() ? await f.length() : 0;
    debugPrint('voice rec stop: src=${_sourceNames[_srcIdx]} '
        'sec=$sec bytes=$len maxDb=$_maxDb maxAmp=$_maxAmp');
    // 静音/未录上检测：64kbps AAC ≈ 8KB/s，这里按 400B/s 兜底（留 20 倍余量）
    final tooSmall = len < 1024 || (sec >= 1 && len < sec * 400);
    // 采到可辨识声音（-45dB 以上≈正常说话）就不判静音。
    // 旧实现用 clamp 后的 0~1 判定，dBFS 负数被压成 0，正常录音也会被误杀
    final heardSomething = _maxDb > -45;
    if (tooSmall && !heardSomething) {
      onError?.call('mic_silent');
      return;
    }
    onFinished(sec, _path);
  }

  /// 取消录音：停止并删除临时文件，不触发 onFinished。
  cancel() async {
    _timer?.cancel();
    _timer = null;
    _ampTimer?.cancel();
    _ampTimer = null;
    try {
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }
      final f = File(_path);
      if (await f.exists()) {
        await f.delete();
      }
    } catch (_) {}
    await dispose();
  }

  /// 释放录音器。每次录音都是新建的 AudioRecorder，不释放会持续堆积原生
  /// 会话，是「第一次能录、后面一直没声音」的常见诱因。
  Future<void> dispose() async {
    try {
      await _audioRecorder.dispose();
    } catch (_) {}
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch;
}
