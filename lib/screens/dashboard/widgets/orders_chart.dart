import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../config/theme.dart';
import '../../../services/analytics_service.dart';

/// Orders trend chart widget for dashboard
class OrdersChart extends StatelessWidget {
  final OrderStatistics orders;

  const OrdersChart({
    Key? key,
    required this.orders,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders by Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Distribution of orders across all statuses',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 60,
                        sections: _getSections(),
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegendItem(
                          color: Colors.orange,
                          label: 'Pending',
                          value: orders.pending,
                        ),
                        const SizedBox(height: 8),
                        _LegendItem(
                          color: Colors.blue,
                          label: 'Processing',
                          value: orders.processing,
                        ),
                        const SizedBox(height: 8),
                        _LegendItem(
                          color: Colors.indigo,
                          label: 'Shipped',
                          value: orders.shipped,
                        ),
                        const SizedBox(height: 8),
                        _LegendItem(
                          color: AppTheme.successColor,
                          label: 'Delivered',
                          value: orders.delivered,
                        ),
                        const SizedBox(height: 8),
                        _LegendItem(
                          color: AppTheme.errorColor,
                          label: 'Cancelled',
                          value: orders.cancelled,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Orders',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${orders.total}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    final total = orders.total - orders.cancelled; // Exclude cancelled for percentage
    
    return [
      PieChartSectionData(
        color: Colors.orange,
        value: orders.pending.toDouble(),
        title: '${_getPercentage(orders.pending, total)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: orders.processing.toDouble(),
        title: '${_getPercentage(orders.processing, total)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.indigo,
        value: orders.shipped.toDouble(),
        title: '${_getPercentage(orders.shipped, total)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: AppTheme.successColor,
        value: orders.delivered.toDouble(),
        title: '${_getPercentage(orders.delivered, total)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      if (orders.cancelled > 0)
        PieChartSectionData(
          color: AppTheme.errorColor,
          value: orders.cancelled.toDouble(),
          title: '${_getPercentage(orders.cancelled, orders.total)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    ];
  }

  int _getPercentage(int value, int total) {
    if (total == 0) return 0;
    return ((value / total) * 100).round();
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({
    Key? key,
    required this.color,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Text(
          '$value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
