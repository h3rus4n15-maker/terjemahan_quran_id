import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'reading_screen.dart';

class JuzListScreen extends StatelessWidget {
  const JuzListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar 30 Juz')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getAllJuzInfo(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = list[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  child: Text('${item['juz']}'),
                ),
                title: Text('Juz ${item['juz']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('QS. ${item['start_surah_name']} : Ayat ${item['start_ayat']}'),
                trailing: Text('Hal. ${item['start_page']}', style: const TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReadingScreen(initialPage: item['start_page'] as int)),
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
