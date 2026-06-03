import '../utils/exports.dart';

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.onSubmitted,
    this.borderColor,
    this.textAlign,
    this.hintColor,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    this.height,
    this.autofocus = false,
    this.readOnly = false,
    this.expands = false,
    this.radius,

    this.focusNode,
    this.cursorColor,
    this.fillColor,
    this.onTap,
    this.errorBorderSide,
    this.focusedErrorBorderSide,
    this.textInputAction,
    this.textCapitalization,
    this.textStyle,
    this.maxLine = 1,
  });

  final String hintText;
  final int? maxLength;
  final int? maxLine;
  final TextEditingController controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final bool obscureText;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final double? height;
  final bool autofocus;
  final bool readOnly;
  final bool expands;
  final BorderRadius? radius;
  final TextAlign? textAlign;
  final TextStyle? textStyle;

  final FocusNode? focusNode;
  final Color? fillColor;
  final Color? hintColor;
  final Color? borderColor;
  final Color? cursorColor;
  final void Function()? onTap;
  final BorderSide? errorBorderSide;
  final BorderSide? focusedErrorBorderSide;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 100),
      child: TextFormField(
        textAlign: textAlign ?? TextAlign.left,
        focusNode: focusNode,
        maxLength: maxLength,
        maxLines: maxLine,
        expands: expands,
        readOnly: readOnly,
        onTap: onTap,
        autofocus: autofocus,
        inputFormatters: inputFormatters,
        validator: validator,
        onChanged: onChanged,
        obscureText: obscureText,
        onFieldSubmitted: onSubmitted,
        keyboardType: keyboardType,
        controller: controller,
        cursorColor: cursorColor ?? AppColors.primaryColor,
        textInputAction: textInputAction ?? TextInputAction.done,
        textCapitalization: textCapitalization != null
            ? textCapitalization!
            : keyboardType == TextInputType.emailAddress
            ? TextCapitalization.none
            : TextCapitalization.sentences,
        textAlignVertical: TextAlignVertical.top,
        style: textStyle ?? TextStyles.medium(16.sp),
        decoration: InputDecoration(
          fillColor: fillColor,
          filled: (fillColor == null) ? false : true,
          counterText: '',
          hintText: hintText,
          hintStyle: TextStyles.regular(16.sp, fontColor: AppColors.grey888888),
          prefixIcon: prefixIcon != null ? SizedBox(height: 24, width: 24, child: Center(child: prefixIcon)) : null,
          suffixIcon: suffixIcon != null ? SizedBox(height: 24, width: 24, child: Center(child: suffixIcon)) : null,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: borderColor ?? AppColors.greyDFDFDF, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: borderColor ?? AppColors.greyDFDFDF, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: borderColor ?? AppColors.primaryColor, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: borderColor ?? AppColors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.red, width: 1),
          ),
        ),
      ),
    );
  }
}

class CommonMainTextField extends StatefulWidget {
  const CommonMainTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.onSubmitted,
    this.borderColor,
    this.textAlign,
    this.hintColor,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    this.height,
    this.autofocus = false,
    this.readOnly = false,
    this.expands = false,
    this.radius,
    this.cursorColor,
    this.maxLines = 1,
    this.minLines = 1,
    this.focusNode,
    this.fillColor,
    this.onTap,
    this.errorBorderSide,
    this.focusedErrorBorderSide,
    this.textStyle,
    this.labelText,
    this.textFieldAlignment,
    this.textFieldPadding,
    this.textInputAction,
    this.errorText,
  });

  final String? labelText;
  final String hintText;
  final int? maxLength;
  final TextEditingController controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final double? height;
  final bool autofocus;
  final bool readOnly;
  final bool expands;
  final BorderRadius? radius;
  final TextAlign? textAlign;
  final Alignment? textFieldAlignment;
  final int? maxLines;
  final TextStyle? textStyle;
  final int? minLines;
  final FocusNode? focusNode;
  final Color? fillColor;
  final Color? hintColor;
  final Color? cursorColor;
  final Color? borderColor;
  final void Function()? onTap;
  final BorderSide? errorBorderSide;
  final BorderSide? focusedErrorBorderSide;
  final EdgeInsetsGeometry? textFieldPadding;
  final TextInputAction? textInputAction;
  final String? errorText;

  @override
  State<CommonMainTextField> createState() => _CommonMainTextFieldState();
}

