import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/bookmark.dart';
import 'reading_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  late Future<List<Bookmark>> _bookmarksFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _bookmarksFuture = DatabaseHelper.instance.getAllBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmark Saya')),
      body: FutureBuilder<List<Bookmark>>(
        future: _bookmarksFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada bookmark.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final b = items[index];
              return ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text('QS. ${b.namaSurat} : ${b.nomorAyat}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(b.snippetTerjemahan ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    await DatabaseHelper.instance.removeBookmark(b.nomorSurat, b.nomorAyat);
                    _refresh();
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReadingScreen(initialPage: b.halaman)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
