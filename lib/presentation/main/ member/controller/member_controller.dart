import 'package:viteezy/core/models/membership_model.dart';
import 'package:viteezy/core/models/transaction_model.dart';
import 'package:viteezy/core/repositories/membership_repository.dart';
import '../../../../core/utils/app_functions.dart';
import '../../../../core/utils/exports.dart';

class MemberController extends GetxController {
  final _membershipRepository = MembershipRepository();

  // State
  final RxList<MembershipListItem> memberships = <MembershipListItem>[].obs;
  final Rx<Membership> activeMembership = Membership().obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingTransactions = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMemberships();
  }

  /// Load memberships from API
  Future<void> loadMemberships() async {
    isLoading.value = true;
    try {
      await _membershipRepository.getMemberships(
        onSuccess: (list) {
          memberships.assignAll(list);
          isLoading.value = false;
        },
        onError: (error) {
          isLoading.value = false;
          AppFunctions.showCustomToast(Get.context!, message: error.message, isSuccess: false);
        },
      );
    } catch (e) {
      isLoading.value = false;
      AppFunctions.showCustomToast(Get.context!, message: 'member_load_error'.tr, isSuccess: false);
    }
  }

  /// Load transactions from API
  Future<void> loadTransactions(String membershipId) async {
    isLoadingTransactions.value = true;
    try {
      await _membershipRepository.getMembershipsTransactionsHistoryGetById(
        membershipId: membershipId,
        onSuccess: (data) {
          activeMembership.value = Membership.fromJson(data.data["membership"]);
          
          final list = <TransactionModel>[];
          if (data.data != null) {
            // Handle if data is directly a list
            if (data.data is List) {
              final raw = data.data as List;
              for (final item in raw) {
                if (item is Map<String, dynamic>) {
                  list.add(TransactionModel.fromJson(item));
                }
              }
            }
            // Handle if data is wrapped in a field
            else if (data.data is Map<String, dynamic>) {
              final dataMap = data.data as Map<String, dynamic>;
              // Try to get from common field names
              List raw = dataMap['transactions'] ?? dataMap['data'] ?? [];
              for (final item in raw) {
                if (item is Map<String, dynamic>) {
                  list.add(TransactionModel.fromJson(item));
                }
              }
            }
          }

          transactions.assignAll(list);
          isLoadingTransactions.value = false;
        },
        onError: (error) {
          isLoadingTransactions.value = false;
          AppFunctions.showCustomToast(Get.context!, message: error.message, isSuccess: false);
        },
      );
    } catch (e) {
      isLoadingTransactions.value = false;
      AppFunctions.showCustomToast(Get.context!, message: 'member_transactions_load_error'.tr, isSuccess: false);
    }
  }

  /// Get active membership
  MembershipListItem? getActiveMembership() {
    try {
      if (memberships.isEmpty) return null;
      // Return the first membership or the one with "Active" status
      return memberships.firstWhere((m) => m.status.toLowerCase() == 'active', orElse: () => memberships.first);
    } catch (e) {
      return memberships.isNotEmpty ? memberships.first : null;
    }
  }

  /// Get transaction by ID
  TransactionModel? getTransactionById(String transactionId) {
    try {
      return transactions.firstWhere((t) => t.id == transactionId);
    } catch (e) {
      return null;
    }
  }

  Future<void> cancelMembership(String id, BuildContext context) async {
    try {
      await _membershipRepository.canselMembership(
        membershipId: id,
        onSuccess: (data) {
          AppFunctions.showCustomToast(
            context,
            message: data.message ?? 'member_cancelled_success'.tr,
            isSuccess: true,
          );
          loadMemberships();
        },
        onError: (error) {
          AppFunctions.showCustomToast(context, message: error.message, isSuccess: false);
        },
      );
    } catch (e) {
      isLoadingTransactions.value = false;
      AppFunctions.showCustomToast(context, message: 'member_transactions_load_error'.tr, isSuccess: false);
    }
  }
}
