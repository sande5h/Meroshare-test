import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioProvider);
    final detail = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: detail != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(detail.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text('${detail.boid} - ${detail.dpName}',
                      style: const TextStyle(fontSize: 11, color: C.muted)),
                ],
              )
            : const Text('Portfolio'),
      ),
      body: portfolioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: C.accent)),
        error: (e, st) => ErrorRetry(
          error: e,
          onRetry: () => ref.invalidate(portfolioProvider),
        ),
        data: (holdings) {
          if (holdings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 56, color: C.muted),
                  SizedBox(height: 16),
                  Text('No holdings found', style: TextStyle(color: C.muted)),
                ],
              ),
            );
          }

          final totalValue = holdings.fold(0.0, (s, h) => s + h.valueOfLastTransPrice);
          final totalPrevValue = holdings.fold(0.0, (s, h) => s + h.valueOfPrevClosingPrice);
          final totalPl = totalValue - totalPrevValue;
          final totalPlPct = totalPrevValue > 0 ? (totalPl / totalPrevValue) * 100 : 0.0;

          return RefreshIndicator(
            color: C.accent,
            backgroundColor: C.surface,
            onRefresh: () async => ref.invalidate(portfolioProvider),
            child: CustomScrollView(
              slivers: [
                // Summary card
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [C.accent.withValues(alpha: 0.1), C.blue.withValues(alpha: 0.05)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: C.accent.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TOTAL PORTFOLIO VALUE',
                            style: TextStyle(fontSize: 10, color: C.muted, letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Rs. ${_fmt(totalValue)}',
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.text),
                            ),
                            const Spacer(),
                            Icon(
                              totalPl >= 0 ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                              color: totalPl >= 0 ? C.profit : C.loss,
                              size: 22,
                            ),
                            Text(
                              'Rs. ${_fmt(totalPl.abs())} (${totalPlPct.abs().toStringAsFixed(2)}%)',
                              style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: totalPl >= 0 ? C.profit : C.loss,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _HoldingCard(holding: holdings[i]),
                      childCount: holdings.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SumStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SumStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, color: C.muted)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    ],
  );
}

class _HoldingCard extends StatelessWidget {
  final dynamic holding;
  const _HoldingCard({required this.holding});

  @override
  Widget build(BuildContext context) {
    final ltp = holding.lastTransactionPrice as double;
    final prevClose = holding.previousClosingPrice as double;
    final priceDiff = ltp - prevClose;
    final pricePct = prevClose > 0 ? (priceDiff / prevClose * 100).abs() : 0.0;
    final isUp = priceDiff >= 0;
    final qty = holding.currentBalance as double;
    final totalValue = holding.valueOfLastTransPrice as double;
    final totalPrev = holding.valueOfPrevClosingPrice as double;
    final totalDiff = totalValue - totalPrev;
    final totalPct = totalPrev > 0 ? (totalDiff / totalPrev * 100).abs() : 0.0;
    final isTotalUp = totalDiff >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border),
      ),
      child: Column(
        children: [
          // Row 1: SCRIPT (Description)              Rs. totalValue
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: holding.script,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    TextSpan(text: ' (${holding.scriptDesc})',
                        style: const TextStyle(fontSize: 11, color: C.muted)),
                  ]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('Rs. ${_fmt(totalValue)}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Qty: N                         ▲ totalDiff (%)
          Row(
            children: [
              Text('Qty: ', style: const TextStyle(fontSize: 12, color: C.muted)),
              Text(
                qty == qty.toInt() ? '${qty.toInt()}' : '$qty',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Icon(
                isTotalUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                color: isTotalUp ? C.profit : C.loss,
                size: 20,
              ),
              Text(
                '${totalDiff.abs().toStringAsFixed(1)} (${totalPct.toStringAsFixed(2)}%)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: isTotalUp ? C.profit : C.loss),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _fmt(double v) {
  final parts = v.toStringAsFixed(2).split('.');
  final intPart = parts[0];
  final decPart = parts[1];
  final isNeg = intPart.startsWith('-');
  final digits = isNeg ? intPart.substring(1) : intPart;
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final pos = digits.length - i;
    if (i > 0 && pos != digits.length && (pos == 3 || (pos > 3 && (pos - 3) % 2 == 0))) {
      buf.write(',');
    }
    buf.write(digits[i]);
  }
  return '${isNeg ? '-' : ''}$buf.$decPart';
}
