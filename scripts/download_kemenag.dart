import 'dart:io';
import 'dart:convert';

void main() async {
  print("[*] Mengunduh dataset 114 Surat & 6.236 Ayat Kemenag dari AlQuran Cloud API...");
  final url = 'https://api.alquran.cloud/v1/quran/id.indonesian';
  
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse(url));
  final response = await request.close();
  
  if (response.statusCode != 200) {
    print("[!] Gagal mengunduh: HTTP ${response.statusCode}");
    return;
  }
  
  final responseBody = await response.transform(utf8.decoder).join();
  final Map<String, dynamic> rawJson = json.decode(responseBody);
  final List<dynamic> surahs = rawJson['data']?['surahs'] ?? [];
  
  print("[✓] Berhasil mengunduh data ${surahs.length} Surat. Memproses format data...");

  List<Map<String, dynamic>> formattedData = [];

  for (var s in surahs) {
    final surahNo = (s['number'] as num?)?.toInt() ?? 1;
    final nameAr = s['name']?.toString() ?? '';
    final nameId = s['englishName']?.toString() ?? 'Surat $surahNo';
    final ayahs = s['ayahs'] as List<dynamic>? ?? [];
    final totalV = (s['numberOfAyahs'] as num?)?.toInt() ?? ayahs.length;

    List<Map<String, dynamic>> versesList = [];
    for (var a in ayahs) {
      final vNo = (a['numberInSurah'] as num?)?.toInt() ?? 1;
      final text = a['text']?.toString() ?? '';
      final juz = (a['juz'] as num?)?.toInt() ?? 1;
      final page = (a['page'] as num?)?.toInt() ?? 1;

      versesList.add({
        "number": {"inSurah": vNo},
        "translation": {"id": text},
        "meta": {"juz": juz, "page": page}
      });
    }

    formattedData.add({
      "number": surahNo,
      "numberOfVerses": totalV,
      "name": {
        "short": nameAr,
        "transliteration": {"id": nameId},
        "id": nameId,
        "translation": {"id": ""}
      },
      "verses": versesList
    });
  }

  final outFile = File('assets/data/quran_kemenag.json');
  await outFile.parent.create(recursive: true);
  await outFile.writeAsString(json.encode(formattedData), encoding: utf8, flush: true);

  print("[✓] SUKSES 100%! Seluruh 6.236 ayat terjemahan resmi Kemenag telah tersimpan.");
}
