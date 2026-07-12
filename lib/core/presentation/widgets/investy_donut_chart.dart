import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// One slice of an [InvestyDonutChart].
class DonutSegment {
  final String label;
  final double value;
  final Color color;

  const DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

/// Themed donut (part-to-whole, categorical identity) built on fl_chart.
/// Follows the dataviz mark spec: 2px surface gap between fills, thin ring,
/// no titles on the slices (identity lives in the caller's legend — never
/// color-alone). Provide [center] for a hero label inside the hole.
class InvestyDonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final Widget? center;
  final double size;

  const InvestyDonutChart({
    super.key,
    required this.segments,
    this.center,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2, // dataviz: 2px surface gap between fills
              centerSpaceRadius: size * 0.32,
              startDegreeOffset: -90,
              sections: [
                for (final s in segments)
                  PieChartSectionData(
                    value: s.value,
                    color: s.color,
                    radius: size * 0.18,
                    showTitle: false,
                    // 2px surface ring so overlapping marks stay separable
                    borderSide: BorderSide(color: cs.surface, width: 1),
                  ),
              ],
            ),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}
