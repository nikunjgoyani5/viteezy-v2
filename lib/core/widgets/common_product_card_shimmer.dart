import 'package:viteezy/core/widgets/shimmer_widget.dart';

import '../utils/exports.dart';

class CommonProductCardShimmer extends StatelessWidget {
  const CommonProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.6,
        ),
        itemCount: 6, // Show 6 shimmer items
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Section (takes most space)
                Expanded(
                  flex: 1,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.grayE3E3DC,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                        ),
                      ),
                      // Favorite button placeholder
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 30.w,
                          height: 30.w,
                          decoration: BoxDecoration(color: AppColors.grayE3E3DC, shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                ),
                // Product Info Section
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name and Discount Tag
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 14.h,
                              decoration: BoxDecoration(
                                color: AppColors.grayE3E3DC,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          Gap(4.w),
                          // Discount tag with rounded right corners
                          Container(
                            width: 60.w,
                            height: 18.h,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(50),
                                bottomRight: Radius.circular(50),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap(4.h),
                      // Product Description (2 lines)
                      Container(
                        width: double.infinity,
                        height: 10.h,
                        decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
                      ),
                      Gap(4.h),
                      Container(
                        width: 100.w,
                        height: 10.h,
                        decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
                      ),
                      Gap(10.h),
                      // Price and Rating Row
                      Row(
                        children: [
                          Container(
                            width: 45.w,
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Gap(4.w),
                          Container(
                            width: 40.w,
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Spacer(),
                          // Star icon placeholder
                          Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(color: AppColors.grayE3E3DC, shape: BoxShape.circle),
                          ),
                          Gap(2.w),
                          Container(
                            width: 25.w,
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Add to Cart Button
                Container(
                  width: double.infinity,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.grayE3E3DC,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
