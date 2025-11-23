# SETUP & TESTING GUIDE - UNIWORK

## 📋 RINGKASAN PERUBAHAN

### Masalah yang Diperbaiki:
1. ❌ **Bug**: Setelah mahasiswa mendaftar project, status project berubah menjadi "Pendaftaran ditutup"
2. ✅ **Fix**: Status project tetap "Tersedia" setelah mahasiswa mendaftar. Status hanya berubah ketika dosen menutup pendaftaran secara manual.

### Fitur Baru:
1. ✅ Sistem login dengan database Supabase
2. ✅ Tabel `users` untuk menyimpan data mahasiswa dan dosen
3. ✅ Tabel `project_applicants` untuk menyimpan data pendaftar
4. ✅ 3 Akun dummy (2 mahasiswa, 1 dosen)

---

## 🔧 CARA SETUP DATABASE

### 1. Buka Supabase Dashboard
- Login ke https://supabase.com
- Pilih project "uniwork" atau project yang sudah ada

### 2. Jalankan SQL Script
- Buka **SQL Editor**
- Copy isi file `complete_supabase_setup.sql`
- Paste dan klik **Run**
- Tunggu sampai selesai (akan ada notifikasi success)

### 2b. Tambahkan Kolom user_id ke Portfolio (PENTING!)
- Copy isi file `add_user_id_to_portfolio.sql`
- Paste dan klik **Run**
- Ini menambahkan kolom `user_id` ke tabel portfolio untuk menghubungkan dengan user

### 3. Verifikasi Data
Jalankan query berikut di SQL Editor untuk memastikan data sudah masuk:

```sql
-- Cek users (harus ada 3 users)
SELECT * FROM users ORDER BY role, full_name;

-- Cek projects (harus ada 3 projects)
SELECT id, title, status, posted_at FROM projects ORDER BY posted_at DESC;

-- Cek applicants (masih kosong sebelum testing)
SELECT * FROM project_applicants;
```

---

## 👥 AKUN DUMMY UNTUK TESTING

### Mahasiswa 1:
- **Email**: `isra@student.com`
- **Password**: `password123`
- **Nama**: Muhammad Isra Alfattah
- **Program**: Prodi Informatika (S1)

### Mahasiswa 2:
- **Email**: `aldi@student.com`
- **Password**: `password123`
- **Nama**: Aldi Pratama
- **Program**: Prodi Sistem Informasi (S1)

### Dosen:
- **Email**: `budi.santoso@lecturer.com`
- **Password**: `password123`
- **Nama**: Dr. Budi Santoso, S.Kom., M.T.

---

## 🧪 CARA TESTING

### Test 1: Login sebagai Mahasiswa
1. Buka aplikasi
2. Login dengan email: `isra@student.com`, password: `password123`
3. ✅ Harus masuk ke Home Screen mahasiswa
4. Buka **Profile** (tab paling kanan)
5. ✅ Nama harus muncul: "Muhammad Isra Alfattah"
6. ✅ Program harus muncul: "Prodi Informatika (S1)"
7. ✅ Avatar harus muncul sesuai data user

### Test 2: Mendaftar Project
1. Login sebagai mahasiswa (isra@student.com)
2. Pilih salah satu project
3. Klik tombol **Daftar >>**
4. Konfirmasi pendaftaran
5. ✅ Harus muncul notifikasi "Pendaftaran project berhasil dilakukan!"

### Test 3: Verifikasi Status Project Tidak Berubah
1. Setelah mendaftar project di Test 2
2. **Logout** (jika ada fitur logout) atau restart aplikasi
3. Login sebagai **Dosen** (budi.santoso@lecturer.com, password123)
4. Lihat list project di halaman dosen
5. ✅ **Status project HARUS TETAP "Tersedia"** (BUKAN "Pendaftaran ditutup")
6. Buka detail project → Klik **List Anggota** → Klik tombol **Pendaftar**
7. ✅ Harus muncul **"Muhammad Isra Alfattah"** di list pendaftar
8. ✅ Nama mahasiswa, program, dan avatar harus tampil dengan benar

