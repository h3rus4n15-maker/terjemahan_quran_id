import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah.dart';
import '../models/translation.dart';
import '../models/bookmark.dart';
import '../models/reading_progress.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  static List<Surah> _surahList = [];
  static Map<int, List<Translation>> _pageMap = {}; // Key: Halaman (1 s.d 604)
  static List<Translation> _allTranslations = [];
  static bool _isLoaded = false;

  Future<void> _loadFullDataset() async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('assets/data/quran_kemenag.json');
      final List<dynamic> data = json.decode(jsonString);

      List<Surah> surahs = [];
      Map<int, List<Translation>> pages = {};
      List<Translation> allVerses = [];

      int verseGlobalId = 1;

      for (var s in data) {
        final surahNo = s['number'] as int;
        final nameShort = s['name']?['short'] ?? '';
        final nameId = s['name']?['transliteration']?['id'] ?? s['name']?['id'] ?? 'Surat $surahNo';
        final translationName = s['name']?['translation']?['id'] ?? '';
        final totalVerses = s['numberOfVerses'] as int;

        int startPage = 1;
        final verses = s['verses'] as List<dynamic>? ?? [];

        if (verses.isNotEmpty) {
          startPage = verses.first['meta']?['page'] ?? 1;
        }

        surahs.add(Surah(
          id: surahNo,
          nomorSurat: surahNo,
          namaArab: nameShort,
          namaIndonesia: nameId,
          artiNama: translationName,
          jumlahAyat: totalVerses,
          startPage: startPage,
        ));

        for (var v in verses) {
          final verseNo = v['number']?['inSurah'] as int;
          final transText = v['translation']?['id'] as String? ?? '';
          final juzNo = v['meta']?['juz'] as int? ?? 1;
          final pageNo = v['meta']?['page'] as int? ?? 1;

          final item = Translation(
            id: verseGlobalId++,
            nomorSurat: surahNo,
            nomorAyat: verseNo,
            terjemahan: transText,
            juz: juzNo,
            halaman: pageNo,
            namaSurat: nameId,
          );

          if (!pages.containsKey(pageNo)) {
            pages[pageNo] = [];
          }
          pages[pageNo]!.add(item);
          allVerses.add(item);
        }
      }

      _surahList = surahs;
      _pageMap = pages;
      _allTranslations = allVerses;
      _isLoaded = true;
    } catch (e) {
      print('Error loading dataset: $e');
    }
  }

  // --- QUERY SURAH (114 Surat) ---
  Future<List<Surah>> getAllSurah() async {
    await _loadFullDataset();
    return _surahList;
  }

  // --- QUERY HALAMAN (1 s.d 604 Lengkap) ---
  Future<List<Translation>> getTranslationsByPage(int pageNumber) async {
    await _loadFullDataset();
    return _pageMap[pageNumber] ?? [];
  }

  // --- QUERY JUZ (1 s.d 30 Lengkap) ---
  Future<List<Map<String, dynamic>>> getAllJuzInfo() async {
    await _loadFullDataset();
    Map<int, Map<String, dynamic>> juzInfoMap = {};

    for (var item in _allTranslations) {
      if (!juzInfoMap.containsKey(item.juz)) {
        juzInfoMap[item.juz] = {
          'juz': item.juz,
          'start_page': item.halaman,
          'start_surah': item.nomorSurat,
          'start_surah_name': item.namaSurat,
          'start_ayat': item.nomorAyat,
        };
      }
    }

    return List.generate(30, (i) {
      final juz = i + 1;
      return juzInfoMap[juz] ?? {
        'juz': juz,
        'start_page': 1,
        'start_surah': 1,
        'start_surah_name': 'Al-Fatihah',
        'start_ayat': 1,
      };
    });
  }

  // --- PENCARIAN TERJEMAHAN CEPAT ---
  Future<List<Translation>> searchTranslation(String keyword) async {
    await _loadFullDataset();
    final q = keyword.toLowerCase().trim();
    if (q.isEmpty) return [];
    return _allTranslations
        .where((t) => t.terjemahan.toLowerCase().contains(q))
        .take(100)
        .toList();
  }

  // --- BOOKMARK (Tersimpan Lokal di SharedPreferences) ---
  Future<List<Bookmark>> getAllBookmarks() async {
    await _loadFullDataset();
    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getStringList('bookmarks_list') ?? [];
    List<Bookmark> list = [];
    for (var str in listJson) {
      final parts = str.split(':');
      if (parts.length >= 3) {
        final surahNo = int.parse(parts[0]);
        final verseNo = int.parse(parts[1]);
        final pageNo = int.parse(parts[2]);

        final verse = _allTranslations.firstWhere(
          (t) => t.nomorSurat == surahNo && t.nomorAyat == verseNo,
          orElse: () => Translation(id: 0, nomorSurat: surahNo, nomorAyat: verseNo, terjemahan: '', juz: 1, halaman: pageNo),
        );

        list.add(Bookmark(
          nomorSurat: surahNo,
          nomorAyat: verseNo,
          halaman: pageNo,
          createdAt: DateTime.now().toIso8601String(),
          namaSurat: verse.namaSurat ?? 'Surat $surahNo',
          snippetTerjemahan: verse.terjemahan,
        ));
      }
    }
    return list;
  }

  Future<int> addBookmark(int nomorSurat, int nomorAyat, int halaman) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('bookmarks_list') ?? [];
    final key = '$nomorSurat:$nomorAyat:$halaman';
    if (!list.contains(key)) {
      list.add(key);
      await prefs.setStringList('bookmarks_list', list);
    }
    return 1;
  }

  Future<int> removeBookmark(int nomorSurat, int nomorAyat) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('bookmarks_list') ?? [];
    list.removeWhere((item) => item.startsWith('$nomorSurat:$nomorAyat:'));
    await prefs.setStringList('bookmarks_list', list);
    return 1;
  }

  // --- LAST READ (Tersimpan Lokal di SharedPreferences) ---
  Future<void> saveLastRead(int halaman, int nomorSurat, int nomorAyat) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_page', halaman);
    await prefs.setInt('last_read_surah', nomorSurat);
    await prefs.setInt('last_read_ayat', nomorAyat);
  }

  Future<ReadingProgress?> getLastRead() async {
    await _loadFullDataset();
    final prefs = await SharedPreferences.getInstance();
    final page = prefs.getInt('last_read_page') ?? 1;
    final surah = prefs.getInt('last_read_surah') ?? 1;
    final ayat = prefs.getInt('last_read_ayat') ?? 1;

    final surahObj = _surahList.firstWhere(
      (s) => s.nomorSurat == surah,
      orElse: () => Surah(id: 1, nomorSurat: 1, namaArab: '', namaIndonesia: 'Al-Fatihah', artiNama: '', jumlahAyat: 7),
    );

    return ReadingProgress(
      halaman: page,
      nomorSurat: surah,
      nomorAyat: ayat,
      updatedAt: DateTime.now().toIso8601String(),
      namaSurat: surahObj.namaIndonesia,
    );
  }
}
