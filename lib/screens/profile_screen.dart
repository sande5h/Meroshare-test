import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(authProvider).valueOrNull;
    final banksAsync = ref.watch(bankDetailsProvider);
    final myDetailAsync = ref.watch(myDetailProvider);

    if (detail == null) return const SizedBox();
    final my = myDetailAsync.valueOrNull;

    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar + name
          Center(
            child: Column(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: C.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: C.accent.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      detail.name.isNotEmpty ? detail.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: C.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(detail.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text(detail.email,
                    style: const TextStyle(fontSize: 13, color: C.muted)),
              ],
            ),
          ),

          const SectionTitle(title: 'Account Details'),
          _Card(children: [
            InfoTile(label: 'BOID', value: detail.boid),
            const Divider(color: C.border),
            InfoTile(label: 'DP Name', value: detail.dpName),
            const Divider(color: C.border),
            InfoTile(label: 'Account No.', value: detail.clientCode),
            const Divider(color: C.border),
            InfoTile(label: 'Mobile', value: detail.contact),
            const Divider(color: C.border),
            InfoTile(
                label: 'Gender',
                value: _genderLabel(my?.gender.isNotEmpty == true
                    ? my!.gender
                    : detail.gender)),
            const Divider(color: C.border),
            InfoTile(label: 'Address', value: detail.address),
            if (my != null) ...[
              const Divider(color: C.border),
              InfoTile(label: 'Date of Birth', value: my.dob),
              const Divider(color: C.border),
              InfoTile(label: 'Status', value: my.accountStatusFlag),
              const Divider(color: C.border),
              InfoTile(label: 'Account Opened', value: my.accountOpenDate),
              const Divider(color: C.border),
              InfoTile(label: 'Sub Status', value: my.subStatus),
            ],
          ]),

          // Visibility into myDetail load state
          myDetailAsync.when(
            data: (_) => const SizedBox.shrink(),
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Center(
                child: SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: C.accent),
                ),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: C.loss.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: C.loss.withValues(alpha: 0.3)),
                ),
                child: Text('myDetail failed: $e',
                    style: const TextStyle(color: C.loss, fontSize: 11)),
              ),
            ),
          ),

          if (my != null) ...[
            const SectionTitle(title: 'Bank (Primary)'),
            _Card(children: [
              InfoTile(label: 'Bank', value: my.bankName),
              const Divider(color: C.border),
              InfoTile(label: 'Account Number', value: my.accountNumber),
              const Divider(color: C.border),
              InfoTile(label: 'Account Type', value: my.accountType),
              const Divider(color: C.border),
              InfoTile(label: 'Bank Code', value: my.bankCode),
              const Divider(color: C.border),
              InfoTile(label: 'Branch Code', value: my.branchCode),
            ]),

            const SectionTitle(title: 'Citizenship'),
            _Card(children: [
              InfoTile(label: 'Citizenship No.', value: my.citizenshipNumber),
              const Divider(color: C.border),
              InfoTile(label: 'Issued From', value: my.issuedFrom),
              const Divider(color: C.border),
              InfoTile(label: 'Issued Date', value: my.issuedDate),
              const Divider(color: C.border),
              InfoTile(label: 'Father / Mother', value: my.fatherMotherName),
              if (my.grandfatherSpouseName.isNotEmpty) ...[
                const Divider(color: C.border),
                InfoTile(
                    label: 'Grandfather / Spouse',
                    value: my.grandfatherSpouseName),
              ],
            ]),
          ],

          const SectionTitle(title: 'Linked Banks'),
          banksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: C.accent)),
            error: (e, _) => Text('Could not load banks: $e',
                style: const TextStyle(color: C.loss, fontSize: 12)),
            data: (banks) => banks.isEmpty
                ? const Text('No banks linked', style: TextStyle(color: C.muted))
                : _Card(
                    children: banks.map((b) => Column(
                      children: [
                        if (banks.indexOf(b) > 0) const Divider(color: C.border),
                        Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: C.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.account_balance, color: C.blue, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.bankName,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                Text(b.accountNumber,
                                    style: const TextStyle(fontSize: 11, color: C.muted)),
                                if (b.crn.isNotEmpty)
                                  Text('CRN: ${b.crn}',
                                      style: const TextStyle(fontSize: 10, color: C.muted)),
                              ],
                            )),
                          ],
                        ),
                      ],
                    )).toList(),
                  ),
          ),

          const SizedBox(height: 24),
          AppBtn(
            label: 'Logout',
            onTap: () => ref.read(authProvider.notifier).logout(),
            color: C.loss.withValues(alpha: 0.8),
            icon: Icons.logout,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

String _genderLabel(String g) {
  final s = g.trim().toUpperCase();
  if (s == 'M' || s == 'MALE') return 'Male';
  if (s == 'F' || s == 'FEMALE') return 'Female';
  if (s == 'O' || s == 'OTHER') return 'Other';
  return g;
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: C.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: C.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}
