import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Themed single-series line/area chart (change-over-time) built on fl_chart.
/// Single series → no legend (the caller's title names it, per dataviz). Brand
/// gradient area fill, thin 2px line, recessive grid, touch crosshair+tooltip.
class InvestyLineChart extends StatelessWidget {
  final List<double> values;

  /// Formats the y value for the touch tooltip (e.g. currency).
  final String Function(double) tooltipFormat;
  final double height;

  /// Optional dashed horizontal reference line (e.g. your average cost).
  final double? referenceValue;
  final Color? referenceColor;

  const InvestyLineChart({
    super.key,
    required this.values,
    required this.tooltipFormat,
    this.height = 180,
    this.referenceValue,
    this.referenceColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Y-axis is driven by the PRICE only — the reference line never rescales it
    // (a far-off avg cost would otherwise flatten the price curve).
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final pad = (maxV - minV) == 0 ? (maxV.abs() * 0.05 + 1) : (maxV - minV) * 0.12;
    final minY = minV - pad;
    final maxY = maxV + pad;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (values.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxV - minV) == 0 ? null : (maxV - minV) / 3,
            getDrawingHorizontalLine: (_) => FlLine(
              color: cs.onSurfaceVariant.withValues(alpha: 0.12),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          extraLinesData: referenceValue == null
              ? const ExtraLinesData()
              : ExtraLinesData(horizontalLines: [
                  HorizontalLine(
                    // Clamp to the visible range so a far-off cost pins to the
                    // edge (labeled with its real value) instead of rescaling.
                    y: referenceValue!.clamp(minY, maxY),
                    color: referenceColor ?? cs.onSurfaceVariant,
                    strokeWidth: 1.5,
                    dashArray: const [6, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 4, bottom: 2),
                      labelResolver: (_) => tooltipFormat(referenceValue!),
                      style: TextStyle(
                        color: referenceColor ?? cs.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ]),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => cs.surfaceContainerHighest,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        tooltipFormat(s.y),
                        TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ))
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: AppTheme.brandPurple,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.brandPurple.withValues(alpha: 0.28),
                    AppTheme.brandPurple.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
