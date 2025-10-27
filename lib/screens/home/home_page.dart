import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store_keeper/screens/home/components/product_card.dart';
import 'package:store_keeper/screens/home/components/stat_card.dart';
import 'package:toastification/toastification.dart';

import 'package:store_keeper/model/product_model.dart';
import 'package:store_keeper/screens/home/add_product.dart';
import 'package:store_keeper/service/product_services.dart';
import 'package:store_keeper/utils/toast.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  HomePage({super.key, required this.themeToggle, required this.isDarkMode});
  final Function() themeToggle;
  bool isDarkMode = false;

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
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? LucideIcons.sun : LucideIcons.moon),
            onPressed: () => widget.themeToggle(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: LucideIcons.package,
                          title: 'Total Items',
                          value: '$_totalProducts',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
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
                              child: ProductCard(
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (context) => SafeArea(child: AddProductDialog(product: product)),
    );

    log("result: $result");

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
