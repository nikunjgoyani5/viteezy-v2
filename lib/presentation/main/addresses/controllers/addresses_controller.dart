import 'package:get/get.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/repositories/profile_repository.dart';
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/widgets/common_loader.dart';
import 'package:viteezy/core/widgets/common_button.dart';
import 'package:viteezy/core/utils/exports.dart';

class Address {
  String? id;
  String? userId;
  String? firstName;
  String? lastName;
  String? streetName;
  String? houseNumber;
  String? houseNumberAddition;
  String? postalCode;
  String? address;
  String? phone;
  String? country;
  String? city;
  bool? isDefault;
  bool? isSelectedForSubscription;
  String? note;
  /// Sub-member / family member id (e.g. MEM-XXX) when address is for a family member.
  String? memberId;
  String? email;
  bool? emailNewsOffer;
  bool? isDeleted;
  String? createdBy;
  String? updatedBy;
  String? createdAt;
  String? updatedAt;
  int? v;

  Address({
    this.id,
    this.userId,
    this.firstName,
    this.lastName,
    this.streetName,
    this.houseNumber,
    this.houseNumberAddition,
    this.postalCode,
    this.address,
    this.phone,
    this.country,
    this.city,
    this.isDefault,
    this.note,
    this.memberId,
    this.email,
    this.emailNewsOffer,
    this.isDeleted,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.isSelectedForSubscription,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json["_id"],
    userId: json["userId"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    streetName: json["streetName"],
    houseNumber: json["houseNumber"],
    houseNumberAddition: json["houseNumberAddition"],
    postalCode: json["postalCode"],
    address: json["address"],
    phone: json["phone"],
    country: json["country"],
    city: json["city"],
    isDefault: json["isDefault"],
    note: json["note"],
    memberId: json["memberId"]?.toString(),
    email: json["email"]?.toString(),
    emailNewsOffer: json["emailNewsOffer"] as bool?,
    isDeleted: json["isDeleted"],
    createdBy: json["createdBy"],
    updatedBy: json["updatedBy"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
    isSelectedForSubscription: json['isSelectedForSubscription']
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "firstName": firstName,
    "lastName": lastName,
    "streetName": streetName,
    "houseNumber": houseNumber,
    "houseNumberAddition": houseNumberAddition,
    "postalCode": postalCode,
    "address": address,
    "phone": phone,
    "country": country,
    "city": city,
    "isDefault": isDefault,
    "note": note,
    "memberId": memberId,
    "email": email,
    "emailNewsOffer": emailNewsOffer,
    "isDeleted": isDeleted,
    "createdBy": createdBy,
    "updatedBy": updatedBy,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}
class AddressesController extends GetxController {
  List<Address> addresses = [];
  bool isLoading = false;
  final ProfileRepository profileRepository = ProfileRepository();

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  void loadAddresses() {
    isLoading = true;
    update();

    profileRepository.getAddresses(
      onSuccess: (ApiResponse response) {
        isLoading = false;
        try {
          if (response.data != null && response.data['addresses'] != null) {
            final List<dynamic> addressesList = response.data['addresses'];
            addresses = addressesList
                .map((addressJson) => Address.fromJson(addressJson))
                .toList();
          } else {
            addresses = [];
          }
          update();
        } catch (e) {
          addresses = [];
          update();
          AppFunctions().showToast('Error parsing addresses', bgColor: AppColors.red);
        }
      },
      onError: (AppException error) {
        isLoading = false;
        addresses = [];
        update();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void refreshAddresses() {
    loadAddresses();
  }

  void addNewAddress() {
Get.toNamed(AppRoutes.addAddress,arguments: {'isEdit' : false});
  }

  void editAddress(String addressId) {
    if (addressId.isEmpty) return;
    
    // Navigate directly to add address screen with address ID
    Get.toNamed(
      AppRoutes.addAddress,
      arguments: {
        'isEdit': true,
        'addressId': addressId,
      },
    );
  }

  RxBool isDeletingAddress = false.obs;

  void deleteAddress(String addressId) {
    if (addressId.isEmpty) return;
    
    // Show confirmation dialog
    _showDeleteAddressDialog(addressId);
  }

  void _showDeleteAddressDialog(String addressId) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text('checkout_delete_address'.tr, style: TextStyles.medium(21.sp)),
              ),
              Gap(6.h),
              Align(
                alignment: Alignment.center,
                child: Text('addresses_delete_confirm'.tr, style: TextStyles.regular(16.sp)),
              ),
              Gap(18.h),
              Row(
                children: [
                  Expanded(
                    child: CommonButtonWidget(
                      height: 44.h,
                      color: AppColors.red,
                      borderRadius: 40,
                      onPressed: () {
                        Get.back();
                      },
                      child: Center(
                        child: Text('common_cancel'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.white)),
                      ),
                    ),
                  ),
                  Gap(10.w),
                  Expanded(
                    child: Obx(() {
                      return CommonButtonWidget(
                        height: 44.h,
                        color: AppColors.black1414141,
                        borderRadius: 40,
                        onPressed: () async {
                          await _performDeleteAddress(addressId);
                        },
                        child: isDeletingAddress.value
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [CommonLoader(color: AppColors.white, size: 15)],
                              )
                            : Center(
                                child: Text('common_yes'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.white)),
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _performDeleteAddress(String addressId) async {
    isDeletingAddress.value = true;

    await profileRepository.deleteAddressAPI(
      addressId: addressId,
      onSuccess: (ApiResponse response) {
        isDeletingAddress.value = false;
        Get.back(); // Close dialog
        AppFunctions().showToast(response.message ?? 'Address deleted successfully', bgColor: AppColors.green);
        loadAddresses(); // Refresh address list
      },
      onError: (AppException error) {
        isDeletingAddress.value = false;
        Get.back(); // Close dialog
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }
}

