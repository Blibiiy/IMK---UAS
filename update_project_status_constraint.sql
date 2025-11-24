-- ============================================
-- MIGRATION: UPDATE PROJECT STATUS CONSTRAINT
-- Menambahkan status 'selesai' ke constraint projects.status
-- ============================================

-- Jalankan script ini di Supabase SQL Editor untuk update constraint

-- 1. Drop constraint lama
ALTER TABLE projects 
DROP CONSTRAINT IF EXISTS projects_status_check;

-- 2. Tambahkan constraint baru dengan status 'selesai'
ALTER TABLE projects 
ADD CONSTRAINT projects_status_check 
CHECK (status IN ('tersedia', 'diproses', 'diterima', 'selesai'));

-- 3. Verifikasi perubahan
-- Uncomment baris berikut untuk melihat constraint yang baru:
-- SELECT conname, pg_get_constraintdef(oid) 
-- FROM pg_constraint 
-- WHERE conrelid = 'projects'::regclass AND conname = 'projects_status_check';

-- ============================================
-- NOTES:
-- ============================================
-- Status yang tersedia sekarang:
-- - 'tersedia': Project baru, pendaftaran terbuka
-- - 'diproses': Pendaftaran ditutup, project sedang dikerjakan
-- - 'diterima': (untuk compatibility, bisa dihapus jika tidak digunakan)
-- - 'selesai': Project sudah selesai dikerjakan
-- ============================================
