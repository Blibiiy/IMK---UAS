# Troubleshooting Login - UniWork

## ❌ Error yang Sering Terjadi

### 1. PostgrestException: Internal server error (code: 556)

**Penyebab:**
- Tabel `users` belum dibuat di Supabase
- RLS (Row Level Security) policy belum dikonfigurasi dengan benar
- Koneksi ke database gagal

**Solusi:**
1. **Pastikan tabel sudah dibuat:**
   - Buka Supabase Dashboard → SQL Editor
   - Jalankan script `complete_supabase_setup.sql`
   - Verifikasi tabel dibuat dengan query:
     ```sql
     SELECT * FROM users;
     ```

2. **Pastikan RLS Policy sudah benar:**
   - Buka Supabase Dashboard → Authentication → Policies
   - Pastikan policy "Allow all access to users" aktif
   - Atau jalankan SQL berikut untuk memastikan:
     ```sql
     -- Enable RLS
     ALTER TABLE users ENABLE ROW LEVEL SECURITY;
     
     -- Create permissive policy untuk development
     DROP POLICY IF EXISTS "Allow all access to users" ON users;
     CREATE POLICY "Allow all access to users"
     ON users FOR ALL TO public USING (true) WITH CHECK (true);
     ```

3. **Cek koneksi Supabase:**
   - Verifikasi URL dan Anon Key di `lib/config/supabase_config.dart`
   - Pastikan tidak ada typo
   - Pastikan project Supabase masih aktif

### 2. Email atau Password Salah

**Penyebab:**
- Data user belum diinsert ke database
- Typo pada email/password

**Solusi:**
1. **Verifikasi data users ada:**
   ```sql
   SELECT email, full_name, role FROM users ORDER BY role;
   ```

2. **Jika data kosong, insert data demo:**
   ```sql
   -- Jalankan section INSERT DUMMY DATA dari complete_supabase_setup.sql
   -- Atau insert manual:
   INSERT INTO users (email, password, full_name, role, program)
   VALUES 
     ('isra@student.com', 'password123', 'Muhammad Isra Alfattah', 'mahasiswa', 'Prodi Informatika (S1)'),
     ('budi.santoso@lecturer.com', 'password123', 'Dr. Budi Santoso, S.Kom., M.T.', 'dosen', NULL);
   ```

## ✅ Akun Demo yang Tersedia

Setelah menjalankan `complete_supabase_setup.sql`, akun berikut tersedia:

### Mahasiswa:
- **Email:** `isra@student.com`
- **Password:** `password123`
- **Nama:** Muhammad Isra Alfattah
- **Program:** Prodi Informatika (S1)

- **Email:** `aldi@student.com`
- **Password:** `password123`
- **Nama:** Aldi Pratama
- **Program:** Prodi Sistem Informasi (S1)

### Dosen:
- **Email:** `budi.santoso@lecturer.com`
- **Password:** `password123`
- **Nama:** Dr. Budi Santoso, S.Kom., M.T.

- **Email:** `siti.nurhaliza@lecturer.com`
- **Password:** `password123`
- **Nama:** Prof. Dr. Siti Nurhaliza, M.Kom.

## 🔍 Cara Verifikasi Database

### 1. Cek Apakah Tabel Ada:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('users', 'projects', 'project_applicants', 'project_members');
```

### 2. Cek Jumlah Users:
```sql
SELECT role, COUNT(*) as total 
FROM users 
GROUP BY role;
```

### 3. Test Query Login Manual:
```sql
SELECT * FROM users 
WHERE email = 'isra@student.com';
```

### 4. Cek RLS Policies:
```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'users';
```

## 🛠️ Setup Ulang Database (Jika Perlu)

Jika semua cara di atas tidak berhasil, lakukan setup ulang:

1. **Backup data penting** (jika ada)

2. **Drop semua tabel:**
   ```sql
   DROP TABLE IF EXISTS project_members CASCADE;
   DROP TABLE IF EXISTS project_applicants CASCADE;
   DROP TABLE IF EXISTS projects CASCADE;
   DROP TABLE IF EXISTS users CASCADE;
   ```

3. **Jalankan ulang setup:**
   - Copy semua isi file `complete_supabase_setup.sql`
   - Paste di Supabase SQL Editor
   - Run

4. **Verifikasi:**
   ```sql
   -- Harus ada 4 users
   SELECT COUNT(*) FROM users;
   
   -- Harus ada 3 projects
   SELECT COUNT(*) FROM projects;
   ```

## 📝 Catatan Penting

1. **Password Plain Text:**
   - Untuk demo/development, password disimpan plain text
   - Ini TIDAK aman untuk production
   - Di production seharusnya menggunakan Supabase Auth atau hash password

2. **RLS Policy Permissive:**
   - Policy saat ini mengizinkan semua akses (untuk development)
   - Di production, implementasikan policy yang lebih ketat

3. **Tidak Menggunakan Supabase Auth:**
   - Aplikasi ini tidak menggunakan `supabase.auth.signIn()`
   - Login dilakukan dengan query langsung ke tabel `users`
   - Ini sengaja untuk kemudahan demo karena akun dibuat dari luar

## 🐛 Debug Mode

Untuk melihat error lebih detail, perhatikan console output di aplikasi:

```dart
// Sudah ada di SupabaseService.login()
print('User not found with email: $email');
print('Invalid password for: $email');
print('Login successful for: $email');
```

Dan di UserProvider:
```dart
print('Login error details: $e');
```

## 📞 Kontak Support

Jika masih ada masalah:
1. Screenshot error message
2. Check console log
3. Export query dari Supabase SQL Editor
4. Verifikasi koneksi internet stabil
