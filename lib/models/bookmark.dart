class Bookmark {
  final int? id;
  final int nomorSurat;
  final int nomorAyat;
  final int halaman;
  final String createdAt;
  final String? namaSurat;
  final String? snippetTerjemahan;

  Bookmark({
    this.id,
    required this.nomorSurat,
    required this.nomorAyat,
    required this.halaman,
    required this.createdAt,
    this.namaSurat,
    this.snippetTerjemahan,
  });

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as int?,
      nomorSurat: map['nomor_surat'] as int,
      nomorAyat: map['nomor_ayat'] as int,
      halaman: map['halaman'] as int,
      createdAt: map['created_at'] as String,
      namaSurat: map['nama_indonesia'] as String?,
      snippetTerjemahan: map['terjemahan'] as String?,
    );
  }
}
