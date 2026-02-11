import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../config/theme.dart';
import '../../../services/analytics_service.dart';

/// Revenue chart widget for dashboard
class RevenueChart extends StatelessWidget {
  final RevenueStatistics revenue;

  const RevenueChart({
    Key? key,
    required this.revenue,
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
              'Revenue Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Revenue breakdown by period',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.shade800,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label;
                        switch (group.x.toInt()) {
                          case 0:
                            label = 'Today';
                            break;
                          case 1:
                            label = 'This Week';
                            break;
                          case 2:
                            label = 'This Month';
                            break;
                          case 3:
                            label = 'Total';
                            break;
                          default:
                            label = '';
                        }
                        return BarTooltipItem(
                          '$label\n\$${rod.toY.toStringAsFixed(2)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _getBottomTitles,
                        reservedSize: 42,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: _getLeftTitles,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getMaxY() / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: [
                    _makeGroupData(0, revenue.today, Colors.blue),
                    _makeGroupData(1, revenue.thisWeek, Colors.indigo),
                    _makeGroupData(2, revenue.thisMonth, AppTheme.primaryColor),
                    _makeGroupData(3, revenue.total, AppTheme.successColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _LegendItem(
                  color: Colors.blue,
                  label: 'Today',
                  value: '\$${revenue.today.toStringAsFixed(2)}',
                ),
                _LegendItem(
                  color: Colors.indigo,
                  label: 'This Week',
                  value: '\$${revenue.thisWeek.toStringAsFixed(2)}',
                ),
                _LegendItem(
                  color: AppTheme.primaryColor,
                  label: 'This Month',
                  value: '\$${revenue.thisMonth.toStringAsFixed(2)}',
                ),
                _LegendItem(
                  color: AppTheme.successColor,
                  label: 'Total',
                  value: '\$${revenue.total.toStringAsFixed(2)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    final values = [
      revenue.today,
      revenue.thisWeek,
      revenue.thisMonth,
      revenue.total,
    ];
    final max = values.reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble(); // Add 20% padding
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 40,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Today';
        break;
      case 1:
        text = 'Week';
        break;
      case 2:
        text = 'Month';
        break;
      case 3:
        text = 'Total';
        break;
      default:
        text = '';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(text, style: style),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    
    if (value == 0) {
      return const SizedBox();
    }
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('\$${_formatNumber(value)}', style: style),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

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
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
