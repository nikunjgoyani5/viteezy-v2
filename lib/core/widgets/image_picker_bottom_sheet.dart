import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/exports.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final Function(XFile?) onImageSelected;

  const ImagePickerBottomSheet({super.key, required this.onImageSelected});

  Future<void> _pickImage(ImageSource source) async {
    final bool hasPermission = source == ImageSource.camera
        ? await _ensureCameraPermission()
        : await _ensureGalleryPermission();

    if (!hasPermission) return;

    try {
      final XFile? image = await ImagePicker().pickImage(source: source);
      Get.back();
      onImageSelected(image);
    } on PlatformException catch (_) {
      _showPermissionSettingsDialog(source);
    }
  }

  Future<bool> _ensureCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    if (status.isGranted) return true;

    status = await Permission.camera.request();
    if (status.isGranted) return true;

    _showPermissionSettingsDialog(ImageSource.camera);
    return false;
  }

  Future<bool> _ensureGalleryPermission() async {
    PermissionStatus photosStatus = await Permission.photos.status;
    PermissionStatus storageStatus = await Permission.storage.status;

    if (GetPlatform.isIOS) {
      if (photosStatus.isGranted || photosStatus.isLimited) return true;

      photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted || photosStatus.isLimited) return true;

      _showPermissionSettingsDialog(ImageSource.gallery);
      return false;
    } else {
      if (photosStatus.isGranted ||
          photosStatus.isLimited ||
          storageStatus.isGranted) {
        return true;
      }

      photosStatus = await Permission.photos.request();
      storageStatus = await Permission.storage.request();
    }

    final bool isGranted =
        photosStatus.isGranted ||
        photosStatus.isLimited ||
        storageStatus.isGranted;
    if (isGranted) return true;

    _showPermissionSettingsDialog(ImageSource.gallery);
    return false;
  }

  void _showPermissionSettingsDialog(ImageSource source) {
    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }

    final bool isCamera = source == ImageSource.camera;
    Get.defaultDialog(
      title: isCamera
          ? 'image_picker_camera_permission_title'.tr
          : 'image_picker_gallery_permission_title'.tr,
      middleText: isCamera
          ? 'image_picker_camera_permission_message'.tr
          : 'image_picker_gallery_permission_message'.tr,
      textConfirm: 'image_picker_open_settings'.tr,
      textCancel: 'common_cancel'.tr,
      onConfirm: () async {
        Get.back();
        await openAppSettings();
      },
      onCancel: () {},
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primaryColor,
      radius: 12.r,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Indicator
            Container(
              width: 50.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: AppColors.greyE5E4DC,
                borderRadius: BorderRadius.circular(500),
              ),
            ),
            Gap(20.h),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.close, size: 30.sp, color: Colors.transparent),
                Text(
                  'image_picker_select'.tr,
                  style: TextStyles.bold(
                    24.sp,
                    fontColor: AppColors.black1414141,
                  ),
                ),
                InkWell(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    size: 30.sp,
                    color: AppColors.black1414141,
                  ),
                ),
              ],
            ),
            Gap(20.h),
            // Image Picker Options
            Row(
              children: [
                Expanded(
                  child: ImagePickerOption(
                    title: 'image_picker_gallery'.tr,
                    icon: Icons.photo_library_outlined,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ),
                Gap(10.w),
                Expanded(
                  child: ImagePickerOption(
                    title: 'image_picker_camera'.tr,
                    icon: Icons.camera_alt_outlined,
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
              ],
            ),
            Gap(20.h),
          ],
        ),
      ),
    );
  }
}

class ImagePickerOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const ImagePickerOption({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: AppColors.white,
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Row(
          children: [
            Icon(icon, size: 24.sp, color: AppColors.primaryColor),
            Gap(15.w),
            Text(
              title,
              style: TextStyles.medium(
                18.sp,
                fontColor: AppColors.black1414141,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
