import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/models/sub_member_model.dart';
import 'package:viteezy/core/repositories/profile_repository.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/utils/validators.dart';
import 'package:viteezy/presentation/main/addresses/controllers/addresses_controller.dart';
import 'package:viteezy/presentation/main/checkout/controllers/checkout_controller.dart';
import 'package:viteezy/presentation/main/profile/controllers/profile_controller.dart';
import 'package:viteezy/presentation/main/subscription/controllers/subscription_controller.dart';

class AddAddressController extends GetxController {
  /// When true (checkout inline form), saving does not pop a route; [CheckoutController] refreshes addresses.
  final bool embeddedInCheckout;

  AddAddressController({this.embeddedInCheckout = false});

  /// Logged-in user's email (display only; not sent on save).
  TextEditingController accountEmailController = TextEditingController();

  /// Optional contact email for this address (sent in API as `email`).
  TextEditingController optionalEmailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController address1Controller = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController provinceController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController houseNoController = TextEditingController();
  TextEditingController houseNoAdditionController = TextEditingController();

  String? selectedCountry = 'Netherlands';
  String selectedProvince = 'Noord-Holland';

  String? selectedCountryCode = "+31";
  bool isEdit = false;
  bool isDefaultAddress = false;
  bool emailNewsOffer = false;
  String? editingAddressId; // Store address ID when editing

  // Error fields
  String optionalEmailError = '';
  String firstNameError = '';
  String lastNameError = '';
  String phoneError = '';
  String address1Error = '';
  String cityError = '';
  String postalCodeError = '';
  String hNoError = '';
  String hNoAdditionError = '';
  String streetError = '';

  List<String> countries = ['Netherlands', 'Belgium', 'India'];
  List<String> countriesCode = ['+31', '+32', "+91"];
  List<String> provinces = [
    'Noord-Holland',
    'Zuid-Holland',
    'Utrecht',
    'Noord-Brabant',
    'Gelderland',
  ];

  final RxList<SubMember> subMembers = <SubMember>[].obs;
  final RxBool isLoadingSubMembers = false.obs;

  /// Selected family member id for shipping (e.g. MEM-XXX); null means primary account holder.
  final RxnString selectedMemberId = RxnString();

  void setSelectedMemberId(String? memberId) {
    selectedMemberId.value = memberId;
    update();
  }

  void toggleDefaultAddress(bool value) {
    isDefaultAddress = value;
    update();
  }

  void toggleEmailNewsOffer(bool value) {
    emailNewsOffer = value;
    update();
  }

  void validateOptionalEmail() {
    final t = optionalEmailController.text.trim();
    if (t.isEmpty) {
      optionalEmailError = '';
    } else {
      optionalEmailError = ValidationUtils.validateEmail(t) ?? '';
    }
    update();
  }

  void loadAccountEmail() {
    if (Get.isRegistered<ProfileController>()) {
      final pc = Get.find<ProfileController>();
      final e = pc.userData.user?.email?.trim() ?? '';
      if (e.isNotEmpty) {
        accountEmailController.text = e;
        update();
        return;
      }
    }
    profileRepository.getUserProfile(
      onSuccess: (ApiResponse response) {
        try {
          final raw = response.data;
          if (raw is Map) {
            final u = raw['user'];
            if (u is Map) {
              accountEmailController.text = u['email']?.toString().trim() ?? '';
            }
          }
        } catch (e) {
          debugPrint('loadAccountEmail: $e');
        }
        update();
      },
      onError: (_) => update(),
    );
  }

  void selectCountry(String country) {
    selectedCountry = country;
    countryController.text = country;
    update();
  }

  void selectProvince(String province) {
    selectedProvince = province;
    provinceController.text = province;
    update();
  }

  void validateFirstName() {
    firstNameError =
        ValidationUtils.validateName(firstNameController.text) ?? '';
    update();
  }

  void validateLastName() {
    lastNameError = ValidationUtils.validateName(lastNameController.text) ?? '';
    update();
  }

  void validatePhone() {
    final raw = phoneController.text.trim();
    if (raw.isEmpty) {
      phoneError = '';
      update();
      return;
    }
    if (raw.length < 8) {
      phoneError = 'validator_phone_invalid'.tr;
      update();
      return;
    }
    phoneError = '';
    update();
  }

