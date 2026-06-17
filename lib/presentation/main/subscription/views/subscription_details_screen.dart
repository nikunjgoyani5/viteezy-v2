import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/models/postponement_model.dart';
import 'package:viteezy/core/models/subscription_model.dart';
import 'package:viteezy/core/models/transaction_history_model.dart';
import 'package:viteezy/core/models/subscription_activity_model.dart';
import 'package:viteezy/core/models/subscription_products_model.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/common_button.dart';
import 'package:viteezy/core/widgets/common_loader.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/presentation/main/addresses/controllers/addresses_controller.dart';
import 'package:viteezy/presentation/main/subscription/controllers/subscription_controller.dart';
import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/gen/assets.gen.dart';

class SubscriptionDetailsScreen extends GetView<SubscriptionController> {
  const SubscriptionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) => _SubscriptionDetailsBody();
}

class _SubscriptionDetailsBody extends StatefulWidget {
  const _SubscriptionDetailsBody();

  @override
  State<_SubscriptionDetailsBody> createState() => _SubscriptionDetailsBodyState();
}

class _SubscriptionDetailsBodyState extends State<_SubscriptionDetailsBody> with SingleTickerProviderStateMixin {
  SubscriptionController get controller => Get.find<SubscriptionController>();

  SubscriptionData? _subscription;
  String? _subscriptionId;

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _subscription = Get.arguments?['subscription'] as SubscriptionData?;
    _subscriptionId = _subscription?.id;
    _tabController = TabController(length: 5, vsync: this);
    _tabController!.addListener(_onTabChanged);
    // Load Plan History (tab 0) when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tabController?.index == 0) {
        controller.loadPlanActivities(_subscriptionId);
      }
    });
  }

  void _onTabChanged() {
    if (_tabController == null || _tabController!.indexIsChanging) return;
    final id = _subscriptionId;
    if (_tabController!.index == 0) {
      controller.loadPlanActivities(id);
    } else if (_tabController!.index == 1) {
      controller.loadSubscriptionProducts(id);
    } else if (_tabController!.index == 2) {
      controller.loadTransactions(id);
    } else if (_tabController!.index == 3) {
      controller.loadPostponements(id);
    } else if (_tabController!.index == 4) {
      controller.loadAddresses(subscriptionId: id);
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }

  void _showCancelDialog(BuildContext context) {
    final subscriptionId = _subscriptionId;
    if (subscriptionId == null || subscriptionId.isEmpty) return;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16.r)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(color: AppColors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.cancel_outlined, size: 28.sp, color: AppColors.red),
              ),
              Gap(16.h),
              Text('subscription_cancel_title'.tr, style: TextStyles.bold(18.sp, fontColor: AppColors.black1414141)),
              Gap(8.h),
              Text(
                'subscription_cancel_full_confirm'.tr,
                textAlign: TextAlign.center,
                style: TextStyles.regular(14.sp, fontColor: AppColors.grey898989),
              ),
              Gap(24.h),
              Obx(() {
                final isCancelling = controller.isCancellingSubscription.value;
                return Row(
                  children: [
                    Expanded(
                      child: CommonButtonWidget(
                        height: 44.h,
                        color: AppColors.grayE3E3DC,
                        borderRadius: 12,
                        onPressed: isCancelling ? () {} : () => Get.back(),
                        child: Center(
                          child: Text('subscription_keep_plan'.tr, style: TextStyles.medium(15.sp, fontColor: AppColors.black1414141)),
                        ),
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: CommonButtonWidget(
                        height: 44.h,
                        color: AppColors.red,
                        borderRadius: 12,
                        onPressed: isCancelling ? () {} : () => controller.confirmCancel(subscriptionId),
                        child: Center(
                          child: isCancelling
                              ? CommonLoader(size: 20, color: Colors.white)
                              : Text('subscription_yes_cancel'.tr, style: TextStyles.medium(15.sp, fontColor: AppColors.white)),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 50.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonAppbar(
              title: 'subscription_details_title'.tr,
              showBackButton: true,
              actionWidget: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 24.sp, color: AppColors.black1414141),
                color: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                onSelected: (value) {
                  if (value == 'cancel') {
                    _showCancelDialog(context);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem<String>(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel_outlined, size: 18.sp, color: AppColors.red),
                        Gap(8.w),
                        Text('subscription_cancel_title'.tr, style: TextStyles.medium(14.sp, fontColor: AppColors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: AppColors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: AppColors.black1414141, width: 2.5),
                  insets: EdgeInsets.zero,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.black1414141,
                unselectedLabelColor: AppColors.grey898989,
                labelStyle: TextStyles.semiBold(14.sp, fontColor: AppColors.black1414141),
                unselectedLabelStyle: TextStyles.regular(14.sp, fontColor: AppColors.grey898989),
                labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
                tabs: [
                  Tab(text: 'subscription_tab_plan_history'.tr),
                  Tab(text: 'subscription_tab_product_history'.tr),
                  Tab(text: 'subscription_tab_transaction_history'.tr),
                  Tab(text: 'subscription_tab_delivery_postponement'.tr),
                  Tab(text: 'subscription_tab_shipping_address'.tr),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PlanHistoryTab(controller: controller, subscriptionId: _subscriptionId),
          _ProductHistoryTab(controller: controller, subscriptionId: _subscriptionId),
          _TransactionHistoryTab(controller: controller),
          _DeliveryPostponementTab(controller: controller, subscription: _subscription),
          _ShippingAddressTab(controller: controller, subscriptionId: _subscriptionId),
        ],
      ),
    );
  }
}

// --- Plan History Tab ---
class _PlanHistoryTab extends StatelessWidget {
  const _PlanHistoryTab({required this.controller, this.subscriptionId});

  final SubscriptionController controller;
  final String? subscriptionId;

  static String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '—';
    try {
      final dt = DateTime.parse(isoDate);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  static Color _statusColor(String? status) {
    if (status == null) return AppColors.grey898989;
    final s = status.toLowerCase();
    if (s == 'active') return AppColors.primaryColor;
    if (s == 'cancelled' || s == 'cancel') return AppColors.red;
    if (s == 'paused') return AppColors.orangeF7A173;
    return AppColors.grey898989;
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: 4,
      separatorBuilder: (_, _) => Gap(12.h),
      itemBuilder: (_, _) => ShimmerWidget(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: AppColors.whiteFBF9F8, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 140.w,
                    height: 14.h,
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  Container(
                    width: 60.w,
                    height: 24.h,
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
                  ),
                ],
              ),
              Gap(12.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70.w,
                          height: 12.h,
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                        Gap(4.h),
                        Container(
                          width: 90.w,
                          height: 14.h,
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80.w,
                          height: 12.h,
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                        Gap(4.h),
                        Container(
                          width: 90.w,
                          height: 14.h,
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap(10.h),
              Container(
                width: 50.w,
                height: 12.h,
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4)),
              ),
              Gap(4.h),
              Container(
                width: double.infinity,
                height: 14.h,
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.icons.icEmptyWhishlist.svg(),
          Gap(12.h),
          Text('subscription_no_plan_history'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.grey898989)),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionActivityItem item) {
    final status = item.status ?? '—';
    final pillColor = _statusColor(item.status);
    final title = item.cycleDays != null ? '${item.cycleDays} Days Subscription' : (item.planType ?? 'Subscription');
    final dateStr = _formatDate(item.subscriptionStartDate);
    final nextDeliveryStr = _formatDate(item.nextDeliveryDate);
    final orderNumber = item.order?.orderNumber ?? '—';
    final priceStr = item.planPriceTotal != null && item.planCurrency != null
        ? '${item.planCurrency} ${item.planPriceTotal!.toStringAsFixed(2)}'
        : '—';
    final reason = item.cancellationReason?.isNotEmpty == true ? item.cancellationReason! : '—';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.yellowF0EFE4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: TextStyles.semiBold(16.sp, fontColor: AppColors.black1414141)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: pillColor, borderRadius: BorderRadius.circular(20)),
                child: Text(status, style: TextStyles.medium(12.sp, fontColor: AppColors.white)),
              ),
            ],
          ),
          Gap(12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('subscription_start_date'.tr, style: TextStyles.regular(12.sp, fontColor: AppColors.grey898989)),
                    Gap(2.h),
                    Text(dateStr, style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('subscription_next_delivery'.tr, style: TextStyles.regular(12.sp, fontColor: AppColors.grey898989)),
                    Gap(2.h),
                    Text(nextDeliveryStr, style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141)),
                  ],
                ),
              ),
            ],
          ),
          // Gap(10.h),
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Expanded(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text('subscription_next_delivery'.tr, style: TextStyles.regular(12.sp, fontColor: AppColors.grey898989)),
          //           Gap(2.h),
          //           Text(nextDeliveryStr, style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141)),
          //         ],
          //       ),
          //     ),
          //     Expanded(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text('Order Number', style: TextStyles.regular(12.sp, fontColor: AppColors.grey898989)),
          //           Gap(2.h),
          //           Text(orderNumber, style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141)),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          Gap(10.h),
          Text('subscription_reason'.tr, style: TextStyles.regular(12.sp, fontColor: AppColors.grey898989)),
          Gap(2.h),
          Text(reason, style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fetched = controller.planActivitiesFetched.value;
      final list = controller.planActivities;
      if (!fetched) {
        return _buildShimmer();
      }
      if (list.isEmpty) {
        return _buildEmptyState();
      }
      return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: list.length,
        separatorBuilder: (_, __) => Gap(12.h),
        itemBuilder: (context, index) {
          return _buildPlanCard(list[index]);
        },
      );
    });
  }
}

