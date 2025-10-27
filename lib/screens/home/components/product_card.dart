import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store_keeper/model/product_model.dart';
import 'package:store_keeper/screens/home/components/details_row.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final categoryIcons = {
      'electronics': LucideIcons.laptop,
      'clothing': LucideIcons.shirt,
      'beverages': LucideIcons.coffee,
      'wine': LucideIcons.wine,
      'accessories': LucideIcons.watch,
      'other': LucideIcons.package,
    };

    final categoryLabels = {
      'electronics': 'Electronics',
      'clothing': 'Clothing',
      'beverages': 'Beverages',
      'wine': 'Wine',
      'accessories': 'Accessories',
      'other': 'Other',
    };

    return ShadCard(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: () => _showProductDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  product.imagePath != null &&
                      File(product.imagePath!).existsSync()
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(product.imagePath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      categoryIcons[product.category] ?? LucideIcons.package,
                      color: theme.colorScheme.primary,
                      size: 30,
                    ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.h4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categoryLabels[product.category] ?? 'Other',
                    style: theme.textTheme.muted,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₦${NumberFormat('#,##0.00').format(product.price)}',
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: product.quantity < 10
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Qty: ${product.quantity}',
                          style: theme.textTheme.small.copyWith(
                            color: product.quantity < 10
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.pencil, size: 18),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 18,
                    color: theme.colorScheme.destructive,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context) {
    showShadDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ShadDialog.alert(
        padding: const EdgeInsets.all(16),
        title: Text('Product Details'),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.imagePath != null &&
                  File(product.imagePath!).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(product.imagePath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              if (product.imagePath != null &&
                  File(product.imagePath!).existsSync())
                const SizedBox(height: 16),
              DetailRow(
                label: 'Price',
                value: '₦${NumberFormat('#,##0.00').format(product.price)}',
              ),
              DetailRow(label: 'Quantity', value: '${product.quantity}'),
              DetailRow(label: 'Category', value: product.category),
              DetailRow(
                label: 'Total Value',
                value:
                    '₦${NumberFormat('#,##0.00').format(product.price * product.quantity)}',
              ),
              DetailRow(
                label: 'Added',
                value: DateFormat('MMM dd, yyyy').format(product.createdAt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
