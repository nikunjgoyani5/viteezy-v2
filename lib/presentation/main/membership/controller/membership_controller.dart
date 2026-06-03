import 'dart:developer';

import 'package:get/get.dart';

import '../../../../core/models/membership_model.dart';
import '../../../../core/repositories/memberships_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_functions.dart';

class MembershipController extends GetxController {
  final _membershipsRepository = MembershipsRepository();
  final RxList<Plan> plans = <Plan>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedPlanId = ''.obs;
  bool _isInitialLoad = true;

  void getMembershipsPlans({bool isRefresh = false}) {
    // Only show loading shimmer on initial load (when plans are empty)
    // On refresh, update in background without showing shimmer
    if (_isInitialLoad && plans.isEmpty) {
      isLoading.value = true;
    }
    _membershipsRepository.getMembershipsPlans(
      onSuccess: (data) {
        try {
          if (data.data != null) {
            List<Plan> plansList = [];
            // Check if data.data is a Map with 'plans' key
            if (data.data is Map<String, dynamic> && data.data['plans'] != null) {
              plansList = (data.data['plans'] as List)
                  .map((plan) => Plan.fromJson(plan as Map<String, dynamic>))
                  .toList();
            } else if (data.data is Map<String, dynamic>) {
              // Try to parse as PlanData
              final planData = PlanData.fromJson(data.data as Map<String, dynamic>);
              plansList = planData.plans ?? [];
            }

            // Sort plans: Annual plan first, then others
            plansList.sort((a, b) {
              final aIsAnnual = _isAnnualPlan(a);
              final bIsAnnual = _isAnnualPlan(b);
              if (aIsAnnual && !bIsAnnual) return -1;
              if (!aIsAnnual && bIsAnnual) return 1;
              return 0;
            });

            plans.value = plansList;

            // Set first plan as default selected
            if (plansList.isNotEmpty && selectedPlanId.value.isEmpty) {
              selectedPlanId.value = plansList.first.id ?? '';
            }

            // Mark initial load as complete
            _isInitialLoad = false;
          }
        } catch (e, stackTrace) {
          log('Error parsing membership plans: $e');
          log('Stack trace: $stackTrace');
          plans.clear();
          _isInitialLoad = false;
        } finally {
          isLoading.value = false;
        }
      },
      onError: (error) {
        isLoading.value = false;
        _isInitialLoad = false;
        log('Error loading membership plans: ${error.message}');
        plans.clear();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  bool _isAnnualPlan(Plan plan) {
    // Check if plan name contains "annual" or "year" (case insensitive)
    final name = plan.name?.toLowerCase() ?? '';
    if (name.contains('annual') || name.contains('year')) {
      return true;
    }
    // Check if duration is around 365 days (annual)
    if (plan.durationDays != null && plan.durationDays! >= 360 && plan.durationDays! <= 370) {
      return true;
    }
    return false;
  }

  void selectPlan(String planId) {
    selectedPlanId.value = planId;
  }

  bool isAnnualPlan(Plan plan) {
    return _isAnnualPlan(plan);
  }

  void buyMembership({
    required String planId,
    required String paymentMethod,
    Function(String? webUrl, String? membershipId)? onSuccess,
    Function(String error)? onError,
  }) {
    _membershipsRepository.buyMembership(
      planId: planId,
      paymentMethod: paymentMethod,
      onSuccess: (data) {
        try {
          // Extract web URL and membershipId from response
          String? webUrl;
          if (data.data != null) {
            if (data.data is Map<String, dynamic>) {
              final responseData = data.data as Map<String, dynamic>;
              // Try different possible keys for the URL
              webUrl = responseData['payment']['redirectUrl'];
            }
          }
          onSuccess?.call(webUrl, planId);
        } catch (e) {
          log('Error parsing buy membership response: $e');
          onError?.call('Failed to process payment URL');
        }
      },
      onError: (error) {
        log('Error buying membership: ${error.message}');
        onError?.call(error.message);
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void trackPayment({
    required String membershipId,
    Function(Map<String, dynamic>? paymentData)? onSuccess,
    Function(String error)? onError,
  }) {
    _membershipsRepository.trackPayment(
      membershipId: membershipId,
      onSuccess: (data) {
        try {
          if (data.data != null && data.data is Map<String, dynamic>) {
            final paymentData = data.data as Map<String, dynamic>;
            onSuccess?.call(paymentData);
          } else {
            onSuccess?.call(null);
          }
        } catch (e) {
          log('Error parsing track payment response: $e');
          onError?.call('Failed to parse payment status');
        }
      },
      onError: (error) {
        log('Error tracking payment: ${error.message}');
        onError?.call(error.message);
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }
}
