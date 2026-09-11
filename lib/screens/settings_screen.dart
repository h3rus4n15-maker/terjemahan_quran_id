import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          const ListTile(title: Text('Tema Tampilan', style: TextStyle(fontWeight: FontWeight.bold))),
          RadioListTile<ThemeMode>(
            title: const Text('Ikuti Sistem'),
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            onChanged: (v) => settings.setThemeMode(v!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Mode Terang'),
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (v) => settings.setThemeMode(v!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Mode Gelap'),
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            onChanged: (v) => settings.setThemeMode(v!),
          ),
          const Divider(),
          const ListTile(title: Text('Ukuran Font', style: TextStyle(fontWeight: FontWeight.bold))),
          Slider(
            value: settings.fontSize,
            min: 13.0,
            max: 26.0,
            divisions: 5,
            label: '${settings.fontSize.toInt()}',
            onChanged: (val) => settings.setFontSize(val),
          ),
        ],
      ),
    );
  }
}
