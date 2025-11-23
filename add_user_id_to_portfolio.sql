-- ============================================
-- ADD user_id COLUMN TO PORTFOLIO TABLES
-- ============================================
-- Script ini menambahkan kolom user_id ke semua tabel portfolio
-- untuk mengaitkan portfolio dengan user (mahasiswa)

-- 1. Tambah kolom user_id ke portfolio_projects
ALTER TABLE portfolio_projects 
ADD COLUMN IF NOT EXISTS user_id UUID;

-- Set default value untuk data yang sudah ada (opsional - sesuaikan dengan kebutuhan)
-- UPDATE portfolio_projects SET user_id = '11111111-1111-1111-1111-111111111111' WHERE user_id IS NULL;

-- Tambah foreign key constraint (opsional - untuk data integrity)
-- ALTER TABLE portfolio_projects 
-- ADD CONSTRAINT fk_portfolio_projects_user 
-- FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 2. Tambah kolom user_id ke portfolio_certificates
ALTER TABLE portfolio_certificates 
ADD COLUMN IF NOT EXISTS user_id UUID;

-- SET default value untuk data yang sudah ada (opsional)
-- UPDATE portfolio_certificates SET user_id = '11111111-1111-1111-1111-111111111111' WHERE user_id IS NULL;

-- Tambah foreign key constraint (opsional)
-- ALTER TABLE portfolio_certificates 
-- ADD CONSTRAINT fk_portfolio_certificates_user 
-- FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 3. Tambah kolom user_id ke portfolio_organizations
ALTER TABLE portfolio_organizations 
ADD COLUMN IF NOT EXISTS user_id UUID;

-- SET default value untuk data yang sudah ada (opsional)
-- UPDATE portfolio_organizations SET user_id = '11111111-1111-1111-1111-111111111111' WHERE user_id IS NULL;

-- Tambah foreign key constraint (opsional)
-- ALTER TABLE portfolio_organizations 
-- ADD CONSTRAINT fk_portfolio_organizations_user 
-- FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 4. Tambah index untuk performa query
CREATE INDEX IF NOT EXISTS idx_portfolio_projects_user_id ON portfolio_projects(user_id);
CREATE INDEX IF NOT EXISTS idx_portfolio_certificates_user_id ON portfolio_certificates(user_id);
CREATE INDEX IF NOT EXISTS idx_portfolio_organizations_user_id ON portfolio_organizations(user_id);

-- 5. Verifikasi struktur tabel
-- SELECT column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name = 'portfolio_projects' AND column_name = 'user_id';

-- ============================================
-- NOTES:
-- ============================================
-- 1. Kolom user_id menghubungkan portfolio dengan tabel users
-- 2. Untuk data yang sudah ada, bisa diset manual atau lewat UPDATE query
-- 3. Foreign key constraint akan memastikan referential integrity
-- 4. Index akan mempercepat query pencarian portfolio by user_id
