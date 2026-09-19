import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';
import 'package:uuid/uuid.dart';

/// 发红包底部面板。确认后返回 [RedPacketInfo]，取消返回 null。
///
/// [isGroup] 为 false（单聊）时红包个数固定为 1。
class RedPacketSendSheet {
  static Future<RedPacketInfo?> show(
    BuildContext context, {
    required bool isGroup,
    String? senderID,
    String? senderName,
  }) =>
      showModalBottomSheet<RedPacketInfo?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _RedPacketSendSheet(
          isGroup: isGroup,
          senderID: senderID,
          senderName: senderName,
        ),
      );
}

class _RedPacketSendSheet extends StatefulWidget {
  const _RedPacketSendSheet({
    required this.isGroup,
    this.senderID,
    this.senderName,
  });

  final bool isGroup;
  final String? senderID;
  final String? senderName;

  @override
  State<_RedPacketSendSheet> createState() => _RedPacketSendSheetState();
}

class _RedPacketSendSheetState extends State<_RedPacketSendSheet> {
  static const double _maxAmount = 200;
  static const int _maxCount = 100;

  final _amountCtrl = TextEditingController();
  final _countCtrl = TextEditingController(text: '1');
  final _greetingCtrl = TextEditingController();
  bool _isLucky = true;

  double get _amount => double.tryParse(_amountCtrl.text) ?? 0;

  int get _count => int.tryParse(_countCtrl.text) ?? 1;

  @override
  void initState() {
    super.initState();
    if (!widget.isGroup) _countCtrl.text = '1';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _countCtrl.dispose();
    _greetingCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = _amount;
    if (amount < 0.01) {
      IMViews.showToast(StrRes.plsEnterRedPacketAmount);
      return;
    }
    if (amount > _maxAmount) {
      IMViews.showToast(sprintf(StrRes.redPacketAmountLimit, [_maxAmount]));
      return;
    }
    final count = widget.isGroup ? _count : 1;
    if (count < 1) {
      IMViews.showToast(sprintf(StrRes.redPacketCountLimit, [_maxCount]));
      return;
    }
    if (count > _maxCount) {
      IMViews.showToast(sprintf(StrRes.redPacketCountLimit, [_maxCount]));
      return;
    }
    final info = RedPacketInfo(
      id: const Uuid().v4(),
      senderID: widget.senderID,
      senderName: widget.senderName,
      greeting: _greetingCtrl.text.trim().isEmpty
          ? StrRes.redPacketDefaultGreeting
          : _greetingCtrl.text.trim(),
      amount: double.parse(amount.toStringAsFixed(2)),
      count: count,
      isLucky: _isLucky,
    );
    Get.back(result: info);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Styles.c_surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(StrRes.sendRedPacket, style: Styles.ts_0C1C33_17sp),
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.close, size: 22.w, color: Styles.c_8E9AB0),
              ),
            ],
          ),
          if (widget.isGroup) ...[
            _ModeSwitch(
              isLucky: _isLucky,
              onChanged: (v) => setState(() => _isLucky = v),
            ),
            16.verticalSpace,
          ],
          _InputRow(
            label: StrRes.redPacketAmount,
            unit: '元',
            controller: _amountCtrl,
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: (_) => setState(() {}),
          ),
          if (widget.isGroup) ...[
            12.verticalSpace,
            _InputRow(
              label: StrRes.redPacketCount,
              unit: '个',
              controller: _countCtrl,
              hint: '1',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
            ),
          ],
          12.verticalSpace,
          _InputRow(
            label: StrRes.redPacketGreeting,
            controller: _greetingCtrl,
            hint: StrRes.redPacketDefaultGreeting,
          ),
          24.verticalSpace,
          Center(
            child: Text(
              '¥${_amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: Styles.c_FA5151,
                fontSize: 28.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          20.verticalSpace,
          SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.c_FA5151,
                foregroundColor: Styles.c_FFFFFF,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(StrRes.sendRedPacket, style: TextStyle(fontSize: 16.sp)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.isLucky, required this.onChanged});
  final bool isLucky;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ModeChip(
          text: StrRes.luckyRedPacket,
          selected: isLucky,
          onTap: () => onChanged(true),
        ),
        10.horizontalSpace,
        _ModeChip(
          text: StrRes.normalRedPacket,
          selected: !isLucky,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });
  final String text;
  final bool selected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: selected ? Styles.c_FA5151 : Styles.c_F0F2F6,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: selected ? Styles.c_FA5151 : Styles.c_E8EAEF,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Styles.c_FFFFFF : Styles.c_8E9AB0,
              fontSize: 13.sp,
            ),
          ),
        ),
      );
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.label,
    required this.controller,
    this.unit,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? unit;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: 72.w,
            child: Text(label, style: Styles.ts_0C1C33_14sp),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onChanged: onChanged,
              style: Styles.ts_0C1C33_14sp,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Styles.c_8E9AB0,
                  fontSize: 14.sp,
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Styles.c_E8EAEF),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Styles.c_FA5151),
                ),
              ),
            ),
          ),
          if (null != unit) ...[
            8.horizontalSpace,
            Text(unit!, style: Styles.ts_0C1C33_14sp),
          ],
        ],
      );
}
