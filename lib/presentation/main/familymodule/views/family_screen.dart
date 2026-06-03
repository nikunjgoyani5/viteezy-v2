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
      appBar: const CommonAppbar(title: "Family Member"),
      body: Obx(() {
        if (familyController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.blackColor),
          );
        }

        if (familyController.subMembers.isEmpty) {
          return Center(
            child: Text(
              "No family members found",
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
              return _buildFamilyCard(member);
            },
          ),
        );
      }),
    );
  }

  Widget _buildFamilyCard(FamilyMember member) {
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
                "Name",
                style: TextStyles.regular(
                  13.sp,
                  fontColor: AppColors.grey898989,
                ),
              ),
              Gap(4.h),
              Text(
                displayName.isNotEmpty ? displayName : "Family Member",
                style: TextStyles.medium(15.sp),
              ),
              Gap(10.h),
              Text(
                "Membership id",
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
          GestureDetector(
            onTap: () {
              showDeleteFamilyDialog(
                onConfirm: () {
                  // TODO: delete logic here
                  print("Deleted!");
                },
              );
            },
            child: SvgPicture.asset(
              Assets.icons.icDelete.path,
              height: 16.h,
              width: 16.w,
            ),
          ),
        ],
      ),
    );
  }
}
