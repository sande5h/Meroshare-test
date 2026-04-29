import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class IpoScreen extends ConsumerStatefulWidget {
  const IpoScreen({super.key});

  @override
  ConsumerState<IpoScreen> createState() => _IpoScreenState();
}

class _IpoScreenState extends ConsumerState<IpoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Text('IPO / FPO'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: C.accent,
          labelColor: C.accent,
          unselectedLabelColor: C.muted,
          tabs: const [Tab(text: 'Open Issues'), Tab(text: 'My Applications')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [_OpenIssuesTab(), _AppliedTab()],
      ),
    );
  }
}

// ── Open Issues ──────────────────────────────────────────────
class _OpenIssuesTab extends ConsumerWidget {
  const _OpenIssuesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(openIssuesProvider);

    return issuesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: C.accent)),
      error: (e, _) => ErrorRetry(
        error: e,
        onRetry: () => ref.invalidate(openIssuesProvider),
      ),
      data: (issues) {
        if (issues.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 56, color: C.muted),
                SizedBox(height: 16),
                Text('No open IPOs right now', style: TextStyle(color: C.muted)),
              ],
            ),
          );
        }

        bool isReserved(OpenIssue i) {
          final t = i.shareTypeName.toLowerCase();
          final g = i.shareGroupName.toLowerCase();
          return t.contains('reserve') || g.contains('reserve');
        }

        final applyFor = issues.where((i) => !isReserved(i)).toList();
        final current = issues.where(isReserved).toList();

        return RefreshIndicator(
          color: C.accent,
          backgroundColor: C.surface,
          onRefresh: () async => ref.invalidate(openIssuesProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              SectionTitle(title: 'Apply for Issue', trailing: '${applyFor.length}'),
              if (applyFor.isEmpty)
                const _EmptySection(text: 'No issues open to apply')
              else
                ...applyFor.map((i) => _IssueCard(issue: i)),
              SectionTitle(title: 'Current Issue', trailing: '${current.length} reserved'),
              if (current.isEmpty)
                const _EmptySection(text: 'No reserved issues')
              else
                ...current.map((i) => _IssueCard(issue: i)),
            ],
          ),
        );
      },
    );
  }
}

class _IssueCard extends ConsumerWidget {
  final OpenIssue issue;
  const _IssueCard({required this.issue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        StatusChip(label: issue.shareTypeName, color: C.accent),
                        const SizedBox(width: 6),
                        StatusChip(label: issue.shareGroupName, color: C.blue),
                      ]),
                      const SizedBox(height: 8),
                      Text(issue.companyName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      if (issue.scrip.isNotEmpty)
                        Text(issue.scrip,
                            style: const TextStyle(fontSize: 12, color: C.muted)),
                    ],
                  ),
                ),
                StatusChip(label: issue.status, color: C.profit),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: C.surface2,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Expanded(child: _IpoStat('PRICE', 'Rs. ${issue.issuePrice.toStringAsFixed(0)}')),
                Expanded(child: _IpoStat('MIN KITTA', '${issue.minUnit.toInt()}')),
                TextButton.icon(
                  onPressed: () => _showApplySheet(context, ref, issue),
                  icon: const Icon(Icons.flash_on, color: C.accent, size: 16),
                  label: const Text('Apply', style: TextStyle(color: C.accent, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showApplySheet(BuildContext ctx, WidgetRef ref, OpenIssue issue) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ApplySheet(ref: ref, issue: issue),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String text;
  const _EmptySection({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.border),
        ),
        child: Center(
          child: Text(text,
              style: const TextStyle(color: C.muted, fontSize: 12)),
        ),
      );
}

class _IpoStat extends StatelessWidget {
  final String label;
  final String value;
  const _IpoStat(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 9, color: C.muted, letterSpacing: 1)),
      const SizedBox(height: 3),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    ],
  );
}

// ── Apply Sheet ──────────────────────────────────────────────
class _ApplySheet extends StatefulWidget {
  final WidgetRef ref;
  final OpenIssue issue;
  const _ApplySheet({required this.ref, required this.issue});

