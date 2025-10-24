import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store_keeper/model/product_model.dart';
import 'package:store_keeper/screens/add_product.dart';
import 'package:store_keeper/screens/components/details_row.dart';
import 'package:store_keeper/service/product_services.dart';
import 'package:store_keeper/utils/toast.dart';
import 'package:toastification/toastification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductServices _productServices = ProductServices();
  final _searchController = TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _selectedCategory = 'all';
  bool _isLoading = true;

  // Statistics
  int _totalProducts = 0;
  double _totalValue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _productServices.getAllProducts();
      final stats = await _productServices.getStatistics();

      setState(() {
        _products = products;
        _filteredProducts = products;
        _totalProducts = stats['totalProducts'];
        _totalValue = stats['totalValue'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ToastUtil.showToast(
          context: context,
          toastMessage: e.toString(),
          toastTitle: "Error loading products",
        );
      }
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = product.name.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        );
        final matchesCategory =
            _selectedCategory == 'all' || product.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Store Keeper Inventory',
          style: theme.textTheme.h3.copyWith(
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                offset: const Offset(2, 2),
                blurRadius: 1,
              ),
            ],
          ),
        ),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Statistics Cards
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: LucideIcons.package,
                          title: 'Total Items',
                          value: '$_totalProducts',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: LucideIcons.dollarSign,
                          title: 'Total Value',
                          value:
                              '₦${NumberFormat('#,##0.00').format(_totalValue)}',
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search and Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ShadInput(
                          controller: _searchController,
                          placeholder: const Text('Search products...'),

                          onChanged: (value) {
                            _filterProducts();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      ShadSelect<String>(
                        placeholder: const Text('Category'),
                        minWidth: 150,
                        initialValue: _selectedCategory,
                        options: const [
                          ShadOption(value: 'all', child: Text('All')),
                          ShadOption(
                            value: 'electronics',
                            child: Text('Electronics'),
                          ),
                          ShadOption(
                            value: 'clothing',
                            child: Text('Clothing'),
                          ),
                          ShadOption(
                            value: 'beverages',
                            child: Text('Beverages'),
                          ),
                          ShadOption(value: 'wine', child: Text('Wine')),
                          ShadOption(
                            value: 'accessories',
                            child: Text('Accessories'),
                          ),
                          ShadOption(value: 'other', child: Text('Other')),
                        ],
                        selectedOptionBuilder: (context, value) {
                          final labels = {
                            'all': 'All',
                            'electronics': 'Electronics',
                            'clothing': 'Clothing',
                            'beverages': 'Beverages',
                            'wine': 'Wine',
                            'accessories': 'Accessories',
                            'other': 'Other',
                          };
                          return Text(labels[value]!);
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                          _filterProducts();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Products List
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.packageOpen,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _products.isEmpty
                                    ? 'No products yet'
                                    : 'No matching products',
                                style: theme.textTheme.h4.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _products.isEmpty
                                    ? 'Add your first product to get started'
                                    : 'Try a different search or filter',
                                style: theme.textTheme.muted,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _ProductCard(
                                product: product,
                                onEdit: () =>
                                    _showAddProductDialog(product: product),
                                onDelete: () => _confirmDelete(product),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Product'),
      ),
    );
  }

  void _showAddProductDialog({Product? product}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddProductDialog(product: product),
    );

    if (result == true) {
      _loadProducts();
    }
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _productServices.deleteProduct(product.id);
                _loadProducts();
                if (context.mounted) {
                  ToastUtil.showToast(
                    context: context,
                    toastMessage: "Product deleted successfully",
                    toastTitle: "Success",
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ToastUtil.showToast(
                    toastMessage: e.toString(),
                    toastTitle: "Error deleting product",
                    type: ToastificationType.error,
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.muted),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.h4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
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
      // description: SizedBox.shrink(),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: () => _showProductDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            // Product Image or Icon
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

            // Product Info
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

            // Actions
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
    // final theme = ShadTheme.of(context);

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
