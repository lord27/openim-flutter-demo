import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:openim_live/openim_live.dart';

import '../im_callback.dart';

class IMController extends GetxController with IMCallback, OpenIMLive {
  late Rx<UserFullInfo> userInfo;
  late String atAllTag;

  // 连接看门狗：ws 长时间既不成也不败时，兜底置为「连接失败」，避免界面永久停在「连接中」
  Timer? _connectWatchdog;

  void _startConnectWatchdog() {
    _connectWatchdog?.cancel();
    _connectWatchdog = Timer(const Duration(seconds: 30), () {
      Logger.print('connect watchdog fired -> connectionFailed');
      imSdkStatus(IMSdkStatus.connectionFailed);
    });
  }

  void _cancelConnectWatchdog() {
    _connectWatchdog?.cancel();
    _connectWatchdog = null;
  }

  @override
  void onClose() {
    super.close();
    onCloseLive();
    super.onClose();
  }

  @override
  void onInit() async {
    super.onInit();
    onInitLive();
    WidgetsBinding.instance.addPostFrameCallback((_) => initOpenIM());
  }

  void initOpenIM() async {
    final initialized = await OpenIM.iMManager.initSDK(
      platformID: IMUtils.getPlatform(),
      apiAddr: Config.imApiUrl,
      wsAddr: Config.imWsUrl,
      dataDir: Config.cachePath,
      logLevel: Config.logLevel,
      logFilePath: Config.cachePath,
      listener: OnConnectListener(
        onConnecting: () {
          imSdkStatus(IMSdkStatus.connecting);
          _startConnectWatchdog();
        },
        onConnectFailed: (code, error) {
          _cancelConnectWatchdog();
          imSdkStatus(IMSdkStatus.connectionFailed);
        },
        onConnectSuccess: () {
          _cancelConnectWatchdog();
          imSdkStatus(IMSdkStatus.connectionSucceeded);
        },
        onKickedOffline: kickedOffline,
        onUserTokenExpired: kickedOffline,
        onUserTokenInvalid: userTokenInvalid,
      ),
    );

    OpenIM.iMManager
      ..setUploadLogsListener(OnUploadLogsListener(onUploadProgress: uploadLogsProgress))
      ..userManager.setUserListener(OnUserListener(
          onSelfInfoUpdated: (u) {
            selfInfoUpdated(u);

            userInfo.update((val) {
              val?.nickname = u.nickname;
              val?.faceURL = u.faceURL;

              val?.remark = u.remark;
              val?.ex = u.ex;
              val?.globalRecvMsgOpt = u.globalRecvMsgOpt;
            });
          },
          onUserStatusChanged: userStausChanged))
      ..messageManager.setAdvancedMsgListener(OnAdvancedMsgListener(
        onRecvC2CReadReceipt: recvC2CMessageReadReceipt,
        onRecvNewMessage: recvNewMessage,
        onNewRecvMessageRevoked: recvMessageRevoked,
        onRecvOfflineNewMessage: recvOfflineMessage,
        onRecvOnlineOnlyMessage: (msg) {
          if (msg.isCustomType) {
            final data = msg.customElem!.data;
            final map = jsonDecode(data!);
            final customType = map['customType'];
            if (customType == CustomMessageType.callingInvite ||
                customType == CustomMessageType.callingAccept ||
                customType == CustomMessageType.callingReject ||
                customType == CustomMessageType.callingCancel ||
                customType == CustomMessageType.callingHungup) {
              final signaling = SignalingInfo(invitation: InvitationInfo.fromJson(map['data']));
              signaling.userID = signaling.invitation?.inviterUserID;

              switch (customType) {
                case CustomMessageType.callingInvite:
                  receiveNewInvitation(signaling);
                  break;
                case CustomMessageType.callingAccept:
                  inviteeAccepted(signaling);
                  break;
                case CustomMessageType.callingReject:
                  inviteeRejected(signaling);
                  break;
                case CustomMessageType.callingCancel:
                  invitationCancelled(signaling);
                  break;
                case CustomMessageType.callingHungup:
                  beHangup(signaling);
                  break;
              }
            }
          }
        },
      ))
      ..messageManager.setMsgSendProgressListener(OnMsgSendProgressListener(
        onProgress: progressCallback,
      ))
      ..messageManager.setCustomBusinessListener(OnCustomBusinessListener(
        onRecvCustomBusinessMessage: recvCustomBusinessMessage,
      ))
      ..friendshipManager.setFriendshipListener(OnFriendshipListener(
        onBlackAdded: blacklistAdded,
        onBlackDeleted: blacklistDeleted,
        onFriendApplicationAccepted: friendApplicationAccepted,
        onFriendApplicationAdded: friendApplicationAdded,
        onFriendApplicationDeleted: friendApplicationDeleted,
        onFriendApplicationRejected: friendApplicationRejected,
        onFriendInfoChanged: friendInfoChanged,
        onFriendAdded: friendAdded,
        onFriendDeleted: friendDeleted,
      ))
      ..conversationManager.setConversationListener(OnConversationListener(
          onConversationChanged: conversationChanged,
          onNewConversation: newConversation,
          onTotalUnreadMessageCountChanged: totalUnreadMsgCountChanged,
          onInputStatusChanged: inputStateChanged,
          onSyncServerFailed: (reInstall) {
            imSdkStatus(IMSdkStatus.syncFailed, reInstall: reInstall ?? false);
          },
          onSyncServerFinish: (reInstall) {
            imSdkStatus(IMSdkStatus.syncEnded, reInstall: reInstall ?? false);
            if (Platform.isAndroid) {
              Permissions.request([Permission.systemAlertWindow]);
            }
          },
          onSyncServerStart: (reInstall) {
            imSdkStatus(IMSdkStatus.syncStart, reInstall: reInstall ?? false);
          },
          onSyncServerProgress: (progress) {
            imSdkStatus(IMSdkStatus.syncProgress, progress: progress);
          }))
      ..groupManager.setGroupListener(OnGroupListener(
        onGroupApplicationAccepted: groupApplicationAccepted,
        onGroupApplicationAdded: groupApplicationAdded,
        onGroupApplicationDeleted: groupApplicationDeleted,
        onGroupApplicationRejected: groupApplicationRejected,
        onGroupInfoChanged: groupInfoChanged,
        onGroupMemberAdded: groupMemberAdded,
        onGroupMemberDeleted: groupMemberDeleted,
        onGroupMemberInfoChanged: groupMemberInfoChanged,
        onJoinedGroupAdded: joinedGroupAdded,
        onJoinedGroupDeleted: joinedGroupDeleted,
      ));

    Logger().sdkIsInited = initialized;
    initializedSubject.sink.add(initialized);
  }

