-- ============================================
-- SQL SCRIPT UNTUK SETUP DATABASE PORTFOLIO
-- UNIWORK PROJECT
-- ============================================

-- 1. CREATE TABLE PORTFOLIO_PROJECTS
CREATE TABLE IF NOT EXISTS portfolio_projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  lecturer TEXT NOT NULL,
  deadline TEXT NOT NULL,
  description TEXT NOT NULL,
  requirements JSONB DEFAULT '[]'::jsonb,
  benefits JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- 2. CREATE TABLE PORTFOLIO_CERTIFICATES
CREATE TABLE IF NOT EXISTS portfolio_certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  issuer TEXT NOT NULL,
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  skills JSONB DEFAULT '[]'::jsonb,
  certificate_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- 3. CREATE TABLE PORTFOLIO_ORGANIZATIONS
CREATE TABLE IF NOT EXISTS portfolio_organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  position TEXT NOT NULL,
  duration TEXT NOT NULL,
  description TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- 4. CREATE INDEXES untuk performa query
CREATE INDEX IF NOT EXISTS idx_portfolio_projects_created_at ON portfolio_projects(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_portfolio_certificates_created_at ON portfolio_certificates(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_portfolio_organizations_created_at ON portfolio_organizations(created_at DESC);

-- 5. ENABLE ROW LEVEL SECURITY (RLS)
ALTER TABLE portfolio_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_organizations ENABLE ROW LEVEL SECURITY;

-- 6. CREATE POLICIES untuk RLS
-- Policies untuk portfolio_projects
CREATE POLICY "Allow public read access to portfolio projects"
ON portfolio_projects FOR SELECT
TO public
USING (true);

CREATE POLICY "Allow authenticated users to insert portfolio projects"
ON portfolio_projects FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update portfolio projects"
ON portfolio_projects FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow authenticated users to delete portfolio projects"
ON portfolio_projects FOR DELETE
TO authenticated
USING (true);

-- Policies untuk portfolio_certificates
CREATE POLICY "Allow public read access to portfolio certificates"
ON portfolio_certificates FOR SELECT
TO public
USING (true);

CREATE POLICY "Allow authenticated users to insert portfolio certificates"
ON portfolio_certificates FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update portfolio certificates"
ON portfolio_certificates FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow authenticated users to delete portfolio certificates"
ON portfolio_certificates FOR DELETE
TO authenticated
USING (true);

-- Policies untuk portfolio_organizations
CREATE POLICY "Allow public read access to portfolio organizations"
ON portfolio_organizations FOR SELECT
TO public
USING (true);

CREATE POLICY "Allow authenticated users to insert portfolio organizations"
ON portfolio_organizations FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update portfolio organizations"
ON portfolio_organizations FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow authenticated users to delete portfolio organizations"
ON portfolio_organizations FOR DELETE
TO authenticated
USING (true);

-- 7. INSERT DATA DUMMY untuk testing
INSERT INTO portfolio_projects (title, lecturer, deadline, description, requirements, benefits)
VALUES 
  (
    'Project Deteksi Plat Kendaraan Bermotor',
    'Dr. Bahlul Amba, S.Pd',
    '10 Oktober 2025',
    'Project Mobile App Yang Ditujukan Untuk Membantu Riset Dan Penelitian Terhadap Masalah Deteksi Plat Nomor Kendaraan',
    '["Menguasai Flutter", "Memahami Computer Vision", "Mampu bekerja dalam tim"]'::jsonb,
    '["Pengalaman praktis dalam pengembangan AI", "Sertifikat project"]'::jsonb
  );

INSERT INTO portfolio_certificates (title, issuer, start_date, end_date, skills, certificate_file)
VALUES 
  (
    'Certified IBM AI Software Engineer',
    'IBM',
    '10 Oktober 2025',
    '10 Oktober 2027',
    '["Problem Solving", "Leadership", "Advanced Python", "Data Analytics"]'::jsonb,
    'IBM-AI-Certificate.pdf'
  ),
  (
    'Google Cloud Professional Certificate',
    'Google',
    '15 Januari 2024',
    '15 Januari 2026',
    '["Cloud Computing", "DevOps", "Kubernetes", "Docker"]'::jsonb,
    'Google-Cloud-Cert.pdf'
  );

INSERT INTO portfolio_organizations (title, position, duration, description)
VALUES 
  (
    'Himpunan Mahasiswa Elektronika',
    'Ketua Divisi Teknologi',
    '1 Tahun 6 Bulan',
    'Kegiatan Dan Kontribusi:

1. Mengatur Jalannya Acara Greet & Meet Dengan Mahasiswa

2. Memberikan Kata Sambutan Pada Acara Pengajian

3. Kolaborasi Dengan Industri Untuk Melakukan Kegiatan Workshop

4. Memimpin Kegiatan Ospek Maba Elektronika'
  );

-- 8. CREATE FUNCTION untuk auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 9. CREATE TRIGGERS untuk auto-update updated_at
DROP TRIGGER IF EXISTS set_updated_at_portfolio_projects ON portfolio_projects;
CREATE TRIGGER set_updated_at_portfolio_projects
BEFORE UPDATE ON portfolio_projects
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS set_updated_at_portfolio_certificates ON portfolio_certificates;
CREATE TRIGGER set_updated_at_portfolio_certificates
BEFORE UPDATE ON portfolio_certificates
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS set_updated_at_portfolio_organizations ON portfolio_organizations;
CREATE TRIGGER set_updated_at_portfolio_organizations
BEFORE UPDATE ON portfolio_organizations
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VERIFIKASI SETUP
-- ============================================
-- Jalankan query berikut untuk memverifikasi:
-- SELECT * FROM portfolio_projects ORDER BY created_at DESC;
-- SELECT * FROM portfolio_certificates ORDER BY created_at DESC;
-- SELECT * FROM portfolio_organizations ORDER BY created_at DESC;

-- ============================================
-- NOTES:
-- ============================================
-- 1. Setiap tipe portfolio disimpan di tabel terpisah untuk flexibility
-- 2. Untuk production, sesuaikan RLS policies sesuai kebutuhan
-- 3. Pertimbangkan menambahkan user_id jika ada sistem authentication
-- 4. Backup database secara berkala
