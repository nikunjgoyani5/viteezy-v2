// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:viteezy/core/theme/app_colors.dart';
// import 'package:viteezy/core/theme/text_styles.dart';
// import 'package:viteezy/gen/assets.gen.dart';
//
// class SupplementCard extends StatelessWidget {
//   final String name;
//   final String desc;
//   final double price;
//   final int quantity;
//   final VoidCallback plus;
//   final VoidCallback minus;
//
//   const SupplementCard({
//     super.key,
//     required this.name,
//     required this.desc,
//     required this.price,
//     required this.quantity,
//     required this.plus,
//     required this.minus,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10.r),
//         border: Border.all(color: const Color(0xFFE3E3DC)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Container(
//           //   width: 72.w,
//           //   height: 72.h,
//           //   decoration: BoxDecoration(
//           //     color: const Color(0xFFF2F2F2),
//           //     borderRadius: BorderRadius.circular(10.r),
//           //   ),
//           // ),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10.r),
//             child: Image.asset(
//               Assets.images.imgAdvancedBundle.path,
//               width: 72.w,
//               height: 72.h,
//               fit: BoxFit.cover,
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             name,
//                             style: TextStyles.semiBold(
//                               18.sp,
//                               fontColor: AppColors.black141414,
//                             ),
//                           ),
//                           SizedBox(height: 2.h),
//                           Text(
//                             desc,
//                             style: TextStyles.medium(
//                               12.sp,
//                               fontColor: AppColors.black717171,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: 8.w),
//                     // Price column (top-right)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           "\$${price.toStringAsFixed(2)}",
//                           // style: TextStyle(
//                           //   fontWeight: FontWeight.bold,
//                           //   fontSize: 16.sp,
//                           // ),
//
//                           style: TextStyles.semiBold(
//                           16.sp,
//                           fontColor: AppColors.black141414,
//                           ),
//                         ),
//                         Text(
//                           "\$13.00",
//                           style: TextStyles.medium(
//                             14.sp,
//                             fontColor: AppColors.black717171,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 10.h),
//                 // Two quantity rows: AM (sun) and PM (moon)
//                 Row(
//                   children: [
//                     _quantityControl(
//                       icon: Icons.wb_sunny_outlined,
//                       quantity: quantity,
//                       onMinus: minus,
//                       onPlus: plus,
//                     ),
//                     SizedBox(width: 12.w),
//                     _quantityControl(
//                       icon: Icons.bedtime_outlined,
//                       quantity: quantity,
//                       onMinus: minus,
//                       onPlus: plus,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   // style: TextStyles.medium(
//   // 14.sp,
//   // fontColor: AppColors.textPrimary,
//   // ),
//   Widget _quantityControl({
//     required IconData icon,
//     required int quantity,
//     required VoidCallback onMinus,
//     required VoidCallback onPlus,
//   }) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _circleButton(Icons.remove, onMinus),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 6.w),
//           child: Icon(icon, size: 14.sp, color: Colors.grey.shade600),
//         ),
//         Text(
//           quantity.toString(),
//           style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
//         ),
//         SizedBox(width: 4.w),
//         _circleButton(Icons.add, onPlus),
//       ],
//     );
//   }
//
//   Widget _circleButton(IconData icon, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 22.h,
//         width: 22.w,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.grey.shade300),
//           color: Colors.white,
//         ),
//         child: Icon(icon, size: 12.sp, color: Colors.black87),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/gen/assets.gen.dart';

class SupplementCard extends StatelessWidget {
  final String name;
  final String desc;
  final double price;
  final int quantity;
  final VoidCallback plus;
  final VoidCallback minus;

  const SupplementCard({
    super.key,
    required this.name,
    required this.desc,
    required this.price,
    required this.quantity,
    required this.plus,
    required this.minus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE3E3DC)),
      ),
      child: Column(
        children: [
          // ── Main content row ──
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.asset(
                    Assets.images.imgAdvancedBundle.path,
                    width: 72.w,
                    height: 72.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyles.semiBold(
                                    18.sp,
                                    fontColor: AppColors.black141414,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  desc,
                                  style: TextStyles.medium(
                                    12.sp,
                                    fontColor: AppColors.black717171,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // Price — top right
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "\$${price.toStringAsFixed(2)}",
                                style: TextStyles.semiBold(
                                  16.sp,
                                  fontColor: AppColors.black141414,
                                ),
                              ),
                              Text(
                                "\$13.00",
                                style: TextStyles.medium(
                                  14.sp,
                                  fontColor: AppColors.black717171,
                                ).copyWith(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      // AM + PM quantity controls
                      Row(
                        children: [
                          _quantityControl(
                            icon: Icons.wb_sunny_outlined,
                            quantity: quantity,
                            onMinus: minus,
                            onPlus: plus,
                          ),
                          SizedBox(width: 12.w),
                          _quantityControl(
                            icon: Icons.bedtime_outlined,
                            quantity: quantity,
                            onMinus: minus,
                            onPlus: plus,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Membership discount gradient strip ──
          Container(
            height: 38.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.r),
                bottomRight: Radius.circular(10.r),
              ),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFB2E0D8), // teal-mint left
                  Color(0xFFF5D5C8), // peach-salmon right
                  // Color(0xFF1BAF9A), // teal-mint left
                  // Color(0xFFF7A173), // peach-salmon right
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Membership Discount",
                  style: TextStyles.medium(
                    13.sp,
                    fontColor: AppColors.black141414,
                  ),
                ),
                Text(
                  "-\$2.09",
                  style: TextStyles.semiBold(
                    13.sp,
                    fontColor: AppColors.black141414,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityControl({
    required IconData icon,
    required int quantity,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE3E3DC)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _circleButton(Icons.remove, onMinus),
          SizedBox(width: 4.w),

          Container(height: 40,width: 1,color: AppColors.greyE5E4DC,),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Icon(icon, size: 14.sp, color: Colors.grey.shade600),
          ),
          Text(
            quantity.toString(),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          Container(height: 40,width: 1,color: AppColors.greyE5E4DC,),
          SizedBox(width: 4.w),

          _circleButton(Icons.add, onPlus),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 22.h,
        width: 22.w,
        decoration: BoxDecoration(
          // shape: BoxShape.circle,
          // border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Icon(icon, size: 12.sp, color: Colors.black87),
      ),
    );
  }
}