  void validateAddress1() {
    address1Error =
        ValidationUtils.validateAddress(address1Controller.text) ?? '';
    update();
  }

  void validateCity() {
    if (cityController.text.trim().isEmpty) {
      cityError = 'validator_city_required'.tr;
    } else {
      cityError = '';
    }
    update();
  }

  void validatePostalCode() {
    if (postalCodeController.text.trim().isEmpty) {
      postalCodeError = 'ZIP code required';
    } else if (postalCodeController.text.trim().length < 4) {
      postalCodeError = 'ZIP code must be at least 4 characters';
    } else {
      postalCodeError = '';
    }
    update();
  }

  void validateHouseNo() {
    hNoError =
        ValidationUtils.validateHouseNumber(houseNoController.text) ?? '';
    update();
  }

  void validateHouseNoAddition() {
    hNoAdditionError =
        ValidationUtils.validateHouseNumberAddition(
          houseNoAdditionController.text,
        ) ??
        '';
    update();
  }

  void validateStreet() {
    streetError = ValidationUtils.validateStreet(streetController.text) ?? '';
    update();
  }

  bool validateAllFields() {
    hNoAdditionError = '';
    validateOptionalEmail();
    validateFirstName();
    validateLastName();
    validatePhone();
    validateAddress1();
    validateCity();
    validatePostalCode();
    validateHouseNo();
    validateStreet();

    return optionalEmailError.isEmpty &&
        firstNameError.isEmpty &&
        lastNameError.isEmpty &&
        phoneError.isEmpty &&
        address1Error.isEmpty &&
        cityError.isEmpty &&
        postalCodeError.isEmpty &&
        hNoError.isEmpty &&
        streetError.isEmpty;
  }

  Map<String, dynamic> _coreAddressFields() {
    final addrLine = address1Controller.text.trim();
    final streetName = streetController.text.trim().isEmpty
        ? addrLine
        : streetController.text.trim();
    return {
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'memberID': selectedMemberId.value,
      'streetName': streetName,
      'houseNumber': houseNoController.text.trim(),
      'houseNumberAddition': houseNoAdditionController.text.trim(),
      'postalCode': postalCodeController.text.trim(),
      'address': addrLine,
      'phone': phoneController.text.trim(),
      'country': selectedCountry == 'India'
          ? 'IN'
          : selectedCountry == 'Belgium'
          ? 'BE'
          : 'NL',
      'city': cityController.text.trim(),
      'isDefault': isDefaultAddress,
      'note': noteController.text.trim(),
       'email': optionalEmailController.text.trim(),
      // 'newsletterSubscribed': emailNewsOffer,
      // ..._memberIdPayload(),
    };
  }

  String? _firstValidationErrorMessage() {
    if (optionalEmailError.isNotEmpty) return optionalEmailError;
    if (firstNameError.isNotEmpty) return firstNameError;
    if (lastNameError.isNotEmpty) return lastNameError;
    if (phoneError.isNotEmpty) return phoneError;
    if (address1Error.isNotEmpty) return address1Error;
    if (postalCodeError.isNotEmpty) return postalCodeError;
    if (hNoError.isNotEmpty) return hNoError;
    if (cityError.isNotEmpty) return cityError;
    if (streetError.isNotEmpty) return streetError;
    return null;
  }

  Future<void> saveAddress() async {
    if (isLoading.value) return;
    if (validateAllFields()) {
      await addAddress();
      return;
    }
    final msg = _firstValidationErrorMessage();
    if (msg != null && msg.isNotEmpty) {
      AppFunctions().showToast(msg, bgColor: AppColors.red);
    } else {
      AppFunctions().showToast(
        'address_form_check_fields'.tr,
        bgColor: AppColors.red,
      );
    }
    update();
  }

  @override
  void onClose() {
    accountEmailController.dispose();
    optionalEmailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    companyController.dispose();
    phoneController.dispose();
    address1Controller.dispose();
    streetController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    provinceController.dispose();
    noteController.dispose();
    houseNoController.dispose();
    houseNoAdditionController.dispose();
    super.onClose();
  }

  RxBool isLoading = false.obs;
  RxBool isFetchingAddress =
      false.obs; // Loading state for fetching address details
  ProfileRepository profileRepository = ProfileRepository();

