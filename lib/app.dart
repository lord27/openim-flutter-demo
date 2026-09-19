import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'core/controller/im_controller.dart';
import 'routes/app_pages.dart';
import 'widgets/app_view.dart';

class ChatApp extends StatefulWidget {
  const ChatApp({Key? key}) : super(key: key);

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  @override
  void initState() {
    super.initState();
    AppThemeService.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    AppThemeService.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final remountInitial = AppThemeService.consumeRemountInitial();
    final pushAfter = AppThemeService.takePushAfter();
    if (pushAfter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute != pushAfter) Get.toNamed(pushAfter);
      });
    }
    return AppView(
      builder: (locale, builder) => GetMaterialApp(
        key: ValueKey('app_theme_v${AppThemeService.version}'),
        debugShowCheckedModeBanner: false,
        enableLog: true,
        builder: builder,
        translations: TranslationService(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        fallbackLocale: TranslationService.fallbackLocale,
        locale: locale,
        localeResolutionCallback: (locale, list) {
          Get.locale ??= locale;
          return locale;
        },
        supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
        getPages: AppPages.routes,
        initialBinding: InitBinding(),
        initialRoute: remountInitial ?? AppRoutes.splash,
        theme: AppThemeService.buildTheme(),
      ),
    );
  }
}

class InitBinding extends Bindings {
  @override
  void dependencies() {
    // permanent + isRegistered 守卫：主题重建整树时复用实例，
    // 避免 IM SDK 重复 init / 推送重复注册。
    if (!Get.isRegistered<IMController>()) {
      Get.put<IMController>(IMController(), permanent: true);
    }
    if (!Get.isRegistered<PushController>()) {
      Get.put<PushController>(PushController(), permanent: true);
    }
    if (!Get.isRegistered<CacheController>()) {
      Get.put<CacheController>(CacheController(), permanent: true);
    }
  }
}
