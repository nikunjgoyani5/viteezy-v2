import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/presentation/main/addresses/controllers/addresses_controller.dart';

import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/common_button.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/core/widgets/empty_state.dart';

class AddressesScreen extends GetView<AddressesController> {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CommonAppbar(title: 'addresses_title'.tr),
      body: GetBuilder<AddressesController>(
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  child: Column(
                    children: [
                      // Add a new address button
                      CommonButtonWidget(
                        width: double.infinity,
                        height: 45.h,
                        color: AppColors.white,
                        borderColor: AppColors.black1414141,
                        borderRadius: 8,
                        onPressed: () {
                          controller.addNewAddress();
                        },
                        child: Center(
                          child: Text(
                            'Add a new address',
                            style: TextStyles.regular(16.sp, fontColor: AppColors.black1414141),
                          ),
                        ),
                      ),
                      Gap(20.h),
                      // Show shimmer while loading
                      if (controller.isLoading)
                        ...List.generate(3, (index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: index < 2 ? 14.h : 0),
                            child: _buildAddressCardShimmer(),
                          );
                        })
                      // Show empty state if no addresses
                      else if (controller.addresses.isEmpty)
                        EmptyState(
                          icon: Icons.location_on_outlined,
                          title: 'addresses_no_found'.tr,
                          message: 'You haven\'t added any addresses yet. Add your first address to get started.',
                        )
                      // Show address cards
                      else
                        ...controller.addresses.map((address) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: controller.addresses.indexOf(address) < controller.addresses.length - 1
                                  ? 14.h
                                  : 0,
                            ),
                            child: _buildAddressCard(address, controller),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(Address address, AddressesController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name (bold)
          Text(
            '${address.firstName ?? ''} ${address.lastName ?? ''}'.trim().isNotEmpty
                ? '${address.firstName ?? ''} ${address.lastName ?? ''}'.trim()
                : 'Address',
            style:  TextStyles.medium(14.sp),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          // Row(
          //   children: [
          //     Flexible(child: Text(address.firstName ?? '', maxLines :2 , overflow: TextOverflow.ellipsis, style: TextStyles.medium(14.sp))),
          //     Gap(5),
          //     Flexible(child: Text(address.lastName ?? '',  maxLines :2 , overflow: TextOverflow.ellipsis, style: TextStyles.medium(14.sp))),
          //   ],
          // ),
          Gap(7.h),

          Text(
            "${address.houseNumber ?? ""} ${address.houseNumberAddition ?? ''} ${address.address ?? ''}",
            style: TextStyles.regular(14.sp),
          ),

          Text(address.streetName ?? "", style: TextStyles.regular(14.sp)),
          Text("${address.city ?? ""} ${address.country ?? ''}", style: TextStyles.regular(14.sp)),
          if (address.phone != null && address.phone!.isNotEmpty) ...[
            Gap(7.h),
            Text(address.phone!, style: TextStyles.regular(14.sp)),
          ],
          Gap(20.h),

          Row(
            children: [
              CommonButtonWidget(
                width: 56,
                height: 34.h,
                color: AppColors.white,
                borderColor: AppColors.black1414141,
                borderRadius: 6,
                onPressed: () {
                  controller.editAddress(address.id ?? "");
                },
                child: Center(
                  child: Text('addresses_edit'.tr, style: TextStyles.regular(16.sp, fontColor: AppColors.black1414141)),
                ),
              ),
              Gap(10.w),
              CommonButtonWidget(
                width: 78,
                height: 34.h,
                color: AppColors.white,
                borderColor: AppColors.black1414141,
                borderRadius: 6,
                onPressed: () {
                  controller.deleteAddress(address.id ?? "");
                },
                child: Center(
                  child: Text('addresses_delete'.tr, style: TextStyles.regular(16.sp, fontColor: AppColors.black1414141)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCardShimmer() {
    return ShimmerWidget(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name shimmer
            Container(
              height: 16.h,
              width: 150.w,
              decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
            ),
            Gap(7.h),
            // Full name shimmer
            Container(
              height: 14.h,
              width: 180.w,
              decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
            ),
            Gap(7.h),
            // Address line shimmer
            Container(
              height: 14.h,
              width: double.infinity,
              decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
            ),
            Gap(7.h),
            // City postal code shimmer
            Container(
              height: 14.h,
              width: 120.w,
              decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
            ),
            Gap(20.h),
            // Buttons shimmer
            Row(
              children: [
                Container(
                  width: 56,
                  height: 34.h,
                  decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(6)),
                ),
                Gap(10.w),
                Container(
                  width: 78,
                  height: 34.h,
                  decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(6)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
