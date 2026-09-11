class Surah {
  final int id;
  final int nomorSurat;
  final String namaArab;
  final String namaIndonesia;
  final String artiNama;
  final int jumlahAyat;
  final int startPage;

  Surah({
    required this.id,
    required this.nomorSurat,
    required this.namaArab,
    required this.namaIndonesia,
    required this.artiNama,
    required this.jumlahAyat,
    this.startPage = 1,
  });

  factory Surah.fromMap(Map<String, dynamic> map) {
    return Surah(
      id: map['id'] as int,
      nomorSurat: map['nomor_surat'] as int,
      namaArab: map['nama_arab'] ?? '',
      namaIndonesia: map['nama_indonesia'] as String,
      artiNama: map['arti_nama'] ?? '',
      jumlahAyat: map['jumlah_ayat'] as int,
      startPage: map['start_page'] != null ? map['start_page'] as int : 1,
    );
  }
}
