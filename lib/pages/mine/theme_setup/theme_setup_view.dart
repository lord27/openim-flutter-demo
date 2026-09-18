import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'theme_setup_logic.dart';

class ThemeSetupPage extends StatelessWidget {
  final logic = Get.find<ThemeSetupLogic>();

  ThemeSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.themeAppearance),
      backgroundColor: Styles.c_F8F9FA,
      body: Obx(() => GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.w,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.82,
            ),
            itemCount: logic.palettes.length,
            itemBuilder: (context, i) => _buildCard(logic.palettes[i]),
          )),
    );
  }

  Widget _buildCard(AppThemePalette p) {
    final selected = logic.currentId.value == p.id;
    return GestureDetector(
      onTap: () => logic.switchTheme(p),
      child: Container(
        decoration: BoxDecoration(
          color: Styles.c_surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? p.primary : Colors.transparent,
            width: 2,
          ),
        ),
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: p.appBarGradient,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: p.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: p.primary.withOpacity(.5),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Icon(Icons.bolt, color: p.textPrimary, size: 24.w),
                  ),
                ),
              ),
            ),
            10.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: p.localName.toText..style = Styles.ts_0C1C33_17sp,
                ),
                if (selected)
                  Icon(Icons.check_circle, color: p.primary, size: 20.w),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