// --- Product History Tab ---
class _ProductHistoryTab extends StatelessWidget {
  const _ProductHistoryTab({required this.controller, this.subscriptionId});

  final SubscriptionController controller;
  final String? subscriptionId;

  void _showChooseHowToBuyDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: _ChooseHowToBuyDialog(subscriptionId: subscriptionId),
      ),
      barrierDismissible: true,
    );
  }

  static   final String _disclaimer =
      'subscription_product_change_notice'.tr;

  Widget _buildShimmer() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12.r)),
            child: ShimmerWidget(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 100.w,
                        height: 16.h,
                        decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
                      ),
                      Container(
                        width: 90.w,
                        height: 32.h,
                        decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(20)),
                      ),
                    ],
                  ),
                  Gap(16.h),
                  ...List.generate(
                    3,
                    (_) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Row(
                        children: [
                          Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          Gap(12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 120.w,
                                  height: 14.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.grayE3E3DC,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Gap(4.h),
                                Container(
                                  width: 80.w,
                                  height: 12.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.grayE3E3DC,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 50.w,
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 10.h,
                    decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.icons.icEmptyWhishlist.svg(),
          Gap(12.h),
          Text('subscription_no_products'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.grey898989)),
        ],
      ),
    );
  }

  Widget _buildProductRow(SubscriptionProductItem item) {
    final name = item.name ?? item.product?.title ?? '—';
    final capsuleCount = item.capsuleCount ?? 0;
    final description = '$capsuleCount capsules';
    final currency = item.product?.price?.currency ?? 'EUR';
    final amount = item.totalAmount ?? item.discountedPrice ?? item.amount ?? 0.0;
    final priceStr = '$currency ${amount.toStringAsFixed(2)}';
    final imageUrl = item.product?.productImage;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(8.r)),
          clipBehavior: Clip.antiAlias,
          child: imageUrl != null && imageUrl.isNotEmpty
              ? CommonNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover, width: 56.w, height: 56.w)
              : Assets.images.imgPlaceholder.image(fit: BoxFit.cover),
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: TextStyles.semiBold(14.sp, fontColor: AppColors.black1414141)),
              Gap(2.h),
              Text(description, style: TextStyles.medium(12.sp, fontColor: AppColors.grey898989)),
            ],
          ),
        ),
        Text(priceStr, style: TextStyles.bold(14.sp, fontColor: AppColors.black1414141)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.subscriptionProductsFetched.value) {
        return _buildShimmer();
      }
      final list = controller.subscriptionProducts;
      if (list.isEmpty) {
        return _buildEmptyState();
      }
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.all(Radius.circular(12.r)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('subscription_change_product'.tr, style: TextStyles.semiBold(16.sp, fontColor: AppColors.black1414141)),
                        GestureDetector(
                          onTap: () => _showChooseHowToBuyDialog(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: AppColors.black1414141,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text('subscription_change_order'.tr, style: TextStyles.medium(14.sp, fontColor: AppColors.white)),
                          ),
                        ),
                      ],
                    ),
                    Gap(16.h),
                    ...List.generate(list.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: index < list.length - 1 ? 16.h : 0),
                        child: _buildProductRow(list[index]),
                      );
                    }),
                    Gap(16.h),
                    Text(_disclaimer, style: TextStyles.medium(10.sp, fontColor: AppColors.grey898989)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// --- Choose How You Want to Buy (dialog) ---
class _ChooseHowToBuyDialog extends StatelessWidget {
  const _ChooseHowToBuyDialog({this.subscriptionId});

  final String? subscriptionId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20.r)),
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'subscription_choose_buy_method'.tr,
            textAlign: TextAlign.center,
            style: TextStyles.semiBold(18.sp, fontColor: AppColors.black1414141),
          ),
          Gap(8.h),
          Text(
            'subscription_choose_buy_subtitle'.tr,
            textAlign: TextAlign.center,
            style: TextStyles.regular(14.sp, fontColor: AppColors.grey898989),
          ),
          Gap(24.h),
          // Take Quiz & Get Best Product
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.greyF0EFE9,
                borderRadius: BorderRadius.circular(12.r),
                // border: Border.all(color: AppColors.grayE3E3DC),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: Icon(Icons.chat_bubble_outline, color: AppColors.black1414141),
                    // child: Assets.icons.icChat.image(fit: BoxFit.contain, color: AppColors.black1414141),
                  ),
                  Gap(6.w),
                  Text(
                    'subscription_take_quiz_product'.tr,
                    style: TextStyles.semiBold(14.sp, fontColor: AppColors.black1414141),
                  ),
                ],
              ),
            ),
          ),
          Gap(12.h),
          // Buy Now
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              if (subscriptionId != null && subscriptionId!.isNotEmpty) {
                Get.toNamed(AppRoutes.subscriptionProducts, arguments: {'subscriptionId': subscriptionId});
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(color: AppColors.black1414141, borderRadius: BorderRadius.circular(12.r)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: Assets.icons.icCart.svg(
                      width: 20.w,
                      height: 20.w,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                  Gap(12.w),
                  Text('product_detail_buy_now'.tr, style: TextStyles.semiBold(15.sp, fontColor: AppColors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Transaction History Tab ---
class _TransactionHistoryTab extends StatelessWidget {
  const _TransactionHistoryTab({required this.controller});

  final SubscriptionController controller;

  static String _formatTransactionDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '—';
    try {
      final dt = DateTime.parse(isoDate);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  static Color _statusColor(String? status) {
    if (status == null) return AppColors.grey898989;
    final s = status.toLowerCase();
    if (s == 'completed' || s == 'paid') return AppColors.green;
    if (s == 'failed') return AppColors.red;
    return AppColors.orangeF7A173;
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: 4,
      separatorBuilder: (_, __) => Gap(12.h),
      itemBuilder: (_, __) => ShimmerWidget(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: AppColors.whiteFBF9F8, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // date | amount row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100.w,
                    height: 14.h,
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  Container(
                    width: 60.w,
                    height: 14.h,
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
              Gap(10.h),
              // "Transaction ID" label
              Container(
                width: 90.w,
                height: 12.h,
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4)),
              ),
              Gap(6.h),
              // Transaction ID value + status pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 160.w,
                    height: 14.h,
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  Container(
                    width: 60.w,
                    height: 24.h,
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show shimmer until the first fetch finishes
      if (!controller.transactionsFetched.value) {
        return _buildShimmer();
      }
      final list = controller.transactions;
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.icons.icEmptyWhishlist.svg(),
              Gap(12.h),
              Text('subscription_no_transactions'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.grey898989)),
            ],
          ),
        );
      }
      return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: list.length,
        separatorBuilder: (_, __) => Gap(12.h),
        itemBuilder: (context, index) => _buildTransactionCard(list[index]),
      );
    });
  }

  Widget _buildTransactionCard(TransactionHistoryItem item) {
    final dateStr = _formatTransactionDate(item.processedAt ?? item.createdAt);
    final currency = item.currency ?? 'EUR';
    final amountStr = '$currency${(item.amount ?? 0).toStringAsFixed(2)}';
    final status = item.status ?? '—';
    final statusColor = _statusColor(item.status);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteFBF9F8,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr, style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141)),
              Text(amountStr, style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141)),
            ],
          ),
          Gap(8.h),
          Text('member_transaction_id'.tr, style: TextStyles.regular(12.sp, fontColor: AppColors.grey898989)),
          Gap(2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.transactionId ?? '—',
                  style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141),
                ),
              ),
              SizedBox(width: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                child: Text(status, style: TextStyles.medium(12.sp, fontColor: AppColors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Delivery Postponement Tab ---
class _DeliveryPostponementTab extends StatelessWidget {
  const _DeliveryPostponementTab({required this.controller, this.subscription});

  final SubscriptionController controller;
  final SubscriptionData? subscription;

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  void _showAddPostponementSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.offWhite,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _AddPostponementBottomSheet(subscription: subscription),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: 3,
      separatorBuilder: (_, __) => Gap(12.h),
      itemBuilder: (_, __) => ShimmerWidget(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 160.w,
                    height: 14.h,
                    decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
                  ),
                  Container(
                    width: 64.w,
                    height: 22.h,
                    decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(20)),
                  ),
                ],
              ),
              Gap(12.h),
              Container(
                width: 120.w,
                height: 12.h,
                decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
              ),
              Gap(4.h),
              Container(
                width: 100.w,
                height: 14.h,
                decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
              ),
              Gap(10.h),
              Container(
                width: 60.w,
                height: 12.h,
                decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
              ),
              Gap(4.h),
              Container(
                width: double.infinity,
                height: 14.h,
                decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.icons.icEmptyWhishlist.svg(),
          Gap(12.h),
          Text('subscription_no_postponements'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.black1414141)),
          Gap(6.h),
          Text(
            'subscription_postponement_empty'.tr,
            textAlign: TextAlign.center,
            style: TextStyles.regular(13.sp, fontColor: AppColors.grey898989),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(PostponementItem item) {
    final status = item.status;
    Color? statusColor;
    if (status?.toLowerCase() == 'approved') statusColor = AppColors.primaryColor;
    if (status?.toLowerCase() == 'pending') statusColor = AppColors.orangeF7A173;
    if (status?.toLowerCase() == 'rejected') statusColor = AppColors.red;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.yellowF0EFE4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Request #${item.id?.substring(item.id!.length > 8 ? item.id!.length - 8 : 0).toUpperCase() ?? '—'}',
                  style: TextStyles.semiBold(15.sp, fontColor: AppColors.black1414141),
                ),
              ),
              if (status != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor ?? AppColors.grey898989,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status, style: TextStyles.medium(12.sp, fontColor: AppColors.white)),
                ),
            ],
          ),
          Gap(10.h),
          Text('subscription_new_delivery_date'.tr, style: TextStyles.regular(12.sp, fontColor: AppColors.grey898989)),
          Gap(2.h),
          Text(
            _formatDate(item.requestedDeliveryDate),
            style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141),
          ),
          Gap(8.h),
          Text('subscription_reason'.tr, style: TextStyles.regular(12.sp, fontColor: AppColors.grey898989)),
          Gap(2.h),
          Text(
            item.reason?.isNotEmpty == true ? item.reason! : '—',
            style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fetched = controller.postponementsFetched.value;
      final list = controller.postponements;
      final isLoadingMore = controller.isLoadingMorePostponements.value;

      return Column(
        children: [
          // Header row always visible
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('subscription_delivery_postponements'.tr, style: TextStyles.semiBold(16.sp, fontColor: AppColors.black1414141)),
                GestureDetector(
                  onTap: () => _showAddPostponementSheet(context),
                  child: Text('subscription_add_postponement'.tr, style: TextStyles.medium(14.sp, fontColor: AppColors.primaryColor)),
                ),
              ],
            ),
          ),
          Gap(12.h),
          Expanded(
            child: !fetched
                ? _buildShimmer()
                : list.isEmpty
                ? _buildEmptyState()
                : NotificationListener<ScrollNotification>(
                    onNotification: (scroll) {
                      if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 80 &&
                          !isLoadingMore &&
                          controller.hasMorePostponements) {
                        controller.loadPostponements(subscription?.id, loadMore: true);
                      }
                      return false;
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                      itemCount: list.length + (isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => Gap(12.h),
                      itemBuilder: (_, index) {
                        if (index == list.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        }
                        return _buildCard(list[index]);
                      },
                    ),
                  ),
          ),
        ],
      );
    });
  }
}

