import 'package:flutter/material.dart';
import 'package:viteezy/core/theme/app_colors.dart';

import '../utils/app_constant.dart';

class TextStyles {
  /* -------------------------------------------------------------------------- */
  /*                            EXTRA-BOLD TEXT STYLE                           */
  /* -------------------------------------------------------------------------- */

  static TextStyle extraBold(
    double fontSize, {
    Color? fontColor = AppColors.textPrimary,
    TextOverflow? textOverflow,
    String? fontFamily,
    FontWeight? fontWeight,
    TextDecoration? textDecoration,
  }) {
    return
      TextStyle(
      color: fontColor,
      fontSize: fontSize,
      fontFamily: fontFamily ?? saansTrial,
      fontWeight: fontWeight ?? FontWeight.w800,
      overflow: textOverflow,
      decoration: textDecoration,
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                               BOLD TEXT STYLE                              */
  /* -------------------------------------------------------------------------- */

  static TextStyle bold(
    double fontSize, {
    Color? fontColor = AppColors.textPrimary,
    TextOverflow? textOverflow,
    String? fontFamily,
    FontWeight? fontWeight,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: fontColor,
      fontSize: fontSize,
      fontFamily: fontFamily ?? saansTrial,
      fontWeight: fontWeight ?? FontWeight.bold,
      overflow: textOverflow,
      decoration: textDecoration,
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                            SEMI-BOLD TEXT STYLE                            */
  /* -------------------------------------------------------------------------- */

  static TextStyle semiBold(
    double fontSize, {
    Color? fontColor = AppColors.textPrimary,
    TextOverflow? textOverflow,
    String? fontFamily,
    FontWeight? fontWeight,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: fontColor,
      fontSize: fontSize,
      fontFamily: fontFamily ?? saansTrial,
      fontWeight: fontWeight ?? FontWeight.w600,
      overflow: textOverflow,
      decoration: textDecoration,
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                              MEDIUM TEXT STYLE                             */
  /* -------------------------------------------------------------------------- */

  static TextStyle medium(
    double fontSize, {
    Color? fontColor = AppColors.textPrimary,
    TextOverflow? textOverflow,
    String? fontFamily,
    FontWeight? fontWeight,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: fontColor,
      fontSize: fontSize,
      fontFamily: fontFamily ?? saansTrial,
      fontWeight: fontWeight ?? FontWeight.w500,
      overflow: textOverflow,
      decoration: textDecoration,
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                             REGULAR TEXT STYLE                             */
  /* -------------------------------------------------------------------------- */

  static TextStyle regular(
    double fontSize, {
    Color? fontColor = AppColors.textPrimary,
    TextOverflow? textOverflow,
    String? fontFamily,
    FontWeight? fontWeight,
    TextDecoration? textDecoration,
    double? letterSpacing,
  }) {
    return TextStyle(
      color: fontColor,
      fontSize: fontSize,
      fontFamily: fontFamily ?? saansTrial,
      fontWeight: fontWeight ?? FontWeight.w400,
      overflow: textOverflow,
      decoration: textDecoration,
      letterSpacing: letterSpacing,
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                              LIGHT TEXT STYLE                              */
  /* -------------------------------------------------------------------------- */

  static TextStyle light(
    double fontSize, {
    Color? fontColor = AppColors.textPrimary,
    TextOverflow? textOverflow,
    String? fontFamily,
    FontWeight? fontWeight,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: fontColor,
      fontSize: fontSize,
      fontFamily: fontFamily ?? saansTrial,
      fontWeight: fontWeight ?? FontWeight.w300,
      overflow: textOverflow,
      decoration: textDecoration,
    );
  }
}
