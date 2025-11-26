# Setup Upload Bukti Sertifikat

## Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Setup Supabase Storage
1. Buka Supabase Dashboard → SQL Editor
2. Copy-paste isi file `supabase_storage_setup.sql`
3. Klik **RUN**
4. Verifikasi bucket `portfolios` muncul di Storage

### 3. Test Upload
1. Run aplikasi: `flutter run`
2. Login sebagai mahasiswa
3. Buka Profile → Portfolio
4. Klik Add → Pilih "Sertifikat"
5. Isi form dan klik "Pilih File"
6. Pilih file PDF atau gambar (< 10MB)
7. Klik "Tambah"

## Troubleshooting

**Error: Missing bucket 'portfolios'**
→ Jalankan `supabase_storage_setup.sql`

**Error: Permission denied**
→ Check RLS policies di Supabase Dashboard → Storage → Policies

**File terlalu besar**
→ Ukuran maksimal 10 MB

## Features
✅ Upload PDF atau gambar (JPG, PNG, GIF, WEBP)
✅ Max 10 MB per file
✅ Ganti file saat edit
✅ Hapus file
✅ Validasi otomatis

Dokumentasi lengkap: `PORTFOLIO_UPLOAD_FEATURE.md`
