import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.muted),
          Text(
            value,
            style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
