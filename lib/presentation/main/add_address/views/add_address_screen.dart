import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/common_loader.dart';
import 'package:viteezy/presentation/main/add_address/controllers/add_address_controller.dart';
import 'package:viteezy/presentation/main/add_address/widgets/add_address_form_content.dart';

import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/common_button.dart';

class AddAddressScreen extends GetView<AddAddressController> {
  const AddAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Gap(10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Obx(() {
              return CommonButtonWidget(
                color: AppColors.primaryColor,
                borderRadius: 30.r,
                height: 52.h,
                onPressed: () {
                  if (controller.isLoading.value) return;
                  controller.saveAddress();
                },
                child: controller.isLoading.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [CommonLoader(size: 25, color: AppColors.white)],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'common_save'.tr,
                            style: TextStyles.semiBold(17.sp, fontColor: AppColors.white),
                          ),
                        ],
                      ),
              );
            }),
          ),
          Gap(20.h),
        ],
      ),
      appBar: CommonAppbar(
        title: controller.isEdit ? 'address_edit_title'.tr : 'address_new_title'.tr,
        bgColor: AppColors.backgroundColor,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: GetBuilder<AddAddressController>(
        builder: (controller) {
          return Obx(() {
            if (controller.isFetchingAddress.value) {
              return Stack(
                children: [
                  Container(
                    color: AppColors.backgroundColor.withValues(alpha: 0.8),
                  ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CommonLoader(size: 40, color: AppColors.primaryColor),
                          Gap(16.h),
                          Text(
                            'common_loading'.tr,
                            style: TextStyles.medium(16.sp, fontColor: AppColors.black1414141),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: AddAddressFormContent(controller: controller),
                  ),
                ),
              ],
            );
          });
        },
      ),
    );
  }
}
