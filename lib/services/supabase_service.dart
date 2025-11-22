import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // ============ PROJECT CRUD OPERATIONS ============

  /// Fetch all projects from database
  Future<List<Map<String, dynamic>>> getAllProjects() async {
    try {
      final response = await client
          .from(SupabaseConfig.projectsTable)
          .select()
          .order('posted_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching projects: $e');
      rethrow;
    }
  }

  /// Fetch single project by ID
  Future<Map<String, dynamic>?> getProjectById(String id) async {
    try {
      final response = await client
          .from(SupabaseConfig.projectsTable)
          .select()
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      print('Error fetching project by id: $e');
      return null;
    }
  }

  /// Add new project to database
  Future<Map<String, dynamic>?> addProject({
    required String title,
    required String supervisor,
    required String description,
    required String deadline,
    required String participants,
    required List<String> requirements,
    List<String> benefits = const [],
  }) async {
    try {
      final response = await client
          .from(SupabaseConfig.projectsTable)
          .insert({
            'title': title,
            'supervisor': supervisor,
            'description': description,
            'deadline': deadline,
            'participants': participants,
            'requirements': requirements,
            'benefits': benefits,
            'status': 'tersedia',
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error adding project: $e');
      rethrow;
    }
  }

  /// Update existing project
  Future<Map<String, dynamic>?> updateProject({
    required String id,
    String? title,
    String? description,
    String? deadline,
    String? participants,
    List<String>? requirements,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'edited_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (deadline != null) updateData['deadline'] = deadline;
      if (participants != null) updateData['participants'] = participants;
      if (requirements != null) updateData['requirements'] = requirements;

      final response = await client
          .from(SupabaseConfig.projectsTable)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error updating project: $e');
      rethrow;
    }
  }

  /// Delete project
  Future<void> deleteProject(String id) async {
    try {
      await client.from(SupabaseConfig.projectsTable).delete().eq('id', id);
    } catch (e) {
      print('Error deleting project: $e');
      rethrow;
    }
  }

  /// Update project status
  Future<Map<String, dynamic>?> updateProjectStatus({
    required String id,
    required String status,
  }) async {
    try {
      final response = await client
          .from(SupabaseConfig.projectsTable)
          .update({
            'status': status,
            'edited_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error updating project status: $e');
      rethrow;
    }
  }

  /// Close registration (change status from tersedia to diproses)
  Future<Map<String, dynamic>?> closeRegistration(String id) async {
    try {
      final response = await client
          .from(SupabaseConfig.projectsTable)
          .update({
            'status': 'diproses',
            'edited_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error closing registration: $e');
      rethrow;
    }
  }

  // ============ APPLICANTS & MEMBERS OPERATIONS ============
  // Note: Ini akan dikembangkan lebih lanjut sesuai dengan struktur tabel
  // yang Anda buat di Supabase untuk mengelola applicants dan members

  /// Get applicants for a project
  Future<List<Map<String, dynamic>>> getProjectApplicants(
    String projectId,
  ) async {
    try {
      final response = await client
          .from(SupabaseConfig.applicantsTable)
          .select()
          .eq('project_id', projectId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching applicants: $e');
      return [];
    }
  }

  /// Get members for a project
  Future<List<Map<String, dynamic>>> getProjectMembers(String projectId) async {
    try {
      final response = await client
          .from(SupabaseConfig.membersTable)
          .select()
          .eq('project_id', projectId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching members: $e');
      return [];
    }
  }

  // ============ PORTFOLIO CRUD OPERATIONS ============

  /// Fetch all portfolio projects
  Future<List<Map<String, dynamic>>> getAllPortfolioProjects() async {
    try {
      final response = await client
          .from(SupabaseConfig.portfolioProjectsTable)
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching portfolio projects: $e');
      rethrow;
    }
  }

  /// Fetch all portfolio certificates
  Future<List<Map<String, dynamic>>> getAllPortfolioCertificates() async {
    try {
      final response = await client
          .from(SupabaseConfig.portfolioCertificatesTable)
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching portfolio certificates: $e');
      rethrow;
    }
  }

  /// Fetch all portfolio organizations
  Future<List<Map<String, dynamic>>> getAllPortfolioOrganizations() async {
    try {
      final response = await client
          .from(SupabaseConfig.portfolioOrganizationsTable)
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching portfolio organizations: $e');
      rethrow;
    }
  }

  /// Add portfolio project
  Future<Map<String, dynamic>?> addPortfolioProject({
    required String title,
    required String lecturer,
    required String deadline,
    required String description,
    required List<String> requirements,
    required List<String> benefits,
  }) async {
    try {
      final response = await client
          .from(SupabaseConfig.portfolioProjectsTable)
          .insert({
            'title': title,
            'lecturer': lecturer,
            'deadline': deadline,
            'description': description,
            'requirements': requirements,
            'benefits': benefits,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error adding portfolio project: $e');
      rethrow;
    }
  }

  /// Add portfolio certificate
  Future<Map<String, dynamic>?> addPortfolioCertificate({
    required String title,
    required String issuer,
    required String startDate,
    required String endDate,
    required List<String> skills,
    String? certificateFile,
  }) async {
    try {
      final response = await client
          .from(SupabaseConfig.portfolioCertificatesTable)
          .insert({
            'title': title,
            'issuer': issuer,
            'start_date': startDate,
            'end_date': endDate,
            'skills': skills,
            'certificate_file': certificateFile,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error adding portfolio certificate: $e');
      rethrow;
    }
  }

  /// Add portfolio organization
  Future<Map<String, dynamic>?> addPortfolioOrganization({
    required String title,
    required String position,
    required String duration,
    required String description,
  }) async {
    try {
      final response = await client
          .from(SupabaseConfig.portfolioOrganizationsTable)
          .insert({
            'title': title,
            'position': position,
            'duration': duration,
            'description': description,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error adding portfolio organization: $e');
      rethrow;
    }
  }

  /// Update portfolio project
  Future<Map<String, dynamic>?> updatePortfolioProject({
    required String id,
    required String title,
    required String lecturer,
    required String deadline,
    required String description,
    required List<String> requirements,
    required List<String> benefits,
  }) async {
    try {
      final response = await client
          .from(SupabaseConfig.portfolioProjectsTable)
          .update({
            'title': title,
            'lecturer': lecturer,
            'deadline': deadline,
            'description': description,
            'requirements': requirements,
            'benefits': benefits,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error updating portfolio project: $e');
      rethrow;
    }
  }

  /// Update portfolio certificate
  Future<Map<String, dynamic>?> updatePortfolioCertificate({
    required String id,
    required String title,
    required String issuer,
    required String startDate,
    required String endDate,
    required List<String> skills,
    String? certificateFile,
  }) async {
    try {
      final response = await client
          .from(SupabaseConfig.portfolioCertificatesTable)
          .update({
            'title': title,
            'issuer': issuer,
            'start_date': startDate,
            'end_date': endDate,
            'skills': skills,
            'certificate_file': certificateFile,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error updating portfolio certificate: $e');
      rethrow;
    }
  }

  /// Update portfolio organization
  Future<Map<String, dynamic>?> updatePortfolioOrganization({
    required String id,
    required String title,
    required String position,
    required String duration,
    required String description,
  }) async {
    try {
      final response = await client
          .from(SupabaseConfig.portfolioOrganizationsTable)
          .update({
            'title': title,
            'position': position,
            'duration': duration,
            'description': description,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error updating portfolio organization: $e');
      rethrow;
    }
  }

  /// Delete portfolio project
  Future<void> deletePortfolioProject(String id) async {
    try {
      await client
          .from(SupabaseConfig.portfolioProjectsTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting portfolio project: $e');
      rethrow;
    }
  }

  /// Delete portfolio certificate
  Future<void> deletePortfolioCertificate(String id) async {
    try {
      await client
          .from(SupabaseConfig.portfolioCertificatesTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting portfolio certificate: $e');
      rethrow;
    }
  }

  /// Delete portfolio organization
  Future<void> deletePortfolioOrganization(String id) async {
    try {
      await client
          .from(SupabaseConfig.portfolioOrganizationsTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting portfolio organization: $e');
      rethrow;
    }
  }
}
