import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/models/postponement_model.dart';
import 'package:viteezy/core/models/subscription_model.dart';
import 'package:viteezy/core/models/transaction_history_model.dart';
import 'package:viteezy/core/models/subscription_activity_model.dart';
import 'package:viteezy/core/models/subscription_products_model.dart';
import 'package:viteezy/core/models/product_response_model.dart';
import 'package:viteezy/core/repositories/profile_repository.dart';
import 'package:viteezy/core/repositories/subscription_repository.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/custom_toast.dart';
import 'package:viteezy/presentation/main/addresses/controllers/addresses_controller.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_functions.dart';

class SubscriptionController extends GetxController {
  final SubscriptionRepository _subscriptionRepository = SubscriptionRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  final RxList<SubscriptionData> subscriptions = <SubscriptionData>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  final RxList<TransactionHistoryItem> transactions = <TransactionHistoryItem>[].obs;
  final RxBool isLoadingTransactions = false.obs;
  final RxBool transactionsFetched = false.obs;

  // Plan activity (Plan History tab)
  final RxList<SubscriptionActivityItem> planActivities = <SubscriptionActivityItem>[].obs;
  final RxBool isLoadingPlanActivities = false.obs;
  final RxBool isLoadingMorePlanActivities = false.obs;
  final RxBool planActivitiesFetched = false.obs;
  int _planActivitiesPage = 1;
  bool _planActivitiesHasMore = true;
  bool get hasMorePlanActivities => _planActivitiesHasMore;
  static const int _planActivitiesLimit = 10;

  // Subscription products (Product History tab)
  final RxList<SubscriptionProductItem> subscriptionProducts = <SubscriptionProductItem>[].obs;
  final RxBool isLoadingSubscriptionProducts = false.obs;
  final RxBool subscriptionProductsFetched = false.obs;

  // Subscription products status (Buy Now flow)
  final RxList<Product> subscriptionStatusProducts = <Product>[].obs;
  final RxBool isLoadingSubscriptionStatus = false.obs;
  final RxBool isLoadingMoreSubscriptionStatus = false.obs;
  int _subscriptionStatusPage = 1;
  bool _subscriptionStatusHasMore = true;
  bool get subscriptionStatusHasMore => _subscriptionStatusHasMore;
  static const int _subscriptionStatusLimit = 10;
  // Collected product IDs where isInSubscription == true (for Buy Now flow)
  final RxList<String> subscriptionSelectedProductIds = <String>[].obs;
  final RxBool isUpdatingSubscriptionProducts = false.obs;

  // Postponements
  final RxList<PostponementItem> postponements = <PostponementItem>[].obs;
  final RxBool isLoadingPostponements = false.obs;
  final RxBool isLoadingMorePostponements = false.obs;
  final RxBool postponementsFetched = false.obs;
  int _postponementsPage = 1;
  bool _postponementsHasMore = true;
  bool get hasMorePostponements => _postponementsHasMore;
  static const int _postponementsLimit = 10;

  // Shipping Addresses
  final RxList<Address> addresses = <Address>[].obs;
  final RxBool isLoadingAddresses = false.obs;
  final RxBool addressesFetched = false.obs;
  final Rx<Address?> selectedAddress = Rx<Address?>(null);

  int currentPage = 1;
  final int limit = 10;
  bool hasMore = true;
  Pagination? pagination;

  @override
  void onInit() {
    super.onInit();
    getSubscriptions();
  }

