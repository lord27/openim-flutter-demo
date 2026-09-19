import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/mic_diag.dart';
import 'package:openim_common/openim_common.dart';

/// 录音 HUD 手势分区
const int kRecZoneSend = 0;
const int kRecZoneCancel = 1;
const int kRecZoneToText = 2;

/// 按住说话录音条：录音时显示微信风格全屏 HUD——
/// 顶部绿色气泡实时音波 + 录音时长（气泡随录音变长），
/// 底部「取消」「滑到这里 转文字」侧区 + 「松开 发送」弧形面板。
class SoundRecordBar extends StatefulWidget {
  const SoundRecordBar({
    Key? key,
    required this.onFinished,
    this.maxRecordSec = 60,
  }) : super(key: key);

  final void Function(int seconds, String path) onFinished;
  final int maxRecordSec;

  @override
  State<SoundRecordBar> createState() => _SoundRecordBarState();
}

class _SoundRecordBarState extends State<SoundRecordBar> {
  VoiceRecord? _recorder;
  bool _recording = false;
  bool _gestureActive = false;
  int _zone = kRecZoneSend;
  OverlayEntry? _hud;
  bool _disposed = false;
  double _pressDy = 0;

  final ValueNotifier<int> _secN = ValueNotifier<int>(0);
  final ValueNotifier<int> _zoneN = ValueNotifier<int>(kRecZoneSend);
  final ValueNotifier<List<double>> _barsN =
      ValueNotifier<List<double>>(List<double>.filled(40, 0.03));

  final AudioPlayer _fxPlayer = AudioPlayer();

  Future<void> _playFx(String asset) async {
    try {
      await _fxPlayer.stop();
      await _fxPlayer.setAsset(asset, package: 'openim_common');
      await _fxPlayer.play();
    } catch (_) {}
  }

  void _showHud() {
    _removeHud();
    _secN.value = 0;
    _zoneN.value = kRecZoneSend;
    _barsN.value = List<double>.filled(40, 0.03);
    _hud = OverlayEntry(
      builder: (_) => _RecHud(
        secN: _secN,
        zoneN: _zoneN,
        barsN: _barsN,
        maxSec: widget.maxRecordSec,
      ),
    );
    Overlay.of(context).insert(_hud!);
  }

  void _removeHud() {
    try {
      _hud?.remove();
    } catch (_) {}
    _hud = null;
  }

  Future<void> _start(LongPressStartDetails d) async {
    if (_recording) return;
    _gestureActive = true;
    _pressDy = d.globalPosition.dy;
    // 权限前置申请：系统权限框在录音启动之外处理，
    // 避免 record 插件在启动流程内部弹框与手势取消产生竞争
    try {
      final st = await Permission.microphone.request();
      if (!st.isGranted) {
        IMViews.showToast('未获得麦克风权限，请在系统设置中开启');
        return;
      }
    } catch (_) {}
    // 麦克风占用诊断：录音前查活动录音会话，直接点名占用方
    try {
      final holders = await MicDiag.occupiedBy();
      if (holders.isNotEmpty) {
        final own = holders.any((p) => p.startsWith('io.openim'));
        if (own) {
          IMViews.showToast('本应用有录音会话未释放，请重启应用后重试');
        } else {
          IMViews.showToast('麦克风被占用：${holders.join('、')}，请关闭对应应用或重启手机后重试');
        }
        return;
      }
    } catch (_) {}
    bool ok = false;
    try {
      _recorder = VoiceRecord(
        maxRecordSec: widget.maxRecordSec,
        onInterrupt: (sec, path) => _finish(sec, path),
        onFinished: (sec, path) => _finish(sec, path),
        onError: (reason) => _micError(),
        onDuration: (sec) => _secN.value = sec,
        onAmplitude: (amp) {
          final bars = List<double>.from(_barsN.value);
          bars.removeAt(0);
          bars.add(amp);
          _barsN.value = bars;
        },
      );
      ok = await _recorder!.start();
    } catch (e) {
      IMViews.showToast('录音启动失败（请检查麦克风权限）: $e');
      return;
    }
    if (!ok) {
      IMViews.showToast('未获得麦克风权限，请在系统设置中开启');
      return;
    }
    // 弹权限框等情况下手势可能已结束：丢弃本次录音，等用户重新按压
    if (!_gestureActive) {
      await _recorder?.cancel();
      if (mounted) setState(() => _recording = false);
      return;
    }
    _playFx('assets/audio/meeting_mic_turn_on.wav');
    if (mounted) {
      setState(() {
        _recording = true;
        _zone = kRecZoneSend;
      });
    }
    _showHud();
  }

  void _onMove(LongPressMoveUpdateDetails d) {
    if (!_recording) return;
    final w = MediaQuery.of(context).size.width;
    final x = d.globalPosition.dx;
    int z = kRecZoneSend;
    if (x < w * 0.33) {
      z = kRecZoneCancel;
    } else if (x > w * 0.67) {
      z = kRecZoneToText;
    }
    if (z != _zone) {
      _zone = z;
      _zoneN.value = z;
    }
  }

  /// 松开手指：左侧取消、右侧转文字，否则发送
  Future<void> _onEnd(LongPressEndDetails d) async {
    _gestureActive = false;
    if (!_recording) return;
    if (_zone == kRecZoneCancel) {
      await _cancel();
      return;
    }
    if (_zone == kRecZoneToText) {
      await _cancel();
      IMViews.showToast('语音转文字暂未开通');
      return;
    }
    try {
      await _recorder?.stop();
    } catch (e) {
      IMViews.showToast('录音结束异常: $e');
      _removeHud();
      if (mounted) setState(() => _recording = false);
    }
  }

