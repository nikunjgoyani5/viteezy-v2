import 'package:flutter_svg/flutter_svg.dart';
import 'package:viteezy/core/models/oders_history_model.dart' as order_model;
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/widgets/common_button.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/presentation/main/orders/controllers/orders_controller.dart';

import '../../../../core/utils/exports.dart';
import '../../../../core/widgets/common_loader.dart';

class OrderReviewBottomSheet extends StatefulWidget {
  final order_model.Item item;

  const OrderReviewBottomSheet({super.key, required this.item});

  @override
  State<OrderReviewBottomSheet> createState() => _OrderReviewBottomSheetState();
}

class _OrderReviewBottomSheetState extends State<OrderReviewBottomSheet> {
  static const String _starSvg = '''
<svg width="30" height="30" viewBox="0 0 30 30" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M10.127 9.77798L10.1706 9.69078L15.0004 0L19.8302 9.69078L19.8738 9.77798L30 11.519L22.9506 18.9253L22.8823 18.9967L22.901 19.0944L24.9756 30L15.0898 24.8024L15.0004 24.7558L14.911 24.8024L5.02442 30L7.09971 19.0944L7.11849 18.9967L7.05012 18.9253L0 11.519L10.127 9.77798Z" fill="currentColor"/>
</svg>
''';

  // static const String _uploadSvg = ''' ... ''';

  final TextEditingController _reviewController = TextEditingController();

  double _rating = 0;
  bool _isSubmitting = false;

  bool get _canSubmit =>
      _rating > 0 && _reviewController.text.trim().isNotEmpty && !_isSubmitting;

  String get _productName =>
      widget.item.productId?.title ?? widget.item.name ?? 'Product';

  String get _productImage => widget.item.productId?.productImage ?? '';

