# Migration Guide - Update Project Status Constraint

## Masalah
Error terjadi saat mencoba menyelesaikan project:
```
PostgrestException: new row for relation "projects" violates check constraint "projects_status_check"
```

## Penyebab
Constraint di database hanya mengizinkan status: `'tersedia'`, `'diproses'`, `'diterima'`  
Tetapi aplikasi mencoba menggunakan status baru: `'selesai'`

## Solusi: Jalankan Migration SQL

### Langkah 1: Buka Supabase Dashboard
1. Login ke [Supabase Dashboard](https://app.supabase.com)
2. Pilih project Anda
3. Klik menu **SQL Editor** di sidebar kiri

### Langkah 2: Jalankan Migration Script
Copy dan paste script berikut ke SQL Editor, kemudian klik **Run**:

```sql
-- Drop constraint lama
ALTER TABLE projects 
DROP CONSTRAINT IF EXISTS projects_status_check;

-- Tambahkan constraint baru dengan status 'selesai'
ALTER TABLE projects 
ADD CONSTRAINT projects_status_check 
CHECK (status IN ('tersedia', 'diproses', 'diterima', 'selesai'));
```

### Langkah 3: Verifikasi
Jalankan query berikut untuk memastikan constraint sudah terupdate:

```sql
SELECT conname, pg_get_constraintdef(oid) 
FROM pg_constraint 
WHERE conrelid = 'projects'::regclass 
AND conname = 'projects_status_check';
```

Expected output:
```
CHECK (status IN ('tersedia', 'diproses', 'diterima', 'selesai'))
```

## Status Project yang Tersedia

Setelah migration, status project yang valid:

| Status | Deskripsi |
|--------|-----------|
| `tersedia` | Project baru, pendaftaran terbuka |
| `diproses` | Pendaftaran ditutup, project sedang dikerjakan |
| `diterima` | (legacy, untuk compatibility) |
| `selesai` | Project sudah selesai dikerjakan |

## Flow Status Project

```
tersedia → (Tutup Pendaftaran) → diproses → (Selesaikan Project) → selesai
```

## File Terkait
- `update_project_status_constraint.sql` - Migration script standalone
- `complete_supabase_setup.sql` - Setup lengkap (sudah include constraint baru)
- `supabase_setup.sql` - Setup dasar (sudah include constraint baru)

## Troubleshooting

**Q: Masih error setelah menjalankan migration?**  
A: Pastikan Anda sudah klik tombol "Run" di SQL Editor dan tidak ada error message yang muncul.

**Q: Apakah data existing akan hilang?**  
A: Tidak, migration ini hanya mengubah constraint, tidak menghapus data apapun.

**Q: Apakah perlu restart aplikasi Flutter?**  
A: Tidak perlu, cukup jalankan migration di Supabase Dashboard.