  void getSubscriptions({bool isLoadMore = false}) {
    if (isLoadMore) {
      if (!hasMore || isLoadingMore.value) return;
      isLoadingMore.value = true;
    } else {
      currentPage = 1;
      hasMore = true;
      isLoading.value = true;
      subscriptions.clear();
    }

    _subscriptionRepository.getSubscriptions(
      page: currentPage,
      limit: limit,
      onSuccess: (data) {
        isLoading.value = false;
        isLoadingMore.value = false;
        if (data.data != null) {
          try {
            final subscriptionList = List<SubscriptionData>.from(data.data.map((x) => SubscriptionData.fromJson(x)));

            if (isLoadMore) {
              subscriptions.addAll(subscriptionList);
            } else {
              subscriptions.assignAll(subscriptionList);
            }

            // Update pagination
            pagination = data.pagination;
            if (pagination != null) {
              hasMore = pagination!.hasNext ?? false;
              if (hasMore) {
                currentPage++;
              }
            } else {
              // If no pagination info, assume hasMore based on the number of items received
              hasMore = subscriptionList.length >= limit;
              if (hasMore) {
                currentPage++;
              }
            }
          } catch (e) {
            log('Error parsing subscriptions: $e');
            if (!isLoadMore) {
              subscriptions.clear();
            }
            hasMore = false;
          }
        } else {
          if (!isLoadMore) {
            subscriptions.clear();
          }
          hasMore = false;
        }
      },
      onError: (error) {
        isLoading.value = false;
        isLoadingMore.value = false;
        log('Error loading subscriptions: ${error.message}');
        if (!isLoadMore) {
          subscriptions.clear();
        }
        hasMore = false;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void pausePlan(String subscriptionId) {
    _subscriptionRepository.pauseSubscription(
      subscriptionId: subscriptionId,
      onSuccess: (data) {
        log('Subscription paused successfully');
        final context = Get.context;
        if (context != null) {
          final message = data.message;
          CustomToast.show(
            context: context,
            message: message != null && message.isNotEmpty ? message : 'subscription_paused_success'.tr,
          );
        }
        // Refresh subscriptions list
        getSubscriptions();
      },
      onError: (error) {
        log('Error pausing subscription: ${error.message}');
        final context = Get.context;
        if (context != null) {
          CustomToast.show(
            context: context,
            message: error.message.isNotEmpty ? error.message : 'subscription_pause_failed'.tr,
          );
        }
      },
    );
  }

  void cancelPlan(String subscriptionId) {
    // Dialog will be shown from the view
  }

  final RxBool isCancellingSubscription = false.obs;

  void confirmCancel(String subscriptionId) {
    isCancellingSubscription.value = true;
    _subscriptionRepository.cancelSubscription(
      subscriptionId: subscriptionId,
      onSuccess: (data) {
        isCancellingSubscription.value = false;
        Get.close(2);
        AppFunctions().showToast(
          data.message?.isNotEmpty == true ? data.message! : 'subscription_cancelled_success'.tr,
          bgColor: AppColors.green,
        );
        getSubscriptions();
      },
      onError: (error) {
        isCancellingSubscription.value = false;
        Get.close(2);
        AppFunctions().showToast(
          error.message.isNotEmpty ? error.message : 'subscription_cancel_failed'.tr,
          bgColor: AppColors.red,
        );
      },
    );
  }

  void restartPlan(String subscriptionId) {
    // TODO: Call restart API with subscriptionId if endpoint exists
    getSubscriptions(); // Refresh data
  }

  final RxBool isSubmittingPostponement = false.obs;

  void createPostponement({
    required String orderId,
    required String requestedDeliveryDate,
    required String reason,
    String? subscriptionId,
    void Function()? onSuccess,
  }) {
    isSubmittingPostponement.value = true;
    _subscriptionRepository.createPostponement(
      body: {'orderId': orderId, 'requestedDeliveryDate': requestedDeliveryDate, 'reason': reason},
      onSuccess: (data) {
        isSubmittingPostponement.value = false;
        onSuccess?.call();
        AppFunctions().showToast(
          data.message?.isNotEmpty == true ? data.message! : 'subscription_postponement_success'.tr,
          bgColor: AppColors.green,
        );
        loadPostponements(subscriptionId);
      },
      onError: (AppException error) {
        isSubmittingPostponement.value = false;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void loadSubscriptionProducts(String? subscriptionId) {
    if (subscriptionId == null || subscriptionId.isEmpty) return;
    if (subscriptionProducts.isEmpty) subscriptionProductsFetched.value = false;
    isLoadingSubscriptionProducts.value = true;
    _subscriptionRepository.getSubscriptionProducts(
      subscriptionId: subscriptionId,
      onSuccess: (ApiResponse data) {
        isLoadingSubscriptionProducts.value = false;
        subscriptionProductsFetched.value = true;
        if (data.data != null && data.data is Map<String, dynamic>) {
          try {
            final productsData = SubscriptionProductsData.fromJson(data.data as Map<String, dynamic>);
            subscriptionProducts.assignAll(productsData.items);
          } catch (_) {
            subscriptionProducts.clear();
          }
        } else {
          subscriptionProducts.clear();
        }
      },
      onError: (AppException error) {
        isLoadingSubscriptionProducts.value = false;
        subscriptionProductsFetched.value = true;
        subscriptionProducts.clear();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void loadSubscriptionProductsStatus(String subscriptionId, {bool loadMore = false}) {
    if (subscriptionId.isEmpty) return;
    if (loadMore) {
      if (!_subscriptionStatusHasMore || isLoadingMoreSubscriptionStatus.value) return;
      isLoadingMoreSubscriptionStatus.value = true;
    } else {
      _subscriptionStatusPage = 1;
      _subscriptionStatusHasMore = true;
      if (subscriptionStatusProducts.isEmpty) {
        isLoadingSubscriptionStatus.value = true;
      }
      // Fresh load: clear previous selection
      subscriptionSelectedProductIds.clear();
    }
    _subscriptionRepository.getSubscriptionProductsStatus(
      subscriptionId: subscriptionId,
      page: _subscriptionStatusPage,
      limit: _subscriptionStatusLimit,
      onSuccess: (ApiResponse data) {
        isLoadingSubscriptionStatus.value = false;
        isLoadingMoreSubscriptionStatus.value = false;
        if (data.data != null && data.data is List) {
          try {
            final list = (data.data as List)
                .map((e) => e is Map<String, dynamic> ? Product.fromJson(e) : null)
                .whereType<Product>()
                .toList();
            if (loadMore) {
              subscriptionStatusProducts.addAll(list);
            } else {
              subscriptionStatusProducts.assignAll(list);
            }
            // Update collected IDs based on isInSubscription flag
            final idsFromBatch = list
                .where((p) => (p.isInSubscription ?? false) && (p.id != null && p.id!.isNotEmpty))
                .map((p) => p.id!)
                .toList();
            if (loadMore) {
              for (final id in idsFromBatch) {
                if (!subscriptionSelectedProductIds.contains(id)) {
                  subscriptionSelectedProductIds.add(id);
                }
              }
            } else {
              subscriptionSelectedProductIds
                  .assignAll(idsFromBatch);
            }
            final pagination = data.pagination;
            _subscriptionStatusHasMore = pagination?.hasNext ?? false;
            if (_subscriptionStatusHasMore) _subscriptionStatusPage++;
          } catch (_) {
            if (!loadMore) subscriptionStatusProducts.clear();
            _subscriptionStatusHasMore = false;
          }
        } else {
          if (!loadMore) subscriptionStatusProducts.clear();
          _subscriptionStatusHasMore = false;
        }
      },
      onError: (AppException error) {
        isLoadingSubscriptionStatus.value = false;
        isLoadingMoreSubscriptionStatus.value = false;
        if (!loadMore) subscriptionStatusProducts.clear();
        _subscriptionStatusHasMore = false;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void updateSubscriptionProducts({
    required String subscriptionId,
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) {
    final ids = subscriptionSelectedProductIds.toList();
    if (ids.isEmpty) {
      onError?.call('subscription_add_product_required'.tr);
      return;
    }
    isUpdatingSubscriptionProducts.value = true;
    _subscriptionRepository.updateSubscriptionProducts(
      subscriptionId: subscriptionId,
      productIds: ids,
      onSuccess: (ApiResponse data) {
        isUpdatingSubscriptionProducts.value = false;
        AppFunctions().showToast(
          data.message?.isNotEmpty == true ? data.message! : 'subscription_products_updated'.tr,
          bgColor: AppColors.green,
        );
        onSuccess?.call();
      },
      onError: (AppException error) {
        isUpdatingSubscriptionProducts.value = false;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
        onError?.call(error.message);
      },
    );
  }

  void loadPlanActivities(String? subscriptionId, {bool loadMore = false}) {
    if (subscriptionId == null || subscriptionId.isEmpty) return;
    if (loadMore) return; // API now returns single `data.subscription` object.
    if (planActivities.isEmpty) planActivitiesFetched.value = false;
    _planActivitiesPage = 1;
    _planActivitiesHasMore = false;
    isLoadingPlanActivities.value = true;

    _subscriptionRepository.getSubscriptionActivity(
      subscriptionId: subscriptionId,
      page: _planActivitiesPage,
      limit: _planActivitiesLimit,
      onSuccess: (ApiResponse data) {
        isLoadingPlanActivities.value = false;
        isLoadingMorePlanActivities.value = false;
        planActivitiesFetched.value = true;
        if (data.data != null && data.data is Map<String, dynamic>) {
          try {
            final dataMap = data.data as Map<String, dynamic>;
            final rawSubscription = dataMap['subscription'];
            if (rawSubscription is Map<String, dynamic>) {
              final item = SubscriptionActivityItem.fromJson(rawSubscription);
              planActivities.assignAll([item]);
            } else {
              planActivities.clear();
            }
            _planActivitiesHasMore = false;
          } catch (_) {
            planActivities.clear();
            _planActivitiesHasMore = false;
          }
        } else {
          planActivities.clear();
          _planActivitiesHasMore = false;
        }
      },
      onError: (AppException error) {
        isLoadingPlanActivities.value = false;
        isLoadingMorePlanActivities.value = false;
        planActivitiesFetched.value = true;
        if (!loadMore) planActivities.clear();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void loadTransactions(String? subscriptionId) {
    if (subscriptionId == null || subscriptionId.isEmpty) return;
    // Reset only on first call (list empty); keep existing data visible on re-fetch
    if (transactions.isEmpty) transactionsFetched.value = false;
    isLoadingTransactions.value = true;
    _subscriptionRepository.getUserTransactions(
      subscriptionId: subscriptionId,
      onSuccess: (ApiResponse data) {
        isLoadingTransactions.value = false;
        transactionsFetched.value = true;
        if (data.data != null && data.data is List) {
          try {
            final list = (data.data as List)
                .map((e) => e is Map<String, dynamic> ? TransactionHistoryItem.fromJson(e) : null)
                .whereType<TransactionHistoryItem>()
                .toList();
            transactions.assignAll(list);
          } catch (_) {
            transactions.clear();
          }
        } else {
          transactions.clear();
        }
      },
      onError: (AppException error) {
        isLoadingTransactions.value = false;
        transactionsFetched.value = true;
        transactions.clear();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void loadPostponements(String? subscriptionId, {bool loadMore = false}) {
    if (subscriptionId == null || subscriptionId.isEmpty) return;
    if (loadMore) {
      if (!_postponementsHasMore || isLoadingMorePostponements.value) return;
      isLoadingMorePostponements.value = true;
    } else {
      if (postponements.isEmpty) postponementsFetched.value = false;
      _postponementsPage = 1;
      _postponementsHasMore = true;
      isLoadingPostponements.value = true;
    }
    _subscriptionRepository.getPostponements(
      subscriptionId: subscriptionId,
      page: _postponementsPage,
      limit: _postponementsLimit,
      onSuccess: (ApiResponse data) {
        isLoadingPostponements.value = false;
        isLoadingMorePostponements.value = false;
        postponementsFetched.value = true;
        if (data.data != null && data.data is List) {
          try {
            final list = (data.data as List)
                .map((e) => e is Map<String, dynamic> ? PostponementItem.fromJson(e) : null)
                .whereType<PostponementItem>()
                .toList();
            if (loadMore) {
              postponements.addAll(list);
            } else {
              postponements.assignAll(list);
            }
            final pagination = data.pagination;
            _postponementsHasMore = pagination?.hasNext ?? false;
            if (_postponementsHasMore) _postponementsPage++;
          } catch (_) {
            if (!loadMore) postponements.clear();
            _postponementsHasMore = false;
          }
        } else {
          if (!loadMore) postponements.clear();
          _postponementsHasMore = false;
        }
      },
      onError: (AppException error) {
        isLoadingPostponements.value = false;
        isLoadingMorePostponements.value = false;
        postponementsFetched.value = true;
        if (!loadMore) postponements.clear();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void loadAddresses({String? subscriptionId}) {
    if (addresses.isEmpty) addressesFetched.value = false;
    isLoadingAddresses.value = true;
    _profileRepository.getAddresses(
      queryParams: subscriptionId != null && subscriptionId.isNotEmpty
          ? {'subscriptionId': subscriptionId}
          : null,
      onSuccess: (ApiResponse response) {
        try {
          isLoadingAddresses.value = false;
          addressesFetched.value = true;
          if (response.data != null && response.data['addresses'] != null) {
            final List<dynamic> list = response.data['addresses'];
            addresses.assignAll(list.map((e) => Address.fromJson(e)).toList());
            if (addresses.isNotEmpty && selectedAddress.value == null) {
              selectedAddress.value = addresses.firstWhere(
                (a) => a.isSelectedForSubscription == true,
                orElse: () => addresses.first,
              );
            }
          } else {
            addresses.clear();
          }
        } catch (e) {
          log('Error parsing addresses: $e');
          addresses.clear();
          isLoadingAddresses.value = false;
          addressesFetched.value = true;
        }
      },
      onError: (AppException error) {
        log('Error loading addresses: ${error.message}');
        isLoadingAddresses.value = false;
        addressesFetched.value = true;
        addresses.clear();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void selectAddress(Address address) {
    selectedAddress.value = address;
  }

  final RxBool isChangingShippingAddress = false.obs;

  void changeShippingAddress({
    required String subscriptionId,
    required Address address,
    void Function()? onSuccess,
  }) {
    if (address.id == null || address.id!.isEmpty) return;
    isChangingShippingAddress.value = true;
    _subscriptionRepository.changeShippingAddress(
      subscriptionId: subscriptionId,
      shippingAddressId: address.id!,
      onSuccess: (ApiResponse response) {
        isChangingShippingAddress.value = false;
        selectedAddress.value = address;
        onSuccess?.call();
        AppFunctions().showToast(
          response.message?.isNotEmpty == true
              ? response.message!
              : 'subscription_address_updated'.tr,
          bgColor: AppColors.green,
        );
      },
      onError: (AppException error) {
        isChangingShippingAddress.value = false;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  final RxBool isDeletingAddress = false.obs;

  void deleteAddress(Address address) {
    if (address.id == null || address.id!.isEmpty) {
      AppFunctions().showToast('subscription_address_id_missing'.tr, bgColor: AppColors.red);
      return;
    }
    _showDeleteAddressDialog(address);
  }

  void _showDeleteAddressDialog(Address address) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text('checkout_delete_address'.tr,
                    style: TextStyles.medium(21, fontColor: AppColors.black1414141)),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'checkout_delete_address_confirm'.tr,
                  style: TextStyles.regular(16, fontColor: AppColors.black1414141),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        elevation: 0,
                      ),
                      child: Text('common_cancel'.tr,
                          style: TextStyles.medium(16, fontColor: AppColors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() {
                      return ElevatedButton(
                        onPressed: isDeletingAddress.value
                            ? null
                            : () async => await _performDeleteAddress(address),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black1414141,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                          elevation: 0,
                        ),
                        child: isDeletingAddress.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text('common_yes'.tr,
                                style: TextStyles.medium(16, fontColor: AppColors.white)),
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

  Future<void> _performDeleteAddress(Address address) async {
    if (address.id == null || address.id!.isEmpty) return;
    isDeletingAddress.value = true;
    await _profileRepository.deleteAddressAPI(
      addressId: address.id!,
      onSuccess: (response) {
        isDeletingAddress.value = false;
        Get.back();
        AppFunctions().showToast(
          response.message?.isNotEmpty == true ? response.message! : 'address_deleted_success'.tr,
          bgColor: AppColors.green,
        );
        final index = addresses.indexWhere((a) => a.id == address.id);
        if (index != -1) {
          addresses.removeAt(index);
          if (selectedAddress.value?.id == address.id) {
            selectedAddress.value = addresses.isNotEmpty ? addresses.first : null;
          }
        }
      },
      onError: (error) {
        isDeletingAddress.value = false;
        Get.back();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }
}
