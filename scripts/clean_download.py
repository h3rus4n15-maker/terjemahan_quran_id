import json
import urllib.request
import os

def download_clean_dataset():
    output_path = "assets/data/quran_kemenag.json"
    os.makedirs("assets/data", exist_ok=True)
    
    url = "https://raw.githubusercontent.com/gadingrst/quran-api/main/data/quran-id.json"
    print("[*] Mengunduh dataset terjemahan Kemenag RI resmi...")
    
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response:
        raw_bytes = response.read()
        raw_text = raw_bytes.decode('utf-8-sig') # Bersihkan BOM jika ada
        data = json.loads(raw_text)
    
    # Simpan kembali sebagai UTF-8 murni tanpa BOM
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False)
    
    print(f"[✓] Berhasil menyimpan {len(data)} Surat dan seluruh ayat resmi ke {output_path}")

if __name__ == "__main__":
    download_clean_dataset()