  @override
  State<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends State<_ApplySheet> {
  final _pinCtrl = TextEditingController();
  int _kitta = 10;
  BankDetail? _selectedBank;
  bool _loading = false;
  String? _resultMsg;
  bool _success = false;

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    if (_selectedBank == null) {
      _show('Select a bank account');
      return;
    }
    if (_pinCtrl.text.length != 4) {
      _show('Enter your 4-digit transaction PIN');
      return;
    }
    setState(() => _loading = true);
    try {
      final detail = widget.ref.read(authProvider).valueOrNull;
      final api = widget.ref.read(apiProvider);
      final res = await api.applyIpo(
        companyShareId: widget.issue.id,
        crn: _selectedBank!.crn,
        boid: detail?.boid ?? '',
        kitta: _kitta,
        transactionPin: _pinCtrl.text,
        bankId: _selectedBank!.id,
        accountNumber: _selectedBank!.accountNumber,
      );
      setState(() {
        _success = true;
        _resultMsg = res['message'] ?? 'Application submitted successfully!';
      });
      widget.ref.invalidate(appliedIposProvider);
    } catch (e) {
      setState(() {
        _success = false;
        _resultMsg = e.toString().contains('DioException')
            ? 'Application failed. Check your PIN and bank details.'
            : e.toString();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: C.orange));
  }

  @override
  Widget build(BuildContext context) {
    final banksAsync = widget.ref.watch(bankDetailsProvider);

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.border),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _resultMsg != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_success ? Icons.check_circle : Icons.error,
                      color: _success ? C.profit : C.loss, size: 52),
                  const SizedBox(height: 12),
                  Text(_resultMsg!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _success ? C.profit : C.loss, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close', style: TextStyle(color: C.accent)),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Apply — ${widget.issue.companyName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Price: Rs. ${widget.issue.issuePrice.toStringAsFixed(0)} • Min: ${widget.issue.minUnit.toInt()} kitta',
                      style: const TextStyle(fontSize: 12, color: C.muted)),
                  const SizedBox(height: 20),

