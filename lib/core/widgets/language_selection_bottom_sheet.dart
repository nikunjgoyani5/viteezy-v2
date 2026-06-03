import 'package:get/get.dart';
import 'package:viteezy/core/l10n/locale_service.dart';
import 'package:viteezy/core/models/general_settings_model.dart';
import 'package:viteezy/core/services/global_settings_service.dart';
import 'package:viteezy/core/widgets/common_button.dart';
import 'package:viteezy/gen/assets.gen.dart';
import 'package:viteezy/presentation/auth/forgot_password/controllers/forgot_password_controller.dart';
import 'package:viteezy/presentation/auth/login/controllers/login_controller.dart';
import 'package:viteezy/presentation/main/otp_verification/controllers/otp_verification_controller.dart';

import '../../presentation/auth/signup/controllers/signup_controller.dart';
import '../../presentation/main/profile/controllers/profile_controller.dart';
import '../utils/exports.dart';

class LanguageSelectionBottomSheet extends StatefulWidget {
  final String selectedLanguage;
  final Function(String) onLanguageSelected;
  final VoidCallback onOkPressed;

  const LanguageSelectionBottomSheet({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
    required this.onOkPressed,
  });

  @override
  State<LanguageSelectionBottomSheet> createState() => _LanguageSelectionBottomSheetState();
}

class _LanguageSelectionBottomSheetState extends State<LanguageSelectionBottomSheet> {
  late String localSelectedLocaleCode;

  /// Map API language name to locale code for initial selection.
  static String _nameToLocaleCode(String name) {
    final lower = name.toLowerCase();
    if (lower == 'dutch' || lower == 'nl') return 'nl';
    if (lower == 'german' || lower == 'de') return 'de';
    if (lower == 'french' || lower == 'fr') return 'fr';
    if (lower == 'spanish' || lower == 'es') return 'es';
    return 'en';
  }

  static String _localeCodeToNameFromCode(String code) {
    switch (code) {
      case 'nl':
        return 'Dutch';
      case 'de':
        return 'German';
      case 'fr':
        return 'French';
      case 'es':
        return 'Spanish';
      default:
        return 'English';
    }
  }

  static String _flagAssetForCode(String? code) {
    final c = (code ?? '').toLowerCase();
    if (c == 'nl') return Assets.icons.icFlagDutch.path;
    if (c == 'en') return Assets.icons.icFlagUs.path;
    if (c == 'de') return Assets.images.germanFlag.path;
    if (c == 'fr') return Assets.images.frenchFlag.path;
    if (c == 'es') return Assets.images.icSpanishFlag.path;
    // No assets for DE, FR, ES; use US as fallback
    return Assets.icons.icFlagUs.path;
  }

  @override
  void initState() {
    super.initState();
    localSelectedLocaleCode = _nameToLocaleCode(widget.selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final enabledLanguages = GlobalSettingsService.to.enabledLanguages;
    final languages = enabledLanguages.isEmpty
        ? <Language>[
            Language(code: 'EN', name: 'English', isEnabled: true),
            Language(code: 'NL', name: 'Dutch', isEnabled: true),
          ]
        : enabledLanguages;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 6,
              decoration: BoxDecoration(color: AppColors.greyE5E4DC, borderRadius: BorderRadius.circular(500)),
            ),
            Gap(20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.close, size: 30.sp, color: Colors.transparent),
                Text('language_select'.tr, style: TextStyles.bold(24.sp)),
                InkWell(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close, size: 30.sp, color: AppColors.black1414141),
                ),
              ],
            ),
            Gap(20.h),
            // Language Options - only enabled languages from API settings
            ...languages.map((lang) {
              final localeCode = LocaleService.normalizeCode(lang.code);
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: LanguageOption(
                  language: lang.name ?? _localeCodeToNameFromCode(localeCode),
                  languageCode: localeCode,
                  flag: _flagAssetForCode(lang.code),
                  isSelected: localSelectedLocaleCode == localeCode,
                  onTap: () {
                    setState(() {
                      localSelectedLocaleCode = localeCode;
                    });
                  },
                ),
              );
            }),
            Gap(100.h),
            CommonButton(
              text: 'common_ok'.tr,
              onPressed: () {
                widget.onLanguageSelected(_localeCodeToNameFromCode(localSelectedLocaleCode));
                if (Get.isRegistered<ProfileController>()) {
                  Get.find<ProfileController>().selectedLanguage = localSelectedLocaleCode;
                }
                if (Get.isRegistered<LoginController>()) {
                  Get.find<LoginController>().selectedLanguage = localSelectedLocaleCode;
                }
                if (Get.isRegistered<ForgotPasswordController>()) {
                  Get.find<ForgotPasswordController>().selectedLanguage = localSelectedLocaleCode;
                }
                if (Get.isRegistered<SignupController>()) {
                  Get.find<SignupController>().selectedLanguage = localSelectedLocaleCode;
                }
                if (Get.isRegistered<OtpVerificationController>()) {
                  Get.find<OtpVerificationController>().selectedLanguage = localSelectedLocaleCode;
                }
                widget.onOkPressed();
              },
              color: AppColors.black1414141,
              textColor: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageOption extends StatelessWidget {
  final String language;
  final String languageCode;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageOption({
    super.key,
    required this.language,
    required this.languageCode,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.white),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Row(
          children: [
            // Flag
            ClipOval(child: Image.asset(flag, fit: BoxFit.fill, scale: 3, width: 30, height: 30)),
            Gap(15.w),
            // Language Name
            Text(language, style: TextStyles.medium(18.sp)),
            Spacer(),
            // Selection Indicator
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryColor : AppColors.white,
                border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.greyDFDFDF, width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.w,
                        height: 12.h,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
