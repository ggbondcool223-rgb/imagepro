import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_compose/pages/image_compose_freeze/image_compose_freeze_binding.dart';
import 'package:image_compose/pages/image_compose_freeze/image_compose_freeze_view.dart';
import 'package:image_compose/pages/image_compose_home/image_compose_home_write.dart';
import '../pages/image_compose_tab/image_compose_tab_binding.dart';
import '../pages/image_compose_tab/image_compose_tab_view.dart';
import '../pages/image_compose_home/image_compose_home_binding.dart';
import '../pages/image_compose_home/image_compose_home_view.dart';
import '../pages/image_compose_edit/image_compose_edit_binding.dart';
import '../pages/image_compose_edit/image_compose_edit_view.dart';
import '../pages/image_compose_records/image_compose_records_binding.dart';
import '../pages/image_compose_records/image_compose_records_view.dart';
import '../pages/image_compose_preview/image_compose_preview_binding.dart';
import '../pages/image_compose_preview/image_compose_preview_view.dart';
import '../pages/image_compose_settings/image_compose_settings_binding.dart';
import '../pages/image_compose_settings/image_compose_settings_view.dart';
import 'db_image_compose/data.dart';

Color primaryColor = const Color(0xFF00D4FF);
Color bgColor = const Color(0xFF0B0B1E);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Get.put(DBImageCompose());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Image Compose',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: bgColor,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                foregroundColor: Colors.white,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                unselectedItemColor: Colors.white,
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                  color: Colors.white,
                ),
                selectedItemColor: primaryColor,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: const Color(0xFF0B0B1E),
              )
          ),
          initialRoute: '/',
          getPages: Compose,
        );
      },
    );
  }
}
List<GetPage<dynamic>> Compose = [
  GetPage(
    name: '/',
    page: () => const ImageComposeFreezeView(),
    binding: ImageComposeFreezeBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/image_compose_tab',
    page: () => const ImageComposeTabView(),
    binding: ImageComposeTabBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/image_compose_home',
    page: () => const ImageComposeHomeView(),
    binding: ImageComposeHomeBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/image_compose_write',
    page: () => ImageComposeHomeWrite(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/image_compose_edit',
    page: () => const ImageComposeEditView(),
    binding: ImageComposeEditBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/image_compose_records',
    page: () => const ImageComposeRecordsView(),
    binding: ImageComposeRecordsBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/image_compose_preview',
    page: () => const ImageComposePreviewView(),
    binding: ImageComposePreviewBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/image_compose_settings',
    page: () => const ImageComposeSettingsView(),
    binding: ImageComposeSettingsBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
];
