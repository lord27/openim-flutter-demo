import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class ThemeSetupLogic extends GetxController {
  final currentId = ''.obs;

  @override
  void onInit() {
    currentId.value = AppThemeService.current.id;
    super.onInit();
  }

  List<AppThemePalette> get palettes => AppThemePalettes.all;

  void switchTheme(AppThemePalette palette) {
    if (palette.id == currentId.value) return;
    currentId.value = palette.id;
    // 页面颜色来自 Styles 静态 getter，Navigator 缓存已打开页面实例，
    // 仅 notify/changeTheme 刷不出新色。这里换 key 重建整树：
    // 以账号设置页为落点，随后压回主题页，保持「主题页→账号设置」返回栈。
    AppThemeService.apply(
      palette,
      remountInitial: '/account_setup',
      pushAfter: '/theme_setup',
    );
  }
}
