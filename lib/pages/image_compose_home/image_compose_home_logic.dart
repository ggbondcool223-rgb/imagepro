import 'package:get/get.dart';

class ImageComposeHomeLogic extends GetxController {
  final List<Map<String, dynamic>> themes = [
    {
      'id': 1,
      'name': 'Regular',
      'description': 'Classic composition',
    },
    {
      'id': 2,
      'name': 'Mask',
      'description': 'Creative mask effects',
    },
    {
      'id': 3,
      'name': 'Tattoo',
      'description': 'Personal tattoo style',
    },
    {
      'id': 4,
      'name': 'Steampunk',
      'description': 'Retro mechanical style',
    },
    {
      'id': 5,
      'name': 'Superhero',
      'description': 'Hero theme style',
    },
    {
      'id': 6,
      'name': 'Text Pattern',
      'description': 'Text art effects',
    },
    {
      'id': 7,
      'name': 'Classical',
      'description': 'Classical art style',
    },
    {
      'id': 8,
      'name': 'Cartoon',
      'description': 'Cartoon style',
    },
  ];

  void onThemeTap(int index) {
    final themeId = themes[index]['id'] as int;
    Get.toNamed(
      '/image_compose_edit',
      arguments: {'themeId': themeId, 'themeName': themes[index]['name']},
    );
  }
}

