import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/features/grades/providers/grades_provider.dart';
import 'package:unigpa/core/widgets/app_card.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/data/models/subject.dart';

class _ChartData {
  const _ChartData({
    required this.label,
    required this.gpa,
    required this.avg10,
  });
  final String label;
  final double gpa;
  final double avg10;
}

class SemesterGpaChart extends StatefulWidget {
  const SemesterGpaChart({
    super.key,
    required this.subjects,
    required this.grades,
  });

  final List<Subject> subjects;
  final List<Grade> grades;

  @override
  State<SemesterGpaChart> createState() => _SemesterGpaChartState();
}

class _SemesterGpaChartState extends State<SemesterGpaChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final data = _buildData(context);
    if (data.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thống kê học kỳ',
                style: AppTextStyles.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              Row(
                children: [
                  _LegendItem(
                    label: 'GPA',
                    color: AppColors.primary.withValues(alpha: 0.35),
                    isSquare: true,
                  ),
                  const SizedBox(width: 12),
                  _LegendItem(
                    label: 'TB',
                    color: AppColors.accent,
                    isSquare: false,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final minWidth = data.length * 84.0;
              final width = minWidth > constraints.maxWidth
                  ? minWidth
                  : constraints.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  height: 480,
                  child: Stack(
                    children: [
                      IgnorePointer(
                        child: LineChart(_buildLineChartData(colors, data)),
                      ),
                      BarChart(_buildBarChartData(colors, data)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  BarChartData _buildBarChartData(AppColorsData colors, List<_ChartData> data) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 10.5,
      minY: 0,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: colors.divider.withValues(alpha: 0.5), strokeWidth: 1),
        checkToShowHorizontalLine: (value) => value <= 10,
      ),
      borderData: FlBorderData(show: false),
      titlesData: _buildTitlesData(colors, data, showXLabels: true),
      barGroups: data.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final isTouched = _touchedIndex == idx;
        return BarChartGroupData(
          x: idx,
          showingTooltipIndicators: isTouched ? [0] : [],
          barRods: [
            BarChartRodData(
              toY: item.gpa,
              color: isTouched 
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : AppColors.primary.withValues(alpha: 0.35),
              width: 22,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 10,
                color: Colors.transparent,
              ),
            ),
          ],
        );
      }).toList(),
      barTouchData: BarTouchData(
        handleBuiltInTouches: true,
        touchCallback: (event, response) {
          if (!event.isInterestedForInteractions ||
              response == null ||
              response.spot == null) {
            setState(() => _touchedIndex = null);
            return;
          }
          setState(() => _touchedIndex = response.spot!.touchedBarGroupIndex);
        },
        touchTooltipData: BarTouchTooltipData(
          // ignore: deprecated_member_use
          tooltipBgColor: AppColors.primary.withValues(alpha: 0.9),
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tooltipMargin: 8,
          getTooltipItem: (group, _, rod, _) {
            final item = data[group.x];
            return BarTooltipItem(
              '',
              AppTextStyles.labelMedium.copyWith(color: Colors.white),
              children: [
                TextSpan(
                  text: 'GPA: ${item.gpa.toStringAsFixed(2)}\n',
                  style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
                ),
                TextSpan(
                  text: 'TB: ${item.avg10.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  LineChartData _buildLineChartData(
    AppColorsData colors,
    List<_ChartData> data,
  ) {
    return LineChartData(
      minY: 0,
      maxY: 10.5,
      minX: -0.5,
      maxX: data.isNotEmpty ? (data.length - 0.5) : 0,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: _buildTitlesData(colors, data, showXLabels: false),
      lineTouchData: const LineTouchData(enabled: false),
      lineBarsData: [
        LineChartBarData(
          spots: data.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.avg10);
          }).toList(),
          isCurved: false,
          color: AppColors.accent,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.accent,
                strokeWidth: 2,
                strokeColor: colors.surface,
              );
            },
          ),
        ),
      ],
    );
  }

  FlTitlesData _buildTitlesData(
    AppColorsData colors,
    List<_ChartData> data, {
    required bool showXLabels,
  }) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 28,
          getTitlesWidget: (v, _) {
            if (v > 10 || !showXLabels) return const SizedBox.shrink();
            return Text(
              v.toInt().toString(),
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 42,
          getTitlesWidget: (v, _) {
            final idx = v.toInt();
            if (idx < 0 || idx >= data.length || !showXLabels) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                data[idx].label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                  fontSize: 10,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<_ChartData> _buildData(BuildContext context) {
    final provider = context.read<GradesProvider>();
    final Map<String, List<Subject>> grouped = {};
    for (final subject in widget.subjects) {
      final key =
          '${subject.semester.year.start}-${subject.semester.year.end}.${subject.semester.semester}';
      grouped.putIfAbsent(key, () => []).add(subject);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) {
        final yearDiff = a.value.first.semester.year.start.compareTo(
          b.value.first.semester.year.start,
        );
        return yearDiff != 0
            ? yearDiff
            : a.value.first.semester.semester.compareTo(
                b.value.first.semester.semester,
              );
      });

    final data = <_ChartData>[];
    for (final entry in entries) {
      final gpa = provider.calculateGPA(entry.value);
      final avg10 = provider.calculateAvg10(entry.value);
      if (gpa != null && avg10 != null) {
        data.add(_ChartData(label: entry.key, gpa: gpa, avg10: avg10));
      }
    }
    return data;
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.color,
    required this.isSquare,
  });
  final String label;
  final Color color;
  final bool isSquare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: isSquare ? 12 : 16,
          height: isSquare ? 12 : 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: context.colors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