### Test 4: Verifikasi Data Pendaftar di Database
Jalankan query ini di Supabase SQL Editor:

```sql
-- Cek applicants setelah mahasiswa mendaftar
SELECT 
  pa.id,
  pa.project_id,
  p.title as project_title,
  u.full_name as student_name,
  u.email as student_email,
  pa.status,
  pa.applied_at
FROM project_applicants pa
JOIN projects p ON p.id = pa.project_id
JOIN users u ON u.id = pa.student_id
ORDER BY pa.applied_at DESC;
```

✅ Harus muncul data pendaftar dengan:
- project_title: (nama project yang didaftar)
- student_name: Muhammad Isra Alfattah
- student_email: isra@student.com
- status: pending

### Test 4b: Dosen Terima/Tolak Pendaftar
1. Login sebagai Dosen
2. Buka project yang ada pendaftar → List Anggota → Pendaftar
3. Klik tombol **Terima** pada salah satu pendaftar
4. ✅ Pendaftar hilang dari list "Pendaftar"
5. Klik tab **Anggota**
6. ✅ Mahasiswa yang diterima muncul di list "Anggota"

### Test 4c: Dosen Lihat Profil Mahasiswa dari List Anggota
1. Login sebagai Dosen
2. Buka project → List Anggota → Tab **Anggota**
3. **Klik salah satu card anggota**
4. ✅ Diarahkan ke halaman profil mahasiswa tersebut
5. ✅ Tampil: Avatar, Nama, Program Studi, dan Portfolio mahasiswa
6. ✅ Portfolio di-load dari database berdasarkan user_id
7. Klik tombol **Back** (panah kiri atas)
8. ✅ Kembali ke List Anggota

### Test 5: Mendaftar dengan Mahasiswa Kedua
1. Logout dari mahasiswa pertama
2. Login sebagai mahasiswa kedua (aldi@student.com, password123)
3. Buka **Profile** untuk verifikasi identitas
   - ✅ Nama: "Aldi Pratama" (BUKAN "Muhammad Isra Alfattah")
   - ✅ Program: "Prodi Sistem Informasi (S1)"
4. Daftar ke project yang SAMA dengan Test 2
5. ✅ Harus berhasil mendaftar
6. ✅ Status project TETAP "Tersedia"

### Test 6: Login sebagai Dosen dan Verifikasi Identitas
1. Logout dari mahasiswa
2. Login sebagai Dosen (budi.santoso@lecturer.com, password123)
3. Buka **Profile** (tab paling kanan)
   - ✅ Nama: "Dr. Budi Santoso, S.Kom., M.T." (BUKAN "Muhammad Isra Alfattah")
   - ✅ Role: "Dosen"
4. ✅ Lihat list project dengan status yang benar

### Test 7: Dosen Menutup Pendaftaran (Manual)
1. Login sebagai Dosen
2. Buka detail project yang sudah ada pendaftar
3. Klik tombol **Tutup Pendaftaran** (jika ada di UI)
4. ✅ Status project berubah menjadi "Diproses"

---

## 📊 STRUKTUR DATABASE BARU

### Tabel `users`
```
id          | UUID (PK)
email       | TEXT (unique)
password    | TEXT
full_name   | TEXT
role        | TEXT ('mahasiswa' / 'dosen')
program     | TEXT (nullable, untuk mahasiswa)
avatar_url  | TEXT (nullable)
created_at  | TIMESTAMPTZ
```

### Tabel `project_applicants`
```
id          | UUID (PK)
project_id  | UUID (FK -> projects.id)
student_id  | UUID (FK -> users.id)
status      | TEXT ('pending' / 'accepted' / 'rejected')
applied_at  | TIMESTAMPTZ
```

### Tabel `project_members`
```
id          | UUID (PK)
project_id  | UUID (FK -> projects.id)
student_id  | UUID (FK -> users.id)
joined_at   | TIMESTAMPTZ
```

---

## 🔄 LOGIC FLOW BARU

### SEBELUM (Bug):
```
Mahasiswa mendaftar → Status project berubah ke "Diproses" ❌
Dosen tidak bisa lihat pendaftar ❌
```

