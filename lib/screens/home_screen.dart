import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/reading_progress.dart';
import 'reading_screen.dart';
import 'surah_list_screen.dart';
import 'juz_list_screen.dart';
import 'bookmark_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ReadingProgress? _lastRead;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLastRead();
  }

  Future<void> _loadLastRead() async {
    try {
      final lastRead = await DatabaseHelper.instance.getLastRead();
      if (mounted) {
        setState(() {
          _lastRead = lastRead;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TERJEMAHAN AL-QUR\'AN',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadLastRead,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: Colors.teal),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Terjemahan Resmi Kemenag RI • Tanpa Teks Arab • 100% Offline',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history_edu, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Terakhir Dibaca',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_lastRead != null) ...[
                      Text(
                        'QS. ${_lastRead!.namaSurat ?? "Al-Fatihah"} : ${_lastRead!.nomorAyat}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Halaman ${_lastRead!.halaman} • Juz 1'),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReadingScreen(initialPage: _lastRead!.halaman),
                              ),
                            );
                            _loadLastRead();
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('LANJUTKAN MEMBACA', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ] else ...[
                      const Text('Belum ada riwayat bacaan. Mulai dari Halaman 1.'),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ReadingScreen(initialPage: 1),
                              ),
                            );
                            _loadLastRead();
                          },
                          icon: const Icon(Icons.book),
                          label: const Text('MULAI BACA'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Menu Utama', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _menuTile(
              context,
              icon: Icons.menu_book,
              title: 'Baca Al-Qur\'an',
              subtitle: 'Membaca terjemahan 604 halaman',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReadingScreen(initialPage: _lastRead?.halaman ?? 1)),
                );
                _loadLastRead();
              },
            ),
            _menuTile(
              context,
              icon: Icons.list_alt,
              title: 'Daftar Surat',
              subtitle: '114 Surat Lengkap',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SurahListScreen()),
              ),
            ),
            _menuTile(
              context,
              icon: Icons.auto_stories,
              title: 'Daftar Juz',
              subtitle: '30 Juz Lengkap',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JuzListScreen()),
              ),
            ),
            _menuTile(
              context,
              icon: Icons.bookmark,
              title: 'Bookmark Saya',
              subtitle: 'Daftar ayat yang ditandai',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookmarkScreen()),
              ),
            ),
            _menuTile(
              context,
              icon: Icons.search,
              title: 'Cari Terjemahan',
              subtitle: 'Pencarian kata dalam terjemahan',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
            ),
            _menuTile(
              context,
              icon: Icons.settings,
              title: 'Pengaturan',
              subtitle: 'Ukuran font & tema tampilan',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withOpacity(0.12),
          child: Icon(icon, color: Colors.teal),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