                  // Kitta selector
                  const Text('KITTA', style: TextStyle(fontSize: 10, color: C.muted, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _kitta > widget.issue.minUnit.toInt()
                            ? () => setState(() => _kitta -= 10)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline, color: C.accent),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: C.surface2,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: C.border),
                          ),
                          child: Text('$_kitta kitta',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _kitta += 10),
                        icon: const Icon(Icons.add_circle_outline, color: C.accent),
                      ),
                    ],
                  ),
                  Text('Total: Rs. ${(_kitta * widget.issue.issuePrice).toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12, color: C.muted)),

                  const SizedBox(height: 16),
                  const Text('BANK ACCOUNT', style: TextStyle(fontSize: 10, color: C.muted, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  banksAsync.when(
                    loading: () => const CircularProgressIndicator(color: C.accent),
                    error: (e, _) => Text('Could not load banks: $e',
                        style: const TextStyle(color: C.loss, fontSize: 12)),
                    data: (banks) => banks.isEmpty
                        ? const Text('No bank accounts linked',
                            style: TextStyle(color: C.muted, fontSize: 12))
                        : DropdownButtonFormField<BankDetail>(
                            isExpanded: true,
                            value: _selectedBank,
                            dropdownColor: C.surface2,
                            style: const TextStyle(color: C.text, fontSize: 13),
                            decoration: InputDecoration(
                              filled: true, fillColor: C.surface2,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: C.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: C.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: C.accent),
                              ),
                            ),
                            hint: const Text('Select bank'),
                            items: banks.map((b) => DropdownMenuItem(
                              value: b,
                              child: Text('${b.bankName} - ${b.accountNumber}',
                                  overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: (v) => setState(() => _selectedBank = v),
                          ),
                  ),

                  const SizedBox(height: 16),
                  const Text('TRANSACTION PIN', style: TextStyle(fontSize: 10, color: C.muted, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _pinCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    style: const TextStyle(color: C.text, letterSpacing: 8, fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: '• • • •',
                      counterText: '',
                    ),
                  ),

                  const SizedBox(height: 20),
                  AppBtn(
                    label: 'Submit Application',
                    onTap: _apply,
                    loading: _loading,
                    icon: Icons.send,
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Applied Tab ──────────────────────────────────────────────
enum _AppliedFilter { all, allotted, notAllotted, verified, rejected }

class _AppliedTab extends ConsumerStatefulWidget {
  const _AppliedTab();

  @override
  ConsumerState<_AppliedTab> createState() => _AppliedTabState();
}

class _AppliedTabState extends ConsumerState<_AppliedTab> {
  _AppliedFilter _filter = _AppliedFilter.all;

  bool _matches(AppliedIpo item) {
    final s = item.statusName.toLowerCase();
    switch (_filter) {
      case _AppliedFilter.all:
        return true;
      case _AppliedFilter.allotted:
        return item.isAllotted;
      case _AppliedFilter.notAllotted:
        return s.contains('not allot');
      case _AppliedFilter.verified:
        return s.contains('verif');
      case _AppliedFilter.rejected:
        return s.contains('reject');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appliedAsync = ref.watch(appliedIposProvider);

    return appliedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: C.accent)),
      error: (e, _) => ErrorRetry(
        error: e,
        onRetry: () => ref.invalidate(appliedIposProvider),
      ),
      data: (applied) {
        if (applied.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 56, color: C.muted),
                SizedBox(height: 16),
                Text('No IPO applications yet', style: TextStyle(color: C.muted)),
              ],
            ),
          );
        }

        final allCount = applied.length;
        final allottedCount = applied.where((e) => e.isAllotted).length;
        final notAllottedCount = applied
            .where((e) => e.statusName.toLowerCase().contains('not allot'))
            .length;
        final verifiedCount = applied
            .where((e) => e.statusName.toLowerCase().contains('verif'))
            .length;
        final rejectedCount = applied
            .where((e) => e.statusName.toLowerCase().contains('reject'))
            .length;
        final filtered = applied.where(_matches).toList();

        return RefreshIndicator(
          color: C.accent,
          backgroundColor: C.surface,
          onRefresh: () async => ref.invalidate(appliedIposProvider),
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  children: [
                    _FilterChip(
                      label: 'All',
                      count: allCount,
                      selected: _filter == _AppliedFilter.all,
                      color: C.accent,
                      onTap: () => setState(() => _filter = _AppliedFilter.all),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Verified',
                      count: verifiedCount,
                      selected: _filter == _AppliedFilter.verified,
                      color: C.blue,
                      onTap: () => setState(() => _filter = _AppliedFilter.verified),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Allotted',
                      count: allottedCount,
                      selected: _filter == _AppliedFilter.allotted,
                      color: C.profit,
                      onTap: () => setState(() => _filter = _AppliedFilter.allotted),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Rejected',
                      count: rejectedCount,
                      selected: _filter == _AppliedFilter.rejected,
                      color: C.orange,
                      onTap: () => setState(() => _filter = _AppliedFilter.rejected),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Not Allotted',
                      count: notAllottedCount,
                      selected: _filter == _AppliedFilter.notAllotted,
                      color: C.loss,
                      onTap: () => setState(() => _filter = _AppliedFilter.notAllotted),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('No applications match this filter',
                            style: TextStyle(color: C.muted)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _AppliedCard(item: filtered[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : C.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : C.border,
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? color : C.muted,
          ),
        ),
      ),
    );
  }
}

class _AppliedCard extends StatelessWidget {
  final AppliedIpo item;
  const _AppliedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isAllotted = item.isAllotted;
    final isNotAllotted = item.statusName.toLowerCase().contains('not allot');
    final statusColor = isAllotted ? C.profit : isNotAllotted ? C.loss : C.muted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAllotted ? C.profit.withValues(alpha: 0.3) : C.border,
        ),
      ),
      child: Row(
        children: [
          if (isAllotted) ...[
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: statusColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.companyName,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text('${item.scrip} • ${item.shareTypeName}',
                    style: const TextStyle(fontSize: 11, color: C.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(isAllotted
                      ? '${item.receivedKitta}/${item.appliedKitta} kitta'
                      : '${item.appliedKitta} kitta',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              StatusChip(label: _friendlyStatus(item.statusName), color: statusColor),
            ],
          ),
        ],
      ),
    );
  }
}

String _friendlyStatus(String raw) {
  final lower = raw.toLowerCase();
  if (lower == 'alloted' || lower == 'allotted') return 'Allotted';
  if (lower == 'not alloted' || lower == 'not allotted') return 'Not Allotted';
  if (lower == 'verified') return 'Verified';
  if (lower.contains('success')) return 'Applied';
  return raw.replaceAll('_', ' ');
}
