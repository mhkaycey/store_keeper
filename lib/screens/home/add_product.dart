import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store_keeper/model/product_model.dart';
import 'package:store_keeper/service/product_services.dart';
import 'package:store_keeper/utils/toast.dart';
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';

class AddProductDialog extends StatefulWidget {
  final Product? product;

  const AddProductDialog({super.key, this.product});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final ProductServices _dbHelper = ProductServices();
  final _formKey = GlobalKey<ShadFormState>();
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productQuantityController = TextEditingController();
  String? _selectedCategory;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _productNameController.text = widget.product!.name;
      _productPriceController.text = widget.product!.price.toStringAsFixed(0);
      _productQuantityController.text = widget.product!.quantity.toString();
      _selectedCategory = widget.product!.category;
      _imagePath = widget.product!.imagePath;
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productPriceController.dispose();
    _productQuantityController.dispose();
    super.dispose();
  }

  void addImage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Text('Add Image'),

          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ShadButton.outline(
                child: const Text('Gallery'),
                onPressed: () {
                  _fromGallery();
                  Navigator.pop(context);
                },
              ),
              ShadButton.outline(
                child: const Text('Camera'),
                onPressed: () {
                  _fromCamera();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showToast(
          context: context,
          toastMessage: e.toString(),
          toastTitle: "Error picking image",
          type: ToastificationType.error,
        );
      }
    }
  }

  Future<void> _fromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        preferredCameraDevice: CameraDevice.front,
      );
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showToast(
          context: context,
          toastMessage: e.toString(),
          toastTitle: "Error capturing image",
          type: ToastificationType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final size = MediaQuery.sizeOf(context);
    final isEditing = widget.product != null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: ShadForm(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 15,
            children: [
              Text(
                isEditing ? 'Edit Product' : 'Add New Product',
                style: theme.textTheme.h3,
              ),

              ShadInputFormField(
                id: 'name',
                label: Text('Product Name', style: theme.textTheme.table),
                controller: _productNameController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),

              ShadInputFormField(
                id: 'price',
                label: Text('Product Price (₦)', style: theme.textTheme.table),
                keyboardType: TextInputType.number,
                controller: _productPriceController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter product price';
                  }
                  return null;
                },
              ),

              SizedBox(
                width: double.infinity,
                child: ShadSelect<String>(
                  placeholder: Text(
                    'Select Category',
                    style: theme.textTheme.table,
                  ),
                  initialValue: _selectedCategory,
                  options: const [
                    ShadOption(
                      value: 'electronics',
                      child: Text('Electronics'),
                    ),
                    ShadOption(value: 'clothing', child: Text('Clothing')),
                    ShadOption(value: 'beverages', child: Text('Beverages')),
                    ShadOption(value: 'wine', child: Text('Wine')),
                    ShadOption(
                      value: 'accessories',
                      child: Text('Accessories'),
                    ),
                    ShadOption(value: 'other', child: Text('Other')),
                  ],
                  selectedOptionBuilder: (context, value) {
                    final labels = {
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
                      _selectedCategory = value;
                    });
                  },
                ),
              ),

              ShadInputFormField(
                id: 'quantity',
                label: Text('Product Quantity', style: theme.textTheme.table),
                keyboardType: TextInputType.number,
                controller: _productQuantityController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Add product quantity';
                  }
                  return null;
                },
              ),

              Row(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: size.height * 0.1,
                      // width: size.width * 0.2,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          _imagePath != null && File(_imagePath!).existsSync()
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_imagePath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                LucideIcons.image,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),

                  ShadButton.outline(
                    onPressed: _isSaving ? null : addImage,
                    child: Text(
                      _imagePath != null ? 'Change Image' : 'Add Image',
                      style: theme.textTheme.table,
                    ),
                  ),
                ],
              ),

              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: ShadButton.outline(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.pop(context),
                      decoration: ShadDecoration(
                        border: ShadBorder.all(
                          color: theme.colorScheme.destructive,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: theme.textTheme.table.copyWith(
                          color: theme.colorScheme.destructive,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ShadButton(
                      onPressed: _isSaving ? null : _saveProduct,
                      child: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              isEditing ? 'Update' : 'Save',
                              style: theme.textTheme.table,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.saveAndValidate()) {
      if (_selectedCategory == null) {
        if (mounted) {
          ToastUtil.showToast(
            context: context,
            toastMessage: 'Please select a category',
            toastTitle: 'Error',
            type: ToastificationType.error,
          );
        }
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        final product = Product(
          id: widget.product?.id ?? Uuid().v4(),
          name: _productNameController.text,
          price: double.parse(_productPriceController.text),
          quantity: int.parse(_productQuantityController.text),
          category: _selectedCategory!,
          imagePath: _imagePath,
          createdAt: widget.product?.createdAt ?? DateTime.now(),
        );

        if (widget.product != null) {
          await _dbHelper.updateProduct(product);
          if (mounted) {
            ToastUtil.showToast(
              context: context,
              toastMessage: "Product updated successfully",
              toastTitle: "Success",
            );
          }
        } else {
          await _dbHelper.addProduct(product);
          log('Product added successfully');
          if (mounted) {
            ToastUtil.showToast(
              context: context,
              toastMessage: "Product added successfully",
              toastTitle: "Success",
            );
          }
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e, s) {
        log(e.toString());
        log(s.toString());
        setState(() {
          _isSaving = false;
        });
        if (mounted) {
          ToastUtil.showToast(
            context: context,
            toastMessage: e.toString(),
            toastTitle: "Error saving product",
            type: ToastificationType.error,
          );
        }
      }
    }
  }
}
