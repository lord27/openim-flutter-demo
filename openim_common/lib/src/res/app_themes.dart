import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../utils/sp_util.dart';

/// 单套主题配色
class AppThemePalette {
  final String id;
  final String nameZh;
  final String nameEn;
  final bool isDark;
  final Color primary; // 主色（按钮/链接/高亮） c_0089FF
  final Color scaffoldBg; // 页面背景 c_F8F9FA
  final Color surface; // 卡片/栏背景（原白色卡片） c_surface
  final Color subBg; // 输入框/次级背景 c_F0F2F6
  final Color divider; // 分割线 c_E8EAEF
  final Color textPrimary; // 主文字 c_0C1C33
  final Color textSecondary; // 次级文字 c_8E9AB0
  final Color bubbleSelf; // 自己的气泡 c_CCE7FE
  final Color bubbleOther; // 对方的气泡 c_F4F5F7
  final Color? backIcon; // 返回箭头颜色（暗色主题为浅色）
  final List<Color> appBarGradient; // 顶栏科技感渐变
  final String? bgImage; // 主题背景图（assets 相对路径，经典蓝无）

  const AppThemePalette({
    required this.id,
    required this.nameZh,
    required this.nameEn,
    required this.isDark,
    required this.primary,
    required this.scaffoldBg,
    required this.surface,
    required this.subBg,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.bubbleSelf,
    required this.bubbleOther,
    this.backIcon,
    this.bgImage,
    required this.appBarGradient,
  });

  String get localName =>
      (Get.locale?.languageCode ?? 'zh').startsWith('zh') ? nameZh : nameEn;
}

/// 内置 6 套配色：经典蓝 + 5 套科技风暗色
class AppThemePalettes {
  static const classic = AppThemePalette(
    id: 'classic',
    nameZh: '经典蓝',
    nameEn: 'Classic Blue',
    isDark: false,
    primary: Color(0xFF0089FF),
    scaffoldBg: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    subBg: Color(0xFFF0F2F6),
    divider: Color(0xFFE8EAEF),
    textPrimary: Color(0xFF0C1C33),
    textSecondary: Color(0xFF8E9AB0),
    bubbleSelf: Color(0xFFCCE7FE),
    bubbleOther: Color(0xFFF4F5F7),
    appBarGradient: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
  );

  /// 赛博潮汐（电路板青）
  static const cyberCyan = AppThemePalette(
    id: 'cyberCyan',
    nameZh: '赛博潮汐',
    nameEn: 'Cyber Tide',
    isDark: true,
    primary: Color(0xFF22D3EE),
    scaffoldBg: Color(0xFF081120),
    surface: Color(0xFF0D1B2E),
    subBg: Color(0xFF13263F),
    divider: Color(0xFF1E3A5C),
    textPrimary: Color(0xFFD7E7FF),
    textSecondary: Color(0xFF6B8CAE),
    bubbleSelf: Color(0xFF0E4A63),
    bubbleOther: Color(0xFF13263F),
    backIcon: Color(0xFFD7E7FF),
    appBarGradient: [Color(0xFF123047), Color(0xFF081120)],
    bgImage: 'assets/images/theme_bg_cyber.jpg',
  );

  /// 矩阵绿洲（终端绿）
  static const matrixGreen = AppThemePalette(
    id: 'matrixGreen',
    nameZh: '矩阵绿洲',
    nameEn: 'Matrix Oasis',
    isDark: true,
    primary: Color(0xFF22E06C),
    scaffoldBg: Color(0xFF060D08),
    surface: Color(0xFF0B1810),
    subBg: Color(0xFF12241A),
    divider: Color(0xFF1E3A28),
    textPrimary: Color(0xFFD6FFE6),
    textSecondary: Color(0xFF6FA98A),
    bubbleSelf: Color(0xFF0E3D22),
    bubbleOther: Color(0xFF12241A),
    backIcon: Color(0xFFD6FFE6),
    appBarGradient: [Color(0xFF14301F), Color(0xFF060D08)],
    bgImage: 'assets/images/theme_bg_matrix.jpg',
  );

  /// 霓虹脉冲（赛博紫粉）
  static const neonPurple = AppThemePalette(
    id: 'neonPurple',
    nameZh: '霓虹脉冲',
    nameEn: 'Neon Pulse',
    isDark: true,
    primary: Color(0xFFB14BFF),
    scaffoldBg: Color(0xFF0E0718),
    surface: Color(0xFF170C26),
    subBg: Color(0xFF221338),
    divider: Color(0xFF38205C),
    textPrimary: Color(0xFFEBDCFF),
    textSecondary: Color(0xFF9A7EC2),
    bubbleSelf: Color(0xFF3A1366),
    bubbleOther: Color(0xFF221338),
    backIcon: Color(0xFFEBDCFF),
    appBarGradient: [Color(0xFF2A1442), Color(0xFF0E0718)],
    bgImage: 'assets/images/theme_bg_neon.jpg',
  );

