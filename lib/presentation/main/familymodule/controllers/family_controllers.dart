import 'package:get/get.dart';
import 'package:viteezy/core/models/family_info_model.dart';
import 'package:viteezy/core/repositories/family_repository.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/utils/app_functions.dart';

class FamilyController extends GetxController {
  final FamilyRepository _familyRepository = FamilyRepository();

  final RxList<FamilyMember> subMembers = <FamilyMember>[].obs;
  final RxBool isLoading = false.obs;
  final RxString role = ''.obs;
  final RxString errorMessage = ''.obs;

  /// Tracks which member IDs are currently being removed (shows per-row loading)
  final RxSet<String> removingIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    getFamilyInfo();
  }

  Future<void> getFamilyInfo() async {
    isLoading.value = true;
    errorMessage.value = '';

    await _familyRepository.getFamilyInfo(
      onSuccess: (data) {
        role.value = data.role;
        // Family screen lists sub-members only; mainMember is intentionally excluded.
        subMembers.assignAll(data.subMembers);
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        errorMessage.value = error.message;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  Future<void> removeFamilyMember(String userId) async {
    removingIds.add(userId);

    await _familyRepository.removeFamilyMember(
      userId: userId,
      onSuccess: (_) {
        // Remove the member locally on success
        subMembers.removeWhere((m) => m.id == userId);
        removingIds.remove(userId);
        AppFunctions().showToast(
          'Family member removed successfully',
          bgColor: AppColors.blackColor,
        );
      },
      onError: (error) {
        removingIds.remove(userId);
        AppFunctions().showToast(
          'Something went wrong',
          bgColor: AppColors.red,
        );
      },
    );
  }
}
