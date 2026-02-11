import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import '../../services/upload_service.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final String? productId;
  const ProductFormScreen({Key? key, this.productId}) : super(key: key);

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageController = TextEditingController();
  final _materialsController = TextEditingController();
  final _careController = TextEditingController();
  String? _selectedCategoryId;
  bool _featured = false;
  bool _isLoading = false;
  bool _isUploading = false;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    try {
      setState(() => _isLoading = true);
      final product = await ref
          .read(productServiceProvider)
          .getProduct(widget.productId!);

      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toString();
      _stockController.text = product.stock.toString();
      _imageController.text = product.image;
      _materialsController.text = product.materials ?? '';
      _careController.text = product.care ?? '';
      _selectedCategoryId = product.categoryId;
      _featured = product.featured;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImageFile == null) return;

    try {
      setState(() => _isUploading = true);
      
      final uploadService = ref.read(uploadServiceProvider);
      final result = await uploadService.uploadImage(_selectedImageFile!);
      
      setState(() {
        _imageController.text = result.url;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      try {
        setState(() => _isLoading = true);

        if (widget.productId == null) {
          // Create
          await ref.read(productServiceProvider).createProduct(
            name: _nameController.text,
            description: _descriptionController.text,
            categoryId: _selectedCategoryId!,
            price: double.parse(_priceController.text),
            stock: int.parse(_stockController.text),
            image: _imageController.text,
            materials: _materialsController.text,
            care: _careController.text,
            featured: _featured,
          );
        } else {
          // Update
          await ref.read(productServiceProvider).updateProduct(
            id: widget.productId!,
            name: _nameController.text,
            description: _descriptionController.text,
            categoryId: _selectedCategoryId,
            price: double.parse(_priceController.text),
            stock: int.parse(_stockController.text),
            image: _imageController.text,
            materials: _materialsController.text,
            care: _careController.text,
            featured: _featured,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.productId == null
                  ? 'Product created successfully'
                  : 'Product updated successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          context.go('/products');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    _materialsController.dispose();
    _careController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? 'New Product' : 'Edit Product'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'Enter product name',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter product description',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        hintText: '0.00',
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Price is required';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock',
                        hintText: '0',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Stock is required';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Invalid stock';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Image Upload Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _imageController,
                          decoration: const InputDecoration(
                            labelText: 'Image URL',
                            hintText: 'Enter image URL or upload',
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Image URL is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickImage,
                        icon: _isUploading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.upload_file),
                        label: Text(_isUploading ? 'Uploading...' : 'Upload'),
                      ),
                    ],
                  ),
                  if (_imageController.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _selectedImageFile != null
                            ? Image.file(
                                _selectedImageFile!,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                _imageController.text,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Failed to load image',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              // Dynamic category dropdown
              Consumer(
                builder: (context, ref, child) {
                  final categoriesAsync = ref.watch(categoriesProvider);

                  return categoriesAsync.when(
                    data: (categories) {
                      if (categories.isEmpty) {
                        return Card(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: AppTheme.errorColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No categories available. Please create categories first.',
                                    style: TextStyle(
                                      color: AppTheme.errorColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategoryId = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Category is required';
                          }
                          return null;
                        },
                      );
                    },
                    loading: () => DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        helperText: 'Loading categories...',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    error: (error, stack) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: null,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            errorText: 'Failed to load categories',
                            helperText: error.toString(),
                          ),
                          items: const [],
                          onChanged: null,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(categoriesProvider),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 36),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _materialsController,
                decoration: const InputDecoration(
                  labelText: 'Materials',
                  hintText: 'Enter materials info',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _careController,
                decoration: const InputDecoration(
                  labelText: 'Care Instructions',
                  hintText: 'Enter care instructions',
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Featured Product'),
                value: _featured,
                onChanged: (value) {
                  setState(() => _featured = value ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.backgroundColor,
                          ),
                        ),
                      )
                    : Text(widget.productId == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