  void loadSubMembers() {
    isLoadingSubMembers.value = true;
    profileRepository.getSubMembers(
      onSuccess: (ApiResponse response) {
        isLoadingSubMembers.value = false;
        try {
          final raw = response.data;
          if (raw is Map) {
            final map = Map<String, dynamic>.from(raw);
            final list = map['subMembers'] as List<dynamic>? ?? [];
            subMembers.assignAll(
              list.map(
                (e) => SubMember.fromJson(Map<String, dynamic>.from(e as Map)),
              ),
            );
          } else {
            subMembers.clear();
          }
        } catch (e) {
          subMembers.clear();
          debugPrint('loadSubMembers parse: $e');
        }

        // Auto-select the logged-in user's own memberId as default,
        // but only if nothing is already selected (e.g. not in edit mode).
        if (selectedMemberId.value == null || selectedMemberId.value!.isEmpty) {
          _setDefaultMemberId();
        }

        update();
      },
      onError: (AppException error) {
        isLoadingSubMembers.value = false;
        subMembers.clear();
        debugPrint('loadSubMembers: ${error.message}');
        update();
      },
    );
  }

  /// Prepends the logged-in user's own profile as the first item in [subMembers]
  /// and sets [selectedMemberId] to their memberId so the dropdown pre-selects
  /// it. Falls back to the first sub-member already in the list if the profile
  /// is unavailable.
  void _setDefaultMemberId() {
    if (Get.isRegistered<ProfileController>()) {
      final pc = Get.find<ProfileController>();
      final user = pc.userData.user;
      final loggedInMemberId = user?.memberId?.trim() ?? '';

      if (loggedInMemberId.isNotEmpty) {
        // Build a SubMember entry for the logged-in user so the dropdown item exists.
        final selfEntry = SubMember(
          id: user?.id?.toString() ?? '',
          firstName: user?.firstName?.trim(),
          lastName: user?.lastName?.trim(),
          memberId: loggedInMemberId,
          email: user?.email?.trim(),
        );

        // Prepend only if not already present.
        final alreadyPresent = subMembers.any(
          (m) => (m.memberId?.trim() ?? '') == loggedInMemberId,
        );
        if (!alreadyPresent) {
          subMembers.insert(0, selfEntry);
        }

        selectedMemberId.value = loggedInMemberId;
        return;
      }
    }

    // Fallback: select the first sub-member's dropdown value if list is non-empty.
    if (subMembers.isNotEmpty) {
      final first = subMembers.first;
      final v = (first.memberId != null && first.memberId!.trim().isNotEmpty)
          ? first.memberId!
          : first.id;
      selectedMemberId.value = v;
    }
  }

  Map<String, dynamic> _memberIdPayload() {
    final v = selectedMemberId.value;
    if (v != null && v.trim().isNotEmpty) {
      return {'memberId': v.trim()};
    }
    return {};
  }

  Future<void> addAddress() async {
    if (editingAddressId == null || editingAddressId!.isEmpty) {
      // Add new address
      await _addNewAddress();
    } else {
      // Update existing address
      await _updateAddress();
    }
  }

  Future<void> _addNewAddress() async {
    isLoading.value = true;

    await profileRepository.addAddressAPI(
      data: _coreAddressFields(),
      onSuccess: (ApiResponse response) {
        try {
          isLoading.value = false;
          if (!embeddedInCheckout) {
            Get.back();
          }
          AppFunctions().showToast(
            response.message ?? 'common_error'.tr,
            bgColor: AppColors.green,
          );
          // Refresh addresses in AddressesController if registered
          if (Get.isRegistered<AddressesController>()) {
            Get.find<AddressesController>().loadAddresses();
          }
          // Refresh addresses in CheckoutController if registered (user might be in checkout)
          if (Get.isRegistered<CheckoutController>()) {
            Get.find<CheckoutController>().loadAddresses();
          }
          if (Get.isRegistered<SubscriptionController>()) {
            Get.find<SubscriptionController>().loadAddresses();
          }
        } catch (e) {
          isLoading.value = false;
          AppFunctions().showToast(
            response.message ?? 'common_error'.tr,
            bgColor: AppColors.red,
          );
          debugPrint('error:::${e.toString()} ');
          update();
        }
      },
      onError: (AppException error) {
        isLoading.value = false;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
        debugPrint('error:::${error.message} ');
        update();
      },
    );
  }

