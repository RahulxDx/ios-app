import 'package:flutter/material.dart';

import '../constants/stellantis_colors.dart';

/// Enterprise-style, navy/gray metrics card for AI analysis results.
///
/// IMPORTANT:
/// - Presentation-only widget.
/// - Accepts pre-computed values; does not contain business logic.
class AiMetricsCard extends StatelessWidget {
  final String title;
  final String statusLabel;
  final String statusValue;
  final Color statusColor;

  /// 0..100
  final double confidencePercent;

  final String diagnosisLabel;
  final String diagnosisText;

  final List<String> issues;

  /// Optional equation to display how a number was derived (presentation only).
  /// Example: "Confidence = 0.87 × 100 = 87%"
  final String? equation;

  /// Optional mathematics/summary metrics from backend.
  /// UI-only: pass through values already computed.
  /// Expected keys: confidence_mean, confidence_median, confidence_std_dev,
  /// negative_labels_count, risk_score, total_labels_detected.
  final Map<String, num>? mathematics;

  const AiMetricsCard({
    super.key,
    required this.title,
    required this.statusLabel,
    required this.statusValue,
    required this.statusColor,
    required this.confidencePercent,
    required this.diagnosisLabel,
    required this.diagnosisText,
    this.issues = const [],
    this.equation,
    this.mathematics,
  });

  @override
  Widget build(BuildContext context) {
    final clampedConfidence = confidencePercent.isNaN
        ? 0.0
        : confidencePercent.clamp(0.0, 100.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? StellantisColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StellantisColors.divider),
        boxShadow: const [
          BoxShadow(
            color: StellantisColors.cardShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderRow(
            title: title,
            confidencePercent: clampedConfidence,
          ),
          const SizedBox(height: 16),

          _KpiStrip(
            statusLabel: statusLabel,
            statusValue: statusValue,
            statusColor: statusColor,
            confidencePercent: clampedConfidence,
          ),
          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: clampedConfidence / 100.0,
              minHeight: 10,
              backgroundColor: StellantisColors.stellantisBlue.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(StellantisColors.stellantisBlue),
            ),
          ),

          const SizedBox(height: 20),
          _SectionLabel(text: diagnosisLabel),
          const SizedBox(height: 10),
          Text(
            diagnosisText,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color ?? StellantisColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),

          if (issues.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionLabel(text: 'DETECTED ISSUES'),
            const SizedBox(height: 10),
            ...issues.map((t) => _IssueRow(text: t)),
          ],

          if (mathematics != null && mathematics!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionLabel(text: 'STATISTICAL ANALYSIS'),
            const SizedBox(height: 12),
            _MathGrid(metrics: mathematics!),
          ],
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final String title;
  final double confidencePercent;

  const _HeaderRow({
    required this.title,
    required this.confidencePercent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: StellantisColors.stellantisBlue.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: StellantisColors.stellantisBlue.withValues(alpha: 0.25)),
          ),
          child: const Icon(
            Icons.psychology,
            color: StellantisColors.stellantisBlue,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.titleMedium?.color ?? StellantisColors.deepBlue,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
        _ConfidenceChip(percent: confidencePercent),
      ],
    );
  }
}

class _ConfidenceChip extends StatelessWidget {
  final double percent;

  const _ConfidenceChip({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: StellantisColors.divider),
      ),
      child: Text(
        '${percent.toStringAsFixed(0)}% confident',
        style: TextStyle(
          color: StellantisColors.deepBlue,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _KpiStrip extends StatelessWidget {
  final String statusLabel;
  final String statusValue;
  final Color statusColor;
  final double confidencePercent;

  const _KpiStrip({
    required this.statusLabel,
    required this.statusValue,
    required this.statusColor,
    required this.confidencePercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StellantisColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StellantisColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: _KpiCell(
              label: statusLabel,
              value: statusValue,
              valueColor: statusColor,
              leading: Icon(
                Icons.verified_rounded,
                size: 18,
                color: statusColor,
              ),
            ),
          ),
          Container(width: 1, height: 40, color: StellantisColors.divider),
          Expanded(
            child: _KpiCell(
              label: 'CONFIDENCE',
              value: '${confidencePercent.toStringAsFixed(0)}%',
              valueColor: StellantisColors.stellantisBlue,
              leading: const Icon(
                Icons.analytics_rounded,
                size: 18,
                color: StellantisColors.stellantisBlue,
              ),
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCell extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Widget leading;
  final bool alignEnd;

  const _KpiCell({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.leading,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!alignEnd) ...[
          leading,
          const SizedBox(width: 10),
        ],
        Column(
          crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: StellantisColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        if (alignEnd) ...[
          const SizedBox(width: 10),
          leading,
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: StellantisColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _IssueRow extends StatelessWidget {
  final String text;

  const _IssueRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning_amber_rounded, size: 16, color: StellantisColors.deepBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color ?? StellantisColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EquationRow extends StatelessWidget {
  final String text;

  const _EquationRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StellantisColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: StellantisColors.stellantisBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.functions_rounded, size: 18, color: StellantisColors.deepBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color ?? StellantisColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MathGrid extends StatelessWidget {
  final Map<String, num> metrics;

  const _MathGrid({required this.metrics});

  String _label(String key) {
    switch (key) {
      case 'confidence_mean':
        return 'CONF. MEAN';
      case 'confidence_median':
        return 'CONF. MEDIAN';
      case 'confidence_std_dev':
        return 'STD DEVIATION';
      case 'confidence_min':
        return 'CONF. MIN';
      case 'confidence_max':
        return 'CONF. MAX';
      case 'negative_labels_count':
        return 'NEG. LABELS';
      case 'positive_labels_count':
        return 'POSITIVE LABELS';
      case 'risk_score':
        return 'RISK SCORE';
      case 'total_labels_detected':
        return 'TOTAL LABELS';
      case 'negative_ratio':
        return 'NEGATIVE RATIO';
      default:
        return key
            .replaceAll('_', ' ')
            .toUpperCase();
    }
  }

  String _format(String key, num value) {
    // Percent-like confidence metrics
    if (key.startsWith('confidence_')) {
      return value.toStringAsFixed(1);
    }
    if (key == 'risk_score') {
      return value.toStringAsFixed(1);
    }
    // counts
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    const order = <String>[
      'confidence_mean',
      'confidence_median',
      'confidence_std_dev',
      'risk_score',
      'negative_labels_count',
      'total_labels_detected',
      'confidence_min',
      'confidence_max',
      'positive_labels_count',
      'negative_ratio',
    ];

    final sortedKeys = <String>[...order.where(metrics.containsKey)];
    for (final k in metrics.keys) {
      if (!sortedKeys.contains(k)) sortedKeys.add(k);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StellantisColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: StellantisColors.divider, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final cols = c.maxWidth >= 520 ? 3 : 2;
          final itemWidth = (c.maxWidth - ((cols - 1) * 14)) / cols;

          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final k in sortedKeys)
                SizedBox(
                  width: itemWidth,
                  child: _MathTile(
                    label: _label(k),
                    value: _format(k, metrics[k]!),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MathTile extends StatelessWidget {
  final String label;
  final String value;

  const _MathTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StellantisColors.divider.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: StellantisColors.stellantisBlue.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: StellantisColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: StellantisColors.deepBlue,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}





