import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:toastification/toastification.dart';

class ToastUtil {
  static void showToast({
    required String toastMessage,
    toastTitle,
    ToastificationType? type,
    BuildContext? context,
  }) {
    toastification.show(
      title: Text(toastTitle),
      description: RichText(
        text: TextSpan(
          text: toastMessage,
          style: ShadTheme.of(context!).textTheme.table.copyWith(
            fontWeight: FontWeight.w500,
            color: Brightness.light == ShadTheme.of(context).brightness
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
      type: type ?? ToastificationType.success,
      showIcon: true,
      style: ToastificationStyle.flatColored,
      context: context,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
    );
  }
}
