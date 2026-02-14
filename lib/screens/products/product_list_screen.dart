import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/product_service.dart';
import '../../widgets/custom/index.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final String? categoryId;

  const ProductListScreen({
    Key? key,
    this.categoryId,
  }) : super(key: key);

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  late ProductsParams _params;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _params = ProductsParams(
      categoryId: widget.categoryId,
      limit: 20,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider(_params));
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: LuxeAppBar(
        title: 'Shop Collection',
        leading: const Icon(Icons.arrow_back),
        showDivider: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: SimpleInput(
              controller: _searchController,
              hint: 'Search products...',
              keyboardType: TextInputType.text,
              prefixIcon: Icons.search,
              suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : null,
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

          // Category Filter
          categoriesAsync.when(
            data: (categories) {
              return SizedBox(
                height: 65,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing4,
                    vertical: AppTheme.spacing2,
                  ),
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(
                    width: AppTheme.spacing2,
                  ),
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final isSelected = isAll
                        ? widget.categoryId == null
                        : widget.categoryId == categories[index - 1].id;
                    final label = isAll ? 'All' : categories[index - 1].name;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isAll) {
                            _params = _params.copyWith(
                              categoryId: null,
                              page: 1,
                            );
                          } else {
                            _params = _params.copyWith(
                              categoryId: categories[index - 1].id,
                              page: 1,
                            );
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing4,
                          vertical: AppTheme.spacing2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLarge,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.borderColor,
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? AppTheme.shadowSmall
                              : AppTheme.shadowNone,
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: AppTheme.textTheme.labelLarge?.copyWith(
                              color: isSelected
                                  ? AppTheme.backgroundColor
                                  : AppTheme.textColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox(
              height: 65,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            error: (error, stack) => const SizedBox(height: 65),
          ),

          const SizedBox(height: AppTheme.spacing4),

          // Products Grid
          Expanded(
            child: productsAsync.when(
              data: (response) {
                if (response.data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          'No products found',
                          style: AppTheme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppTheme.spacing3),
                        Text(
                          'Try adjusting your filters or search',
                          style: AppTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacing4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: AppTheme.spacing4,
                    mainAxisSpacing: AppTheme.spacing4,
                  ),
                  itemCount: response.data.length,
                  itemBuilder: (context, index) {
                    final product = response.data[index];
                    return ProductCard(
                      imageUrl: product.image,
                      title: product.name,
                      price: product.price,
                      category: product.category?.name,
                      onTap: () => context.push('/products/${product.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading products',
                  style: AppTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
