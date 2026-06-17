import 'package:flutter_svg/svg.dart';
import 'package:viteezy/core/models/family_info_model.dart';
import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/presentation/main/familymodule/controllers/family_controllers.dart';
import 'package:viteezy/presentation/main/familymodule/views/delete_dialog.dart';

import '../../../../gen/assets.gen.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final familyController = Get.find<FamilyController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CommonAppbar(title: 'family_title'.tr),
      body: Obx(() {
        if (familyController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.blackColor),
          );
        }

        if (familyController.subMembers.isEmpty) {
          return Center(
            child: Text(
              'family_no_members'.tr,
              style: TextStyles.medium(14.sp, fontColor: AppColors.grey898989),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: familyController.getFamilyInfo,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            itemCount: familyController.subMembers.length,
            itemBuilder: (context, index) {
              final member = familyController.subMembers[index];
              return _buildFamilyCard(member, familyController);
            },
          ),
        );
      }),
    );
  }

  Widget _buildFamilyCard(FamilyMember member, FamilyController familyController) {
    final displayName = member.name.isNotEmpty
        ? member.name
        : '${member.firstName} ${member.lastName}'.trim();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'family_label_name'.tr,
                style: TextStyles.regular(
                  13.sp,
                  fontColor: AppColors.grey898989,
                ),
              ),
              Gap(4.h),
              Text(
                displayName.isNotEmpty ? displayName : 'family_member_default_name'.tr,
                style: TextStyles.medium(15.sp),
              ),
              Gap(10.h),
              Text(
                'family_label_membership_id'.tr,
                style: TextStyles.regular(
                  13.sp,
                  fontColor: AppColors.grey898989,
                ),
              ),
              Gap(4.h),
              Text(
                member.memberId.isNotEmpty ? member.memberId : "-",
                style: TextStyles.medium(15.sp),
              ),
            ],
          ),
          Obx(() {
            final isRemoving = familyController.removingIds.contains(member.id);
            return GestureDetector(
              onTap: isRemoving
                  ? null
                  : () {
                      showDeleteFamilyDialog(
                        onConfirm: () {
                          familyController.removeFamilyMember(member.id);
                        },
                      );
                    },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: isRemoving
                    ? SizedBox(
                        height: 16.h,
                        width: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.blackColor,
                        ),
                      )
                    : SvgPicture.asset(
                        Assets.icons.icDelete.path,
                        height: 16.h,
                        width: 16.w,
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
