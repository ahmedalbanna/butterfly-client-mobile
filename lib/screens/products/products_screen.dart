import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/product_service.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  late AdminProductsParams _params;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _params = AdminProductsParams();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    final productsAsync = ref.read(adminProductsProvider(_params));
    final products = productsAsync.value;

    if (products != null && products.pagination.page < products.pagination.pages) {
      setState(() {
        _isLoadingMore = true;
        _params = _params.copyWith(page: _params.page + 1);
      });

      // Wait for new data to load
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(adminProductsProvider(_params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products Management'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/products/new'),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _params = _params.copyWith(search: null);
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _params = _params.copyWith(
                    search: value.isEmpty ? null : value,
                    page: 1,
                  );
                });
              },
            ),
          ),

          // Products Table
          Expanded(
            child: productsAsync.when(
              data: (response) {
                if (response.data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Pagination info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${response.data.length} of ${response.pagination.total} products',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Page ${response.pagination.page} of ${response.pagination.pages}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Stock')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: response.data.map((product) {
                      return DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 200,
                              child: Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: product.stock > 0
                                    ? AppTheme.successColor.withOpacity(0.2)
                                    : AppTheme.errorColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${product.stock}',
                                style: TextStyle(
                                  color: product.stock > 0
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(product.category.name)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      context.push('/products/${product.id}/edit'),
                                  color: AppTheme.primaryColor,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _showDeleteConfirmation(
                                    context,
                                    product,
                                  ),
                                  color: AppTheme.errorColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                      ),
                    ),
                    if (_isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AdminProduct product) {
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
                await ref
                    .read(productServiceProvider)
                    .deleteProduct(product.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product deleted successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                  setState(() {});
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