  /// 机甲赤焰（战斗红）
  static const mechaRed = AppThemePalette(
    id: 'mechaRed',
    nameZh: '机甲赤焰',
    nameEn: 'Mecha Crimson',
    isDark: true,
    primary: Color(0xFFFF4D5E),
    scaffoldBg: Color(0xFF120708),
    surface: Color(0xFF1D0C0F),
    subBg: Color(0xFF2A1216),
    divider: Color(0xFF45202A),
    textPrimary: Color(0xFFFFE4E8),
    textSecondary: Color(0xFFC08A93),
    bubbleSelf: Color(0xFF57121C),
    bubbleOther: Color(0xFF2A1216),
    backIcon: Color(0xFFFFE4E8),
    appBarGradient: [Color(0xFF3A1116), Color(0xFF120708)],
    bgImage: 'assets/images/theme_bg_mecha.jpg',
  );

  /// 极地冰蓝（深空蓝）
  static const iceBlue = AppThemePalette(
    id: 'iceBlue',
    nameZh: '极地冰蓝',
    nameEn: 'Polar Ice',
    isDark: true,
    primary: Color(0xFF4DA6FF),
    scaffoldBg: Color(0xFF070D1A),
    surface: Color(0xFF0C1526),
    subBg: Color(0xFF13203A),
    divider: Color(0xFF1F3358),
    textPrimary: Color(0xFFDCEAFF),
    textSecondary: Color(0xFF7C93B8),
    bubbleSelf: Color(0xFF10386B),
    bubbleOther: Color(0xFF13203A),
    backIcon: Color(0xFFDCEAFF),
    appBarGradient: [Color(0xFF16294A), Color(0xFF070D1A)],
    bgImage: 'assets/images/theme_bg_ice.jpg',
  );

  static const all = [classic, cyberCyan, matrixGreen, neonPurple, mechaRed, iceBlue];

  static AppThemePalette byId(String id) =>
      all.firstWhere((e) => e.id == id, orElse: () => classic);
}

/// 主题服务：持久化 + 切换 + ThemeData 构建
class AppThemeService extends ChangeNotifier {
  AppThemeService._();
  static final AppThemeService _instance = AppThemeService._();
  static const String _spKey = 'appThemeStyleId';

  AppThemePalette _current = AppThemePalettes.classic;
  bool _inited = false;

  static void init() {
    final self = _instance;
    if (self._inited) return;
    self._inited = true;
    final id = SpUtil().getString(_spKey, defValue: '') ?? '';
    self._current = AppThemePalettes.byId(id);
  }

  static AppThemePalette get current {
    if (!_instance._inited) init();
    return _instance._current;
  }

  static AppThemeService get instance => _instance;

  /// 主题版本号：apply() 自增，GetMaterialApp 以此作 ValueKey 强制重建整树。
  /// 页面颜色来自 Styles 静态 getter 且 Navigator 缓存页面实例，
  /// 仅 notify/changeTheme 不会刷新已打开页面，必须换 key 重建。
  static int version = 0;
  static String? _remountInitial;
  static String? _pushAfter;

  static String? consumeRemountInitial() {
    final r = _remountInitial;
    _remountInitial = null;
    return r;
  }

  static String? takePushAfter() {
    final r = _pushAfter;
    _pushAfter = null;
    return r;
  }

  static void apply(AppThemePalette palette,
      {String? remountInitial, String? pushAfter}) {
    _instance._current = palette;
    SpUtil().putString(_spKey, palette.id);
    _remountInitial = remountInitial ?? Get.currentRoute;
    _pushAfter = pushAfter;
    version++;
    _instance.notifyListeners();
  }

  static ThemeData buildTheme() {
    final p = current;
    final base = p.isDark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: p.scaffoldBg,
      canvasColor: p.surface,
      appBarTheme: AppBarTheme(
        color: p.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: p.textPrimary),
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: p.primary),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey;
          }
          if (states.contains(WidgetState.selected)) {
            return p.primary;
          }
          return p.isDark ? p.subBg : Colors.white;
        }),
        side: BorderSide(
          color: p.isDark ? p.textSecondary : Colors.grey.shade500,
          width: 1,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          ),
          textStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 16.sp, color: p.textPrimary),
          ),
          foregroundColor: WidgetStatePropertyAll(p.textPrimary),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData().copyWith(
        color: p.primary,
        linearTrackColor: p.subBg,
        circularTrackColor: p.subBg,
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: p.isDark ? Brightness.dark : Brightness.light,
        primaryColor: p.primary,
        barBackgroundColor: p.surface,
        applyThemeToAll: true,
        textTheme: const CupertinoTextThemeData().copyWith(
          navActionTextStyle:
              TextStyle(color: p.textPrimary, fontSize: 17.sp),
          actionTextStyle: TextStyle(color: p.primary, fontSize: 17.sp),
          textStyle: TextStyle(color: p.textPrimary, fontSize: 17.sp),
          navLargeTitleTextStyle:
              TextStyle(color: p.textPrimary, fontSize: 20.sp),
          navTitleTextStyle: TextStyle(color: p.textPrimary, fontSize: 17.sp),
          pickerTextStyle: TextStyle(color: p.textPrimary, fontSize: 17.sp),
          tabLabelTextStyle: TextStyle(color: p.textPrimary, fontSize: 17.sp),
          dateTimePickerTextStyle:
              TextStyle(color: p.textPrimary, fontSize: 17.sp),
        ),
      ),
    );
  }
}


/// 主题页面背景：包一层 body 即可获得当前主题的背景图（无背景图时透传 child）
class ThemedBackground extends StatelessWidget {
  final Widget child;

  const ThemedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bg = AppThemeService.current.bgImage;
    if (bg == null) return child;
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(bg, package: 'openim_common'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
