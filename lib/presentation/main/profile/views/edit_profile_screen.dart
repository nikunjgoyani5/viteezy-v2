import 'package:image_picker/image_picker.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/common_button.dart';
import 'package:viteezy/core/widgets/common_loader.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/core/widgets/common_textfield.dart';
import 'package:viteezy/core/widgets/image_picker_bottom_sheet.dart';
import 'package:viteezy/presentation/main/profile/controllers/profile_controller.dart';

import '../../../../core/utils/exports.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileController controller;
  late String firstName;
  late String lastName;
  late String email;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProfileController>();
    // Defer so we don't call update() during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetEditProfileState();
    });
    firstName = controller.userData.user?.firstName ?? '';
    lastName = controller.userData.user?.lastName ?? "";
    email = controller.userData.user?.email ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundColor,
      appBar: CommonAppbar(title: 'edit_profile_title'.tr, showBackButton: true, centerTitle: true,
          onLeadPress: () {
          controller.fNameController.text = firstName;
          controller.lNameController.text= lastName;
            controller.emailController.text = email;
           Get.back();

          }),
      body: GetBuilder<ProfileController>(
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Gap(30.h),
                Builder(
                  key: ValueKey('profile_image_${controller.selectedImageFile?.path}_${controller.shouldRemoveImage}'),
                  builder: (context) {
                    // Show selected image if available
                    if (controller.selectedImageFile != null) {
                      return Container(
                        width: 110.w,
                        height: 110.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.backgroundColor,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.file(
                            controller.selectedImageFile!,
                            fit: BoxFit.cover,
                            width: 110.w,
                            height: 110.w,
                          ),
                        ),
                      );
                    }
                    // Show network image only if not marked for removal and image exists
                    else if (!controller.shouldRemoveImage &&
                        controller.userData.user?.profileImage != null &&
                        controller.userData.user!.profileImage!.isNotEmpty) {
                      return Container(
                        width: 110.w,
                        height: 110.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.backgroundColor,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: ClipOval(
                          child: CommonNetworkImage(imageUrl: controller.userData.user?.profileImage ?? ''),
                        ),
                      );
                    }
                    // Show initials (default or when removed)
                    else {
                      return Container(
                        width: 110.w,
                        height: 110.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.backgroundColor,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            controller.getInitials(
                              controller.userData.user?.firstName ?? '',
                              controller.userData.user?.lastName ?? '',
                            ),
                            style: TextStyles.bold(24.sp),
                          ),
                        ),
                      );
                    }
                  },
                ),

                Gap(10.h),
                // Change profile and Remove options
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        _showImagePickerBottomSheet(context, controller);
                      },
                      child: Text(
                        'edit_profile_change_photo'.tr,
                        style: TextStyles.medium(14.sp, fontColor: AppColors.primaryColor),
                      ),
                    ),
                    if (controller.selectedImageFile != null ||
                        controller.shouldRemoveImage ||
                        (controller.userData.user?.profileImage != null &&
                            controller.userData.user!.profileImage!.isNotEmpty)) ...[
                      Gap(16.w),
                      Container(width: 1, height: 14.h, color: AppColors.gray949391),
                      Gap(16.w),
                      InkWell(
                        onTap: () {
                          if (!controller.shouldRemoveImage) {
                            controller.removeProfileImage();
                          }
                        },
                        child: Text(
                          controller.shouldRemoveImage ? 'Removed' : 'Remove',
                          style: TextStyles.medium(
                            14.sp,
                            fontColor: controller.shouldRemoveImage ? AppColors.gray949391 : AppColors.red,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Gap(10.h),
                SizedBox(
                  width: Get.width,
                  child: CommonMainTextField(
                    hintText: 'First Name',
                    labelText: 'First Name',
                    controller: controller.fNameController,
                    errorText: controller.firstNameError,
                    onChanged: (val) {
                      controller.validateFirstName();
                    },
                    borderColor: AppColors.greyF0EFE4,
                  ),
                ),

                Gap(8.h),
                SizedBox(
                  width: Get.width,
                  child: CommonMainTextField(
                    borderColor: AppColors.greyF0EFE4,
                    hintText: 'Last Name',
                    labelText: 'Last Name',
                    controller: controller.lNameController,
                    errorText: controller.lastNameError,
                    onChanged: (val) {
                      controller.validateLastName();
                    },
                  ),
                ),

                Gap(8.h),
                SizedBox(
                  width: Get.width,
                  child: CommonMainTextField(
                    readOnly: true,
                    hintText: 'Email',
                    labelText: 'Email',
                    controller: controller.emailController,
                    errorText: controller.emailError,
                    onChanged: (val) {
                      controller.validateEmail();
                    },
                    borderColor: AppColors.greyF0EFE4,
                  ),
                ),
                Spacer(),
                Obx(() {
                  return CommonButtonWidget(
                    height: 48.h,
                    color:
                        controller.emailController.text.isNotEmpty &&
                            controller.fNameController.text.isNotEmpty &&
                            controller.lNameController.text.isNotEmpty &&
                            controller.emailError.isEmpty &&
                            controller.firstNameError.isEmpty &&
                            controller.lastNameError.isEmpty
                        ? AppColors.primaryColor
                        : AppColors.lightPrimaryColor,
                    child: controller.loader.value
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [CommonLoader(color: AppColors.white, size: 20)],
                          )
                        : Center(
                            child: Text(
                              'edit_profile_save_changes'.tr,
                              style: TextStyles.medium(17.sp, fontColor: AppColors.white),
                            ),
                          ),
                    onPressed: () {
                      if (controller.emailController.text.isNotEmpty &&
                          controller.fNameController.text.isNotEmpty &&
                          controller.lNameController.text.isNotEmpty &&
                          controller.emailError.isEmpty &&
                          controller.firstNameError.isEmpty &&
                          controller.lastNameError.isEmpty) {
                        AppFunctions().closeKeyboard();
                        controller.updateUserProfile(context);
                      }
                    },
                  );
                }),
                Gap(20.h),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showImagePickerBottomSheet(BuildContext context, ProfileController controller) {
    Get.bottomSheet(
      ImagePickerBottomSheet(
        onImageSelected: (XFile? imageFile) {
          if (imageFile != null) {
            controller.setSelectedImage(imageFile);
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
