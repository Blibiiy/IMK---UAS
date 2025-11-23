-- ============================================
-- SQL SCRIPT UNTUK SETUP DATABASE SUPABASE
-- UNIWORK PROJECT
-- ============================================
-- 
-- ⚠️ CATATAN PENTING:
-- File ini adalah versi LAMA (hanya setup tabel projects)
-- Gunakan file: complete_supabase_setup.sql
-- untuk setup lengkap dengan users, applicants, dan members
-- ============================================

-- 1. CREATE TABLE PROJECTS
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  supervisor TEXT NOT NULL,
  description TEXT NOT NULL,
  deadline TEXT NOT NULL,
  participants TEXT NOT NULL,
  requirements JSONB DEFAULT '[]'::jsonb,
  benefits JSONB DEFAULT '[]'::jsonb,
  status TEXT DEFAULT 'tersedia' CHECK (status IN ('tersedia', 'diproses', 'diterima')),
  posted_at TIMESTAMPTZ DEFAULT NOW(),
  edited_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CREATE INDEX untuk performa query yang lebih baik
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_posted_at ON projects(posted_at DESC);

-- 3. ENABLE ROW LEVEL SECURITY (RLS)
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- 4. CREATE POLICIES untuk RLS
-- Policy untuk membaca semua project (public read)
CREATE POLICY "Allow public read access to projects"
ON projects FOR SELECT
TO public
USING (true);

-- Policy untuk insert project (authenticated users only)
CREATE POLICY "Allow authenticated users to insert projects"
ON projects FOR INSERT
TO authenticated
WITH CHECK (true);

-- Policy untuk update project (authenticated users only)
CREATE POLICY "Allow authenticated users to update projects"
ON projects FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Policy untuk delete project (authenticated users only)
CREATE POLICY "Allow authenticated users to delete projects"
ON projects FOR DELETE
TO authenticated
USING (true);

-- 5. INSERT DATA DUMMY untuk testing (opsional)
INSERT INTO projects (title, supervisor, description, deadline, participants, requirements, benefits, status, posted_at)
VALUES 
  (
    'Project Deteksi Plat Nomor Kendaraan',
    'Dosen Pembimbing: Dr. Mas Isra, S.Kom., M.T.',
    'Project ini bertujuan untuk mengembangkan aplikasi mobile yang dapat mendeteksi dan membaca plat nomor kendaraan secara otomatis menggunakan teknologi computer vision dan machine learning.',
    '15 Desember 2025',
    '5',
    '["Menguasai Flutter", "Memahami Computer Vision", "Mampu bekerja dalam tim", "Komitmen tinggi terhadap project"]'::jsonb,
    '["Pengalaman praktis dalam pengembangan AI", "Sertifikat project", "Publikasi ilmiah"]'::jsonb,
    'tersedia',
    NOW()
  ),
  (
    'Aplikasi E-Learning Interaktif',
    'Dosen Pembimbing: Prof. Dr. Ahmad Santoso, M.Kom.',
    'Pengembangan platform e-learning yang interaktif dengan fitur video conference, quiz online, dan tracking progress mahasiswa.',
    '20 Januari 2026',
    '8',
    '["Menguasai Flutter/React Native", "Pengalaman dengan API Integration", "UI/UX Design skills", "Komunikasi yang baik"]'::jsonb,
    '["Portfolio project yang solid", "Networking dengan industri", "Recommendation letter"]'::jsonb,
    'tersedia',
    NOW() - INTERVAL '2 days'
  ),
  (
    'Sistem Monitoring IoT Greenhouse',
    'Dosen Pembimbing: Ir. Siti Nurhaliza, M.T.',
    'Membangun sistem monitoring dan kontrol greenhouse berbasis IoT untuk optimalisasi pertumbuhan tanaman dengan sensor suhu, kelembaban, dan cahaya.',
    '10 Februari 2026',
    '4',
    '["Pemahaman IoT dan sensor", "Programming Arduino/ESP32", "Mobile app development", "Analisis data"]'::jsonb,
    '["Hands-on experience dengan IoT", "Kolaborasi dengan pertanian modern", "Publikasi konferensi"]'::jsonb,
    'diproses',
    NOW() - INTERVAL '5 days'
  );

-- 6. CREATE FUNCTION untuk auto-update edited_at
CREATE OR REPLACE FUNCTION update_edited_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.edited_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. CREATE TRIGGER untuk auto-update edited_at
DROP TRIGGER IF EXISTS set_edited_at ON projects;
CREATE TRIGGER set_edited_at
BEFORE UPDATE ON projects
FOR EACH ROW
EXECUTE FUNCTION update_edited_at_column();

-- ============================================
-- VERIFIKASI SETUP
-- ============================================
-- Jalankan query berikut untuk memverifikasi:
-- SELECT * FROM projects ORDER BY posted_at DESC;

-- ============================================
-- NOTES:
-- ============================================
-- 1. Untuk production, sesuaikan RLS policies sesuai kebutuhan keamanan
-- 2. Backup database secara berkala
-- 3. Monitor performa query dengan EXPLAIN ANALYZE
-- 4. Pertimbangkan untuk menambahkan full-text search jika diperlukan