  String get _packInfo {
    final days = widget.item.durationDays;
    if (days != null) {
      if (days % 30 == 0 && days >= 30) {
        final months = days ~/ 30;
        return 'Pack $months month${months == 1 ? '' : 's'}';
      }
      return 'Pack $days days';
    }
    if (widget.item.capsuleCount != null) {
      return '${widget.item.capsuleCount} capsules';
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _reviewController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_canSubmit) return;

    final productId = widget.item.productId?.id;
    if (productId == null || productId.isEmpty) {
      AppFunctions().showToast('Product not found.', bgColor: AppColors.red);
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await Get.find<OrdersController>().submitProductReview(
      productId: productId,
      rating: _rating,
      content: _reviewController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Get.back();
      AppFunctions().showToast(
        'Review submitted successfully.',
        bgColor: AppColors.primaryColor,
      );
    }
  }

  // Image upload — kept for future use
  // Future<void> _pickImages() async { ... }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.greyDFDFDF,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Gap(16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  SizedBox(width: 40.w),
                  Expanded(
                    child: Text(
                      'Review',
                      textAlign: TextAlign.center,
                      style: TextStyles.semiBold(
                        20.sp,
                        fontColor: AppColors.black1414141,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmitting ? null : () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.close,
                      size: 24.sp,
                      color: AppColors.black1414141,
                    ),
                  ),
                ],
              ),
            ),
            Gap(16.h),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductHeader(),
                    Gap(20.h),
                    Text(
                      'Write a review',
                      style: TextStyles.semiBold(
                        16.sp,
                        fontColor: AppColors.black1414141,
                      ),
                    ),
                    Gap(10.h),
                    _buildReviewField(),
                    // Gap(20.h),
                    // Text(
                    //   'Share a photo',
                    //   style: TextStyles.semiBold(
                    //     16.sp,
                    //     fontColor: AppColors.black1414141,
                    //   ),
                    // ),
                    // Gap(10.h),
                    // _buildUploadArea(),
                    // if (_uploadedImages.isNotEmpty) ...[
                    //   Gap(12.h),
                    //   _buildUploadedFilesRow(),
                    // ],
                    Gap(24.h),
                    AbsorbPointer(
                      absorbing: !_canSubmit,
                      child: CommonButtonWidget(
                        height: 48.h,
                        color: _canSubmit
                            ? AppColors.primaryColor
                            : AppColors.lightPrimaryColor,
                        borderRadius: 50,
                        onPressed: () {
                          if (_canSubmit) _submitReview();
                        },
                        child: _isSubmitting
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [CommonLoader(size: 25, color: AppColors.white)],
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('auth_submit'.tr, style: TextStyles.semiBold(17.sp, fontColor: AppColors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: _productImage.isNotEmpty
                ? CommonNetworkImage(
                    imageUrl: _productImage,
                    fit: BoxFit.cover,
                    width: 72.w,
                    height: 72.w,
                  )
                : Icon(Icons.image, size: 28.sp, color: AppColors.gray949391),
          ),
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _productName,
                style: TextStyles.semiBold(
                  16.sp,
                  fontColor: AppColors.black1414141,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (_packInfo.isNotEmpty) ...[
                Gap(4.h),
                Text(
                  _packInfo,
                  style: TextStyles.regular(
                    14.sp,
                    fontColor: AppColors.gray949391,
                  ),
                ),
              ],
              Gap(8.h),
              _buildStarRating(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        final isFull = starValue <= _rating;
        final isHalf = !isFull && (starValue - 0.5 <= _rating);

        return GestureDetector(
          onTapDown: (details) {
            final double tapX = details.localPosition.dx;
            final double starWidth = 22.sp;
            setState(() {
              if (tapX < starWidth / 2) {
                _rating = index + 0.5;
              } else {
                _rating = index + 1.0;
              }
            });
          },
          child: Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Stack(
              children: [
                SvgPicture.string(
                  _starSvg,
                  width: 22.sp,
                  height: 22.sp,
                  colorFilter: const ColorFilter.mode(
                    AppColors.greyDFDFDF,
                    BlendMode.srcIn,
                  ),
                ),
                if (isFull || isHalf)
                  ClipRect(
                    clipper: isHalf ? _HalfClipper() : null,
                    child: SvgPicture.string(
                      _starSvg,
                      width: 22.sp,
                      height: 22.sp,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildReviewField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.greyDFDFDF),
      ),
      child: TextField(
        controller: _reviewController,
        maxLines: 5,
        minLines: 5,
        decoration: InputDecoration(
          hintText: 'Add a Comment...',
          hintStyle: TextStyles.regular(14.sp, fontColor: AppColors.gray949391),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(14.w),
        ),
        style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
      ),
    );
  }

  // Image upload UI — kept commented for future use
  /*
  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _pickImages,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.greyDFDFDF,
          strokeWidth: 1.2,
          radius: 10.r,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            children: [
              SvgPicture.string(
                _uploadSvg,
                width: 28.sp,
                height: 28.sp,
                colorFilter: const ColorFilter.mode(
                  AppColors.gray949391,
                  BlendMode.srcIn,
                ),
              ),
              Gap(8.h),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyles.regular(
                    14.sp,
                    fontColor: AppColors.gray949391,
                  ),
                  children: [
                    TextSpan(
                      text: 'Click to upload',
                      style: TextStyles.medium(
                        14.sp,
                        fontColor: AppColors.black1414141,
                        textDecoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' or drag and drop'),
                  ],
                ),
              ),
              Gap(4.h),
              Text(
                'Max. File Size: 15MB (PNG, JPG)',
                style: TextStyles.regular(
                  12.sp,
                  fontColor: AppColors.gray949391,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadedFilesRow() {
    return SizedBox(
      height: 64.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _uploadedImages.length,
        separatorBuilder: (_, _) => Gap(8.w),
        itemBuilder: (context, index) {
          final file = _uploadedImages[index];
          return _UploadedFileRow(
            file: file,
            fileName: _fileName(file),
            onRemove: () => _removeImage(index),
          );
        },
      ),
    );
  }
  */
}

/*
class _UploadedFileRow extends StatelessWidget {
  ...
}
*/

class _HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;
}
