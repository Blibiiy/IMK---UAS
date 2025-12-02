// Konfigurasi Supabase
// PENTING: Ganti dengan URL dan API Key dari project Supabase Anda
class SupabaseConfig {
  // URL Supabase project Anda
  static const String supabaseUrl = 'https://hbguuvzxzigxnwwefeuk.supabase.co';

  // Anon key dari Supabase project Anda
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhiZ3V1dnp4emlneG53d2VmZXVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2NDM3OTksImV4cCI6MjA4MDIxOTc5OX0.B1MpLNY0sHo84g2PiQnmba7aQU92paRfNkUErdkPxMw';

  // Nama tabel di database
  static const String projectsTable = 'projects';
  static const String studentsTable = 'students';
  static const String applicantsTable = 'project_applicants';
  static const String membersTable = 'project_members';

  // Portfolio tables
  static const String portfolioProjectsTable = 'portfolio_projects';
  static const String portfolioCertificatesTable = 'portfolio_certificates';
  static const String portfolioOrganizationsTable = 'portfolio_organizations';
}

/* 
INSTRUKSI SETUP SUPABASE:

1. Buat project di https://supabase.com
2. Buat tabel 'projects' dengan struktur:
   - id (uuid, primary key, default: gen_random_uuid())
   - title (text)
   - supervisor (text)
   - description (text)
   - deadline (text)
   - participants (text)
   - requirements (jsonb) - array of strings
   - benefits (jsonb) - array of strings
   - posted_at (timestamp with time zone, default: now())
   - edited_at (timestamp with time zone, nullable)
   - status (text, default: 'tersedia')
   - created_at (timestamp with time zone, default: now())

3. Enable Row Level Security (RLS) dan tambahkan policies sesuai kebutuhan
4. Copy URL dan anon key dari Settings > API
5. Paste URL dan anon key ke file ini
*/
