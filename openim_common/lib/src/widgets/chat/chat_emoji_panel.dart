import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class ChatEmojiPanel extends StatelessWidget {
  const ChatEmojiPanel({super.key, required this.onSelected, this.onBack});
  final ValueChanged<String> onSelected;
  final VoidCallback? onBack;

  static const List<String> _emojis = [
    '😀','😃','😄','😁','😆','😅','🤣','😂','🙂','🙃','😉','😊','😇','🥰','😍','🤩',
    '😘','😗','😚','😙','🥲','😋','😛','😜','🤪','😝','🤑','🤗','🤭','🤫','🤔','🤐',
    '🤨','😐','😑','😶','😏','😒','🙄','😬','🤥','😌','😔','😪','🤤','😴','😷','🤒',
    '🤕','🤢','🤮','🤧','🥵','🥶','🥴','😵','🤯','🤠','🥳','🥸','😎','🤓','🧐','😕',
    '😟','🙁','😮','😯','😲','😳','🥺','😦','😧','😨','😰','😥','😢','😭','😱','😖',
    '😣','😞','😓','😩','😫','🥱','😤','😡','😠','🤬','😈','👿','💀','💩','🤡','👻',
    '👽','🤖','😺','😹','😻','😼','😽','🙀','😿','😾','🙈','🙉','🙊','💋','💌','👍',
    '👎','👌','✌️','🤞','🤟','🤘','🤙','👈','👉','👆','👇','☝️','✋','🤚','🖖','👋',
    '🤝','🙏','💪','✍️','👏','🙌','👐','🤲','🤜','🤛','✊','👊','❤️','🧡','💛','💚',
    '💙','💜','🖤','🤍','🤎','💔','❣️','💕','💞','💓','💗','💖','💘','💝','🎉','🎊',
    '🎈','🎁','🏆','⚽','🏀','🍺','🍻','☕','🍵','🌹','🌸','☀️','🌙','⭐','🔥','💧',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Styles.c_F0F2F6,
      height: 224.h,
      child: Column(
        children: [
          SizedBox(
            height: 40.h,
            child: Row(
              children: [
                if (onBack != null)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onBack,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Icon(Icons.arrow_back_ios_new, size: 18.w),
                    ),
                  ),
                Text(
                  StrRes.toolboxEmoji,
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF0C1C33)),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 8.h),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                childAspectRatio: 1,
              ),
              itemCount: _emojis.length,
              itemBuilder: (_, index) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(_emojis[index]),
                child: Center(
                  child: Text(
                    _emojis[index],
                    style: TextStyle(fontSize: 24.sp),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
