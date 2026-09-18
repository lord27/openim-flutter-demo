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
    // 持久化 + 通知全局重建
    AppThemeService.apply(palette);
  }
}