  Future login(String userID, String token) async {
    try {
      var user = await OpenIM.iMManager
          .login(
            userID: userID,
            token: token,
            defaultValue: () async => UserInfo(userID: userID),
          )
          .timeout(const Duration(seconds: 25));
      userInfo = UserFullInfo.fromJson(user.toJson()).obs;
      _queryMyFullInfo();
      _queryAtAllTag();
    } catch (e, s) {
      Logger.print('e: $e  s:$s');
      if (e is TimeoutException) {
        // 登录请求长时间无响应：断开引擎，避免残留坏连接影响下次登录
        try {
          await OpenIM.iMManager.logout();
        } catch (_) {}
      }
      await _handleLoginRepeatError(e);

      return Future.error(e, s);
    }
  }

  Future logout() {
    return OpenIM.iMManager.logout();
  }

  void _queryAtAllTag() async {
    atAllTag = OpenIM.iMManager.conversationManager.atAllTag;
  }

  void _queryMyFullInfo() async {
    final data = await Apis.queryMyFullInfo();
    if (data is UserFullInfo) {
      userInfo.update((val) {
        val?.allowAddFriend = data.allowAddFriend;
        val?.allowBeep = data.allowBeep;
        val?.allowVibration = data.allowVibration;
        val?.nickname = data.nickname;
        val?.faceURL = data.faceURL;
        val?.phoneNumber = data.phoneNumber;
        val?.email = data.email;
        val?.birth = data.birth;
        val?.gender = data.gender;
      });
    }
  }

  static const _reloginCodes = <String>{
    '13002', // 已在别处登录
    '1501',  // token 无效
    '1502',  // token 过期
    '1503',  // token 格式错误
    '1505',  // token 未知
    '1506',  // token 已被踢下线
    '1507',  // 平台不一致
    '1508',  // 已登出
  };

  _handleLoginRepeatError(e) async {
    if (e is PlatformException && _reloginCodes.contains(e.code)) {
      Logger.print('need relogin, code=${e.code} -> clear certificate');
      try {
        await logout();
      } catch (_) {}
      await DataSp.removeLoginCertificate();
    }
  }
}
