import '../../../../core/utils/app_functions.dart';
import '../../addresses/controllers/addresses_controller.dart';
import '../../add_address/checkout_inline_address_helper.dart';
import '../../add_address/controllers/add_address_controller.dart';
import '../../add_address/widgets/add_address_form_content.dart';
import '../../cart/controllers/cart_controller.dart';
import 'package:viteezy/core/models/checkout_summary_model.dart';
import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/common_textfield.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/gen/assets.gen.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  CheckoutView({super.key});

  // ScrollController for packaging step
  final ScrollController _packagingScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: controller.currentStep.value == 1,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Handle back button press
          if (controller.currentStep.value == 1) {
            // If on first step, exit screen
            Get.back();
          } else {
            // If on step 2 or 3, go to previous step
            controller.goToPreviousStep();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceColor,
        appBar: _buildCheckoutAppBar(),
        body: Obx(() {
          if (controller.currentStep.value == 1) {
            return _buildPackagingStep();
          } else if (controller.currentStep.value == 2) {
            return _buildAddressStep();
          } else {
            return _buildPaymentStep();
          }
        }),
      ),
    );
  }

  PreferredSizeWidget _buildCheckoutAppBar() {
    return _CheckoutAppBar(
      onBackPressed: () {
        if (controller.currentStep.value == 1) {
          // If on first step, exit screen
          Get.back();
        } else {
          // If on step 2 or 3, go to previous step
          controller.goToPreviousStep();
        }
      },
    );
  }

  Widget _buildPackagingStep() {
    return Container(
      color: AppColors.offWhite,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _packagingScrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(12.h),
                  Text(
                    'checkout_choose_packaging'.tr,
                    style: TextStyles.bold(
                      18.sp,
                      fontColor: AppColors.black1414141,
                    ),
                  ),
                  Gap(20.h),
                  Obx(() {
                    if (controller.isLoadingSubscriptionPlans.value) {
                      return _buildSubscriptionPlansShimmer();
                    }
                    final checkoutData = controller.checkoutSummaryData.value;
                    final cartItems = checkoutData?.cart?.items ?? [];
                    final standUpPouchPlans = checkoutData?.standUpPouchPlans;
                    final hasSachets = cartItems.any(
                      (i) => i.variant == 'SACHETS',
                    );
                    final hasStandUpPouch =
                        standUpPouchPlans != null &&
                        standUpPouchPlans.isNotEmpty;
                    final hasSachetsPlans =
                        controller.subscriptionPlans.isNotEmpty;

                    if (!hasStandUpPouch && !hasSachetsPlans && !hasSachets) {
                      return _buildEmptyState();
                    }

                    final readOnly = controller.fromSubscriptionUpdate.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stand-up pouch section: one card per productId in standUpPouchPlans
                        if (hasStandUpPouch) ...[
                          _buildExpandableSection(
                            title: 'Stand-up pouch',
                            children: standUpPouchPlans.entries.map((entry) {
                              final productId = entry.key;
                              final plans = entry.value;
                              Item? item;
                              for (final i in cartItems) {
                                if (i.productId == productId &&
                                    i.variant == 'STAND_UP_POUCH') {
                                  item = i;
                                  break;
                                }
                              }
                              return _buildStandUpPouchCard(
                                productId,
                                plans,
                                item,
                                readOnly: readOnly,
                              );
                            }).toList(),
                          ),
                          Gap(16.h),
                        ],
                        // Viteezy Sachets section
                        if (hasSachets && hasSachetsPlans) ...[
                          _buildExpandableSection(
                            title: 'Viteezy Sachets',
                            children: controller.subscriptionPlans
                                .asMap()
                                .entries
                                .map((entry) {
                                  final plan = entry.value;
                                  // Selected = user's choice from controller (match by planKey); default from API is set on load
                                  final selectedPlan =
                                      controller.selectedSubscriptionPlan.value;
                                  final isSelected =
                                      selectedPlan != null &&
                                      selectedPlan.planKey == plan.planKey;
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: _buildPackagingCard(
                                      plan,
                                      key: ValueKey(
                                        'plan_${plan.planKey ?? entry.key}',
                                      ),
                                      isSelected: isSelected,
                                      readOnly: readOnly,
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                          Gap(16.h),
                        ],
                        Gap(10.h),
                      ],
                    );
                  }),
                  Gap(10.h),
                ],
              ),
            ),
          ),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required List<Widget> children,
  }) {
    return _ExpandableCheckoutSection(title: title, children: children);
  }

  Widget _buildStandUpPouchCard(
    String productId,
    List<SubscriptionPlan> plans,
    Item? item, {
    bool readOnly = false,
  }) {
    final selectedPlan = controller.getSelectedStandUpPouchPlan(productId);
    final currency = item?.basePlanPrice?.currency ?? 'EUR';
    final title = item?.title ?? 'Product';

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grayE3E3DC),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final plan = controller.getSelectedStandUpPouchPlan(productId);
              // Unit price = selected SubscriptionPlan's totalAmount (from dropdown; default = API's isSelected option)
              final unitPrice = plan?.amount ?? 0.0;
              final quantity = controller.getStandUpPouchQuantity(productId);
              // product price = totalAmount × quantity
              final totalAmount = unitPrice * quantity;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'One-time purchase',
                        style: TextStyles.medium(
                          16.sp,
                          fontColor: AppColors.black1414141,
                        ),
                      ),
                      Gap(2.h),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              title,
                              style: TextStyles.regular(
                                12.sp,
                                fontColor: AppColors.gray686767,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Gap(5.h),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.gray686767,
                              shape: BoxShape.circle,
                            ),
                            width: 5,
                            height: 5,
                          ),
                          Gap(5.h),
                          Text(
                            "${plan?.capsuleCount} count",
                            style: TextStyles.regular(
                              12.sp,
                              fontColor: AppColors.gray686767,
                            ),
                          ),
                          Gap(5.h),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.gray686767.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            child: Text(
                              ('x$quantity'),
                              style: TextStyles.regular(
                                12.sp,
                                fontColor: AppColors.gray686767,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Flexible(
                    child: Text(
                      '$currency ${totalAmount.toStringAsFixed(2)}',
                      style: TextStyles.bold(
                        14.sp,
                        fontColor: AppColors.black1414141,
                      ),
                    ),
                  ),
                ],
              );
            }),
            if (plans.isNotEmpty) ...[
              Gap(12.h),
              Text(
                'checkout_capsules_options'.tr,
                style: TextStyles.bold(
                  14.sp,
                  fontColor: AppColors.black1414141,
                ),
              ),
              Gap(8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildStandUpPouchCapsuleDropdown(
                      productId: productId,
                      plans: plans,
                      selectedPlan: selectedPlan,
                      readOnly: readOnly,
                    ),
                  ),
                  Gap(12.w),
                  Obx(
                    () => _buildStandUpPouchQuantitySelector(
                      productId,
                      controller.getStandUpPouchQuantity(productId),
                      readOnly: readOnly,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStandUpPouchCapsuleDropdown({
    required String productId,
    required List<SubscriptionPlan> plans,
    SubscriptionPlan? selectedPlan,
    bool readOnly = false,
  }) {
    if (plans.isEmpty) return const SizedBox.shrink();

    return Obx(() {
      // Use controller's selection so dropdown displays the selected option after user change
      final value = controller.getSelectedStandUpPouchPlan(productId);
      // Ensure value is in the items list (DropdownButton requires value to be in items)
      final valueInList =
          value != null && plans.any((p) => p.capsuleCount == value.capsuleCount && p.planKey == value.planKey)
          ? plans.firstWhere((p) => p.capsuleCount == value.capsuleCount && p.planKey == value.planKey)
          : value;

      return Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.grayE3E3DC),
          color: AppColors.surfaceColor,
        ),
        alignment: Alignment.centerLeft,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<SubscriptionPlan?>(
            value: valueInList,
            hint: Text(
              'Select',
              style: TextStyles.regular(14.sp, fontColor: AppColors.gray949391),
            ),
            isExpanded: true,
            isDense: true,
            iconSize: 20.sp,
            icon: Icon(
              Icons.keyboard_arrow_down,
              size: 20.sp,
              color: AppColors.gray949391,
            ),
            items: plans.map<DropdownMenuItem<SubscriptionPlan?>>((plan) {
              return DropdownMenuItem<SubscriptionPlan?>(
                value: plan,
                child: Text(
                  '${plan.capsuleCount ?? 0} Capsules',
                  style: TextStyles.regular(
                    14.sp,
                    fontColor: AppColors.black1414141,
                  ),
                ),
              );
            }).toList(),
            onChanged: readOnly
                ? null
                : (SubscriptionPlan? plan) {
                    if (plan != null) controller.selectStandUpPouchPlan(productId, plan);
                  },
          ),
        ),
      );
    });
  }

  /// Quantity selector same as cart_view: white container, border, minus | qty | plus.
  static const int _minQty = 1;
  static const int _maxQty = 99;

  Widget _buildStandUpPouchQuantitySelector(
    String productId,
    int quantity, {
    bool readOnly = false,
  }) {
    final qty = quantity.clamp(_minQty, _maxQty);
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grayE3E3DC, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CheckoutQuantityButton(
            icon: Icons.remove,
            onTap: readOnly
                ? null
                : (qty <= _minQty
                      ? () => controller.confirmRemoveStandUpPouchItem(productId)
                      : () => controller.updateStandUpPouchQuantity(productId, qty - 1)),
            size: 16.sp,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          ),
          Container(width: 1, color: AppColors.grayE3E3DC),
          SizedBox(
            width: 28.w,
            child: Center(
              child: Text(
                '$qty',
                style: TextStyles.semiBold(
                  12.sp,
                  fontColor: AppColors.black1414141,
                ),
              ),
            ),
          ),
          Container(width: 1, color: AppColors.grayE3E3DC),
          _CheckoutQuantityButton(
            icon: Icons.add,
            onTap: readOnly
                ? null
                : (qty >= _maxQty ? null : () => controller.updateStandUpPouchQuantity(productId, qty + 1)),
            size: 16.sp,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagingCard(
    SubscriptionPlan plan, {
    Key? key,
    required bool isSelected,
    bool readOnly = false,
  }) {
    return GestureDetector(
      key: key,
      onTap: readOnly ? null : () => controller.selectSubscriptionPlan(plan),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),

            decoration: BoxDecoration(
              color: isSelected ? AppColors.offWhite : AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.black1414141
                    : AppColors.grayE3E3DC,
                width: isSelected ? 1 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Radio, Title/Save Badge, Price
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Radio Button
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: AppColors.black1414141,
                      size: 25.sp,
                    ),
                    Gap(12.w),
                    // Content Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Save Badge - Wrap allows badge to move to next line when narrow
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8.w,
                            runSpacing: 4.h,
                            children: [
                              Text(
                                plan.label ?? '',
                                style: TextStyles.bold(
                                  15.sp,
                                  fontColor: AppColors.black1414141,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (plan.savePercentage != null &&
                                  plan.savePercentage! > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.yellowEDDFA5,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    'Save ${plan.savePercentage!.toStringAsFixed(0)}%',
                                    style: TextStyles.medium(
                                      10.sp,
                                      fontColor: AppColors.black1414141,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Gap(4.h),
                          Text(
                            '${plan.capsuleCount ?? 0} capsules',
                            style: TextStyles.regular(
                              14.sp,
                              fontColor: AppColors.gray686767,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Price Section - Flexible so it can shrink on narrow screens
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (plan.perMonthAmount != null &&
                              plan.isSubscription == true)
                            Text(
                              '\$${plan.perMonthAmount!.toStringAsFixed(2)} / month',
                              style: TextStyles.bold(
                                14.sp,
                                fontColor: AppColors.black1414141,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          else if (plan.totalAmount != null)
                            Text(
                              '\$${plan.totalAmount!.toStringAsFixed(2)}',
                              style: TextStyles.bold(
                                14.sp,
                                fontColor: AppColors.black1414141,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (plan.durationDays != null &&
                              plan.isSubscription == true) ...[
                            Gap(2.h),
                            Text(
                              'every ${plan.durationDays} days',
                              style: TextStyles.regular(
                                14.sp,
                                fontColor: AppColors.gray686767,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                Gap(10.h),
                // Features Section - Below the main row (only for subscription options)
                if (plan.isSubscription == true &&
                    plan.features != null &&
                    plan.features!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(left: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...plan.features!.map((feature) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: _buildFeatureItem(Icons.check, feature),
                          );
                        }),
                      ],
                    ),
                  ),
                // Capsules options dropdown for one-time purchase
                if (plan.isSubscription == false) ...[
                  _buildCapsulesDropdown(plan),
                ],
              ],
            ),
          ),
          // Show "Trusted by Most Users" badge only on 180-day plan
          if (plan.durationDays == 180 && isSelected)
            Positioned(
              top: -12.h,
              right: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: !isSelected
                      ? AppColors.surfaceColor
                      : AppColors.offWhite,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.black1414141, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'checkout_trusted_by_users'.tr,
                      style: TextStyles.medium(
                        10.sp,
                        fontColor: AppColors.black1414141,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 4.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.icCheckedCircle.svg(),
          Gap(8.w),
          Text(
            text,
            style: TextStyles.medium(12.sp, fontColor: AppColors.black1414141),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlansShimmer() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: ShimmerWidget(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.grayE3E3DC,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Radio button shimmer
                      Container(
                        width: 25.w,
                        height: 25.w,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Gap(12.w),
                      // Content shimmer
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title shimmer
                            Container(
                              width: 150.w,
                              height: 18.h,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            Gap(8.h),
                            // Capsules shimmer
                            Container(
                              width: 100.w,
                              height: 14.h,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Price shimmer
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 80.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          Gap(4.h),
                          Container(
                            width: 60.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64.sp,
              color: AppColors.gray949391,
            ),
            Gap(16.h),
            Text(
              'checkout_no_subscription_plans'.tr,
              style: TextStyles.medium(18.sp, fontColor: AppColors.gray686767),
            ),
            Gap(8.h),
            Text(
              'checkout_try_again_later'.tr,
              style: TextStyles.regular(14.sp, fontColor: AppColors.gray949391),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapsulesDropdown(SubscriptionPlan plan) {
    // Available capsule options
    final List<int> capsuleOptions = [30, 60];
    final planKey = plan.planKey ?? '';
    final defaultCapsuleCount = 30; // Default to 60 capsules
    final GlobalKey dropdownKey = GlobalKey();

    return Obx(() {
      final selectedCapsuleCount = controller.getSelectedCapsuleCount(
        planKey,
        defaultCapsuleCount,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'checkout_capsules_options'.tr,
            style: TextStyles.bold(14.sp, fontColor: AppColors.black1414141),
          ),
          Gap(8.h),
          Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  // Show dropdown menu
                  final RenderBox? renderBox =
                      dropdownKey.currentContext?.findRenderObject()
                          as RenderBox?;
                  if (renderBox == null) return;

                  final Offset offset = renderBox.localToGlobal(Offset.zero);

                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      offset.dx,
                      offset.dy + renderBox.size.height,
                      offset.dx + renderBox.size.width,
                      offset.dy +
                          renderBox.size.height +
                          (capsuleOptions.length * 48.h),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    items: capsuleOptions.map((capsuleCount) {
                      return PopupMenuItem<int>(
                        value: capsuleCount,
                        child: Text(
                          '$capsuleCount Capsules',
                          style: TextStyles.regular(
                            14.sp,
                            fontColor: AppColors.black1414141,
                          ),
                        ),
                      );
                    }).toList(),
                  ).then((selectedValue) {
                    if (selectedValue != null) {
                      controller.selectCapsuleCount(planKey, selectedValue);
                    }
                  });
                },
                child: Container(
                  key: dropdownKey,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.grayE3E3DC, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$selectedCapsuleCount Capsules',
                        style: TextStyles.regular(
                          14.sp,
                          fontColor: AppColors.black1414141,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 20.sp,
                        color: AppColors.gray949391,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildContinueButton() {
    return Obx(() {
      final isPaymentStep = controller.currentStep.value == 3;
      final fromSubscriptionUpdate = controller.fromSubscriptionUpdate.value;
      final isAddressStepEmpty = controller.currentStep.value == 2 &&
          !controller.isLoadingAddresses.value &&
          controller.addresses.isEmpty;
      final buttonText = isPaymentStep
          ? (fromSubscriptionUpdate ? 'Update My Plan' : 'Place Order')
          : (isAddressStepEmpty ? 'checkout_add_address'.tr : 'Continue');
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (isPaymentStep && fromSubscriptionUpdate) {
                  controller.confirmSubscriptionUpdateAndRedirect();
                } else if (isPaymentStep) {
                  _showPaymentMethodDialog();
                } else if (controller.currentStep.value == 2) {
                  if (isAddressStepEmpty) {
                    if (Get.isRegistered<AddAddressController>(tag: CheckoutInlineAddressHelper.tag)) {
                      Get.find<AddAddressController>(tag: CheckoutInlineAddressHelper.tag).saveAddress();
                    } else {
                      AppFunctions().showToast('Please add a shipping address', bgColor: AppColors.red);
                    }
                    return;
                  }
                  final addressId = controller.selectedAddress.value?.id;
                  if (addressId == null || addressId.toString().trim().isEmpty) {
                    AppFunctions().showToast('Please select a shipping address', bgColor: AppColors.red);
                    return;
                  }
                  if (fromSubscriptionUpdate) {
                    controller.continueFromAddressStepWithSubscriptionSummary();
                  } else {
                    controller.continueToNextStep();
                  }
                } else {
                  controller.continueToNextStep();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isAddressStepEmpty ? AppColors.addressFormSaveButton : AppColors.primaryColor,
                foregroundColor: AppColors.surfaceColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: TextStyles.semiBold(
                  16.sp,
                  fontColor: AppColors.surfaceColor,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showPaymentMethodDialog() {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
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
                      decoration: BoxDecoration(
                        color: AppColors.greyE5E4DC,
                        borderRadius: BorderRadius.circular(500),
                      ),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.close, size: 30.sp, color: Colors.transparent),
                      Text(
                        'checkout_select_payment_method'.tr,
                        style: TextStyles.bold(
                          24.sp,
                          fontColor: AppColors.black1414141,
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.back(),
                        child: Icon(
                          Icons.close,
                          size: 30.sp,
                          color: AppColors.black1414141,
                        ),
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
                        description: 'Pay securely with Stripe',
                        icon: Icons.payment,
                        onTap: () {
                          Get.back();
                          controller.createOrder('Stripe');
                        },
                      ),
                      Gap(16.h),
                      _buildPaymentOption(
                        context: bottomSheetContext,
                        title: 'checkout_mollie'.tr,
                        description: 'Pay securely with Mollie',
                        icon: Icons.account_balance_wallet,
                        onTap: () {
                          Get.back();
                          controller.createOrder('Mollie');
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
            BoxShadow(
              color: AppColors.black1414141.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
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
                  Text(
                    title,
                    style: TextStyles.bold(
                      18.sp,
                      fontColor: AppColors.black1414141,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    description,
                    style: TextStyles.regular(
                      14.sp,
                      fontColor: AppColors.grey888888,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 18.sp,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressStep() {
    return Obx(() {
      final inlineEmpty = !controller.isLoadingAddresses.value && controller.addresses.isEmpty;
      return Container(
        color: inlineEmpty ? AppColors.addressFormBackground : AppColors.offWhite,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(12.h),
                    if (!inlineEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'checkout_shipping_address'.tr,
                            style: TextStyles.bold(
                              18.sp,
                              fontColor: AppColors.black1414141,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.addNewAddress(),
                            child: Text(
                              '+ New address',
                              style: TextStyles.medium(
                                14.sp,
                                fontColor: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (!inlineEmpty) Gap(20.h),
                  // Address Cards or inline add form
                  Obx(() {
                    // Show shimmer when loading
                    if (controller.isLoadingAddresses.value) {
                      return _buildAddressesShimmer();
                    }
                    // Show full add-address form when no addresses (first-time user)
                    if (controller.addresses.isEmpty) {
                      return GetBuilder<AddAddressController>(
                        tag: CheckoutInlineAddressHelper.tag,
                        builder: (addCtrl) {
                          return AddAddressFormContent(controller: addCtrl);
                        },
                      );
                    }
                    // Show addresses with animation
                    return _buildAnimatedAddressList();
                  }),
                  Gap(10.h),
                ],
              ),
            ),
          ),
          _buildContinueButton(),
        ],
      ),
    );
    });
  }

  Widget _buildAddressCard(Address address) {
    final isSelected = controller.selectedAddress.value?.id == address.id;

    return GestureDetector(
      onTap: () => controller.selectAddress(address),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.black1414141
                    : AppColors.grayE3E3DC,
                width: isSelected ? 1 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(5.h),
                // Name with dot and house icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '${address.firstName ?? ''} ${address.lastName ?? ''}'
                                      .trim()
                                      .isNotEmpty
                                  ? '${address.firstName ?? ''} ${address.lastName ?? ''}'
                                        .trim()
                                  : 'Address',
                              style: TextStyles.bold(
                                16.sp,
                                fontColor: AppColors.black1414141,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          Gap(4.w),
                          Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.black1414141,
                            ),
                          ),
                          Gap(4.w),
                          Icon(
                            Icons.home,
                            size: 16.sp,
                            color: AppColors.gray949391,
                          ),
                          Gap(4.w),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          child: Assets.icons.icEdit.svg(),
                          onTap: () => controller.editAddress(address),
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
                // Address lines
                Text(
                  _buildFullAddress(address),
                  style: TextStyles.regular(
                    14.sp,
                    fontColor: AppColors.black1414141,
                  ),
                ),
                Gap(2.h),
                Text(
                  '${address.postalCode ?? ''} ${address.city ?? ''}'.trim(),
                  style: TextStyles.regular(
                    14.sp,
                    fontColor: AppColors.black1414141,
                  ),
                ),
                Gap(12.h),
                // Phone
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      address.phone ?? '',
                      style: TextStyles.medium(
                        12.sp,
                        fontColor: AppColors.black1414141,
                      ),
                    ),
                  ],
                ),
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
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(4.r),
                  ),
                ),
                child: Icon(
                  Icons.check,
                  size: 15.sp,
                  color: AppColors.surfaceColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _buildFullAddress(Address address) {
    final streetName = address.streetName ?? '';
    final houseNumber = address.houseNumber ?? '';
    final houseNumberAddition = address.houseNumberAddition ?? '';
    final addressLine = '$streetName $houseNumber $houseNumberAddition'.trim();

    if (addressLine.isNotEmpty) {
      return '$addressLine, ${address.postalCode ?? ''} ${address.city ?? ''}, ${address.country ?? ''}'
          .trim();
    } else if (address.address != null && address.address!.isNotEmpty) {
      return '${address.address}, ${address.postalCode ?? ''} ${address.city ?? ''}, ${address.country ?? ''}'
          .trim();
    } else {
      return '${address.postalCode ?? ''} ${address.city ?? ''}, ${address.country ?? ''}'
          .trim();
    }
  }

  Widget _buildAddressesShimmer() {
    return Column(
      children: List.generate(2, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: ShimmerWidget(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.grayE3E3DC,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name shimmer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 120.w,
                        height: 18.h,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Gap(12.w),
                          Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Gap(12.h),
                  // Address line shimmer
                  Container(
                    width: double.infinity,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(4.h),
                  Container(
                    width: 150.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(12.h),
                  // Email and phone shimmer
                  Row(
                    children: [
                      Container(
                        width: 100.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      Gap(12.w),
                      Container(width: 1, height: 16.h, color: AppColors.white),
                      Gap(12.w),
                      Container(
                        width: 80.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnimatedAddressList() {
    return Obx(() {
      return Column(
        children: controller.addresses.asMap().entries.map((entry) {
          final index = entry.key;
          final address = entry.value;
          return AnimatedSize(
            key: ValueKey('address_${address.id}_$index'),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildAddressCard(address),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildPaymentStep() {
    return Container(
      color: AppColors.offWhite,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(12.h),
                  // Cart Summary Section
                  Text(
                    'checkout_cart_summary'.tr,
                    style: TextStyles.bold(
                      18.sp,
                      fontColor: AppColors.black1414141,
                    ),
                  ),
                  Gap(20.h),
                  Obx(() {
                    final checkoutData = controller.checkoutSummaryData.value;
                    if (checkoutData?.cart?.items == null ||
                        checkoutData!.cart!.items!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 60.h),
                          child: Text(
                            'No items in cart',
                            style: TextStyles.regular(
                              14.sp,
                              fontColor: AppColors.gray949391,
                            ),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: checkoutData.cart!.items!.map((item) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _buildCartItem(item),
                        );
                      }).toList(),
                    );
                  }),
                  Gap(20.h),
                  // Discount Code Section - Show applied coupon or input field
                  Obx(() {
                    // Check if coupon code exists from API (CartController)
                    final cartController = Get.isRegistered<CartController>()
                        ? Get.find<CartController>()
                        : null;
                    final couponCode =
                        cartController?.cartData.value?.cart?.couponCode;
                    final hasCouponCode =
                        couponCode != null && couponCode.toString().isNotEmpty;

                    if (hasCouponCode) {
                      // Show applied coupon code with Remove button
                      return _buildAppliedCouponCode(couponCode.toString());
                    } else {
                      // Show discount code input field
                      return _buildDiscountCodeInput();
                    }
                  }),
                  Gap(20.h),
                  // Payment Details Section
                  Text(
                    'orders_payment_details'.tr,
                    style: TextStyles.bold(
                      18.sp,
                      fontColor: AppColors.black1414141,
                    ),
                  ),
                  Gap(10.h),
                  _buildPaymentDetails(),
                  Gap(100.h), // Space for bottom button
                ],
              ),
            ),
          ),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildCartItem(Item item) {
    final basePrice = item.basePlanPrice;
    final currency = basePrice?.currency ?? '\$';
    final isStandUpPouch = item.variant == 'STAND_UP_POUCH';
    final membershipDiscount = item.membershipDiscount ?? 0.0;

    // Only use Obx for STAND_UP_POUCH so we subscribe to observables; non-stand-up-pouch has no observables.
    if (isStandUpPouch && item.productId != null) {
      return Obx(() {
        final quantity = controller.getStandUpPouchQuantity(item.productId!);
        final selectedPlan = controller.getSelectedStandUpPouchPlan(
          item.productId!,
        );
        final unitTotalAmount = selectedPlan?.totalAmount ?? 0.0;
        final currentPrice = unitTotalAmount;
        final displayOriginalPrice =
            (basePrice?.amount ?? unitTotalAmount) * quantity;
        return _buildCartItemContent(
          item: item,
          currency: currency,
          quantity: quantity,
          currentPrice: currentPrice,
          displayOriginalPrice: displayOriginalPrice,
          membershipDiscount: membershipDiscount,
        );
      });
    }

    final quantity = item.quantity ?? 1;
    final currentPrice =
        basePrice?.discountedPrice ?? basePrice?.totalAmount ?? 0.0;
    final originalPrice = basePrice?.amount ?? basePrice?.totalAmount ?? 0.0;
    return _buildCartItemContent(
      item: item,
      currency: currency,
      quantity: quantity,
      currentPrice: currentPrice,
      displayOriginalPrice: originalPrice,
      membershipDiscount: membershipDiscount,
    );
  }

  Widget _buildCartItemContent({
    required Item item,
    required String currency,
    required int quantity,
    required double currentPrice,
    required double displayOriginalPrice,
    required double membershipDiscount,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10.r),
              topLeft: Radius.circular(10.r),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: item.image != null && item.image!.isNotEmpty
                      ? CommonNetworkImage(
                          imageUrl: item.image!,
                          fit: BoxFit.cover,
                          width: 70.w,
                          height: 70.w,
                        )
                      : Icon(
                          Icons.image_not_supported,
                          size: 24.sp,
                          color: AppColors.gray949391,
                        ),
                ),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? '',
                      style: TextStyles.bold(
                        14.sp,
                        fontColor: AppColors.black1414141,
                      ),
                    ),
                    if (item.basePlanPrice?.planType != null &&
                        item.basePlanPrice!.planType!.isNotEmpty) ...[
                      Gap(3.h),
                      Text(
                        item.basePlanPrice?.planType ?? "",
                        style: TextStyles.medium(
                          12.sp,
                          fontColor: AppColors.black1414141,
                        ),
                      ),
                    ],
                    if (quantity > 1) ...[
                      Gap(3.h),
                      Text(
                        'Qty: $quantity',
                        style: TextStyles.medium(
                          12.sp,
                          fontColor: AppColors.gray686767,
                        ),
                      ),
                    ],
                    Gap(3.h),
                    Row(
                      children: [
                        Text(
                          '$currency${currentPrice.toStringAsFixed(2)}',
                          style: TextStyles.bold(
                            14.sp,
                            fontColor: AppColors.black1414141,
                          ),
                        ),
                        if (displayOriginalPrice > currentPrice) ...[
                          Gap(8.w),
                          Text(
                            '$currency${displayOriginalPrice.toStringAsFixed(2)}',
                            style: TextStyles.regular(
                              12.sp,
                              fontColor: AppColors.gray949391,
                              textDecoration: TextDecoration.lineThrough,
                            ).copyWith(decorationColor: AppColors.gray949391),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (membershipDiscount > 0) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight,
                  AppColors.orangeF7A173.withValues(alpha: 0.3),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.r),
                bottomRight: Radius.circular(10.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'cart_membership_discount'.tr,
                  style: TextStyles.semiBold(
                    12.sp,
                    fontColor: AppColors.black1414141,
                  ),
                ),
                Text(
                  '-$currency${membershipDiscount.toStringAsFixed(2)}',
                  style: TextStyles.semiBold(
                    12.sp,
                    fontColor: AppColors.black1414141,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDiscountCodeInput() {
    return Row(
      children: [
        Expanded(
          child: CommonMainTextField(
            controller: controller.discountCodeController,
            hintText: 'Enter discount code',
            labelText: 'Enter discount code',
            fillColor: AppColors.surfaceColor,
            borderColor: AppColors.grayE3E3DC,
            radius: BorderRadius.circular(8.r),
            textStyle: TextStyles.regular(
              14.sp,
              fontColor: AppColors.black1414141,
            ),
            hintColor: AppColors.gray949391,
          ),
        ),
        Gap(12.w),
        ElevatedButton(
          onPressed: () {
            if (controller.discountCodeController.text.isNotEmpty) {
              controller.applyDiscountCode(
                controller.discountCodeController.text,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.black1414141,
            foregroundColor: AppColors.surfaceColor,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 15.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            elevation: 0,
          ),
          child: Text(
            'cart_apply'.tr,
            style: TextStyles.semiBold(
              14.sp,
              fontColor: AppColors.surfaceColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Obx(() {
      final checkoutData = controller.checkoutSummaryData.value;
      final pricing = checkoutData?.pricing;
      final overall = pricing?.overall;
      final currency = overall?.currency ?? pricing?.overall?.currency ?? '\$';

      if (pricing == null) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.yellowF0EFE4,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              'Loading payment details...',
              style: TextStyles.regular(14.sp, fontColor: AppColors.gray949391),
            ),
          ),
        );
      }

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.yellowF0EFE4,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            if (overall?.subTotal != null)
              _buildPaymentDetailRow(
                'Subtotal',
                '$currency${overall!.subTotal!.toStringAsFixed(2)}',
              ),
            if (overall?.subTotal != null) Gap(12.h),
            if (overall?.discountedPrice != null &&
                overall!.discountedPrice! > 0) ...[
              _buildPaymentDetailRow(
                'Discount',
                '-$currency${overall.discountedPrice!.toStringAsFixed(2)}',
              ),
              Gap(12.h),
            ],
            if (overall?.membershipDiscountAmount != null &&
                overall!.membershipDiscountAmount! > 0) ...[
              _buildPaymentDetailRow(
                'Membership Discount',
                '-$currency${overall.membershipDiscountAmount!.toStringAsFixed(2)}',
              ),
              Gap(12.h),
            ],
            if (overall?.subscriptionPlanDiscountAmount != null &&
                overall!.subscriptionPlanDiscountAmount! > 0) ...[
              _buildPaymentDetailRow(
                'Subscription Discount',
                '-$currency${overall.subscriptionPlanDiscountAmount!.toStringAsFixed(2)}',
              ),
              Gap(12.h),
            ],
            if (overall?.couponDiscountAmount != null &&
                overall!.couponDiscountAmount! > 0) ...[
              _buildPaymentDetailRow(
                'Coupon Discount',
                '-$currency${overall.couponDiscountAmount!.toStringAsFixed(2)}',
              ),
              Gap(12.h),
            ],
            Gap(16.h),
            Divider(height: 1, color: AppColors.grayE3E3DC),
            Gap(16.h),
            if (overall?.grandTotal != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPaymentDetailRow(
                    'Grand Total',
                    '$currency${overall!.grandTotal!.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                  Text(
                    'checkout_inc_taxes'.tr,
                    style: TextStyles.regular(
                      12.sp,
                      fontColor: AppColors.black1414141,
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPaymentDetailRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? TextStyles.bold(16.sp, fontColor: AppColors.black1414141)
              : TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
        ),
        Text(
          value,
          style: isBold
              ? TextStyles.bold(16.sp, fontColor: AppColors.black1414141)
              : TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
        ),
      ],
    );
  }

  Widget _buildAppliedCouponCode(String couponCode) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grayE3E3DC, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 20.sp,
                  color: AppColors.primaryColor,
                ),
                Gap(8.w),
                Expanded(
                  child: Text(
                    'Coupon: $couponCode',
                    style: TextStyles.medium(
                      14.sp,
                      fontColor: AppColors.black1414141,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              controller.removeCouponCode();
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Remove',
              style: TextStyles.medium(14.sp, fontColor: AppColors.primaryColor)
                  .copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom AppBar with dynamic height using LayoutBuilder
class _CheckoutAppBar extends GetView<CheckoutController>
    implements PreferredSizeWidget {
  final VoidCallback onBackPressed;

  const _CheckoutAppBar({required this.onBackPressed});

  @override
  Size get preferredSize => Size.fromHeight(120.h); // Initial estimate, will be adjusted

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            color: AppColors.surfaceColor,
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : double.infinity,
              minHeight: 0,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // AppBar with title and back button
                  Row(
                    children: [
                      IconButton(
                        icon: Image.asset(
                          Assets.icons.icBackArrow.path,
                          scale: 3,
                        ),
                        onPressed: onBackPressed,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'checkout_checkout'.tr,
                            style: TextStyles.bold(
                              18.sp,
                              fontColor: AppColors.black1414141,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 48.w), // Balance for back button
                    ],
                  ),
                  // Progress Indicator
                  Flexible(child: Obx(() => _buildProgressIndicator())),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProgressStep(1, 'Packaging', controller.currentStep.value >= 1),
          _buildProgressLine(controller.currentStep.value > 1),
          _buildProgressStep(2, 'Address', controller.currentStep.value >= 2),
          _buildProgressLine(controller.currentStep.value > 2),
          _buildProgressStep(3, 'Payment', controller.currentStep.value >= 3),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int stepNumber, String label, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primaryColor : AppColors.grayE3E3DC,
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: TextStyles.semiBold(
                12.sp,
                fontColor: isActive
                    ? AppColors.surfaceColor
                    : AppColors.gray949391,
              ),
            ),
          ),
        ),
        Gap(4.h),
        Text(
          label,
          style: TextStyles.semiBold(
            10.sp,
            fontColor: isActive ? AppColors.black1414141 : AppColors.gray949391,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2.h,
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          // color: isActive ? AppColors.primaryColor : AppColors.grayE3E3DC,
          color: AppColors.grayE3E3DC,
          borderRadius: BorderRadius.circular(1.r),
        ),
      ),
    );
  }
}

/// Expand/collapse card for packaging sections; header tap toggles content and arrow.
class _ExpandableCheckoutSection extends StatefulWidget {
  final String title;
  final List<Widget> children;

  const _ExpandableCheckoutSection({
    required this.title,
    required this.children,
  });

  @override
  State<_ExpandableCheckoutSection> createState() =>
      _ExpandableCheckoutSectionState();
}

class _ExpandableCheckoutSectionState
    extends State<_ExpandableCheckoutSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grayE3E3DC),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyles.bold(
                          16.sp,
                          fontColor: AppColors.black1414141,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      turns: _expanded ? 0.5 : 0,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 24.sp,
                        color: AppColors.black1414141,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.children,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Minus/plus button for quantity selector (same as cart_view).
class _CheckoutQuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final EdgeInsets padding;

  const _CheckoutQuantityButton({
    required this.icon,
    this.onTap,
    this.size = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Padding(
          padding: padding,
          child: Icon(icon, size: size, color: AppColors.black1414141),
        ),
      ),
    );
  }
}