### SESUDAH (Fixed):
```
1. Mahasiswa mendaftar → Data masuk ke tabel project_applicants ✅
2. Status project TETAP "Tersedia" ✅
3. Dosen buka screen "Pendaftar" → Load data dari database ✅
4. Dosen bisa lihat list applicants dengan data lengkap (nama, program, avatar) ✅
5. Dosen terima applicant → Pindah ke tabel project_members ✅
6. Dosen tolak applicant → Status jadi 'rejected' di tabel ✅
7. Dosen menutup pendaftaran (manual) → Status berubah ke "Diproses" ✅
```

---

## 🚨 TROUBLESHOOTING

### Error: "Gagal mendaftar project"
- Pastikan sudah login sebagai mahasiswa
- Pastikan SQL script sudah dijalankan di Supabase
- Cek console untuk error detail

### Error: "Anda sudah mendaftar ke project ini sebelumnya"
- Ini adalah validasi normal - satu mahasiswa hanya bisa mendaftar 1x per project
- Jika ingin test lagi, hapus data di tabel `project_applicants`:
  ```sql
  DELETE FROM project_applicants WHERE student_id = '22222222-2222-2222-2222-222222222222';
  ```

### Error: "Invalid image data" pada avatar
- Avatar menggunakan DiceBear API yang mengembalikan PNG
- Jika avatar tidak muncul, jalankan script `fix_avatar_urls.sql` di Supabase SQL Editor
- Atau pastikan URL avatar di tabel users menggunakan format PNG bukan SVG

### Error: "Email atau password salah"
- Pastikan email ditulis lengkap dengan @student.com atau @lecturer.com
- Pastikan password: `password123` (huruf kecil semua)
- Pastikan tabel users sudah terisi (jalankan query SELECT * FROM users)

### Status project tetap berubah jadi "Diproses" setelah mendaftar
- Pastikan code sudah di-update (git pull latest)
- Pastikan restart aplikasi (hot reload mungkin tidak cukup)
- Cek file `lib/providers/project_provider.dart` method `registerProject` harus menggunakan `addApplicant` BUKAN `updateProjectStatus`

---

## 📝 NOTES PENTING

1. **Password Plain Text**: Saat ini password disimpan plain text untuk demo. Di production harus menggunakan Supabase Auth atau hashing.

2. **RLS Policies**: Saat ini menggunakan public access untuk development. Di production harus diubah ke authenticated users only.

3. **Avatar URL**: Menggunakan DiceBear API (free) untuk generate avatar random dalam format PNG.

4. **Role Toggle**: UI login masih ada role toggle (Mahasiswa/Dosen) tapi tidak terpakai karena role diambil dari database.

5. **Logout**: Sudah ada fitur logout di Profile screen.

6. **Duplicate Registration**: Satu mahasiswa hanya bisa mendaftar 1x per project. Jika mencoba mendaftar lagi akan muncul error "Anda sudah mendaftar ke project ini sebelumnya".

---

## ✅ CHECKLIST TESTING

- [ ] Database sudah di-setup dengan `complete_supabase_setup.sql`
- [ ] Bisa login dengan ketiga akun dummy
- [ ] **Profile mahasiswa menampilkan nama dan program sesuai akun yang login**
- [ ] **Profile dosen menampilkan nama dan role "Dosen"**
- [ ] Mahasiswa bisa mendaftar project
- [ ] Status project TETAP "Tersedia" setelah mahasiswa mendaftar
- [ ] Data pendaftar muncul di tabel `project_applicants`
- [ ] Mahasiswa kedua bisa mendaftar ke project yang sama
- [ ] **Setiap user yang login menampilkan identitas yang berbeda-beda**
- [ ] Dosen bisa melihat project dengan status yang benar

---

## 📞 NEED HELP?

Jika ada error atau pertanyaan:
1. Cek console log di VS Code (Debug Console)
2. Cek log di Supabase Dashboard > Logs
3. Screenshot error dan kirim untuk debugging

---

**File ini dibuat pada**: 23 November 2025  
**Versi**: 1.0  
**Last Updated**: Fix bug status project + implement user authentication
