import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../models/translation.dart';
import '../providers/settings_provider.dart';

class ReadingScreen extends StatefulWidget {
  final int initialPage;
  const ReadingScreen({super.key, required this.initialPage});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  late PageController _pageController;
  late int _currentPage;
  final Set<String> _bookmarks = {};

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(1, 604);
    _pageController = PageController(initialPage: _currentPage - 1);
    _recordLastRead(_currentPage);
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final list = await DatabaseHelper.instance.getAllBookmarks();
    setState(() {
      _bookmarks.clear();
      for (var b in list) {
        _bookmarks.add('${b.nomorSurat}_${b.nomorAyat}');
      }
    });
  }

  Future<void> _recordLastRead(int page) async {
    final list = await DatabaseHelper.instance.getTranslationsByPage(page);
    if (list.isNotEmpty) {
      await DatabaseHelper.instance.saveLastRead(page, list.first.nomorSurat, list.first.nomorAyat);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman $_currentPage / 604'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Salin Seluruh Halaman',
            onPressed: () => _copyPage(_currentPage),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Bagikan Halaman Ini',
            onPressed: () => _sharePage(_currentPage),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: 604,
        onPageChanged: (idx) {
          final p = idx + 1;
          setState(() => _currentPage = p);
          _recordLastRead(p);
        },
        itemBuilder: (ctx, idx) {
          final page = idx + 1;
          return _PageBody(
            pageNumber: page,
            fontSize: settings.fontSize,
            bookmarks: _bookmarks,
            onToggleBookmark: (s, a) async {
              final k = '${s}_$a';
              if (_bookmarks.contains(k)) {
                await DatabaseHelper.instance.removeBookmark(s, a);
                setState(() => _bookmarks.remove(k));
              } else {
                await DatabaseHelper.instance.addBookmark(s, a, page);
                setState(() => _bookmarks.add(k));
              }
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _currentPage > 1
                  ? () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      )
                  : null,
              child: const Text('← Sebelumnya'),
            ),
            Text('Halaman $_currentPage / 604', style: const TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: _currentPage < 604
                  ? () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      )
                  : null,
              child: const Text('Berikutnya →'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyPage(int page) async {
    final list = await DatabaseHelper.instance.getTranslationsByPage(page);
    if (list.isEmpty) return;
    final buffer = StringBuffer();
    buffer.writeln('=== TERJEMAHAN AL-QUR\'AN HALAMAN $page ===\n');
    for (var item in list) {
      buffer.writeln('QS. ${item.namaSurat} : ${item.nomorAyat}');
      buffer.writeln('${item.terjemahan}\n');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Halaman berhasil disalin')));
  }

  Future<void> _sharePage(int page) async {
    final list = await DatabaseHelper.instance.getTranslationsByPage(page);
    if (list.isEmpty) return;
    final buffer = StringBuffer();
    buffer.writeln('Terjemahan Al-Qur\'an Halaman $page:\n');
    for (var item in list) {
      buffer.writeln('QS. ${item.namaSurat} : ${item.nomorAyat}\n${item.terjemahan}\n');
    }
    Share.share(buffer.toString(), subject: 'Terjemahan Al-Qur\'an Hal $page');
  }
}

class _PageBody extends StatelessWidget {
  final int pageNumber;
  final double fontSize;
  final Set<String> bookmarks;
  final Function(int, int) onToggleBookmark;

  const _PageBody({
    required this.pageNumber,
    required this.fontSize,
    required this.bookmarks,
    required this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Translation>>(
      future: DatabaseHelper.instance.getTranslationsByPage(pageNumber),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final list = snap.data!;
        if (list.isEmpty) return Center(child: Text('Halaman $pageNumber'));

        final first = list.first;
        final last = list.last;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('Halaman $pageNumber', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Juz ${first.juz} • QS. ${first.namaSurat} (Ayat ${first.nomorAyat}–${last.nomorAyat})'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < list.length; i++) ...[
              if (i == 0 || list[i].nomorSurat != list[i - 1].nomorSurat) ...[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(10),
                  color: Colors.teal.withOpacity(0.1),
                  child: Center(
                    child: Text(
                      'QS. ${list[i].nomorSurat} — ${(list[i].namaSurat ?? "").toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ),
                ),
              ],
              _buildVerse(context, list[i]),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _buildVerse(BuildContext context, Translation item) {
    final isMarked = bookmarks.contains('${item.nomorSurat}_${item.nomorAyat}');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text('Ayat ${item.nomorAyat}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  visualDensity: VisualDensity.compact,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(isMarked ? Icons.bookmark : Icons.bookmark_border, color: isMarked ? Colors.amber : Colors.grey),
                      onPressed: () => onToggleBookmark(item.nomorSurat, item.nomorAyat),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: 'QS. ${item.namaSurat} : ${item.nomorAyat}\n\n${item.terjemahan}'));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ayat disalin')));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, size: 20),
                      onPressed: () {
                        Share.share('QS. ${item.namaSurat} : ${item.nomorAyat}\n\n${item.terjemahan}\n\n(Kemenag RI)');
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.terjemahan,
              style: TextStyle(fontSize: fontSize, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