  /// 系统打断（来电、手势冲突等）一律取消，避免误发
  Future<void> _onSystemCancel() async {
    _gestureActive = false;
    if (!_recording) return;
    await _cancel();
  }

  Future<void> _cancel() async {
    try {
      await _recorder?.cancel();
    } catch (_) {}
    _playFx('assets/audio/meeting_mic_turn_off.wav');
    _removeHud();
    if (mounted) {
      setState(() {
        _recording = false;
        _zone = kRecZoneSend;
      });
    }
  }

  Future<void> _micError() async {
    _playFx('assets/audio/meeting_mic_turn_off.wav');
    _removeHud();
    if (mounted) {
      setState(() {
        _recording = false;
        _zone = kRecZoneSend;
      });
    }
    final wrapped = VoiceRecord.cycleSource();
    // 静音诊断：峰值振幅 + 设备品牌/型号，帮助定位 ROM 级拦截
    final dev = await MicDiag.deviceInfo();
    final device = [
      (dev['manufacturer'] ?? '').toUpperCase(),
      dev['model'] ?? '',
    ].where((s) => s.isNotEmpty).join('/');
    final peak =
        (((_recorder?.lastMaxAmplitude ?? 0) * 100).toStringAsFixed(0));
    if (wrapped) {
      IMViews.showToast(
          '各采集模式均无声(峰值$peak%，$device)——录音被系统拦截。请检查：①系统设置中本应用麦克风权限 ②手机管家「隐私保护/录音监控」是否放行 ③关闭语音助手等后台应用 ④重启手机后再试');
    } else {
      IMViews.showToast(
          '麦克风没有采集到声音(峰值$peak%，$device)，已切换采集模式(${VoiceRecord.currentSourceName})，请再按住重试');
    }
  }

  void _finish(int sec, String path) {
    _playFx('assets/audio/meeting_mic_turn_off.wav');
    _removeHud();
    if (_disposed || !mounted) return;
    setState(() {
      _recording = false;
      _zone = kRecZoneSend;
    });
    if (sec < 1) {
      IMViews.showToast('按住时间太短');
      return;
    }
    widget.onFinished(sec, path);
  }

  @override
  void dispose() {
    _disposed = true;
    _removeHud();
    try {
      _recorder?.cancel();
    } catch (_) {}
    _fxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppThemeService.current.primary;
    final danger = const Color(0xFFE5484D);
    final bg = _zone == kRecZoneCancel
        ? danger
        : (_recording ? primary : const Color(0xFFFFFFFF));
    final fg = _recording ? Colors.white : const Color(0xFF0C1C33);
    return GestureDetector(
      onLongPressStart: _start,
      onLongPressMoveUpdate: _onMove,
      onLongPressEnd: _onEnd,
      onLongPressCancel: _onSystemCancel,
      child: Container(
        height: 40.h,
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4.r),
        ),
        alignment: Alignment.center,
        child: Text(
          _recording ? '松开 发送' : '按住 说话',
          style: TextStyle(color: fg, fontSize: 15.sp),
        ),
      ),
    );
  }
}

/// 全屏录音 HUD（IgnorePointer：手势穿透到下方录音条）
class _RecHud extends StatelessWidget {
  _RecHud({
    required this.secN,
    required this.zoneN,
    required this.barsN,
    required this.maxSec,
  });

  final ValueNotifier<int> secN;
  final ValueNotifier<int> zoneN;
  final ValueNotifier<List<double>> barsN;
  final int maxSec;

  static const Color _bubbleColor = Color(0xFFA8E05F);
  static const Color _bar = Color(0xFF31531C);
  static const Color _pillIdle = Color(0xFF6B6B6B);
  static const Color _pillActive = Color(0xFFA6A6A6);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: Listenable.merge([secN, zoneN, barsN]),
          builder: (context, _) {
            final zone = zoneN.value;
            final sec = secN.value;
            return Stack(
              children: [
                const Positioned.fill(
                  child: ColoredBox(color: Colors.black54),
                ),
                Positioned(
                  top: 100.h,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [_buildBubble(sec)],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _bottom(zone),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBubble(int sec) {
    final width = (150 + sec * 4.0).w.clamp(150.0, 330.0).toDouble();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          padding: EdgeInsets.symmetric(vertical: 18.h),
          decoration: BoxDecoration(
            color: _bubbleColor,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final v in barsN.value)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                      width: 2.5.w,
                      height: (4 + v * 36).h,
                      decoration: BoxDecoration(
                        color: _bar,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '${sec}s / ${maxSec}s',
                style: TextStyle(
                  color: _bar,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // 气泡小尾巴
        Transform.translate(
          offset: Offset(0, -8.h),
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(width: 14.w, height: 14.w, color: _bubbleColor),
          ),
        ),
      ],
    );
  }

  Widget _bottom(int zone) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.h),
          child: Row(
            children: [
              Expanded(child: _sidePill('取消', zone == kRecZoneCancel, -0.10)),
              SizedBox(width: 16.w),
              Expanded(
                  child: _sidePill('滑到这里 转文字', zone == kRecZoneToText, 0.10)),
            ],
          ),
        ),
        Container(
          height: 120.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: zone == kRecZoneSend
                ? const Color(0xFFE7E7E7)
                : const Color(0xFFCFCFCF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(150.r)),
          ),
          child: Text(
            zone == kRecZoneSend
                ? '松开 发送'
                : (zone == kRecZoneCancel ? '松开 取消录音' : '松开 转文字'),
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sidePill(String label, bool active, double tilt) {
    return Transform.rotate(
      angle: tilt,
      child: Container(
        height: 72.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? _pillActive : _pillIdle,
          borderRadius: BorderRadius.circular(36.r),
        ),
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      ),
    );
  }
}
