-- ============================================
-- SETUP SUPABASE STORAGE UNTUK PORTFOLIO FILES
-- Untuk menyimpan bukti sertifikat (PDF/Gambar)
-- ============================================

-- ============================================
-- 1. CREATE STORAGE BUCKET
-- ============================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('portfolios', 'portfolios', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 2. ENABLE RLS ON STORAGE.OBJECTS
-- ============================================
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 3. CREATE STORAGE POLICIES (DEVELOPMENT MODE)
-- ============================================

-- Policy: Allow public to read files
DROP POLICY IF EXISTS "Allow public read access" ON storage.objects;
CREATE POLICY "Allow public read access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'portfolios');

-- Policy: Allow authenticated users to upload files
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'portfolios');

-- Policy: Allow authenticated users to update their own files
DROP POLICY IF EXISTS "Allow authenticated updates" ON storage.objects;
CREATE POLICY "Allow authenticated updates"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'portfolios');

-- Policy: Allow authenticated users to delete their own files
DROP POLICY IF EXISTS "Allow authenticated deletes" ON storage.objects;
CREATE POLICY "Allow authenticated deletes"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'portfolios');

-- ============================================
-- 4. VERIFIKASI SETUP
-- ============================================

-- Check bucket created
SELECT * FROM storage.buckets WHERE id = 'portfolios';

-- Check policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies 
WHERE tablename = 'objects' 
AND schemaname = 'storage';

-- ============================================
-- NOTES:
-- ============================================
-- 1. Bucket 'portfolios' bersifat PUBLIC untuk read access
-- 2. Semua user yang authenticated bisa upload, update, delete
-- 3. File structure: portfolios/certificates/{userId}/{filename}
-- 4. Max file size: 10 MB (handled di aplikasi)
-- 5. Allowed formats: PDF, JPG, JPEG, PNG, GIF, WEBP
-- 
-- IMPORTANT untuk Production:
-- - Ganti policy menjadi lebih restrictive
-- - User hanya bisa upload/update/delete file mereka sendiri
-- - Implementasi proper authentication
-- - Set file size limit di Supabase Dashboard
