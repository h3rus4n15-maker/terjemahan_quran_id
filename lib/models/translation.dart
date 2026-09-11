class Translation {
  final int id;
  final int nomorSurat;
  final int nomorAyat;
  final String terjemahan;
  final int juz;
  final int halaman;
  final String? namaSurat;

  Translation({
    required this.id,
    required this.nomorSurat,
    required this.nomorAyat,
    required this.terjemahan,
    required this.juz,
    required this.halaman,
    this.namaSurat,
  });

  factory Translation.fromMap(Map<String, dynamic> map) {
    return Translation(
      id: map['id'] as int,
      nomorSurat: map['nomor_surat'] as int,
      nomorAyat: map['nomor_ayat'] as int,
      terjemahan: map['terjemahan'] as String,
      juz: map['juz'] as int,
      halaman: map['halaman'] as int,
      namaSurat: map['nama_indonesia'] as String?,
    );
  }
}
