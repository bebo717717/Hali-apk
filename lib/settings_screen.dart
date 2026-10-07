import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../app_state.dart';
import '../strings.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final AppState app;
  const SettingsScreen(this.app, {super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _url, _u, _p;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: widget.app.sheetUrl);
    _u = TextEditingController(text: widget.app.username);
    _p = TextEditingController(text: widget.app.password);
  }

  @override
  void dispose() {
    _url.dispose(); _u.dispose(); _p.dispose();
    super.dispose();
  }

  Future<void> _pickCustomSound() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (r != null && r.files.single.path != null) {
      await widget.app
          .updateSettings(sound: 'custom:${r.files.single.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    return Scaffold(
      appBar: AppBar(title: Text(S.get('settings'))),
      body: AnimatedBuilder(
        animation: app,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(S.get('login_title'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _url,
              decoration: InputDecoration(
                labelText: S.get('sheet_url'),
                prefixIcon: const Icon(Icons.link),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _u,
              decoration: InputDecoration(
                labelText: S.get('username'),
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _p,
              obscureText: true,
              decoration: InputDecoration(
                labelText: S.get('password'),
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: FilledButton.icon(
                onPressed: () async {
                  await app.updateSettings(
                    sheetUrl: _url.text.trim(),
                    username: _u.text.trim(),
                    password: _p.text.trim(),
                  );
                  final ok = await app.login(_u.text.trim(), _p.text.trim());
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok
                            ? S.get('connected')
                            : S.get('login_error'))));
                  }
                },
                icon: const Icon(Icons.login),
                label: Text(S.get('save_login')),
              ),
            ),
            const Divider(height: 32),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: Text(S.get('dark_mode')),
              value: app.dark,
              onChanged: (v) => app.updateSettings(dark: v),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(S.get('language')),
              trailing: DropdownButton<String>(
                value: app.lang,
                items: const [
                  DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                ],
                onChanged: (v) => app.updateSettings(lang: v),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: Text(S.get('notif_sound')),
              trailing: DropdownButton<String>(
                value: app.sound.startsWith('custom:') ? 'custom' : app.sound,
                items: [
                  DropdownMenuItem(
                      value: 'default', child: Text(S.get('sound_default'))),
                  DropdownMenuItem(
                      value: 'alarm', child: Text(S.get('sound_alarm'))),
                  DropdownMenuItem(
                      value: 'silent', child: Text(S.get('sound_silent'))),
                  DropdownMenuItem(
                      value: 'custom', child: Text(S.get('sound_custom'))),
                ],
                onChanged: (v) async {
                  if (v == 'custom') {
                    await _pickCustomSound();
                  } else {
                    await app.updateSettings(sound: v);
                  }
                },
              ),
            ),
            if (app.sound.startsWith('custom:'))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  app.sound.substring(7).split('/').last,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            SwitchListTile(
              secondary: const Icon(Icons.vibration),
              title: Text(S.get('vibrate')),
              value: app.vibrate,
              onChanged: (v) => app.updateSettings(vibrate: v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.crop_square),
              title: Text(S.get('banner')),
              value: app.banner,
              onChanged: (v) => app.updateSettings(banner: v),
            ),
            const Divider(height: 32),
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  await app.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => LoginScreen(app)),
                      (_) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(S.get('logout')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
