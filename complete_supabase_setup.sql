-- ============================================
-- COMPLETE SQL SCRIPT UNTUK SETUP DATABASE SUPABASE
-- UNIWORK PROJECT - LENGKAP DENGAN USERS & APPLICANTS
-- ============================================

-- ============================================
-- 1. TABEL USERS (Mahasiswa & Dosen)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL, -- Untuk demo, di production gunakan Supabase Auth
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('mahasiswa', 'dosen')),
  program TEXT, -- Untuk mahasiswa: 'Prodi Informatika (S1)', dll
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 2. TABEL PROJECTS (sudah ada, pastikan struktur benar)
-- ============================================
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

-- ============================================
-- 3. TABEL PROJECT APPLICANTS (Pendaftar)
-- ============================================
CREATE TABLE IF NOT EXISTS project_applicants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  applied_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(project_id, student_id) -- Satu mahasiswa hanya bisa daftar sekali per project
);

-- ============================================
-- 4. TABEL PROJECT MEMBERS (Anggota yang diterima)
-- ============================================
CREATE TABLE IF NOT EXISTS project_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(project_id, student_id) -- Satu mahasiswa hanya bisa join sekali per project
);

-- ============================================
-- 5. CREATE INDEXES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_posted_at ON projects(posted_at DESC);
CREATE INDEX IF NOT EXISTS idx_applicants_project ON project_applicants(project_id);
CREATE INDEX IF NOT EXISTS idx_applicants_student ON project_applicants(student_id);
CREATE INDEX IF NOT EXISTS idx_members_project ON project_members(project_id);
CREATE INDEX IF NOT EXISTS idx_members_student ON project_members(student_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- ============================================
-- 6. ENABLE ROW LEVEL SECURITY
-- ============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_applicants ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_members ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 7. CREATE RLS POLICIES (DEVELOPMENT MODE - PUBLIC ACCESS)
-- ============================================

-- Users table policies
DROP POLICY IF EXISTS "Allow all access to users" ON users;
CREATE POLICY "Allow all access to users"
ON users FOR ALL TO public USING (true) WITH CHECK (true);

-- Projects table policies
DROP POLICY IF EXISTS "Allow all access to projects" ON projects;
CREATE POLICY "Allow all access to projects"
ON projects FOR ALL TO public USING (true) WITH CHECK (true);

-- Applicants table policies
DROP POLICY IF EXISTS "Allow all access to applicants" ON project_applicants;
CREATE POLICY "Allow all access to applicants"
ON project_applicants FOR ALL TO public USING (true) WITH CHECK (true);

-- Members table policies
DROP POLICY IF EXISTS "Allow all access to members" ON project_members;
CREATE POLICY "Allow all access to members"
ON project_members FOR ALL TO public USING (true) WITH CHECK (true);

-- ============================================
-- 8. CREATE TRIGGER FUNCTIONS
-- ============================================
CREATE OR REPLACE FUNCTION update_edited_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.edited_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 9. CREATE TRIGGERS
-- ============================================
DROP TRIGGER IF EXISTS set_edited_at ON projects;
CREATE TRIGGER set_edited_at
BEFORE UPDATE ON projects
FOR EACH ROW
EXECUTE FUNCTION update_edited_at_column();

-- ============================================
-- 10. INSERT DUMMY DATA - USERS
-- ============================================

-- Hapus data lama jika ada (untuk testing)
DELETE FROM project_members;
DELETE FROM project_applicants;
DELETE FROM projects;
DELETE FROM users;

-- 2 Mahasiswa
INSERT INTO users (id, email, password, full_name, role, program, avatar_url)
VALUES 
  (
    '11111111-1111-1111-1111-111111111111',
    'isra@student.com',
    'password123',
    'Muhammad Isra Alfattah',
    'mahasiswa',
    'Prodi Informatika (S1)',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Isra'
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'aldi@student.com',
    'password123',
    'Aldi Pratama',
    'mahasiswa',
    'Prodi Sistem Informasi (S1)',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Aldi'
  );

-- 1 Dosen
INSERT INTO users (id, email, password, full_name, role, program, avatar_url)
VALUES 
  (
    '99999999-9999-9999-9999-999999999999',
    'budi.santoso@lecturer.com',
    'password123',
    'Dr. Budi Santoso, S.Kom., M.T.',
    'dosen',
    NULL,
    'https://api.dicebear.com/7.x/avataaars/png?seed=Budi'
  );

-- ============================================
-- 11. INSERT DUMMY DATA - PROJECTS
-- ============================================
INSERT INTO projects (id, title, supervisor, description, deadline, participants, requirements, benefits, status, posted_at)
VALUES 
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'Project Deteksi Plat Nomor Kendaraan',
    'Dosen Pembimbing: Dr. Budi Santoso, S.Kom., M.T.',
    'Project ini bertujuan untuk mengembangkan aplikasi mobile yang dapat mendeteksi dan membaca plat nomor kendaraan secara otomatis menggunakan teknologi computer vision dan machine learning. Aplikasi akan dibangun menggunakan Flutter untuk frontend dan Python untuk backend AI.',
    '15 Desember 2025',
    '5',
    '["Menguasai Flutter atau bersedia belajar", "Memahami dasar Computer Vision", "Mampu bekerja dalam tim", "Komitmen tinggi terhadap project", "Minimal sudah semester 5"]'::jsonb,
    '["Pengalaman praktis dalam pengembangan AI", "Sertifikat project dari kampus", "Publikasi ilmiah di jurnal nasional", "Portfolio yang kuat untuk melamar kerja"]'::jsonb,
    'tersedia',
    NOW()
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'Aplikasi E-Learning Interaktif',
    'Dosen Pembimbing: Dr. Budi Santoso, S.Kom., M.T.',
    'Pengembangan platform e-learning yang interaktif dengan fitur video conference, quiz online, dan tracking progress mahasiswa. Platform ini akan memudahkan pembelajaran jarak jauh dengan antarmuka yang user-friendly.',
    '20 Januari 2026',
    '8',
    '["Menguasai Flutter/React Native", "Pengalaman dengan API Integration", "UI/UX Design skills dasar", "Komunikasi yang baik", "Bersedia full-time selama project"]'::jsonb,
    '["Portfolio project yang solid", "Networking dengan industri edtech", "Recommendation letter dari dosen", "Kemungkinan diangkat sebagai asisten"]'::jsonb,
    'tersedia',
    NOW() - INTERVAL '2 days'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    'Sistem Monitoring IoT Greenhouse',
    'Dosen Pembimbing: Dr. Budi Santoso, S.Kom., M.T.',
    'Membangun sistem monitoring dan kontrol greenhouse berbasis IoT untuk optimalisasi pertumbuhan tanaman dengan sensor suhu, kelembaban, dan cahaya. Project ini kolaborasi dengan Fakultas Pertanian.',
    '10 Februari 2026',
    '4',
    '["Pemahaman IoT dan sensor", "Programming Arduino/ESP32", "Mobile app development", "Analisis data sensor", "Minat di bidang pertanian"]'::jsonb,
    '["Hands-on experience dengan IoT", "Kolaborasi interdisipliner dengan pertanian", "Publikasi konferensi internasional", "Networking dengan startup agritech"]'::jsonb,
    'tersedia',
    NOW() - INTERVAL '5 days'
  );

-- ============================================
-- 12. VERIFIKASI DATA
-- ============================================
-- Jalankan query berikut untuk memverifikasi:

-- Cek users:
-- SELECT * FROM users ORDER BY role, full_name;

-- Cek projects:
-- SELECT id, title, status, posted_at FROM projects ORDER BY posted_at DESC;

-- Cek applicants (masih kosong):
-- SELECT * FROM project_applicants;

-- Cek members (masih kosong):
-- SELECT * FROM project_members;

-- ============================================
-- NOTES PENTING:
-- ============================================
-- 1. Password disimpan plain text untuk demo, di production gunakan Supabase Auth
-- 2. RLS policies saat ini permissive (public access) untuk development
-- 3. Untuk production, implementasi authentication proper dan policy yang lebih ketat
-- 4. Avatar URL menggunakan DiceBear API (free avatar generator)
-- 5. Email dummy: 
--    - Mahasiswa: isra@student.com, aldi@student.com (password: password123)
--    - Dosen: budi.santoso@lecturer.com (password: password123)