class _CommonMainTextFieldState extends State<CommonMainTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.fillColor ?? AppColors.white,
            borderRadius: widget.radius ?? BorderRadius.circular(10.r),
            border: Border.all(
              color: widget.errorText?.isNotEmpty ?? false
                  ? AppColors.red
                  : isFocused
                  ? AppColors.primaryColor
                  : widget.borderColor ?? AppColors.greyDFDFDF,
              width: 1
            ),
          ),
          child: Padding(
            padding: widget.textFieldPadding ?? EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextFormField(

                textAlign: widget.textAlign ?? TextAlign.left,
                focusNode: _focusNode,
                maxLength: widget.maxLength,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                expands: widget.expands,
                readOnly: widget.readOnly,
                onTap: widget.onTap,
                autofocus: widget.autofocus,
                inputFormatters: widget.inputFormatters,
                onChanged: widget.onChanged,
                // validator: widget.validator,
                obscureText: widget.obscureText,
                onFieldSubmitted: widget.onSubmitted,
                keyboardType: widget.keyboardType,
                controller: widget.controller,
                cursorColor: widget.cursorColor ?? AppColors.primaryColor,
                textInputAction: widget.textInputAction ?? TextInputAction.done,
                textAlignVertical: TextAlignVertical.center,
                style: widget.textStyle ?? TextStyles.medium(16.sp),
                cursorHeight: 20.h,
                decoration: InputDecoration(
                  counterText: '',
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon != null
                      ? SizedBox(height: 24, width: 24, child: Center(child: widget.suffixIcon))
                      : null,
                  border: InputBorder.none,
                  filled: true,
                  fillColor: widget.fillColor ?? AppColors.white,
                  labelText: widget.labelText,
                  labelStyle: TextStyles.regular(16.sp, fontColor: AppColors.grey888888),
                  // hintText: widget.hintText,
                  hintStyle: TextStyles.regular(16.sp, fontColor: AppColors.grey888888),
                ),
              ),
            ),
          ),
        ),
        if (widget.errorText?.isNotEmpty ?? false) ...[
          Gap(5),
          Text(widget.errorText ?? '', style: TextStyles.regular(12.sp, fontColor: AppColors.red)),
        ],
      ],
    );
  }
}
class CommonSearchTextField extends StatelessWidget {
  const CommonSearchTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.onSubmitted,
    this.borderColor,
    this.textAlign,
    this.hintColor,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    this.height,
    this.autofocus = false,
    this.readOnly = false,
    this.expands = false,
    this.radius,

    this.focusNode,
    this.cursorColor,
    this.fillColor,
    this.onTap,
    this.errorBorderSide,
    this.focusedErrorBorderSide,
    this.textInputAction,
    this.textCapitalization,
    this.textStyle,
    this.maxLine = 1,
  });

  final String hintText;
  final int? maxLength;
  final int? maxLine;
  final TextEditingController controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final bool obscureText;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final double? height;
  final bool autofocus;
  final bool readOnly;
  final bool expands;
  final BorderRadius? radius;
  final TextAlign? textAlign;
  final TextStyle? textStyle;

  final FocusNode? focusNode;
  final Color? fillColor;
  final Color? hintColor;
  final Color? borderColor;
  final Color? cursorColor;
  final void Function()? onTap;
  final BorderSide? errorBorderSide;
  final BorderSide? focusedErrorBorderSide;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 100),
      child: TextFormField(
        textAlign: textAlign ?? TextAlign.left,
        focusNode: focusNode,
        maxLength: maxLength,
        maxLines: maxLine,
        expands: expands,
        readOnly: readOnly,
        onTap: onTap,
        autofocus: autofocus,
        inputFormatters: inputFormatters,
        validator: validator,
        onChanged: onChanged,
        obscureText: obscureText,
        onFieldSubmitted: onSubmitted,
        keyboardType: keyboardType,
        controller: controller,
        cursorColor: cursorColor ?? AppColors.primaryColor,
        textInputAction: textInputAction ?? TextInputAction.done,
        textCapitalization: textCapitalization != null
            ? textCapitalization!
            : keyboardType == TextInputType.emailAddress
            ? TextCapitalization.none
            : TextCapitalization.sentences,
        textAlignVertical: TextAlignVertical.top,
        style: textStyle ?? TextStyles.medium(16.sp),
        decoration: InputDecoration(

          
          fillColor: fillColor ?? AppColors.greyF3F4F5,
          filled:  true,
          counterText: '',
          hintText: hintText,
          hintStyle: TextStyles.regular(16.sp, fontColor: AppColors.grey9BA3AA),
          prefixIcon: prefixIcon != null ? SizedBox(height: 24, width: 24, child: Center(child: prefixIcon)) : null,
          suffixIcon: suffixIcon != null ? SizedBox(height: 24, width: 24, child: Center(child: suffixIcon)) : null,

          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent,
            width: 0),borderRadius: BorderRadius.circular(10),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent,
                width: 0),borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent,
                width: 0),borderRadius: BorderRadius.circular(10),
          ),errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent,
              width: 0),borderRadius: BorderRadius.circular(10),
        ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent,
                width: 0),borderRadius: BorderRadius.circular(10),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent,
                width: 0),borderRadius: BorderRadius.circular(10),
          )

            
        ),
      ),
    );
  }
}