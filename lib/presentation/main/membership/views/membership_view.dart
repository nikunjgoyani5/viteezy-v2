import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:sliding_up_panel_custom/sliding_up_panel_custom.dart';
import 'package:viteezy/core/models/product_response_model.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/utils/dialog_service.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/core/widgets/custom_toast.dart';
import 'package:viteezy/gen/assets.gen.dart';
import '../controller/membership_controller.dart';
import 'payment_webview.dart';

class MembershipView extends StatefulWidget {
  const MembershipView({super.key, this.product});

  final Product? product;

  @override
  State<MembershipView> createState() => _MembershipViewState();
}

class _MembershipViewState extends State<MembershipView> {
  late PanelController _panelController;
  late MembershipController controller;

  @override
  void initState() {
    super.initState();
    _panelController = PanelController();

    // Initialize controller
    if (!Get.isRegistered<MembershipController>()) {
      controller = Get.put(MembershipController());
    } else {
      controller = Get.find<MembershipController>();
    }

    // Call API to get membership plans
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.getMembershipsPlans();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light, statusBarBrightness: Brightness.dark),
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      body: SlidingUpPanel(
        controller: _panelController,
        panel: _buildPanelContent(),
        body: _buildBodyContent(),
        options: SlidingUpPanelOptions(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
          initialMaxHeight: Get.height * 0.8,
          initialMinHeight: Get.height * 0.72,
          isDraggable: true,
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (widget.product != null) {
      return Stack(
        children: [
          // Product Image
          CommonNetworkImage(
            imageUrl: widget.product?.productImage ?? "",
            height: Get.height * 0.4,
            width: Get.width,
            fit: BoxFit.cover,
          ),
          // Overlay with gradient
          Container(width: Get.width, height: Get.height * 0.4, color: Color(0xFF00373B).withValues(alpha: 0.5)),
          // Content overlay
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            width: Get.width,
            height: Get.height * 0.4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 50.h),
                      width: 35.w,
                      height: 35.w,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Image.asset(Assets.icons.icBackArrow.path, scale: 3),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                // Product details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product?.title ?? "",
                      textAlign: TextAlign.start,
                      style: TextStyles.semiBold(28.sp, fontColor: Colors.white.withValues(alpha: 0.9)),
                    ),
                    Gap(4.h),
                    Text(
                      widget.product?.shortDescription ?? '',
                      textAlign: TextAlign.start,
                      style: TextStyles.regular(14.sp, fontColor: Colors.white.withValues(alpha: 0.9)),
                    ),
                    Gap(8.h),
                    Row(
                      children: [
                        Text(
                          '${widget.product?.sachetPrices?.thirtyDays?.currency} ${widget.product?.sachetPrices?.thirtyDays?.totalAmount}',
                          style: TextStyles.semiBold(24.sp, fontColor: AppColors.primaryColor),
                        ),
                        Gap(4.w),
                        Text(
                          '${widget.product?.sachetPrices?.thirtyDays?.currency} ${widget.product?.sachetPrices?.thirtyDays?.amount}',
                          style: TextStyles.regular(
                            18.sp,
                            fontColor: AppColors.white,
                            textDecoration: TextDecoration.lineThrough,
                          ).copyWith(decorationColor: AppColors.white, decorationThickness: 1),
                        ),
                        Gap(5.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.black1414141,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(50),
                              bottomRight: Radius.circular(50),
                            ),
                          ),
                          child: Text(
                            'Save ${widget.product?.sachetPrices?.thirtyDays?.savingsPercentage}%',
                            style: TextStyles.medium(10.sp, fontColor: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(),
                SizedBox(),
              ],
            ),
          ),
        ],
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            transform: GradientRotation(-0.2),
            colors: [
              const Color(0xFF0A5B62),
              const Color(0xFF00373B),
              const Color(0xFF00373B),
              const Color(0xFF00373B),
              const Color(0xFF00373B),
              const Color(0xFF00373B),
              const Color(0xFF00373B),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 35.h),
              child: Row(
                children: [
                  Container(
                    // margin: EdgeInsets.only(top: 50.h),
                    width: 35.w,
                    height: 35.w,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Image.asset(Assets.icons.icBackArrow.path, scale: 3),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30.h),
                  Assets.icons.icAppName.image(color: AppColors.primaryColor, scale: 2.5),
                  // Gap(12.h),
                  // Text(
                  //   'Your Gold membership will\nstart on 04th November 2023',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyles.medium(16.sp, fontColor: Colors.white.withValues(alpha: 0.9)),
                  // ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPanelContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Panel handle
          // Container(
          //   margin: EdgeInsets.only(top: 12.h),
          //   width: 40.w,
          //   height: 4.h,
          //   decoration: BoxDecoration(
          //     color: AppColors.grey888888.withValues(alpha: 0.3),
          //     borderRadius: BorderRadius.circular(2.r),
          //   ),
          // ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'membership_your_benefits'.tr,
                      style: TextStyles.semiBold(14.sp, fontColor: const Color(0xFF00373B)).copyWith(letterSpacing: 5),
                    ),
                  ),
                  Gap(20.h),
                  _benefitTile(
                    icon: Assets.icons.icFreeShipping.path,
                    title: 'membership_free_shipping'.tr,
                    subtitle: 'membership_free_shipping_sub'.tr,
                  ),
                  Gap(16.h),
                  _benefitTile(
                    icon: Assets.icons.icDiscount.path,
                    title: 'membership_exclusive_discounts'.tr,
                    subtitle: 'membership_exclusive_discounts_sub'.tr,
                  ),
                  Gap(16.h),
                  _benefitTile(
                    icon: Assets.icons.icFreeDelivery.path,
                    title: 'membership_fast_delivery'.tr,
                    subtitle: 'membership_fast_delivery_sub'.tr,
                  ),
                  Gap(24.h),
                  // Plans List
                  Obx(() {
                    // Show shimmer only on initial load when plans are empty
                    if (controller.isLoading.value && controller.plans.isEmpty) {
                      return Column(
                        children: [
                          _buildPlanShimmer(isHighlight: true),
                          Gap(12.h),
                          _buildPlanShimmer(isHighlight: false),
                        ],
                      );
                    }

                    if (controller.plans.isEmpty && !controller.isLoading.value) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Text(
                            'membership_no_plans'.tr,
                            style: TextStyles.regular(14.sp, fontColor: AppColors.grey888888),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: controller.plans.asMap().entries.map((entry) {
                        final index = entry.key;
                        final plan = entry.value;
                        final isSelected = plan.id != null && plan.id == controller.selectedPlanId.value;
                        final isAnnual = controller.isAnnualPlan(plan);

                        // Format price
                        final currency = plan.price?.currency ?? '\$';
                        final amount = plan.price?.amount ?? 0;
                        final monthlyPrice = amount / (plan.durationDays ?? 30) * 30; // Calculate monthly price
                        final totalPrice = amount;

                        String priceText = '$currency ${monthlyPrice.toStringAsFixed(2)} / Monthly';
                        String? subPriceText;
                        if (plan.durationDays != null && plan.durationDays! > 30) {
                          subPriceText = '$currency ${totalPrice.toStringAsFixed(2)} / ${plan.durationDays} Days';
                        }

                        // Calculate savings percentage only for Annual plan
                        String? badgeText;
                        if (isAnnual && controller.plans.length > 1) {
                          // Find monthly plan to compare
                          try {
                            final monthlyPlan = controller.plans.firstWhere((p) => !controller.isAnnualPlan(p));
                            if (monthlyPlan.price?.amount != null) {
                              final monthlyAmount = monthlyPlan.price!.amount!;
                              final annualAmount = amount;
                              final monthlyTotalForYear = monthlyAmount * 12.0;
                              if (monthlyTotalForYear > annualAmount) {
                                final savings = ((monthlyTotalForYear - annualAmount) / monthlyTotalForYear) * 100;
                                if (savings > 0) {
                                  badgeText = 'SAVE ${savings.toStringAsFixed(0)}%';
                                }
                              }
                            }
                          } catch (e) {
                            // No monthly plan found, skip savings calculation
                          }
                        }

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (plan.id != null) {
                                  controller.selectPlan(plan.id!);
                                }
                              },
                              child: _planCard(
                                title: plan.name ?? 'common_plan'.tr,
                                price: priceText,
                                subPrice: subPriceText,
                                isHighlight: isSelected,
                                badgeText: badgeText,
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [const Color(0xFF22A19B), const Color(0xFFB88B65)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      )
                                    : null,
                              ),
                            ),
                            if (index < controller.plans.length - 1) Gap(12.h),
                          ],
                        );
                      }).toList(),
                    );
                  }),
                  Gap(16.h),
                  Center(
                    child: Text(
                      'membership_auto_renew'.tr,
                      style: TextStyles.medium(12.sp, fontColor: AppColors.grey888888),
                    ),
                  ),
                  Gap(16.h),
                  Obx(() {
                    final selectedPlanId = controller.selectedPlanId.value;
                    return ElevatedButton(
                      onPressed: selectedPlanId.isEmpty
                          ? null
                          : () {
                              final isLoggedIn =
                                  PrefService.getBool(PrefKeys.isLogin) &&
                                  PrefService.getString(PrefKeys.accessToken).isNotEmpty;
                              if (!isLoggedIn) {
                                DialogService.showLoginRequiredDialog(
                                  message: 'membership_login_required'.tr,
                                  onLogin: () {
                                    Get.toNamed(AppRoutes.login);
                                  },
                                );
                                return;
                              }
                              _showPaymentMethodDialog(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedPlanId.isEmpty ? AppColors.grey888888 : AppColors.black1414141,
                        foregroundColor: AppColors.surfaceColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: StadiumBorder(),
                        elevation: 0,
                        minimumSize: Size(double.infinity, 50.h),
                        disabledBackgroundColor: AppColors.grey888888,
                      ),
                      child: Text('membership_continue'.tr, style: TextStyles.semiBold(16.sp, fontColor: Colors.white)),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitTile({required String icon, required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(icon, width: 30.w, height: 30.w),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyles.bold(16.sp, fontColor: AppColors.black1414141)),
              Gap(2.h),
              Text(subtitle, style: TextStyles.regular(13.sp, fontColor: AppColors.grey888888)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _planCard({
    required String title,
    required String price,
    String? subPrice,
    required bool isHighlight,
    LinearGradient? gradient,
    String? badgeText,
  }) {
    final baseColor = isHighlight ? Colors.white : AppColors.offWhite;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          decoration: BoxDecoration(color: baseColor, gradient: gradient, borderRadius: BorderRadius.circular(12.r)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyles.bold(18.sp, fontColor: isHighlight ? Colors.white : AppColors.black1414141),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyles.bold(16.sp, fontColor: isHighlight ? Colors.white : AppColors.black1414141),
                  ),
                  if (subPrice != null)
                    Text(
                      subPrice,
                      style: TextStyles.regular(
                        12.sp,
                        fontColor: (isHighlight ? Colors.white : AppColors.black1414141).withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (badgeText != null)
          Positioned(
            right: 12.w,
            top: -12.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8.r)),
              child: Text(badgeText, style: TextStyles.regular(11.sp, fontColor: Colors.white)),
            ),
          ),
      ],
    );
  }

  Widget _buildPlanShimmer({required bool isHighlight}) {
    return ShimmerWidget(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isHighlight ? Colors.white : AppColors.offWhite,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 18.h,
              width: 100.w,
              decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4.r)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 16.h,
                  width: 120.w,
                  decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4.r)),
                ),
                Gap(4.h),
                Container(
                  height: 12.h,
                  width: 100.w,
                  decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4.r)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Indicator
                Padding(
                  padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                  child: Center(
                    child: Container(
                      width: 50.w,
                      height: 6.h,
                      decoration: BoxDecoration(color: AppColors.greyE5E4DC, borderRadius: BorderRadius.circular(500)),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.close, size: 30.sp, color: Colors.transparent),
                      Text('checkout_select_payment_method'.tr, style: TextStyles.bold(24.sp, fontColor: AppColors.black1414141)),
                      InkWell(
                        onTap: () => Get.back(),
                        child: Icon(Icons.close, size: 30.sp, color: AppColors.black1414141),
                      ),
                    ],
                  ),
                ),
                Gap(8.h),
                // Payment Options
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      _buildPaymentOption(
                        context: bottomSheetContext,
                        title: 'checkout_stripe'.tr,
                        description: 'checkout_pay_stripe_desc'.tr,
                        icon: Icons.payment,
                        onTap: () {
                          Get.back();
                          _processPayment('Stripe');
                        },
                      ),
                      Gap(16.h),
                      _buildPaymentOption(
                        context: bottomSheetContext,
                        title: 'checkout_mollie'.tr,
                        description: 'checkout_pay_mollie_desc'.tr,
                        icon: Icons.account_balance_wallet,
                        onTap: () {
                          Get.back();
                          _processPayment('Mollie');
                        },
                      ),
                    ],
                  ),
                ),
                Gap(32.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.yellowF0EFE4, width: 1.5),
          boxShadow: [
            BoxShadow(color: AppColors.black1414141.withValues(alpha: 0.05), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 28.sp, color: AppColors.primaryColor),
            ),
            Gap(16.w),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyles.bold(18.sp, fontColor: AppColors.black1414141)),
                  Gap(4.h),
                  Text(description, style: TextStyles.regular(14.sp, fontColor: AppColors.grey888888)),
                ],
              ),
            ),
            // Arrow Icon
            Icon(Icons.arrow_forward_ios, size: 18.sp, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }

  void _processPayment(String paymentMethod) {
    final selectedPlanId = controller.selectedPlanId.value;
    if (selectedPlanId.isEmpty) {
      CustomToast.show(context: context, message: 'membership_select_plan'.tr);
      return;
    }

    // Show loading dialog with text
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16.r)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primaryColor),
              Gap(24.h),
              Text(
                'membership_redirecting_payment'.tr,
                style: TextStyles.semiBold(16.sp, fontColor: AppColors.black1414141),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    controller.buyMembership(
      planId: selectedPlanId,
      paymentMethod: paymentMethod,
      onSuccess: (webUrl, membershipId) {
        Get.back(); // Close loading dialog
        if (webUrl != null && webUrl.isNotEmpty) {
          // Open WebView with payment URL
          Get.to(() => PaymentWebView(webUrl: webUrl));
        }
        // else {
        //   CustomToast.show(context: context, message: 'Payment URL not found in response');
        // }
      },
      onError: (error) {
        Get.back(); // Close loading dialog
        // CustomToast.show(context: context, message: error);
      },
    );
  }
}