  Future<void> _updateAddress() async {
    if (editingAddressId == null || editingAddressId!.isEmpty) {
      AppFunctions().showToast('address_id_missing'.tr, bgColor: AppColors.red);
      return;
    }

    isLoading.value = true;

    await profileRepository.updateAddressAPI(
      addressId: editingAddressId!,
      data: _coreAddressFields(),
      onSuccess: (ApiResponse response) {
        try {
          isLoading.value = false;
          if (!embeddedInCheckout) {
            Get.back();
          }
          AppFunctions().showToast(
            response.message ?? 'address_updated_success'.tr,
            bgColor: AppColors.green,
          );
          // Refresh addresses in AddressesController if registered
          if (Get.isRegistered<AddressesController>()) {
            Get.find<AddressesController>().loadAddresses();
          }
          // Refresh addresses in CheckoutController if registered (user might be in checkout)
          if (Get.isRegistered<CheckoutController>()) {
            Get.find<CheckoutController>().loadAddresses();
          }
          if (Get.isRegistered<SubscriptionController>()) {
            Get.find<SubscriptionController>().loadAddresses();
          }
        } catch (e) {
          isLoading.value = false;
          AppFunctions().showToast(
            response.message ?? 'common_error'.tr,
            bgColor: AppColors.red,
          );
          debugPrint('error:::${e.toString()} ');
          update();
        }
      },
      onError: (AppException error) {
        isLoading.value = false;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
        debugPrint('error:::${error.message} ');
        update();
      },
    );
  }

  @override
  void onInit() {
    countryController.text = selectedCountry ?? 'Netherlands';
    phoneController.text = selectedCountryCode ?? '+31';

    if (Get.arguments != null) {
      isEdit = Get.arguments['isEdit'] ?? false;

      // If editing, fetch address details by ID
      if (isEdit && Get.arguments['addressId'] != null) {
        final addressId = Get.arguments['addressId'] as String;
        _fetchAddressDetails(addressId);
      }
    }
    loadAccountEmail();
    loadSubMembers();
    super.onInit();
  }

  Future<void> _fetchAddressDetails(String addressId) async {
    isFetchingAddress.value = true;
    update();

    await profileRepository.getAddressById(
      addressId: addressId,
      onSuccess: (ApiResponse response) {
        isFetchingAddress.value = false;
        try {
          if (response.data != null && response.data['address'] != null) {
            final addressData = response.data['address'];
            _prefillForm(addressData);
          } else {
            AppFunctions().showToast(
              'address_not_found'.tr,
              bgColor: AppColors.red,
            );
            Get.back();
          }
        } catch (e) {
          isFetchingAddress.value = false;
          AppFunctions().showToast(
            'address_load_error'.tr,
            bgColor: AppColors.red,
          );
          debugPrint('Error parsing address: $e');
          update();
        }
      },
      onError: (AppException error) {
        isFetchingAddress.value = false;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
        debugPrint('Error fetching address: ${error.message}');
        update();
      },
    );
  }

  void _prefillForm(Map<String, dynamic> addressData) {
    try {
      final address = Address.fromJson(addressData);

      // Store address ID for edit mode
      editingAddressId = address.id;

      // Pre-fill all form fields
      optionalEmailController.text = address.email ?? '';
      firstNameController.text = address.firstName ?? '';
      lastNameController.text = address.lastName ?? '';
      streetController.text = address.streetName ?? '';
      houseNoController.text = address.houseNumber ?? '';
      houseNoAdditionController.text = address.houseNumberAddition ?? '';
      postalCodeController.text = address.postalCode ?? '';
      address1Controller.text = address.address ?? '';
      phoneController.text = address.phone ?? '';
      cityController.text = address.city ?? '';
      noteController.text = address.note ?? '';
      isDefaultAddress = address.isDefault ?? false;
      emailNewsOffer = address.emailNewsOffer ?? false;
      final mid = address.memberId?.trim();
      selectedMemberId.value = (mid != null && mid.isNotEmpty) ? mid : null;

      // Set country based on country code
      if (address.country == 'IN') {
        selectedCountry = 'India';
        selectedCountryCode = '+91';
      } else if (address.country == 'BE') {
        selectedCountry = 'Belgium';
        selectedCountryCode = '+32';
      } else {
        selectedCountry = 'Netherlands';
        selectedCountryCode = '+31';
      }
      countryController.text = selectedCountry ?? 'Netherlands';

      update();
    } catch (e) {
      debugPrint('Error pre-filling form: $e');
    }
  }
}
