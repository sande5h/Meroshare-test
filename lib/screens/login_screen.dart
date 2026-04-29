import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _userCtrl = TextEditingController(text: '777632');
  final _passCtrl = TextEditingController();
  CapitalItem? _selectedDp;
  bool _obscure = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_selectedDp == null) {
      _snack('Please select your DP / broker');
      return;
    }
    if (_userCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      _snack('Enter username and password');
      return;
    }
    await ref.read(authProvider.notifier).login(
          clientId: _selectedDp!.id,
          username: _userCtrl.text.trim(),
          password: _passCtrl.text,
          capitalName: _selectedDp!.name,
        );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: C.orange));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    // Pre-select default DP (Nabil Investment Banking Ltd., id 10400).
    // Use both ref.listen (fires on async load) and a direct read of the
    // current value (handles already-cached data after logout/re-entry).
    void applyDefault(List<CapitalItem> capitals) {
      if (_selectedDp != null) return;
      final def = capitals.where((c) => c.id == 10400).firstOrNull ??
          capitals.where((c) =>
              c.name.toLowerCase().contains('nabil investment')).firstOrNull;
      if (def != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedDp == null) {
            setState(() => _selectedDp = def);
          }
        });
      }
    }

    ref.listen(capitalsProvider, (_, next) {
      next.whenOrNull(data: applyDefault);
    });
    ref.read(capitalsProvider).whenOrNull(data: applyDefault);

    // Always keep the username prefilled with the default account
    if (_userCtrl.text.isEmpty) _userCtrl.text = '777632';

    // Show error snackbar on failure
    ref.listen(authProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) {
          String msg = e.toString();
          if (msg.contains('401') || msg.contains('Unauthorized')) {
            msg = 'Invalid username or password';
          } else if (msg.contains('SocketException') || msg.contains('Failed host')) {
            msg = 'No internet / cannot reach CDSC server';
          } else if (msg.contains('No token')) {
            msg = 'Login failed — server did not return a token';
          } else if (msg.contains('DioException') || msg.contains('DioError')) {
            msg = 'Network error: $msg';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: C.loss,
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'OK',
                textColor: C.text,
                onPressed: () {},
              ),
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Logo / header
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: C.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: C.accent.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.show_chart, color: C.accent, size: 28),
              ),
              const SizedBox(height: 20),
              const Text('MeroShare Login',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.text)),
              const SizedBox(height: 6),
              const Text('Connect your MeroShare account',
                  style: TextStyle(fontSize: 14, color: C.muted)),
              const SizedBox(height: 36),

              // DP Selector
              const Text('SELECT YOUR DP / BROKER',
                  style: TextStyle(fontSize: 10, color: C.muted, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              ref.watch(capitalsProvider).when(
                loading: () => Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: C.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: C.border),
                  ),
                  child: const Center(
                    child: SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: C.accent)),
                  ),
                ),
                error: (e, _) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: C.loss.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: C.loss.withValues(alpha: 0.3)),
                  ),
                  child: Text('Failed to load DP list: $e',
                      style: const TextStyle(color: C.loss, fontSize: 12)),
                ),
                data: (capitals) => DropdownButtonFormField<CapitalItem>(
                  isExpanded: true,
                  value: _selectedDp,
                  dropdownColor: C.surface2,
                  style: const TextStyle(color: C.text, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search and select DP...',
                    prefixIcon: const Icon(Icons.account_balance, color: C.muted, size: 18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    filled: true,
                    fillColor: C.surface2,
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
                  items: capitals.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedDp = v),
                ),
              ),

              const SizedBox(height: 16),
              const Text('USERNAME',
                  style: TextStyle(fontSize: 10, color: C.muted, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              TextField(
                controller: _userCtrl,
                keyboardType: TextInputType.visiblePassword,
                autocorrect: false,
                style: const TextStyle(color: C.text, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Your MeroShare username',
                  prefixIcon: Icon(Icons.person_outline, color: C.muted, size: 18),
                ),
              ),

              const SizedBox(height: 16),
              const Text('PASSWORD',
                  style: TextStyle(fontSize: 10, color: C.muted, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: C.text, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Your MeroShare password',
                  prefixIcon: const Icon(Icons.lock_outline, color: C.muted, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                        color: C.muted, size: 18),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                onSubmitted: (_) => _login(),
              ),

              const SizedBox(height: 28),
              AppBtn(
                label: 'Login to MeroShare',
                onTap: _login,
                loading: auth.isLoading,
                icon: Icons.login,
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: C.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: C.orange.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: C.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(child: Text(
                      'This app uses the official MeroShare API over HTTPS. '
                      'Your credentials are stored securely on-device only.',
                      style: TextStyle(fontSize: 11, color: C.orange, height: 1.5),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
