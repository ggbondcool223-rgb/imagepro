import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'image_compose_records_logic.dart';

class ImageComposeRecordsView extends GetView<ImageComposeRecordsLogic> {
  const ImageComposeRecordsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF0B0B1E),
        appBar: AppBar(
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00FFC2), Color(0xFFFF00C7)],
            ).createShader(bounds),
            child: const Text(
              'Compose Records',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: const Color(0xFF0B0B1E),
          elevation: 0,
        ),
        body: Obx(() {
          return controller.records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_search_outlined,
                          size: 64, color: Colors.grey[600]),
                      SizedBox(height: 16.h),
                      Text(
                        'No records yet',
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 16.sp),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(16.w),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: controller.records.length,
                    itemBuilder: (context, index) {
                      final record = controller.records[index];
                      return _buildImageCard(record, index, controller);
                    },
                  ),
                );
        }));
  }

  Widget _buildImageCard(
      dynamic record, int index, ImageComposeRecordsLogic logic) {
    return GestureDetector(
      onTap: () => logic.onImageTap(record),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: MemoryImage(record.imageData),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
              right: 5,
              top: 5,
              child: GestureDetector(
                onTap: () => logic.onMoreTap(record),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.more_vert, color: Colors.white,size: 16,),
                ),
              ))
        ],
      ),
    );
  }
}
