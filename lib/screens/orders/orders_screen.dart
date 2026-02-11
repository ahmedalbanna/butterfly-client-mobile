import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/order_service.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  late AdminOrdersParams _params;
  String? _selectedStatus;
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _params = AdminOrdersParams();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
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

    final ordersAsync = ref.read(adminOrdersProvider(_params));
    final orders = ordersAsync.value;

    if (orders != null && orders.pagination.page < orders.pagination.pages) {
      setState(() {
        _isLoadingMore = true;
        _params = _params.copyWith(page: _params.page + 1);
      });

      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider(_params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Management'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Status Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedStatus == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = null;
                        _params = _params.copyWith(status: null);
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Pending'),
                    selected: _selectedStatus == 'pending',
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = 'pending';
                        _params = _params.copyWith(status: 'pending');
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Processing'),
                    selected: _selectedStatus == 'processing',
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = 'processing';
                        _params = _params.copyWith(status: 'processing');
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Shipped'),
                    selected: _selectedStatus == 'shipped',
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = 'shipped';
                        _params = _params.copyWith(status: 'shipped');
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Delivered'),
                    selected: _selectedStatus == 'delivered',
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = 'delivered';
                        _params = _params.copyWith(status: 'delivered');
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Orders Table
          Expanded(
            child: ordersAsync.when(
              data: (response) {
                if (response.data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_outlined,
                          size: 64,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders found',
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
                            'Showing ${response.data.length} of ${response.pagination.total} orders',
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
                      DataColumn(label: Text('Order ID')),
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Total')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Items')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: response.data.map((order) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              order.id.substring(0, 8),
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(order.user.name ?? 'Unknown'),
                                Text(
                                  order.user.email,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text('\$${order.total.toStringAsFixed(2)}')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.statusDisplay,
                                style: TextStyle(
                                  color: _getStatusColor(order.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text('${order.items.length}')),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () =>
                                  context.push('/orders/${order.id}'),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }
}
