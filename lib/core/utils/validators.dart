import 'package:get/get.dart';

class ValidationUtils {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'validator_email_required'.tr;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'validator_email_invalid'.tr;
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validator_phone_required'.tr;
    }
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'validator_phone_invalid'.tr;
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'validator_name_required'.tr;
    if (value.trim().length < 2) return 'validator_name_too_short'.tr;
    return null;
  }
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) return 'validator_description_required'.tr;
    if (value.trim().length < 2) return 'validator_description_short'.tr;
    return null;
  }
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return 'validator_address_required'.tr;
    if (value.trim().length < 4) return 'validator_address_short'.tr;
    return null;
  }
  static String? validateWebsite(String? value) {
    if (value == null || value.trim().isEmpty) return 'Website required';
    if (value.trim().length < 2) return 'Website too short';
    return null;
  }
  static String? validateTotalRoom(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter total rooms';

    return null;
  }
  static String? validateTotalFloor(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter total floors';

    return null;
  }
  static String? validateYearBuilt(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter year built';

    return null;
  }
  static String? validateLastRenovated(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter last renovated year';

    return null;
  }
  static String? validateDistance(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter Distance';

    return null;
  }


  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'validator_password_required'.tr;
    if (value.length < 6) return 'validator_password_min'.tr;
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'validator_date_required'.tr;
    try {
      DateTime.parse(value);
      return null;
    } catch (_) {
      return 'validator_date_invalid'.tr;
    }
  }

  static String? validateHouseNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'validator_house_number_required'.tr;
    if (value.trim().length < 1) return 'validator_house_number_required'.tr;
    return null;
  }

  static String? validateHouseNumberAddition(String? value) {
    if ( value?.trim().isEmpty ?? true) {
      return 'validator_house_number_required'.tr;
    }
    return null;
  }

  static String? validateStreet(String? value) {
    if (value == null || value.trim().isEmpty) return 'validator_street_required'.tr;
    if (value.trim().length < 4) return 'validator_street_min'.tr;
    return null;
  }

  static String? validateNote(String? value) {
    if (value?.isEmpty??true) {
      return 'validator_note_required'.tr;
    }
    return null;
  }

}
