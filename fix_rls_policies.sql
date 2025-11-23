-- ============================================
-- FIX RLS POLICIES UNTUK DEVELOPMENT
-- Jalankan script ini untuk memperbaiki error RLS
-- ============================================

-- 1. DROP EXISTING POLICIES untuk portfolio_organizations
DROP POLICY IF EXISTS "Allow public read access to portfolio organizations" ON portfolio_organizations;
DROP POLICY IF EXISTS "Allow authenticated users to insert portfolio organizations" ON portfolio_organizations;
DROP POLICY IF EXISTS "Allow authenticated users to update portfolio organizations" ON portfolio_organizations;
DROP POLICY IF EXISTS "Allow authenticated users to delete portfolio organizations" ON portfolio_organizations;

-- 2. CREATE NEW POLICIES yang mengizinkan akses PUBLIC (untuk development)
CREATE POLICY "Allow all access to portfolio organizations"
ON portfolio_organizations
FOR ALL
TO public
USING (true)
WITH CHECK (true);

-- 3. DROP EXISTING POLICIES untuk portfolio_projects
DROP POLICY IF EXISTS "Allow public read access to portfolio projects" ON portfolio_projects;
DROP POLICY IF EXISTS "Allow authenticated users to insert portfolio projects" ON portfolio_projects;
DROP POLICY IF EXISTS "Allow authenticated users to update portfolio projects" ON portfolio_projects;
DROP POLICY IF EXISTS "Allow authenticated users to delete portfolio projects" ON portfolio_projects;

-- 4. CREATE NEW POLICIES untuk portfolio_projects
CREATE POLICY "Allow all access to portfolio projects"
ON portfolio_projects
FOR ALL
TO public
USING (true)
WITH CHECK (true);

-- 5. DROP EXISTING POLICIES untuk portfolio_certificates
DROP POLICY IF EXISTS "Allow public read access to portfolio certificates" ON portfolio_certificates;
DROP POLICY IF EXISTS "Allow authenticated users to insert portfolio certificates" ON portfolio_certificates;
DROP POLICY IF EXISTS "Allow authenticated users to update portfolio certificates" ON portfolio_certificates;
DROP POLICY IF EXISTS "Allow authenticated users to delete portfolio certificates" ON portfolio_certificates;

-- 6. CREATE NEW POLICIES untuk portfolio_certificates
CREATE POLICY "Allow all access to portfolio certificates"
ON portfolio_certificates
FOR ALL
TO public
USING (true)
WITH CHECK (true);

-- 7. JUGA FIX untuk tabel projects jika ada masalah serupa
DROP POLICY IF EXISTS "Allow public read access to projects" ON projects;
DROP POLICY IF EXISTS "Allow authenticated users to insert projects" ON projects;
DROP POLICY IF EXISTS "Allow authenticated users to update projects" ON projects;
DROP POLICY IF EXISTS "Allow authenticated users to delete projects" ON projects;

CREATE POLICY "Allow all access to projects"
ON projects
FOR ALL
TO public
USING (true)
WITH CHECK (true);

-- ============================================
-- VERIFIKASI
-- ============================================
-- Cek policies yang aktif:
-- SELECT tablename, policyname, permissive, roles, cmd, qual, with_check 
-- FROM pg_policies 
-- WHERE schemaname = 'public' 
-- AND tablename IN ('portfolio_projects', 'portfolio_certificates', 'portfolio_organizations', 'projects');

-- ============================================
-- NOTES PENTING:
-- ============================================
-- 1. Policy ini HANYA untuk DEVELOPMENT
-- 2. Untuk PRODUCTION, gunakan authentication dan policy yang lebih ketat:
--    - Hanya owner yang bisa edit/delete portfolio sendiri
--    - Semua orang bisa read portfolio public
-- 3. Setelah implement authentication, update policy ini

-- ============================================
-- CONTOH POLICY UNTUK PRODUCTION (setelah ada auth):
-- ============================================
/*
-- Policy untuk user hanya bisa CRUD portfolio sendiri:
CREATE POLICY "Users can CRUD own portfolio organizations"
ON portfolio_organizations
FOR ALL
TO authenticated
USING (auth.uid()::text = user_id)
WITH CHECK (auth.uid()::text = user_id);

-- Semua orang bisa read:
CREATE POLICY "Anyone can read portfolio organizations"
ON portfolio_organizations
FOR SELECT
TO public
USING (true);
*/
