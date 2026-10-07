import 'package:flutter/material.dart';
import '../app_state.dart';
import '../strings.dart';
import 'orders_screen.dart';

class LoginScreen extends StatefulWidget {
  final AppState app;
  const LoginScreen(this.app, {super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _u = TextEditingController();
  final _p = TextEditingController();
  final _url = TextEditingController();
  bool _showErr = false;

  @override
  void initState() {
    super.initState();
    _u.text = widget.app.username;
    _p.text = widget.app.password;
    _url.text = widget.app.sheetUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const Icon(Icons.local_laundry_service, size: 72),
                  const SizedBox(height: 12),
                  Text(S.get('login_title'),
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _url,
                    decoration: InputDecoration(
                      labelText: S.get('sheet_url'),
                      prefixIcon: const Icon(Icons.link),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _u,
                    decoration: InputDecoration(
                      labelText: S.get('username'),
                      prefixIcon: const Icon(Icons.person),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _p,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: S.get('password'),
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (_showErr) ...[
                    const SizedBox(height: 12),
                    Text(S.get('login_error'),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      icon: widget.app.loading
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.login),
                      label: Text(S.get('login')),
                      onPressed: widget.app.loading
                          ? null
                          : () async {
                              await widget.app.updateSettings(
                                  sheetUrl: _url.text.trim());
                              final ok = await widget.app
                                  .login(_u.text.trim(), _p.text.trim());
                              if (!mounted) return;
                              if (ok) {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            OrdersScreen(widget.app)));
                              } else {
                                setState(() => _showErr = true);
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
