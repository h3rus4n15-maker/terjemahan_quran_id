import sqlite3
import os
import json
import urllib.request

def build_quran_db():
    db_path = "assets/databases/quran_id.db"
    os.makedirs("assets/databases", exist_ok=True)
    if os.path.exists(db_path):
        os.remove(db_path)

    print("[*] Membuat SQLite Database Al-Qur'an Kemenag...")
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()

    cur.execute("""
    CREATE TABLE surah (
        id INTEGER PRIMARY KEY,
        nomor_surat INTEGER NOT NULL UNIQUE,
        nama_arab TEXT,
        nama_indonesia TEXT NOT NULL,
        arti_nama TEXT,
        jumlah_ayat INTEGER NOT NULL
    );""")

    cur.execute("""
    CREATE TABLE translation (
        id INTEGER PRIMARY KEY,
        nomor_surat INTEGER NOT NULL,
        nomor_ayat INTEGER NOT NULL,
        terjemahan TEXT NOT NULL,
        juz INTEGER NOT NULL,
        halaman INTEGER NOT NULL
    );""")
    cur.execute("CREATE INDEX idx_trans_halaman ON translation(halaman);")

    cur.execute("""
    CREATE TABLE bookmark (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomor_surat INTEGER NOT NULL,
        nomor_ayat INTEGER NOT NULL,
        halaman INTEGER NOT NULL,
        created_at TEXT NOT NULL
    );""")

    cur.execute("""
    CREATE TABLE reading_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        halaman INTEGER NOT NULL,
        nomor_surat INTEGER NOT NULL,
        nomor_ayat INTEGER NOT NULL,
        updated_at TEXT NOT NULL
    );""")

    print("[*] Mengunduh dataset 114 Surat & 6236 Ayat terjemahan resmi Kemenag...")
    url = "https://raw.githubusercontent.com/gadingrst/quran-api/main/data/quran-id.json"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode())

    for surah in data:
        cur.execute("""
            INSERT INTO surah (id, nomor_surat, nama_arab, nama_indonesia, arti_nama, jumlah_ayat)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (
            surah['number'],
            surah['number'],
            surah.get('name', {}).get('short', ''),
            surah.get('name', {}).get('transliteration', {}).get('id', ''),
            surah.get('name', {}).get('translation', {}).get('id', ''),
            surah['numberOfVerses']
        ))

        for v in surah.get('verses', []):
            cur.execute("""
                INSERT INTO translation (nomor_surat, nomor_ayat, terjemahan, juz, halaman)
                VALUES (?, ?, ?, ?, ?)
            """, (
                surah['number'],
                v['number']['inSurah'],
                v['translation']['id'],
                v.get('meta', {}).get('juz', 1),
                v.get('meta', {}).get('page', 1)
            ))

    conn.commit()
    conn.close()
    print("[✓] Database quran_id.db berhasil dibuat!")

if __name__ == "__main__":
    build_quran_db()
