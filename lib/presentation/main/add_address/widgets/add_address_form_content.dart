import 'package:viteezy/core/models/sub_member_model.dart';
import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/common_checkbox.dart';
import 'package:viteezy/core/widgets/common_textfield.dart';
import 'package:viteezy/presentation/main/add_address/controllers/add_address_controller.dart';
import 'package:viteezy/presentation/main/profile/controllers/profile_controller.dart';

/// New UI (sections + white fields) with all legacy address fields in **Additional details**.
class AddAddressFormContent extends StatelessWidget {
  const AddAddressFormContent({super.key, required this.controller});

  final AddAddressController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('address_section_account'.tr),
        Gap(4.h),
        CommonMainTextField(
          hintText: 'address_email_placeholder'.tr,
          labelText: 'address_email_placeholder'.tr,
          controller: c.accountEmailController,
          keyboardType: TextInputType.emailAddress,
          readOnly: true,
          borderColor: AppColors.greyF0EFE4,
          fillColor: AppColors.white,
          radius: BorderRadius.circular(10.r),
          onChanged: (_) {},
        ),
        Gap(12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: CommonCheckBox(
                borderColor: AppColors.greyD7D7D7,
                radius: 4,
                value: c.emailNewsOffer,
                onChanged: (_) => c.toggleEmailNewsOffer(!c.emailNewsOffer),
              ),
            ),
            Gap(10.w),
            Expanded(
              child: GestureDetector(
                onTap: () => c.toggleEmailNewsOffer(!c.emailNewsOffer),
                child: Text(
                  'address_email_news_offers'.tr,
                  style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
                ),
              ),
            ),
          ],
        ),
        Gap(22.h),
        _sectionTitle('address_member_id'.tr),
        Gap(10.h),
        _MemberIdDropdown(controller: c),
        Gap(22.h),
        _sectionTitle('address_section_shipping'.tr),
        Gap(10.h),
        CommonMainTextField(
          hintText: 'auth_first_name'.tr,
          labelText: 'auth_first_name'.tr,
          controller: c.firstNameController,
          errorText: c.firstNameError,
          onChanged: (_) => c.validateFirstName(),
          borderColor: AppColors.greyF0EFE4,
          fillColor: AppColors.white,
          radius: BorderRadius.circular(10.r),
        ),
        Gap(10.h),
        CommonMainTextField(
          hintText: 'auth_last_name'.tr,
          labelText: 'auth_last_name'.tr,
          controller: c.lastNameController,
          errorText: c.lastNameError,
          onChanged: (_) => c.validateLastName(),
          borderColor: AppColors.greyF0EFE4,
          fillColor: AppColors.white,
          radius: BorderRadius.circular(10.r),
        ),
        Gap(10.h),
        CommonMainTextField(
          hintText: 'address_phone_optional'.tr,
          labelText: 'address_phone_optional'.tr,
          controller: c.phoneController,
          keyboardType: TextInputType.phone,
          errorText: c.phoneError,
          onChanged: (_) => c.validatePhone(),
          borderColor: AppColors.greyF0EFE4,
          fillColor: AppColors.white,
          radius: BorderRadius.circular(10.r),
        ),
        Gap(10.h),
        CommonMainTextField(
          hintText: 'auth_email'.tr,
          labelText: 'auth_email'.tr,
          controller: c.optionalEmailController,
          keyboardType: TextInputType.emailAddress,
          errorText: c.optionalEmailError,
          onChanged: (_) => c.validateOptionalEmail(),
          borderColor: AppColors.greyF0EFE4,
          fillColor: AppColors.white,
          radius: BorderRadius.circular(10.r),
        ),
        Gap(10.h),
        CommonMainTextField(
          hintText: 'address_zip_label'.tr,
          labelText: 'address_zip_label'.tr,
          controller: c.postalCodeController,
          errorText: c.postalCodeError,
          onChanged: (_) => c.validatePostalCode(),
          borderColor: AppColors.greyF0EFE4,
          fillColor: AppColors.white,
          radius: BorderRadius.circular(10.r),
        ),
        Gap(10.h),
        CommonMainTextField(
          keyboardType: TextInputType.text,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          hintText: 'address_house_number_label'.tr,
          labelText: 'address_house_number_label'.tr,
          controller: c.houseNoController,
          errorText: c.hNoError,
          onChanged: (_) => c.validateHouseNo(),
          borderColor: AppColors.greyF0EFE4,
          fillColor: AppColors.white,
          radius: BorderRadius.circular(10.r),
        ),
        Gap(10.h),
        CommonMainTextField(
          hintText: 'address_line_label'.tr,
          labelText: 'address_line_label'.tr,
          controller: c.address1Controller,
          errorText: c.address1Error,
          onChanged: (_) => c.validateAddress1(),
          borderColor: AppColors.greyF0EFE4,
          fillColor: AppColors.white,
          radius: BorderRadius.circular(10.r),
        ),
        Gap(22.h),
        _sectionTitle('address_section_additional'.tr),
        Gap(10.h),
        CommonMainTextField(
          hintText: 'address_house_addition'.tr,
          labelText: 'address_house_addition'.tr,
          controller: c.houseNoAdditionController,
          errorText: c.hNoAdditionError,
          onChanged: (_) => c.update(),
          borderColor: AppColors.greyF0EFE4,
          fillColor: AppColors.white,
          radius: BorderRadius.circular(10.r),
        ),
        Gap(10.h),
        CommonMainTextField(
          hintText: 'address_street'.tr,
          labelText: 'address_street'.tr,
          controller: c.streetController,
          errorText: c.streetError,
          onChanged: (_) => c.validateStreet(),
          borderColor: AppColors.greyF0EFE4,
          fillColor: AppColors.white,
          radius: BorderRadius.circular(10.r),
        ),
        Gap(10.h),
        CommonMainTextField(
          hintText: 'address_city'.tr,
          labelText: 'address_city'.tr,
          controller: c.cityController,
          errorText: c.cityError,
          onChanged: (_) => c.validateCity(),
          borderColor: AppColors.greyF0EFE4,
          fillColor: AppColors.white,
          radius: BorderRadius.circular(10.r),
        ),
        Gap(10.h),
        CommonMainTextField(
          onTap: () => _showCountryBottomSheet(context, c),
          borderColor: AppColors.greyF0EFE4,
          hintText: 'address_country'.tr,
          labelText: 'address_country'.tr,
          controller: c.countryController,
          readOnly: true,
          fillColor: AppColors.white,
          radius: BorderRadius.circular(10.r),
          suffixIcon: Icon(Icons.keyboard_arrow_down_sharp, color: AppColors.black1414141, size: 26),
          onChanged: (_) => c.update(),
        ),
        Gap(10.h),
        CommonMainTextField(
          borderColor: AppColors.greyF0EFE4,
          hintText: 'address_note'.tr,
          labelText: 'address_note'.tr,
          controller: c.noteController,
          fillColor: AppColors.white,
          radius: BorderRadius.circular(10.r),
          onChanged: (_) => c.update(),
        ),
        Gap(16.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: CommonCheckBox(
                borderColor: AppColors.greyD7D7D7,
                radius: 6,
                value: c.isDefaultAddress,
                onChanged: (_) => c.toggleDefaultAddress(!c.isDefaultAddress),
              ),
            ),
            Gap(10.w),
            Expanded(
              child: GestureDetector(
                onTap: () => c.toggleDefaultAddress(!c.isDefaultAddress),
                child: Text('address_save_info'.tr, style: TextStyles.regular(14.sp)),
              ),
            ),
          ],
        ),
        Gap(12.h),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyles.bold(16.sp, fontColor: AppColors.black1414141),
    );
  }

  void _showCountryBottomSheet(BuildContext context, AddAddressController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: Get.height * 0.50,
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30.r), topRight: Radius.circular(30.r)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 6,
                decoration: BoxDecoration(color: AppColors.greyE5E4DC, borderRadius: BorderRadius.circular(500)),
              ),
              Gap(16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.close, size: 30.sp, color: Colors.transparent),
                  Text('address_country'.tr, style: TextStyles.bold(24.sp)),
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close, size: 26.sp, color: AppColors.black1414141),
                  ),
                ],
              ),
              Gap(15.h),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.countries.length,
                  separatorBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 15.h),
                      height: 1,
                      color: AppColors.greyF7F6F0,
                      width: Get.width,
                    );
                  },
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        controller.selectedCountry = controller.countries[index];
                        controller.countryController.text = controller.countries[index];
                        controller.phoneController.text = controller.countriesCode[index];
                        controller.phoneError = '';
                        controller.update();
                        Get.back();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(controller.countries[index], style: TextStyles.medium(18.sp)),
                          Container(
                            height: 21.w,
                            width: 21.w,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                              border: controller.selectedCountry == controller.countries[index]
                                  ? Border.all(color: AppColors.primaryColor, width: 6)
                                  : Border.all(color: AppColors.grey949597, width: 1.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Gap(20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberIdDropdown extends StatelessWidget {
  const _MemberIdDropdown({required this.controller});

  final AddAddressController controller;

  String _memberIdLabel(SubMember member) {
    final memberId = member.memberId?.trim();
    return (memberId != null && memberId.isNotEmpty) ? memberId : '—';
  }

  String? _memberIdValue(SubMember member) {
    final memberId = member.memberId?.trim();
    if (memberId != null && memberId.isNotEmpty) return memberId;
    if (member.id.isNotEmpty) return member.id;
    return null;
  }

  List<SubMember> _memberOptions() {
    final members = List<SubMember>.from(controller.subMembers);
    if (!Get.isRegistered<ProfileController>()) return members;

    final user = Get.find<ProfileController>().userData.user;
    final memberId = user?.memberId?.trim();
    if (memberId == null || memberId.isEmpty) return members;

    final alreadyListed = members.any((m) => _memberIdValue(m) == memberId);
    if (alreadyListed) return members;

    members.insert(
      0,
      SubMember(
        id: user?.id ?? '',
        firstName: user?.firstName,
        lastName: user?.lastName,
        memberId: memberId,
        email: user?.email,
      ),
    );
    return members;
  }

  bool _valueInItems(String? value, List<SubMember> members) {
    if (value == null || value.isEmpty) return true;
    for (final m in members) {
      if (_memberIdValue(m) == value) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingSubMembers.value) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.greyF0EFE4),
          ),
          child: Center(
            child: SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
            ),
          ),
        );
      }

      final members = _memberOptions();
      final raw = controller.selectedMemberId.value;
      final String? safeValue = (raw != null && raw.isNotEmpty && !_valueInItems(raw, members)) ? null : raw;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.greyF0EFE4),
        ),
        child: members.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'address_select_member_id'.tr,
                        style: TextStyles.regular(16.sp, fontColor: AppColors.grey888888),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey888888, size: 22.sp),
                  ],
                ),
              )
            : DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: safeValue,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.black1414141, size: 22.sp),
                  hint: Text(
                    'address_select_member_id'.tr,
                    style: TextStyles.regular(16.sp, fontColor: AppColors.grey888888),
                  ),
                  style: TextStyles.medium(16.sp, fontColor: AppColors.black1414141),
                  items: members.map((m) {
                    return DropdownMenuItem<String?>(
                      value: _memberIdValue(m),
                      child: Text(
                        _memberIdLabel(m),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.regular(16.sp),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => controller.setSelectedMemberId(v),
                ),
              ),
      );
    });
  }
}
