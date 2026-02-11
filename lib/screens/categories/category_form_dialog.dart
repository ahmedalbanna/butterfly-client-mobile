import 'package:flutter/material.dart';

class CategoryFormDialog extends StatefulWidget {
  final String? categoryId;
  final String? initialName;
  final String? initialSlug;
  final String? initialDescription;
  final int? initialDisplayOrder;

  const CategoryFormDialog({
    Key? key,
    this.categoryId,
    this.initialName,
    this.initialSlug,
    this.initialDescription,
    this.initialDisplayOrder,
  }) : super(key: key);

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _slugController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _displayOrderController;
  bool _autoGenerateSlug = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _slugController = TextEditingController(text: widget.initialSlug ?? '');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
    _displayOrderController = TextEditingController(
      text: (widget.initialDisplayOrder ?? 0).toString(),
    );

    // Only auto-generate for new categories
    _autoGenerateSlug = widget.categoryId == null;

    // Listen for name changes to auto-generate slug
    if (_autoGenerateSlug) {
      _nameController.addListener(_generateSlug);
    }
  }

  void _generateSlug() {
    if (_autoGenerateSlug) {
      final name = _nameController.text;
      final slug = name
          .toLowerCase()
          .trim()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
      _slugController.text = slug;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final result = {
        'name': _nameController.text.trim(),
        'slug': _slugController.text.trim(),
        'description': _descriptionController.text.trim(),
        'displayOrder': int.tryParse(_displayOrderController.text) ?? 0,
      };
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.categoryId != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Category' : 'Create Category'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g., Bags',
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Category name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _slugController,
                decoration: InputDecoration(
                  labelText: 'Slug',
                  hintText: 'e.g., bags',
                  helperText: _autoGenerateSlug
                      ? 'Auto-generated from name'
                      : 'Unique identifier for URL',
                  suffixIcon: widget.categoryId == null
                      ? IconButton(
                          icon: Icon(_autoGenerateSlug
                              ? Icons.auto_awesome
                              : Icons.edit),
                          onPressed: () {
                            setState(() {
                              _autoGenerateSlug = !_autoGenerateSlug;
                              if (_autoGenerateSlug) {
                                _nameController.addListener(_generateSlug);
                                _generateSlug();
                              } else {
                                _nameController.removeListener(_generateSlug);
                              }
                            });
                          },
                          tooltip: _autoGenerateSlug
                              ? 'Manual entry'
                              : 'Auto-generate',
                        )
                      : null,
                ),
                enabled: !_autoGenerateSlug || isEdit,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Slug is required';
                  }
                  if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value!)) {
                    return 'Slug can only contain lowercase letters, numbers, and hyphens';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Brief description of this category',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _displayOrderController,
                decoration: const InputDecoration(
                  labelText: 'Display Order',
                  hintText: '0',
                  helperText: 'Lower numbers appear first',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isNotEmpty ?? false) {
                    if (int.tryParse(value!) == null) {
                      return 'Must be a valid number';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text(isEdit ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
