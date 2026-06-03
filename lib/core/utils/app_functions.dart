import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluttertoast/fluttertoast.dart' as ftoast;

import 'exports.dart';
import 'package:viteezy/gen/assets.gen.dart';

class AppFunctions {
  showToast(String msg, {Color? textColor, Color? bgColor}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: bgColor ?? Colors.black,
      textColor: textColor ?? Colors.white,
      fontSize: 16.0,
    );

    // return Get.snackbar('sdg', 'sdjfbdjs',
    //
    //
    //   icon: const Icon(Icons.info, color: Colors.white,
    //
    //
    // ),
    //   snackPosition: SnackPosition.BOTTOM,
    // );
  }

  showSnackBar({
    required String title,
    required String message,
    Color? bgColor,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    BuildContext? context,
  }) {
    return Get.snackbar(
      title,
      message,
      titleText: Text(title, style: titleStyle ?? TextStyles.regular(14.sp)),
      messageText: Text(message, style: messageStyle ?? TextStyles.regular(14.sp)),
      icon: const Icon(Icons.info, color: Colors.white),
      mainButton: TextButton(
        onPressed: () {
          Get.back();
        },
        child: Text('Dismiss', style: TextStyles.regular(16.sp)),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: bgColor ?? Colors.green,
      borderRadius: 20,
      margin: const EdgeInsets.all(15),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  void closeKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static void showCustomToast(BuildContext context, {required String message, required bool isSuccess}) {
    final fToast = ftoast.FToast();
    fToast.init(context);

    Widget toast = Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isSuccess ? AppColors.green : AppColors.red,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isSuccess
              ? Assets.icons.icSuccess.svg(
                  width: 20.w,
                  height: 20.h,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                )
              : Assets.icons.icFailed.svg(
                  width: 20.w,
                  height: 20.h,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(message, style: TextStyles.semiBold(14.sp, fontColor: Colors.white)),
          ),
        ],
      ),
    );

    fToast.showToast(child: toast, gravity: ToastGravity.BOTTOM, toastDuration: const Duration(seconds: 3));
  }

  static String formatToIso8601(DateTime date) {
    final utcTime = date.toUtc();
    return "${utcTime.year.toString().padLeft(4, '0')}-${utcTime.month.toString().padLeft(2, '0')}-${utcTime.day.toString().padLeft(2, '0')}T${utcTime.hour.toString().padLeft(2, '0')}:${utcTime.minute.toString().padLeft(2, '0')}:${utcTime.second.toString().padLeft(2, '0')}.000Z";
  }
}
