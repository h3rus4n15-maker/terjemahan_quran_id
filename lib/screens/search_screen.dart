import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/translation.dart';
import 'reading_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Translation> _results = [];
  bool _isSearching = false;

  Future<void> _search(String keyword) async {
    if (keyword.trim().isEmpty) return;
    setState(() => _isSearching = true);
    final res = await DatabaseHelper.instance.searchTranslation(keyword.trim());
    setState(() {
      _results = res;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Cari kata dalam terjemahan...',
            border: InputBorder.none,
          ),
          onSubmitted: _search,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => _search(_searchCtrl.text)),
        ],
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = _results[index];
                return ListTile(
                  title: Text('QS. ${item.namaSurat} : ${item.nomorAyat}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.terjemahan, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Text('Hal. ${item.halaman}'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ReadingScreen(initialPage: item.halaman)));
                  },
                );
              },
            ),
    );
  }
}
