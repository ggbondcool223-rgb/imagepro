import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_compose/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import '../../db_image_compose/data.dart';
import '../../db_image_compose/image_compose_entity.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:image/image.dart' as img;
import 'mask_clipper.dart';
import 'mask_shape_painter.dart';
import 'blend_mode_preview_painter.dart';

class ImageComposeEditLogic extends GetxController {
  final DBImageCompose db = Get.find<DBImageCompose>();

  int themeId = 1;
  String themeName = 'Regular';

  Uint8List? backgroundImageData;
  Uint8List? foregroundImageData;

  String? selectedForegroundImagePath;
  String? selectedBackgroundImagePath;

  double foregroundOpacity = 1.0;
  double backgroundOpacity = 1.0;

  Offset foregroundPosition = const Offset(0, 0);
  double foregroundWidth = 0;
  double foregroundHeight = 0;

  double get backgroundContainerWidth => ScreenUtil().screenWidth;

  double get backgroundContainerHeight => ScreenUtil().screenWidth;

  String selectedBlendMode = 'normal';
  String selectedMask = 'none';
  String selectedFilter = 'none';

  bool foregroundAdjustActive = false;
  bool backgroundAdjustActive = false;

  String foregroundOperationMode = 'none';

  Offset topLeftOffset = Offset.zero;
  Offset topRightOffset = Offset.zero;
  Offset bottomLeftOffset = Offset.zero;
  Offset bottomRightOffset = Offset.zero;

  String draggingControlPoint = 'none';

  Offset _dragStartPosition = Offset.zero;
  Offset _dragStartTopLeft = Offset.zero;
  Offset _dragStartTopRight = Offset.zero;
  Offset _dragStartBottomLeft = Offset.zero;
  Offset _dragStartBottomRight = Offset.zero;

  Offset _dragStartForegroundPosition = Offset.zero;
  double _dragStartForegroundWidth = 0;
  double _dragStartForegroundHeight = 0;

  List<Map<String, dynamic>> history = [];
  int historyIndex = -1;

  ScreenshotController screenshotController = ScreenshotController();

  List<String> getFrontImages(int themeId) {
    if (themeId == 1) return [];
    return List.generate(
        4, (index) => 'assets/bg_${themeId - 1}_front$index.png');
  }

  List<String> getBehindImages(int themeId) {
    if (themeId == 1) return [];
    return List.generate(
        4, (index) => 'assets/bg_${themeId - 1}_behind$index.png');
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      themeId = args['themeId'] ?? 1;
      themeName = args['themeName'] ?? 'Regular';
    }

