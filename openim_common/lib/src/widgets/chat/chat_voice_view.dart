import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openim_common/openim_common.dart';
import 'package:path_provider/path_provider.dart';

class ChatVoiceView extends StatefulWidget {
  const ChatVoiceView({
    Key? key,
    required this.isISend,
    required this.message,
  }) : super(key: key);

  final bool isISend;
  final Message message;

  @override
  State<ChatVoiceView> createState() => _ChatVoiceViewState();
}

class _ChatVoiceViewState extends State<ChatVoiceView> {
  final _player = AudioPlayer();
  StreamSubscription? _sub;
  bool _playing = false;
  bool _loading = false;
  bool _sessionInited = false;

  int get _duration => widget.message.soundElem?.duration ?? 0;

  /// 自己刚发的消息 sourceUrl 可能未被回填到本地消息副本 → 为空时回落本地录音
  String get _url => widget.message.soundElem?.sourceUrl ?? '';
  String get _localPath => widget.message.soundElem?.soundPath ?? '';
  String get _msgId => widget.message.clientMsgID ?? '';

  double get _width => (66.w + (_duration * 4.w)).clamp(66.w, 220.w);

  @override
  void dispose() {
    _sub?.cancel();
    _player.dispose();
    super.dispose();
  }

  /// 强制媒体音频（扬声器）出声，避免被路由到听筒导致「没声音」
  Future<void> _ensureAudioSession() async {
    if (_sessionInited) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      _sessionInited = true;
    } catch (_) {}
  }

  /// 语音播放源优先级：
  /// 1) sourceUrl 为空 → 直接播本地录音文件 soundPath（发送方场景）
  /// 2) 有 sourceUrl → 下载到本地缓存再播（语音 URL 是网关 302 跳 MinIO 的地址，
  ///    ExoPlayer 直接 setUrl 对该重定向处理不可靠，因此先落地再播）
  Future<File> _resolveVoiceFile() async {
    if (_url.isEmpty) {
      final local = File(_localPath);
      if (_localPath.isNotEmpty &&
          await local.exists() &&
          await local.length() > 0) {
        return local;
      }
      throw 'no source';
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/voice_cache_$_msgId.m4a');
    if (await file.exists() && await file.length() > 0) {
      return file;
    }
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(_url));
      final resp = await req.close();
      if (resp.statusCode != HttpStatus.ok) {
        throw 'HTTP ${resp.statusCode}';
      }
      final bytes = await resp.fold<List<int>>(<int>[], (acc, d) => acc..addAll(d));
      if (bytes.isEmpty) {
        throw 'empty body';
      }
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _toggle() async {
    if (_url.isEmpty && _localPath.isEmpty) {
      IMViews.showToast('语音地址为空');
      return;
    }
    try {
      if (_playing) {
        await _player.stop();
        if (mounted) setState(() => _playing = false);
        return;
      }
      if (_loading) return;
      if (mounted) setState(() => _loading = true);
      await _ensureAudioSession();
      final file = await _resolveVoiceFile();
      if (mounted) setState(() => _loading = false);
      await _player.setFilePath(file.path);
      _sub?.cancel();
      _sub = _player.playerStateStream.listen((s) {
        if (s.processingState == ProcessingState.completed) {
          if (mounted) setState(() => _playing = false);
        }
      });
      await _player.play();
      if (mounted) setState(() => _playing = true);
    } catch (e) {
      if (mounted) setState(() {
        _playing = false;
        _loading = false;
      });
      IMViews.showToast('语音播放失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isISend ? const Color(0xFFFFFFFF) : const Color(0xFF0C1C33);
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: _width,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.isISend) ...[
              ImageRes.voiceBlack.toImage
                ..width = 20.w
                ..height = 20.h,
              SizedBox(width: 8.w),
            ],
            Text(_loading ? '···' : '$_duration"',
                style: TextStyle(color: textColor, fontSize: 16.sp)),
            if (widget.isISend) ...[
              SizedBox(width: 8.w),
              ImageRes.voiceWhite.toImage
                ..width = 20.w
                ..height = 20.h,
            ],
          ],
        ),
      ),
    );
  }
}
