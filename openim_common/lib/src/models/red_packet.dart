import 'dart:math';

/// 红包消息载荷。
///
/// demo 没有红包服务端，红包以自定义消息(customType 914)承载，
/// 「是否已领取」由本地 [DataSp] 记录，跨设备/换登录账号不会同步。
class RedPacketInfo {
  const RedPacketInfo({
    required this.id,
    this.senderID,
    this.senderName,
    this.greeting,
    required this.amount,
    this.count = 1,
    this.isLucky = true,
  });

  final String id;
  final String? senderID;
  final String? senderName;
  final String? greeting;

  /// 红包总金额（元）
  final double amount;

  /// 红包个数（单聊固定 1）
  final int count;

  /// true 拼手气红包；false 普通红包
  final bool isLucky;

  String get displayGreeting =>
      (greeting != null && greeting!.trim().isNotEmpty) ? greeting!.trim() : '';

  Map<String, dynamic> toMap() => {
        'id': id,
        'senderID': senderID,
        'senderName': senderName,
        'greeting': greeting,
        'amount': amount,
        'count': count,
        'isLucky': isLucky,
      };

  factory RedPacketInfo.fromMap(Map map) => RedPacketInfo(
        id: (map['id'] ?? '').toString(),
        senderID: map['senderID']?.toString(),
        senderName: map['senderName']?.toString(),
        greeting: map['greeting']?.toString(),
        amount: map['amount'] is num ? (map['amount'] as num).toDouble() : 0.0,
        count: map['count'] is num ? (map['count'] as num).toInt() : 1,
        isLucky: map['isLucky'] == true,
      );

  /// 以「红包 id + 领取人」为随机种子，保证同一人多次打开得到相同金额。
  double grabbedAmount(String userID) {
    if (count <= 1 || !isLucky) return amount;
    final random = Random('$id-$userID'.hashCode);
    final average = amount / count;
    final value = average * (0.4 + random.nextDouble() * 1.2);
    return double.parse(value.clamp(0.01, amount).toStringAsFixed(2));
  }
}