class _AddPostponementBottomSheet extends StatefulWidget {
  const _AddPostponementBottomSheet({this.subscription});
  final SubscriptionData? subscription;

  @override
  State<_AddPostponementBottomSheet> createState() => _AddPostponementBottomSheetState();
}

class _AddPostponementBottomSheetState extends State<_AddPostponementBottomSheet> {
  final _reasonController = TextEditingController();
  static const int _reasonMaxLength = 1000;

  DateTime? _selectedDate;
  String? _dateError;
  String? _reasonError;

  SubscriptionController get _controller => Get.find<SubscriptionController>();

  String _formatDisplayDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
  }

  String _formatApiDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _currentDeliveryDate() {
    final dt = widget.subscription?.initialDeliveryDate;
    if (dt == null) return '—';
    return _formatDisplayDate(dt);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primaryColor)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateError = null;
      });
    }
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _dateError = _selectedDate == null ? 'subscription_select_delivery_date'.tr : null;
      _reasonError = _reasonController.text.trim().isEmpty ? 'subscription_postponement_reason_required'.tr : null;
    });
    if (_dateError != null || _reasonError != null) valid = false;
    return valid;
  }

  void _submit() {
    if (!_validate()) return;
    final orderId = widget.subscription?.orderId?.id ?? '';
    if (orderId.isEmpty) {
      AppFunctions().showToast('subscription_order_id_missing'.tr, bgColor: AppColors.red);
      return;
    }
    final nav = Navigator.of(context);
    _controller.createPostponement(
      orderId: orderId,
      requestedDeliveryDate: _formatApiDate(_selectedDate!),
      reason: _reasonController.text.trim(),
      subscriptionId: widget.subscription?.id,
      onSuccess: () => nav.pop(),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSubmitting = _controller.isSubmittingPostponement.value;
      return Container(
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(color: AppColors.greyDFDFDF, borderRadius: BorderRadius.circular(2)),
                ),
                Gap(16.h),
                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 40.w),
                    Text('subscription_postponement_title'.tr, style: TextStyles.semiBold(20.sp, fontColor: AppColors.black1414141)),
                    IconButton(
                      onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, size: 24.sp, color: AppColors.black1414141),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                Gap(16.h),
                // Current Delivery Date (read-only)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'subscription_current_delivery_date'.tr,
                    style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141),
                  ),
                ),
                Gap(6.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.yellowF0EFE4),
                    color: AppColors.greyF0EFE9,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _currentDeliveryDate(),
                    style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
                  ),
                ),
                Gap(14.h),
                // New Delivery Date (date picker)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('subscription_new_delivery_date'.tr, style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141)),
                ),
                Gap(6.h),
                GestureDetector(
                  onTap: isSubmitting ? null : _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: _dateError != null ? AppColors.red : AppColors.yellowF0EFE4),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate != null ? _formatDisplayDate(_selectedDate!) : 'dd-mm-yyyy',
                          style: TextStyles.regular(
                            14.sp,
                            fontColor: _selectedDate != null ? AppColors.black1414141 : AppColors.grey898989,
                          ),
                        ),
                        Icon(Icons.calendar_today_outlined, size: 20.sp, color: AppColors.grey898989),
                      ],
                    ),
                  ),
                ),
                if (_dateError != null) ...[
                  Gap(4.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_dateError!, style: TextStyles.regular(12.sp, fontColor: AppColors.red)),
                  ),
                ],
                Gap(14.h),
                // Reason
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'subscription_reason_for_postponement'.tr,
                    style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141),
                  ),
                ),
                Gap(6.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: _reasonError != null ? AppColors.red : AppColors.yellowF0EFE4),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
                        controller: _reasonController,
                        maxLines: 4,
                        maxLength: _reasonMaxLength,
                        enabled: !isSubmitting,
                        decoration: InputDecoration(
                          hintText: 'subscription_postponement_reason_hint'.tr,
                          hintStyle: TextStyles.regular(14.sp, fontColor: AppColors.grey898989),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          counterText: '',
                        ),
                        style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
                        onChanged: (_) => setState(() {
                          _reasonError = null;
                        }),
                      ),
                      Text(
                        '${_reasonController.text.length}/$_reasonMaxLength',
                        style: TextStyles.regular(12.sp, fontColor: AppColors.grey898989),
                      ),
                    ],
                  ),
                ),
                if (_reasonError != null) ...[
                  Gap(4.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_reasonError!, style: TextStyles.regular(12.sp, fontColor: AppColors.red)),
                  ),
                ],
                Gap(20.h),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: CommonButtonWidget(
                    height: 48.h,
                    color: isSubmitting ? AppColors.grey898989 : AppColors.primaryColor,
                    borderRadius: 12,
                    onPressed: isSubmitting ? () {} : _submit,
                    child: Center(
                      child: isSubmitting
                          ? SizedBox(
                              height: 22.h,
                              width: 22.h,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white),
                            )
                          : Text('subscription_submit_request'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// --- Shipping Address Tab ---
class _ShippingAddressTab extends StatelessWidget {
  const _ShippingAddressTab({required this.controller, this.subscriptionId});

  final SubscriptionController controller;
  final String? subscriptionId;

  static String _buildFullAddress(Address address) {
    final streetName = address.streetName ?? '';
    final houseNumber = address.houseNumber ?? '';
    final houseNumberAddition = address.houseNumberAddition ?? '';
    final addressLine = '$streetName $houseNumber $houseNumberAddition'.trim();
    if (addressLine.isNotEmpty) {
      return '$addressLine, ${address.postalCode ?? ''} ${address.city ?? ''}, ${address.country ?? ''}'.trim();
    } else if (address.address != null && address.address!.isNotEmpty) {
      return '${address.address}, ${address.postalCode ?? ''} ${address.city ?? ''}, ${address.country ?? ''}'.trim();
    } else {
      return '${address.postalCode ?? ''} ${address.city ?? ''}, ${address.country ?? ''}'.trim();
    }
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      itemCount: 3,
      separatorBuilder: (_, __) => Gap(12.h),
      itemBuilder: (_, __) => ShimmerWidget(
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 120.w,
                    height: 18.h,
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4.r)),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                      ),
                      Gap(12.w),
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                      ),
                    ],
                  ),
                ],
              ),
              Gap(12.h),
              Container(
                width: double.infinity,
                height: 14.h,
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4.r)),
              ),
              Gap(4.h),
              Container(
                width: 150.w,
                height: 14.h,
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4.r)),
              ),
              Gap(12.h),
              Container(
                width: 100.w,
                height: 14.h,
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4.r)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, size: 64.sp, color: AppColors.gray949391),
            Gap(16.h),
            Text('checkout_no_addresses_found'.tr, style: TextStyles.medium(18.sp, fontColor: AppColors.gray686767)),
            Gap(8.h),
            Text('checkout_add_new_address'.tr, style: TextStyles.regular(14.sp, fontColor: AppColors.gray949391)),
          ],
        ),
      ),
    );
  }

  void _showChangeAddressDialog(BuildContext context, Address address) {
    final sid = subscriptionId;
    if (sid == null || sid.isEmpty) return;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'subscription_address_change_confirm'.tr,
                textAlign: TextAlign.center,
                style: TextStyles.medium(16.sp, fontColor: AppColors.black1414141),
              ),
              Gap(8.h),
              Text(
                'subscription_address_change_note'.tr,
                textAlign: TextAlign.center,
                style: TextStyles.regular(14.sp, fontColor: AppColors.grey898989),
              ),
              Gap(20.h),
              Row(
                children: [
                  Expanded(
                    child: CommonButtonWidget(
                      height: 44.h,
                      color: AppColors.black1414141,
                      borderRadius: 30,
                      onPressed: () => Get.back(),
                      child: Center(
                        child: Text('common_cancel'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.white)),
                      ),
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Obx(() {
                      final isLoading = controller.isChangingShippingAddress.value;
                      return CommonButtonWidget(
                        height: 44.h,
                        color: AppColors.primaryColor,
                        borderRadius: 30,
                        onPressed: isLoading
                            ? () {}
                            : () => controller.changeShippingAddress(
                                subscriptionId: sid,
                                address: address,
                                onSuccess: () => Get.back(),
                              ),
                        child: Center(
                          child: isLoading
                              ? CommonLoader(size: 20, color: Colors.white)
                              : Text('subscription_confirm'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.white)),
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

  Widget _buildAddressCard(BuildContext context, Address address, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        _showChangeAddressDialog(context, address);
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: isSelected ? AppColors.black1414141 : AppColors.grayE3E3DC, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '${address.firstName ?? ''} ${address.lastName ?? ''}'.trim().isNotEmpty
                                  ? '${address.firstName ?? ''} ${address.lastName ?? ''}'.trim()
                                  : 'Address',
                              style: TextStyles.bold(16.sp, fontColor: AppColors.black1414141),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Gap(4.w),
                          Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.black1414141),
                          ),
                          Gap(4.w),
                          Icon(Icons.home, size: 16.sp, color: AppColors.gray949391),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          child: Assets.icons.icEdit.svg(),
                          onTap: () => Get.toNamed(
                            AppRoutes.addAddress,
                            arguments: {'isEdit': true, 'addressId': address.id ?? ''},
                          ),
                        ),
                        Gap(12.w),
                        GestureDetector(
                          child: Assets.icons.icDelete.svg(),
                          onTap: () => controller.deleteAddress(address),
                        ),
                      ],
                    ),
                  ],
                ),
                Gap(8.h),
                Text(_buildFullAddress(address), style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141)),
                Gap(2.h),
                Text(
                  '${address.postalCode ?? ''} ${address.city ?? ''}'.trim(),
                  style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
                ),
                Gap(12.h),
                Text(address.phone ?? '', style: TextStyles.medium(12.sp, fontColor: AppColors.black1414141)),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 1,
              left: 1,
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), bottomRight: Radius.circular(4.r)),
                ),
                child: Icon(Icons.check, size: 15.sp, color: AppColors.surfaceColor),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fetched = controller.addressesFetched.value;
      final list = controller.addresses;
      final selectedId = controller.selectedAddress.value?.id;

      return Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('checkout_shipping_address'.tr, style: TextStyles.bold(18.sp, fontColor: AppColors.black1414141)),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.addAddress, arguments: {'isEdit': false}),
                  child: Text('subscription_new_address'.tr, style: TextStyles.medium(14.sp, fontColor: AppColors.primaryColor)),
                ),
              ],
            ),
          ),
          Gap(12.h),
          Expanded(
            child: !fetched
                ? _buildShimmer()
                : list.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => Gap(12.h),
                    itemBuilder: (_, index) {
                      final address = list[index];
                      final isSelected = selectedId == address.id;
                      return _buildAddressCard(context, address, isSelected);
                    },
                  ),
          ),
        ],
      );
    });
  }
}
