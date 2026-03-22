import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/utils/gpa_calculator.dart';
import 'package:unigpa/core/widgets/app_card.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/data/models/subject.dart';

class _ChartData {
  const _ChartData({required this.label, required this.gpa});
  final String label;
  final double gpa;
}

class SemesterGpaChart extends StatelessWidget {
  const SemesterGpaChart({
    super.key,
    required this.subjects,
    required this.grades,
  });

  final List<Subject> subjects;
  final List<Grade> grades;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final data = _buildData();
    if (data.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GPA theo học kỳ',
            style: AppTextStyles.headingSmall.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final minWidth = data.length * 80.0;
              final width = minWidth > constraints.maxWidth
                  ? minWidth
                  : constraints.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  height: 180,
                  child: Stack(
                    children: [
                      BarChart(_buildBarChartData(colors, data)),

                      LineChart(_buildLineChartData(colors, data)),
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
      maxY: 4.2,
      minY: 0,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: colors.divider, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 28,
            getTitlesWidget: (v, _) {
              if (v % 1 != 0) return const SizedBox.shrink();
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
              if (idx < 0 || idx >= data.length) {
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
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: data.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final color = AppColors.gpaColor(item.gpa).withValues(alpha: 0.35);
        return BarChartGroupData(
          x: idx,
          barRods: [
            BarChartRodData(
              toY: item.gpa,
              color: color,
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        );
      }).toList(),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, _, rod, _) => BarTooltipItem(
            data[group.x].label.replaceAll('\n', ' - '),
            AppTextStyles.labelMedium.copyWith(color: Colors.white),
            children: [
              TextSpan(
                text: '\nGPA: ${rod.toY.toStringAsFixed(2)}',
                style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
              ),
            ],
          ),
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
      maxY: 4.2,
      minX: -0.5,
      maxX: data.isNotEmpty ? (data.length - 0.5) : 0,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 28,
            getTitlesWidget: (v, _) {
              if (v % 1 != 0) return const SizedBox.shrink();
              return Opacity(
                opacity: 0,
                child: Text(
                  v.toInt().toString(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
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
              if (idx < 0 || idx >= data.length) {
                return const SizedBox.shrink();
              }
              return Opacity(
                opacity: 0,
                child: Padding(
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
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineTouchData: const LineTouchData(enabled: false),
      lineBarsData: [
        LineChartBarData(
          spots: data.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.gpa);
          }).toList(),
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: colors.surface,
              );
            },
          ),
        ),
      ],
    );
  }

  List<_ChartData> _buildData() {
    final Map<String, List<Subject>> grouped = {};
    for (final subject in subjects) {
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

    return entries.where((e) => e.value.any((s) => s.finalPoint10 != null)).map(
      (e) {
        final gpa = GpaCalculator.calculateForSemester(
          semesterSubjects: e.value,
          grades: grades,
        );
        return _ChartData(label: e.key, gpa: gpa);
      },
    ).toList();
  }
}