    if (themeId != 1) {
      final frontImages = getFrontImages(themeId);
      final behindImages = getBehindImages(themeId);
      if (frontImages.isNotEmpty) {
        _loadImageFromAssets(frontImages[0], true);
      }
      if (behindImages.isNotEmpty) {
        _loadImageFromAssets(behindImages[0], false);
      }
    }
    update();
  }

  Future<void> _loadImageFromAssets(String assetPath, bool isForeground) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      if (isForeground) {
        foregroundImageData = bytes;
        foregroundWidth = backgroundContainerWidth;
        foregroundHeight = backgroundContainerHeight;
        foregroundPosition = const Offset(0, 0);
      } else {
        backgroundImageData = bytes;
      }
      update();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load image: $e');
    }
  }

  Future<void> onSelectForegroundFromGallery() async {
    try {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        Fluttertoast.showToast(msg: 'Permission denied');
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        foregroundImageData = bytes;
        foregroundWidth = backgroundContainerWidth;
        foregroundHeight = backgroundContainerHeight;
        foregroundPosition = const Offset(0, 0);
        addToHistory();
        update();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to select image');
    }
  }

  Future<void> onSelectBackgroundFromGallery() async {
    try {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        Fluttertoast.showToast(msg: 'Permission denied');
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        backgroundImageData = bytes;
        addToHistory();
        update();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to select image');
    }
  }

  Future<void> onSelectForegroundImage(String imagePath) async {
    try {
      if (imagePath.startsWith('assets/')) {
        await _loadImageFromAssets(imagePath, true);
      } else {
        final file = File(imagePath);
        final bytes = await file.readAsBytes();
        foregroundImageData = bytes;
        selectedForegroundImagePath = imagePath;
      }
      foregroundWidth = backgroundContainerWidth;
      foregroundHeight = backgroundContainerHeight;
      foregroundPosition = const Offset(0, 0);
      addToHistory();
      update();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load image');
    }
  }

  Future<void> onSelectBackgroundImage(String imagePath) async {
    try {
      if (imagePath.startsWith('assets/')) {
        await _loadImageFromAssets(imagePath, false);
      } else {
        final file = File(imagePath);
        final bytes = await file.readAsBytes();
        backgroundImageData = bytes;
        selectedBackgroundImagePath = imagePath;
      }
      addToHistory();
      update();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load image');
    }
  }

  BlendMode _getBlendMode(String mode) {
    switch (mode) {
      case 'normal':
        return BlendMode.srcOver;
      case 'overlay':
        return BlendMode.overlay;
      case 'softLight':
        return BlendMode.softLight;
      case 'darken':
        return BlendMode.darken;
      case 'exclusion':
        return BlendMode.exclusion;
      case 'saturation':
        return BlendMode.saturation;
      default:
        return BlendMode.srcOver;
    }
  }

  List<String> get blendModes => [
        'normal',
        'overlay',
        'softLight',
        'darken',
        'exclusion',
        'saturation',
      ];

  Future<List<ui.Image>> _loadImagesForPreview(
      Uint8List foregroundData, Uint8List? backgroundData) async {
    final List<ui.Image> images = [];

    final foregroundCodec = await ui.instantiateImageCodec(foregroundData);
    final foregroundFrame = await foregroundCodec.getNextFrame();
    images.add(foregroundFrame.image);

    if (backgroundData != null) {
      final backgroundCodec = await ui.instantiateImageCodec(backgroundData);
      final backgroundFrame = await backgroundCodec.getNextFrame();
      images.add(backgroundFrame.image);
    }

    return images;
  }

  void onBlendModeTap() {
    final String originalBlendMode = selectedBlendMode;
    String tempBlendMode = selectedBlendMode;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: 500.h,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Blend Mode',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(16.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: blendModes.length,
                      itemBuilder: (context, index) {
                        final mode = blendModes[index];
                        final isSelected = tempBlendMode == mode;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              tempBlendMode = mode;
                            });
                            selectedBlendMode = mode;
                            update();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00D4FF).withOpacity(0.2)
                                  : Colors.grey[800]!.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00D4FF)
                                    : Colors.grey[700]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (foregroundImageData != null)
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: mode == 'normal'
                                            ? Image.memory(
                                                foregroundImageData!,
                                                fit: BoxFit.cover,
                                              )
                                            : FutureBuilder<List<ui.Image>>(
                                                future: _loadImagesForPreview(
                                                    foregroundImageData!, null),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return Container();
                                                  }
                                                  final images = snapshot.data!;
                                                  final foregroundImg =
                                                      images[0];

                                                  return CustomPaint(
                                                    painter:
                                                        BlendModePreviewPainter(
                                                      foregroundImage:
                                                          foregroundImg,
                                                      backgroundImage: null,
                                                      blendMode:
                                                          _getBlendMode(mode),
                                                    ),
                                                    child: Container(),
                                                  );
                                                },
                                              ),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        mode,
                                        style: TextStyle(
                                          color: isSelected
                                              ? const Color(0xFF00D4FF)
                                              : Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        SizedBox(width: 4.w),
                                        const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF00D4FF),
                                          size: 16,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  List<String> get masks => [
        'none',
        'featherSquare',
        'featherTriangle',
        'featherCircle',
        'featherHexagon',
        'halfFeatherSquare',
        'halfFeatherTriangle',
        'halfFeatherCircle',
        'halfFeatherHexagon',
        'solidSquare',
        'solidTriangle',
        'solidCircle',
        'solidHexagon',
      ];

  void onMaskTap() {
    final String originalMask = selectedMask;
    String tempMask = selectedMask;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: 500.h,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mask',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(16.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: masks.length,
                      itemBuilder: (context, index) {
                        final mask = masks[index];
                        final isSelected = tempMask == mask;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              tempMask = mask;
                            });
                            selectedMask = mask;
                            update();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00D4FF).withOpacity(0.2)
                                  : Colors.grey[800]!.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00D4FF)
                                    : Colors.grey[700]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: mask == 'none'
                                        ? null
                                        : _buildMaskPreview(mask),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _getMaskName(mask),
                                        style: TextStyle(
                                          color: isSelected
                                              ? const Color(0xFF00D4FF)
                                              : Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        SizedBox(width: 4.w),
                                        const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF00D4FF),
                                          size: 16,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String _getMaskName(String mask) {
    switch (mask) {
      case 'none':
        return 'None';
      case 'featherSquare':
        return 'Feather Square';
      case 'featherTriangle':
        return 'Feather Triangle';
      case 'featherCircle':
        return 'Feather Circle';
      case 'featherHexagon':
        return 'Feather Hexagon';
      case 'halfFeatherSquare':
        return 'Half Feather Square';
      case 'halfFeatherTriangle':
        return 'Half Feather Triangle';
      case 'halfFeatherCircle':
        return 'Half Feather Circle';
      case 'halfFeatherHexagon':
        return 'Half Feather Hexagon';
      case 'solidSquare':
        return 'Solid Square';
      case 'solidTriangle':
        return 'Solid Triangle';
      case 'solidCircle':
        return 'Solid Circle';
      case 'solidHexagon':
        return 'Solid Hexagon';
      default:
        return mask;
    }
  }

  Widget _buildMaskPreview(String mask) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: MaskShapePainter(maskType: mask),
      ),
    );
  }

  ColorFilter? _getColorFilter(String filter) {
    switch (filter) {
      case 'none':
        return null;
      case 'vintage':
        return const ColorFilter.matrix([
          0.9,
          0.5,
          0.1,
          0,
          0,
          0.3,
          0.8,
          0.1,
          0,
          0,
          0.2,
          0.3,
          0.5,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case 'blackWhite':
        return const ColorFilter.matrix([
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case 'sepia':
        return const ColorFilter.matrix([
          0.393,
          0.769,
          0.189,
          0,
          0,
          0.349,
          0.686,
          0.168,
          0,
          0,
          0.272,
          0.534,
          0.131,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case 'warm':
        return const ColorFilter.matrix([
          2.0,
          0.0,
          0.0,
          0,
          0,
          0.0,
          1.5,
          0.0,
          0,
          0,
          0.0,
          0.0,
          0.3,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case 'cool':
        return const ColorFilter.matrix([
          0.3,
          0.0,
          0.0,
          0,
          0,
          0.0,
          1.0,
          0.0,
          0,
          0,
          0.0,
          0.0,
          2.0,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case 'bright':
        return const ColorFilter.matrix([
          2.2,
          0.0,
          0.0,
          0,
          0.3,
          0.0,
          2.2,
          0.0,
          0,
          0.3,
          0.0,
          0.0,
          2.2,
          0,
          0.3,
          0,
          0,
          0,
          1,
          0,
        ]);
      case 'dark':
        return const ColorFilter.matrix([
          0.3,
          0.0,
          0.0,
          0,
          0,
          0.0,
          0.3,
          0.0,
          0,
          0,
          0.0,
          0.0,
          0.3,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case 'saturate':
        return const ColorFilter.matrix([
          2.5,
          -0.8,
          -0.8,
          0,
          0,
          -0.5,
          2.5,
          -0.5,
          0,
          0,
          -0.5,
          -0.5,
          2.5,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case 'desaturate':
        return const ColorFilter.matrix([
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case 'contrast':
        return const ColorFilter.matrix([
          2.5,
          0.0,
          0.0,
          0,
          -0.75,
          0.0,
          2.5,
          0.0,
          0,
          -0.75,
          0.0,
          0.0,
          2.5,
          0,
          -0.75,
          0,
          0,
          0,
          1,
          0,
        ]);
      case 'blur':
        return null;
      default:
        return null;
    }
  }

  List<String> get filters => [
        'none',
        'vintage',
        'blackWhite',
        'sepia',
        'warm',
        'cool',
        'bright',
        'dark',
        'saturate',
        'desaturate',
        'contrast',
        'blur',
      ];

  void onFilterTap() {
    final String originalFilter = selectedFilter;
    String tempFilter = selectedFilter;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: 500.h,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(16.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: filters.length,
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final isSelected = tempFilter == filter;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              tempFilter = filter;
                            });
                            selectedFilter = filter;
                            update();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00D4FF).withOpacity(0.2)
                                  : Colors.grey[800]!.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00D4FF)
                                    : Colors.grey[700]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: _buildFilterColorPreview(filter),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        filter,
                                        style: TextStyle(
                                          color: isSelected
                                              ? const Color(0xFF00D4FF)
                                              : Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        SizedBox(width: 4.w),
                                        const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF00D4FF),
                                          size: 16,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildFilterColorPreview(String filter) {
    Widget colorBlock = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.indigo,
            Colors.purple,
          ],
        ),
      ),
    );

    if (filter == 'none') {
      return colorBlock;
    } else if (filter == 'blur') {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[400]!,
              Colors.grey[600]!,
              Colors.grey[800]!,
            ],
          ),
        ),
      );
    } else {
      final colorFilter = _getColorFilter(filter);
      if (colorFilter != null) {
        return ColorFiltered(
          colorFilter: colorFilter,
          child: colorBlock,
        );
      }
      return colorBlock;
    }
  }

  void onForegroundAdjustTap() {
    foregroundAdjustActive = !foregroundAdjustActive;
    backgroundAdjustActive = false;
    if (!foregroundAdjustActive) {
      foregroundOperationMode = 'none';
    }
    update();
  }

  void onForegroundMoveTap() {
    if (foregroundOperationMode == 'move') {
      foregroundOperationMode = 'none';
    } else {
      foregroundOperationMode = 'move';
    }
    update();
  }

  void onForegroundScaleTap() {
    if (foregroundOperationMode == 'scale') {
      foregroundOperationMode = 'none';
    } else {
      foregroundOperationMode = 'scale';
    }
    update();
  }

  void onForegroundTransformTap() {
    foregroundOperationMode =
        foregroundOperationMode == 'transform' ? 'none' : 'transform';
    update();
  }

  List<Offset> getForegroundCorners() {
    final width =
        foregroundWidth > 0 ? foregroundWidth : backgroundContainerWidth;
    final height =
        foregroundHeight > 0 ? foregroundHeight : backgroundContainerHeight;

    return [
      foregroundPosition + topLeftOffset,
      Offset(foregroundPosition.dx + width, foregroundPosition.dy) +
          topRightOffset,
      Offset(foregroundPosition.dx, foregroundPosition.dy + height) +
          bottomLeftOffset,
      Offset(foregroundPosition.dx + width, foregroundPosition.dy + height) +
          bottomRightOffset,
    ];
  }

  List<Offset> getForegroundEdgeCenters() {
    final width =
        foregroundWidth > 0 ? foregroundWidth : backgroundContainerWidth;
    final height =
        foregroundHeight > 0 ? foregroundHeight : backgroundContainerHeight;

    final corners = getForegroundCorners();

    return [
      Offset((corners[0].dx + corners[1].dx) / 2,
          (corners[0].dy + corners[1].dy) / 2),
      Offset((corners[1].dx + corners[3].dx) / 2,
          (corners[1].dy + corners[3].dy) / 2),
      Offset((corners[2].dx + corners[3].dx) / 2,
          (corners[2].dy + corners[3].dy) / 2),
      Offset((corners[0].dx + corners[2].dx) / 2,
          (corners[0].dy + corners[2].dy) / 2),
    ];
  }

  String? getControlPointAt(Offset position, double threshold) {
    if (foregroundOperationMode == 'scale') {
      final edges = getForegroundEdgeCenters();
      for (int i = 0; i < edges.length; i++) {
        if ((position - edges[i]).distance < threshold) {
          return ['top', 'right', 'bottom', 'left'][i];
        }
      }
    } else if (foregroundOperationMode == 'transform') {
      final corners = getForegroundCorners();
      for (int i = 0; i < corners.length; i++) {
        if ((position - corners[i]).distance < threshold) {
          return ['topLeft', 'topRight', 'bottomLeft', 'bottomRight'][i];
        }
      }
    }
    return null;
  }

  void onControlPointDragStart(String controlPointType, Offset globalPosition) {
    draggingControlPoint = controlPointType;
    _dragStartPosition = globalPosition;
    _dragStartTopLeft = topLeftOffset;
    _dragStartTopRight = topRightOffset;
    _dragStartBottomLeft = bottomLeftOffset;
    _dragStartBottomRight = bottomRightOffset;

    _dragStartForegroundPosition = foregroundPosition;
    _dragStartForegroundWidth =
        foregroundWidth > 0 ? foregroundWidth : backgroundContainerWidth;
    _dragStartForegroundHeight =
        foregroundHeight > 0 ? foregroundHeight : backgroundContainerHeight;

    update();
  }

  void onControlPointDragUpdate(
      String controlPointType, Offset globalPosition) {
    if (draggingControlPoint != controlPointType) {
      draggingControlPoint = controlPointType;
    }

    final delta = globalPosition - _dragStartPosition;

    if (foregroundOperationMode == 'scale') {
      final sensitivity = 0.5;
      final scaledDelta = delta * sensitivity;

      final startWidth = _dragStartForegroundWidth;
      final startHeight = _dragStartForegroundHeight;
      final startPosition = _dragStartForegroundPosition;

      final startTopLeftOffset = _dragStartTopLeft;
      final startTopRightOffset = _dragStartTopRight;
      final startBottomLeftOffset = _dragStartBottomLeft;
      final startBottomRightOffset = _dragStartBottomRight;

      switch (draggingControlPoint) {
        case 'top':
          final newHeight = (startHeight - scaledDelta.dy)
              .clamp(50.0, backgroundContainerHeight * 2);
          final heightScale = newHeight / startHeight;
          foregroundHeight = newHeight;
          foregroundPosition = Offset(
              startPosition.dx, startPosition.dy + startHeight - newHeight);
          topLeftOffset = Offset(
              startTopLeftOffset.dx, startTopLeftOffset.dy * heightScale);
          topRightOffset = Offset(
              startTopRightOffset.dx, startTopRightOffset.dy * heightScale);
          bottomLeftOffset =
              Offset(startBottomLeftOffset.dx, startBottomLeftOffset.dy);
          bottomRightOffset =
              Offset(startBottomRightOffset.dx, startBottomRightOffset.dy);
          break;
        case 'right':
          final newWidth = (startWidth + scaledDelta.dx)
              .clamp(50.0, backgroundContainerWidth * 2);
          final widthScale = newWidth / startWidth;
          foregroundWidth = newWidth;
          foregroundPosition = startPosition;
          topLeftOffset = Offset(startTopLeftOffset.dx, startTopLeftOffset.dy);
          topRightOffset = Offset(
              startTopRightOffset.dx * widthScale, startTopRightOffset.dy);
          bottomLeftOffset =
              Offset(startBottomLeftOffset.dx, startBottomLeftOffset.dy);
          bottomRightOffset = Offset(startBottomRightOffset.dx * widthScale,
              startBottomRightOffset.dy);
          break;
        case 'bottom':
          final newHeight = (startHeight + scaledDelta.dy)
              .clamp(50.0, backgroundContainerHeight * 2);
          final heightScale = newHeight / startHeight;
          foregroundHeight = newHeight;
          foregroundPosition = startPosition;
          topLeftOffset = Offset(startTopLeftOffset.dx, startTopLeftOffset.dy);
          topRightOffset =
              Offset(startTopRightOffset.dx, startTopRightOffset.dy);
          bottomLeftOffset = Offset(
              startBottomLeftOffset.dx, startBottomLeftOffset.dy * heightScale);
          bottomRightOffset = Offset(startBottomRightOffset.dx,
              startBottomRightOffset.dy * heightScale);
          break;
        case 'left':
          final newWidth = (startWidth - scaledDelta.dx)
              .clamp(50.0, backgroundContainerWidth * 2);
          final widthScale = newWidth / startWidth;
          foregroundWidth = newWidth;
          foregroundPosition = Offset(
              startPosition.dx + startWidth - newWidth, startPosition.dy);
          topLeftOffset =
              Offset(startTopLeftOffset.dx * widthScale, startTopLeftOffset.dy);
          topRightOffset =
              Offset(startTopRightOffset.dx, startTopRightOffset.dy);
          bottomLeftOffset = Offset(
              startBottomLeftOffset.dx * widthScale, startBottomLeftOffset.dy);
          bottomRightOffset =
              Offset(startBottomRightOffset.dx, startBottomRightOffset.dy);
          break;
      }
    } else if (foregroundOperationMode == 'transform') {
      final sensitivity = 0.5;
      final scaledDelta = delta * sensitivity;

      switch (draggingControlPoint) {
        case 'topLeft':
          topLeftOffset = _dragStartTopLeft + scaledDelta;
          break;
        case 'topRight':
          topRightOffset = _dragStartTopRight + scaledDelta;
          break;
        case 'bottomLeft':
          bottomLeftOffset = _dragStartBottomLeft + scaledDelta;
          break;
        case 'bottomRight':
          bottomRightOffset = _dragStartBottomRight + scaledDelta;
          break;
      }
    }

    update();
  }

  void onControlPointDragEnd() {
    if (draggingControlPoint != 'none') {
      addToHistory();
      draggingControlPoint = 'none';
      update();
    }
  }

  void onBackgroundAdjustTap() {
    backgroundAdjustActive = !backgroundAdjustActive;
    foregroundAdjustActive = false;
    update();
  }

  void onForegroundOpacityChanged(double value) {
    foregroundOpacity = value;
    addToHistory();
    update();
  }

  void onBackgroundOpacityChanged(double value) {
    backgroundOpacity = value;
    addToHistory();
    update();
  }

  Future<void> onForegroundCropTap() async {
    if (foregroundImageData == null) return;
    try {
      final tempFile = await _saveTempFile(foregroundImageData!);

      Uint8List? editedImageData;
      await Navigator.push(
        Get.context!,
        MaterialPageRoute(
          builder: (context) => ProImageEditor.file(
            tempFile,
            configs: ProImageEditorConfigs(
                heroTag: 'foreground_crop', ),
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List editedImage) async {
                editedImageData = editedImage;
                Navigator.pop(context);
              },
            ),
          ),
        ),
      );

      if (editedImageData != null) {
        foregroundImageData = editedImageData;
        addToHistory();
        update();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Crop failed: $e');
    }
  }

  Future<void> onBackgroundCropTap() async {
    if (backgroundImageData == null) return;
    try {
      final tempFile = await _saveTempFile(backgroundImageData!);

      Uint8List? editedImageData;
      await Navigator.push(
        Get.context!,
        MaterialPageRoute(
          builder: (context) => ProImageEditor.file(
            tempFile,
            configs: ProImageEditorConfigs(
              heroTag: 'background_crop',
            ),
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List editedImage) async {
                editedImageData = editedImage;
                Navigator.pop(context);
              },
            ),
          ),
        ),
      );

      if (editedImageData != null) {
        backgroundImageData = editedImageData;
        addToHistory();
        update();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Crop failed: $e');
    }
  }

  Future<File> _saveTempFile(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final file = File(
        '${directory.path}/temp_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  void onUndoTap() {
    if (historyIndex > 0) {
      historyIndex--;
      restoreFromHistory();
      update();
    }
  }

  void onRedoTap() {
    if (historyIndex < history.length - 1) {
      historyIndex++;
      restoreFromHistory();
      update();
    }
  }

  void addToHistory() {
    history = history.sublist(0, historyIndex + 1);
    history.add({
      'foregroundImageData': foregroundImageData != null
          ? base64Encode(foregroundImageData!)
          : null,
      'backgroundImageData': backgroundImageData != null
          ? base64Encode(backgroundImageData!)
          : null,
      'foregroundOpacity': foregroundOpacity,
      'backgroundOpacity': backgroundOpacity,
      'foregroundPosition': foregroundPosition,
      'foregroundWidth': foregroundWidth,
      'foregroundHeight': foregroundHeight,
      'topLeftOffset': topLeftOffset,
      'topRightOffset': topRightOffset,
      'bottomLeftOffset': bottomLeftOffset,
      'bottomRightOffset': bottomRightOffset,
      'selectedBlendMode': selectedBlendMode,
      'selectedMask': selectedMask,
      'selectedFilter': selectedFilter,
    });
    historyIndex = history.length - 1;
    if (history.length > 50) {
      history.removeAt(0);
      historyIndex--;
    }
  }

  void restoreFromHistory() {
    if (historyIndex >= 0 && historyIndex < history.length) {
      final state = history[historyIndex];
      if (state['foregroundImageData'] != null) {
        foregroundImageData = base64Decode(state['foregroundImageData']);
      } else {
        foregroundImageData = null;
      }
      if (state['backgroundImageData'] != null) {
        backgroundImageData = base64Decode(state['backgroundImageData']);
      } else {
        backgroundImageData = null;
      }
      foregroundOpacity = state['foregroundOpacity'] ?? 1.0;
      backgroundOpacity = state['backgroundOpacity'] ?? 1.0;
      foregroundPosition = state['foregroundPosition'] ?? const Offset(0, 0);
      foregroundWidth = state['foregroundWidth'] ?? backgroundContainerWidth;
      foregroundHeight = state['foregroundHeight'] ?? backgroundContainerHeight;
      topLeftOffset = state['topLeftOffset'] ?? Offset.zero;
      topRightOffset = state['topRightOffset'] ?? Offset.zero;
      bottomLeftOffset = state['bottomLeftOffset'] ?? Offset.zero;
      bottomRightOffset = state['bottomRightOffset'] ?? Offset.zero;
      selectedBlendMode = state['selectedBlendMode'] ?? 'normal';
      selectedMask = state['selectedMask'] ?? 'none';
      selectedFilter = state['selectedFilter'] ?? 'none';
    }
  }

  Future<void> onSaveTap() async {
    if (backgroundImageData == null) {
      Fluttertoast.showToast(msg: 'Please select background image');
      return;
    }

    foregroundOperationMode = 'none';
    update();

    try {
      final imageBytes = await screenshotController.capture();
      if (imageBytes == null) {
        Fluttertoast.showToast(msg: 'Failed to capture image');
        return;
      }

      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final record = ImageComposeEntity(
        imageData: imageBytes,
        createdAt: now,
      );

      await db.insertImageComposeRecord(record);
      Fluttertoast.showToast(msg: 'Saved successfully');
      Get.back();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Save failed: $e');
    }
  }

  double _lastScale = 1.0;
  Offset _lastFocalPoint = Offset.zero;

  void onForegroundScaleStart(ScaleStartDetails details) {
    _lastScale = 1.0;
    _lastFocalPoint = details.focalPoint;
  }

  void onForegroundScaleUpdate(ScaleUpdateDetails details) {
    if (foregroundOperationMode == 'none') return;

    if (foregroundOperationMode == 'move') {
      if (details.focalPointDelta != Offset.zero) {
        foregroundPosition += details.focalPointDelta;
        addToHistory();
        update();
      }
      _lastScale = details.scale;
      _lastFocalPoint = details.focalPoint;
    } else if (foregroundOperationMode == 'scale') {
      if (details.scale != 1.0) {
        final scaleChange = details.scale / _lastScale;
        foregroundWidth *= scaleChange;
        foregroundHeight *= scaleChange;
        if (foregroundWidth < 50) foregroundWidth = 50;
        if (foregroundHeight < 50) foregroundHeight = 50;
        if (foregroundWidth > backgroundContainerWidth * 2)
          foregroundWidth = backgroundContainerWidth * 2;
        if (foregroundHeight > backgroundContainerHeight * 2)
          foregroundHeight = backgroundContainerHeight * 2;
        _lastScale = details.scale;
        addToHistory();
        update();
      }
      _lastScale = details.scale;
      _lastFocalPoint = details.focalPoint;
    }
  }
}
