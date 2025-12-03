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

  // Chat tables (NEW)
  static const String conversationsTable = 'conversations';
  static const String conversationParticipantsTable = 'conversation_participants';
  static const String messagesTable = 'messages';

  // Storage buckets
  static const String portfoliosBucket = 'portfolios';
  static const String chatAttachmentsBucket = 'chat-attachments';
} 