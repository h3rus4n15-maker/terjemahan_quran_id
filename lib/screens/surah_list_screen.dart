import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/surah.dart';
import 'reading_screen.dart';

class SurahListScreen extends StatelessWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar 114 Surat')),
      body: FutureBuilder<List<Surah>>(
        future: DatabaseHelper.instance.getAllSurah(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final surahs = snapshot.data!;
          return ListView.separated(
            itemCount: surahs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final s = surahs[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${s.nomorSurat}')),
                title: Text(s.namaIndonesia, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${s.artiNama} • ${s.jumlahAyat} Ayat'),
                trailing: Text('Hal. ${s.startPage}', style: const TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReadingScreen(initialPage: s.startPage)),
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
