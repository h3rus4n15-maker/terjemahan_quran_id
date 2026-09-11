class ReadingProgress {
  final int? id;
  final int halaman;
  final int nomorSurat;
  final int nomorAyat;
  final String updatedAt;
  final String? namaSurat;

  ReadingProgress({
    this.id,
    required this.halaman,
    required this.nomorSurat,
    required this.nomorAyat,
    required this.updatedAt,
    this.namaSurat,
  });

  factory ReadingProgress.fromMap(Map<String, dynamic> map) {
    return ReadingProgress(
      id: map['id'] as int?,
      halaman: map['halaman'] as int,
      nomorSurat: map['nomor_surat'] as int,
      nomorAyat: map['nomor_ayat'] as int,
      updatedAt: map['updated_at'] as String,
      namaSurat: map['nama_indonesia'] as String?,
    );
  }
}
