import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'image_compose_edit_logic.dart';
import 'mask_clipper.dart';
import 'blend_mode_preview_painter.dart';
import 'blend_mode_foreground_painter.dart';

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

class ImageComposeEditView extends GetView<ImageComposeEditLogic> {
  const ImageComposeEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B1E),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Get.back(),
        ),
        title: Text(
          controller.themeName,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.grey, size: 20),
            onPressed: controller.onUndoTap,
          ),
          IconButton(
            icon: const Icon(Icons.redo, color: Colors.grey, size: 20),
            onPressed: controller.onRedoTap,
          ),
          TextButton(
            onPressed: controller.onSaveTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FFC2), Color(0xFFFF00C7)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Save',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: GetBuilder<ImageComposeEditLogic>(
        builder: (logic) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Screenshot(
                    controller: controller.screenshotController,
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        width: double.infinity,
                        color: Colors.black,
                        child: _buildFilterWrapper(
                          logic,
                          Stack(
                            children: [
                              if (logic.backgroundImageData != null)
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: logic.backgroundOpacity,
                                    child: Image.memory(
                                      logic.backgroundImageData!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              if (logic.foregroundImageData != null)
                                _buildForegroundImageWithControls(
                                    logic, context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Stack(
                children: [
                  SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildImageSelectors(logic),
                          _buildToolBar(logic),
                        ],
                      ),
                    ),
                  ),
                  if (logic.foregroundAdjustActive ||
                      logic.backgroundAdjustActive)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        top: false,
                        bottom: false,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A1A2E),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: logic.foregroundAdjustActive
                              ? _buildForegroundAdjustPanel(logic)
                              : _buildBackgroundAdjustPanel(logic),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterWrapper(ImageComposeEditLogic logic, Widget child) {
    final colorFilter = _getColorFilter(logic.selectedFilter);
    if (colorFilter != null) {
      return ColorFiltered(
        colorFilter: colorFilter,
        child: child,
      );
    }
    if (logic.selectedFilter == 'blur') {
      return BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: child,
      );
    }
    return child;
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

  Widget _buildImageSelectors(ImageComposeEditLogic logic) {
    return Container(
      padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1A1A2E))),
      ),
      child: Column(
        children: [
          _buildForegroundSelector(logic),
          SizedBox(height: 16.h),
          _buildBackgroundSelector(logic),
        ],
      ),
    );
  }

  Widget _buildForegroundSelector(ImageComposeEditLogic logic) {
    return Row(
      children: [
        Text(
          'Foreground Image',
          style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14.sp,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 50.w,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: (logic.themeId != 1
                      ? logic.getFrontImages(logic.themeId).length
                      : 0) +
                  1, 
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: logic.onSelectForegroundFromGallery,
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      margin: EdgeInsets.only(right: 12.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[700]!,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withAlpha(50),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.photo_library,
                            color: Color(0xFF00D4FF),
                            size: 16,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              color: Color(0xFF00D4FF),
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final imageIndex = index - 1;
                final imagePath =
                    logic.getFrontImages(logic.themeId)[imageIndex];
                return GestureDetector(
                  onTap: () => logic.onSelectForegroundImage(imagePath),
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    margin: EdgeInsets.only(right: 12.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: logic.selectedForegroundImagePath == imagePath
                            ? const Color(0xFF00D4FF)
                            : Colors.grey[700]!,
                        width: logic.selectedForegroundImagePath == imagePath
                            ? 2
                            : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withAlpha(50),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.asset(imagePath, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundSelector(ImageComposeEditLogic logic) {
    return Row(
      children: [
        Text(
          'Background Image',
          style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14.sp,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 50.w,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: (logic.themeId != 1
                      ? logic.getBehindImages(logic.themeId).length
                      : 0) +
                  1, 
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: logic.onSelectBackgroundFromGallery,
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      margin: EdgeInsets.only(right: 12.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[700]!,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withAlpha(50),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.photo_library,
                            color: Color(0xFF00D4FF),
                            size: 16,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final imageIndex = index - 1;
                final imagePath =
                    logic.getBehindImages(logic.themeId)[imageIndex];
                return GestureDetector(
                  onTap: () => logic.onSelectBackgroundImage(imagePath),
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    margin: EdgeInsets.only(right: 12.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: logic.selectedBackgroundImagePath == imagePath
                            ? const Color(0xFF00D4FF)
                            : Colors.grey[700]!,
                        width: logic.selectedBackgroundImagePath == imagePath
                            ? 2
                            : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.asset(imagePath, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolBar(ImageComposeEditLogic logic) {
    return Container(
      padding: EdgeInsets.only(top: 16.h),
      child: SizedBox(
        height: 70.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          children: [
            _buildToolButton(
              icon: Icons.layers,
              label: 'Blend',
              onTap: logic.onBlendModeTap,
            ),
            SizedBox(width: 12.w),
            _buildToolButton(
              icon: Icons.filter_center_focus,
              label: 'Mask',
              onTap: logic.onMaskTap,
            ),
            SizedBox(width: 12.w),
            _buildToolButton(
              icon: Icons.auto_fix_high,
              label: 'Filter',
              onTap: logic.onFilterTap,
            ),
            SizedBox(width: 12.w),
            _buildToolButton(
              icon: Icons.tune,
              label: 'Foreground',
              onTap: logic.onForegroundAdjustTap,
            ),
            SizedBox(width: 12.w),
            _buildToolButton(
              icon: Icons.landslide_rounded,
              label: 'Background',
              onTap: logic.onBackgroundAdjustTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70.w,
        decoration: BoxDecoration(
          color: const Color(0xFF00D4FF).withOpacity(0.1),
          border: Border.all(
            color: const Color(0xFF00D4FF).withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 10.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForegroundAdjustPanel(ImageComposeEditLogic logic) {
    return Container(
      padding:
          EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h, bottom: 40.h),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Foreground Adjust',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: logic.onForegroundAdjustTap,
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Opacity',
                  style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  '${(logic.foregroundOpacity * 100).toInt()}%',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
                ),
              ],
            ),
            Slider(
              value: logic.foregroundOpacity,
              min: 0.0,
              max: 1.0,
              activeColor: const Color(0xFF00D4FF),
              onChanged: logic.onForegroundOpacityChanged,
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: logic.onForegroundCropTap,
                    icon: const Icon(Icons.image, size: 16),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 12.h),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: logic.onForegroundMoveTap,
                    icon: Icon(
                      Icons.open_with,
                      size: 16,
                      color: logic.foregroundOperationMode == 'move'
                          ? Colors.white
                          : Colors.grey[400],
                    ),
                    label: Text(
                      'Move',
                      style: TextStyle(
                        color: logic.foregroundOperationMode == 'move'
                            ? Colors.white
                            : Colors.grey[400],
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: logic.foregroundOperationMode == 'move'
                          ? const Color(0xFF00D4FF)
                          : Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: logic.onForegroundScaleTap,
                    icon: Icon(
                      Icons.fit_screen,
                      size: 16,
                      color: logic.foregroundOperationMode == 'scale'
                          ? Colors.white
                          : Colors.grey[400],
                    ),
                    label: Text(
                      'Scale',
                      style: TextStyle(
                        color: logic.foregroundOperationMode == 'scale'
                            ? Colors.white
                            : Colors.grey[400],
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: logic.foregroundOperationMode == 'scale'
                          ? const Color(0xFF00D4FF)
                          : Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForegroundImageWithControls(
      ImageComposeEditLogic logic, BuildContext context) {
    final width = logic.foregroundWidth > 0
        ? logic.foregroundWidth
        : logic.backgroundContainerWidth;
    final height = logic.foregroundHeight > 0
        ? logic.foregroundHeight
        : logic.backgroundContainerHeight;

    final isMoveMode = logic.foregroundOperationMode == 'move';
    final isScaleMode = logic.foregroundOperationMode == 'scale';

    return Stack(
      children: [
        Positioned(
          left: logic.foregroundPosition.dx,
          top: logic.foregroundPosition.dy,
          child: GestureDetector(
            onScaleStart: isMoveMode ? logic.onForegroundScaleStart : null,
            onScaleUpdate: isMoveMode ? logic.onForegroundScaleUpdate : null,
            child: Opacity(
              opacity: logic.foregroundOpacity,
              child: Container(
                width: width,
                height: height,
                decoration: isMoveMode || isScaleMode
                    ? BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF00D4FF),
                          width: 2,
                        ),
                      )
                    : null,
                child: logic.selectedMask != 'none'
                    ? ClipPath(
                        clipper: MaskClipper(
                          maskType: logic.selectedMask,
                          size: Size(width, height),
                        ),
                        child: logic.selectedBlendMode == 'normal'
                            ? Image.memory(
                                logic.foregroundImageData!,
                                fit: BoxFit.cover,
                              )
                            : FutureBuilder<List<ui.Image>>(
                                future: _loadImagesForBlendMode(
                                  logic.foregroundImageData!,
                                  null,
                                ),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Container();
                                  }
                                  final images = snapshot.data!;
                                  final foregroundImg = images[0];
                                  
                                  return ClipRect(
                                    child: CustomPaint(
                                      size: Size(width, height),
                                      painter: BlendModeForegroundPainter(
                                        foregroundImage: foregroundImg,
                                        backgroundImage: null,
                                        blendMode: _getBlendMode(logic.selectedBlendMode),
                                      ),
                                      child: Container(),
                                    ),
                                  );
                                },
                              ),
                      )
                    : logic.selectedBlendMode == 'normal'
                        ? Image.memory(
                            logic.foregroundImageData!,
                            fit: BoxFit.cover,
                          )
                        : FutureBuilder<List<ui.Image>>(
                            future: _loadImagesForBlendMode(
                              logic.foregroundImageData!,
                              logic.backgroundImageData,
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container();
                              }
                              final images = snapshot.data!;
                              final foregroundImg = images[0];
                              final backgroundImg = images.length > 1 ? images[1] : null;
                              
                              return ClipRect(
                                child: CustomPaint(
                                  size: Size(width, height),
                                  painter: BlendModeForegroundPainter(
                                    foregroundImage: foregroundImg,
                                    backgroundImage: null,
                                    blendMode: _getBlendMode(logic.selectedBlendMode),
                                  ),
                                  child: Container(),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ),
        ),
        if (isScaleMode)
          ..._buildScaleControlPoints(context, logic, width, height),
      ],
    );
  }

  List<Widget> _buildScaleControlPoints(BuildContext context,
      ImageComposeEditLogic logic, double width, double height) {
    final left = logic.foregroundPosition.dx;
    final top = logic.foregroundPosition.dy;
    final controlPointSize = 24.0;

    return [
      Positioned(
        left: left + width / 2 - controlPointSize / 2,
        top: top - controlPointSize / 2,
        child: GestureDetector(
          onPanStart: (details) {
            logic.onControlPointDragStart('top', details.globalPosition);
          },
          onPanUpdate: (details) {
            logic.onControlPointDragUpdate('top', details.globalPosition);
          },
          onPanEnd: (_) {
            logic.onControlPointDragEnd();
          },
          child: Container(
            width: controlPointSize,
            height: controlPointSize,
            decoration: BoxDecoration(
              color: const Color(0xFF00D4FF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ),
      Positioned(
        left: left + width - controlPointSize / 2,
        top: top + height / 2 - controlPointSize / 2,
        child: GestureDetector(
          onPanStart: (details) {
            logic.onControlPointDragStart('right', details.globalPosition);
          },
          onPanUpdate: (details) {
            logic.onControlPointDragUpdate('right', details.globalPosition);
          },
          onPanEnd: (_) {
            logic.onControlPointDragEnd();
          },
          child: Container(
            width: controlPointSize,
            height: controlPointSize,
            decoration: BoxDecoration(
              color: const Color(0xFF00D4FF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ),
      Positioned(
        left: left + width / 2 - controlPointSize / 2,
        top: top + height - controlPointSize / 2,
        child: GestureDetector(
          onPanStart: (details) {
            logic.onControlPointDragStart('bottom', details.globalPosition);
          },
          onPanUpdate: (details) {
            logic.onControlPointDragUpdate('bottom', details.globalPosition);
          },
          onPanEnd: (_) {
            logic.onControlPointDragEnd();
          },
          child: Container(
            width: controlPointSize,
            height: controlPointSize,
            decoration: BoxDecoration(
              color: const Color(0xFF00D4FF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ),
      Positioned(
        left: left - controlPointSize / 2,
        top: top + height / 2 - controlPointSize / 2,
        child: GestureDetector(
          onPanStart: (details) {
            logic.onControlPointDragStart('left', details.globalPosition);
          },
          onPanUpdate: (details) {
            logic.onControlPointDragUpdate('left', details.globalPosition);
          },
          onPanEnd: (_) {
            logic.onControlPointDragEnd();
          },
          child: Container(
            width: controlPointSize,
            height: controlPointSize,
            decoration: BoxDecoration(
              color: const Color(0xFF00D4FF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildBackgroundAdjustPanel(ImageComposeEditLogic logic) {
    return Container(
      padding:
          EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h, bottom: 40.h),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Background Adjust',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: logic.onBackgroundAdjustTap,
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Opacity',
                  style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  '${(logic.backgroundOpacity * 100).toInt()}%',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
                ),
              ],
            ),
            Slider(
              value: logic.backgroundOpacity,
              min: 0.0,
              max: 1.0,
              activeColor: const Color(0xFF00D4FF),
              onChanged: logic.onBackgroundOpacityChanged,
            ),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: logic.onBackgroundCropTap,
              icon: const Icon(Icons.image, size: 16),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<List<ui.Image>> _loadImagesForBlendMode(Uint8List foregroundData, Uint8List? backgroundData) async {
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
}
