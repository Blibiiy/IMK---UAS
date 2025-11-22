# 🚀 Setup Supabase untuk CRUD Project

Panduan lengkap untuk menghubungkan aplikasi UniWork dengan database Supabase.

## 📋 Langkah-Langkah Setup

### 1. Buat Project di Supabase

1. Kunjungi [https://supabase.com](https://supabase.com)
2. Sign up / Login dengan akun GitHub atau email
3. Klik **"New Project"**
4. Isi form:
   - **Project Name**: `uniwork` (atau nama lain sesuai keinginan)
   - **Database Password**: Buat password yang kuat (simpan password ini!)
   - **Region**: Pilih region terdekat (misalnya: Southeast Asia)
   - **Pricing Plan**: Pilih **Free** untuk development
5. Klik **"Create new project"** dan tunggu beberapa menit

### 2. Setup Database

1. Setelah project dibuat, buka **SQL Editor** di sidebar kiri
2. Copy semua isi dari file `supabase_setup.sql`
3. Paste ke SQL Editor
4. Klik **"Run"** untuk execute script
5. Verifikasi dengan menjalankan query:
   ```sql
   SELECT * FROM projects ORDER BY posted_at DESC;
   ```
6. Anda akan melihat 3 data dummy project

### 3. Copy Credentials

1. Buka **Settings** > **API** di sidebar
2. Copy dua nilai berikut:
   - **Project URL** (contoh: `https://xyzcompany.supabase.co`)
   - **anon public** key (ada di bagian Project API keys)

### 4. Konfigurasi Aplikasi

1. Buka file `lib/config/supabase_config.dart`
2. Ganti placeholder dengan credentials Anda:

```dart
class SupabaseConfig {
  // Ganti dengan Project URL Anda
  static const String supabaseUrl = 'https://xyzcompany.supabase.co';
  
  // Ganti dengan anon public key Anda
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
  
  // Nama tabel (jangan diubah)
  static const String projectsTable = 'projects';
}
```

3. Save file

### 5. Install Dependencies

Jalankan command berikut di terminal:

```bash
flutter pub get
```

### 6. Test Aplikasi

```bash
flutter run
```

## ✅ Fitur yang Sudah Terintegrasi

### CRUD Operations:
- ✅ **Create** - Tambah project baru (lecturer)
- ✅ **Read** - Load semua projects dari database
- ✅ **Update** - Edit project existing (lecturer)
- ✅ **Delete** - Hapus project (via SupabaseService)
- ✅ **Status Update** - Update status project (tersedia, diproses, diterima)
- ✅ **Close Registration** - Tutup pendaftaran project

### Auto Features:
- ✅ Auto load projects saat membuka home screen
- ✅ Real-time data sync dengan Supabase
- ✅ Error handling dengan fallback ke dummy data
- ✅ Loading states
- ✅ Timestamp otomatis (posted_at, edited_at)

## 🔧 Struktur Database

### Tabel: `projects`

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key (auto-generated) |
| `title` | TEXT | Nama project |
| `supervisor` | TEXT | Nama dosen pembimbing |
| `description` | TEXT | Deskripsi lengkap project |
| `deadline` | TEXT | Tanggal deadline |
| `participants` | TEXT | Jumlah partisipan yang dibutuhkan |
| `requirements` | JSONB | Array persyaratan (JSON) |
| `benefits` | JSONB | Array manfaat (JSON) |
| `status` | TEXT | Status: 'tersedia', 'diproses', 'diterima' |
| `posted_at` | TIMESTAMPTZ | Waktu posting |
| `edited_at` | TIMESTAMPTZ | Waktu terakhir diedit |
| `created_at` | TIMESTAMPTZ | Waktu dibuat |

## 🔐 Row Level Security (RLS)

Database sudah dikonfigurasi dengan RLS policies:

- **Public Read**: Semua orang bisa melihat projects
- **Authenticated Write**: Hanya user yang login bisa create/update/delete
- **Untuk development**: Sementara semua operasi diizinkan

### Mengubah RLS untuk Production:

```sql
-- Contoh: Hanya lecturer yang bisa create project
CREATE POLICY "Only lecturers can create"
ON projects FOR INSERT
TO authenticated
WITH CHECK (
  auth.jwt() ->> 'role' = 'lecturer'
);
```

## 🐛 Troubleshooting

### Error: "Invalid API key"
- Pastikan `supabaseAnonKey` benar
- Copy ulang dari Supabase Dashboard > Settings > API

### Error: "Failed to connect"
- Pastikan `supabaseUrl` benar (harus https)
- Cek koneksi internet
- Pastikan project Supabase sudah aktif

### Data tidak muncul
- Cek console untuk error messages
- Jalankan query di SQL Editor untuk verify data:
  ```sql
  SELECT * FROM projects;
  ```
- Pastikan RLS policies sudah di-enable

### Aplikasi menggunakan dummy data
- Ini normal jika Supabase belum di-setup
- Cek console log untuk pesan error
- Setup Supabase sesuai panduan di atas

## 📱 Testing di Aplikasi

### Untuk Mahasiswa (Student):
1. Login sebagai mahasiswa
2. Browse projects di Home
3. Projects akan dimuat dari Supabase
4. Klik project untuk lihat detail

### Untuk Dosen (Lecturer):
1. Login sebagai dosen
2. Klik tombol "+" untuk add project baru
3. Isi form dan klik "Post"
4. Project akan tersimpan di Supabase
5. Edit project dengan klik "Edit" di detail
6. Update akan langsung sync ke database

## 📋 Setup CRUD Portfolio

Setelah CRUD Project berhasil, ikuti langkah berikut untuk CRUD Portfolio:

### 1. Setup Database Portfolio

1. Buka **SQL Editor** di Supabase Dashboard
2. Copy semua isi dari file `portfolio_supabase_setup.sql`
3. Paste ke SQL Editor dan **Run**
4. Verifikasi dengan query:
   ```sql
   SELECT * FROM portfolio_projects;
   SELECT * FROM portfolio_certificates;
   SELECT * FROM portfolio_organizations;
   ```

### 2. Struktur Database Portfolio

**Tabel: `portfolio_projects`**
- id, title, lecturer, deadline, description
- requirements (JSONB), benefits (JSONB)
- created_at, updated_at

**Tabel: `portfolio_certificates`**
- id, title, issuer, start_date, end_date
- skills (JSONB), certificate_file
- created_at, updated_at

**Tabel: `portfolio_organizations`**
- id, title, position, duration, description
- created_at, updated_at

### 3. Test Portfolio CRUD

- Buka Profile → Portfolio
- Tambah portfolio baru (Sertifikat/Organisasi)
- Data akan tersimpan di Supabase
- Edit dan delete juga sudah terintegrasi

## 🔄 Next Steps

Fitur yang sudah selesai:
- ✅ CRUD Project
- ✅ CRUD Portfolio

Fitur yang bisa ditambahkan:
- [ ] Authentication (login/register via Supabase Auth)
- [ ] Manage Applicants & Members
- [ ] Real-time subscriptions
- [ ] File upload untuk certificate ke Supabase Storage
- [ ] Search & Filter projects
- [ ] User profiles dengan avatar

## 📚 Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

## 💬 Need Help?

Jika ada masalah, cek:
1. Console logs di aplikasi
2. Supabase Dashboard > Logs
3. SQL Editor untuk test queries

---

**Happy Coding! 🎉**
