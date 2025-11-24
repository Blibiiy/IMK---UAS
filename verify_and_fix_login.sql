-- ============================================
-- SCRIPT VERIFIKASI DAN PERBAIKAN LOGIN
-- Jalankan script ini di Supabase SQL Editor
-- ============================================

-- ============================================
-- STEP 1: VERIFIKASI TABEL ADA
-- ============================================
SELECT 
    'users' as table_name,
    EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'users'
    ) as exists;

-- ============================================
-- STEP 2: CEK RLS STATUS
-- ============================================
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables
WHERE tablename = 'users';

-- ============================================
-- STEP 3: CEK RLS POLICIES
-- ============================================
SELECT 
    policyname,
    permissive,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'users';

-- ============================================
-- STEP 4: PASTIKAN RLS POLICY BENAR
-- ============================================
-- Hapus policy lama
DROP POLICY IF EXISTS "Allow all access to users" ON users;
DROP POLICY IF EXISTS "Enable read access for all users" ON users;
DROP POLICY IF EXISTS "Enable insert for all users" ON users;
DROP POLICY IF EXISTS "Enable update for all users" ON users;

-- Buat policy baru yang permissive (untuk development)
CREATE POLICY "Allow all access to users"
ON users FOR ALL 
TO public
USING (true) 
WITH CHECK (true);

-- ============================================
-- STEP 5: VERIFIKASI DATA USERS ADA
-- ============================================
SELECT 
    email,
    full_name,
    role,
    program,
    CASE 
        WHEN password = 'password123' THEN '✓ Correct'
        ELSE '✗ Wrong password'
    END as password_check
FROM users
ORDER BY role, email;

-- ============================================
-- STEP 6: JIKA DATA USERS KOSONG, INSERT DATA DEMO
-- ============================================
-- Jalankan hanya jika query di atas tidak mengembalikan data

INSERT INTO users (email, password, full_name, role, program, avatar_url)
VALUES 
  -- Mahasiswa 1
  (
    'isra@student.com',
    'password123',
    'Muhammad Isra Alfattah',
    'mahasiswa',
    'Prodi Informatika (S1)',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Isra'
  ),
  -- Mahasiswa 2
  (
    'aldi@student.com',
    'password123',
    'Aldi Pratama',
    'mahasiswa',
    'Prodi Sistem Informasi (S1)',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Aldi'
  ),
  -- Dosen 1
  (
    'budi.santoso@lecturer.com',
    'password123',
    'Dr. Budi Santoso, S.Kom., M.T.',
    'dosen',
    NULL,
    'https://api.dicebear.com/7.x/avataaars/png?seed=Budi'
  ),
  -- Dosen 2
  (
    'siti.nurhaliza@lecturer.com',
    'password123',
    'Prof. Dr. Siti Nurhaliza, M.Kom.',
    'dosen',
    NULL,
    'https://api.dicebear.com/7.x/avataaars/png?seed=Siti'
  )
ON CONFLICT (email) DO NOTHING;

-- ============================================
-- STEP 7: TEST QUERY LOGIN
-- ============================================
-- Test dengan email mahasiswa
SELECT 
    'TEST MAHASISWA' as test_type,
    email,
    full_name,
    role,
    CASE 
        WHEN password = 'password123' THEN '✓ Password match'
        ELSE '✗ Password not match'
    END as result
FROM users
WHERE email = 'isra@student.com';

-- Test dengan email dosen
SELECT 
    'TEST DOSEN' as test_type,
    email,
    full_name,
    role,
    CASE 
        WHEN password = 'password123' THEN '✓ Password match'
        ELSE '✗ Password not match'
    END as result
FROM users
WHERE email = 'budi.santoso@lecturer.com';

-- ============================================
-- STEP 8: VERIFIKASI FINAL
-- ============================================
SELECT 
    '✓ Setup Complete!' as status,
    COUNT(*) as total_users,
    COUNT(CASE WHEN role = 'mahasiswa' THEN 1 END) as total_mahasiswa,
    COUNT(CASE WHEN role = 'dosen' THEN 1 END) as total_dosen
FROM users;

-- ============================================
-- NOTES:
-- ============================================
-- Jika semua query di atas berhasil:
-- 1. Tabel users sudah ada
-- 2. RLS policy sudah benar
-- 3. Data users sudah tersedia
-- 4. Login seharusnya berhasil dengan:
--    - isra@student.com / password123
--    - budi.santoso@lecturer.com / password123
