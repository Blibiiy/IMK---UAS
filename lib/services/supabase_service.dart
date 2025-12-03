import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase. instance.client;

  // ============ FILE STORAGE ============

  /// Upload file to Supabase Storage
  /// Returns the public URL of the uploaded file
  Future<String? > uploadFile({
    required File file,
    required String bucket,
    required String path,
  }) async {
    try {
      final fileName = path.split('/').last;
      final fileExtension = fileName.split('.'). last. toLowerCase();

      // Validate file size (max 10MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Ukuran file tidak boleh lebih dari 10 MB');
      }

      // Validate file type
      final allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'webp'];
      if (!allowedExtensions.contains(fileExtension)) {
        throw Exception(
          'Format file tidak didukung.  Gunakan PDF atau gambar (JPG, PNG, GIF, WEBP)',
        );
      }

      // Upload file to Supabase Storage
      final uploadPath = await client.storage
          .from(bucket)
          .upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get public URL
      final publicUrl = client.storage.from(bucket).getPublicUrl(path);

      print('File uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  /// Delete file from Supabase Storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await client.storage. from(bucket).remove([path]);
      print('File deleted successfully: $path');
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }

  // ============ USER AUTHENTICATION ============

  /// Login user (simple auth without Supabase Auth for demo)
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      // First, get user by email only
      final response = await client
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        print('User not found with email: $email');
        return null;
      }

      // Check if password matches
      if (response['password'] == password) {
        print('Login successful for: $email');
        return response;
      } else {
        print('Invalid password for: $email');
        return null;
      }
    } catch (e) {
      print('Error login: $e');
      rethrow;
    }
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          . single();

      return response;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

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
    required String supervisorId, // NEW
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
            'supervisor_id': supervisorId, // NEW
            'description': description,
            'deadline': deadline,
            'participants': participants,
            'requirements': requirements,
            'benefits': benefits,
            'status': 'tersedia',
          })
          .select()
          . single();

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
    String?  description,
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
          . single();

      return response;
    } catch (e) {
      print('Error updating project: $e');
      rethrow;
    }
  }

  /// Delete project
  Future<void> deleteProject(String id) async {
    try {
      await client. from(SupabaseConfig. projectsTable).delete().eq('id', id);
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
          . update({
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

  /// Update project group chat ID (NEW)
  Future<void> updateProjectGroupChatId(String projectId, String groupChatId) async {
    try {
      await client
          .from(SupabaseConfig.projectsTable)
          .update({'group_chat_id': groupChatId})
          .eq('id', projectId);
      
      print('✅ Project $projectId linked to group chat $groupChatId');
    } catch (e) {
      print('Error updating project group chat id: $e');
      rethrow;
    }
  }

  // ============ APPLICANTS & MEMBERS OPERATIONS ============

  /// Check if student already applied to project
  Future<bool> isAlreadyApplied({
    required String projectId,
    required String studentId,
  }) async {
    try {
      final response = await client
          .from(SupabaseConfig.applicantsTable)
          .select()
          .eq('project_id', projectId)
          . eq('student_id', studentId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking applicant: $e');
      return false;
    }
  }

  /// Add applicant to project
  Future<Map<String, dynamic>?> addApplicant({
    required String projectId,
    required String studentId,
  }) async {
    try {
      final response = await client
          .from(SupabaseConfig.applicantsTable)
          .insert({
            'project_id': projectId,
            'student_id': studentId,
            'status': 'pending',
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error adding applicant: $e');
      rethrow;
    }
  }

  /// Get applicants for a project with user details
  Future<List<Map<String, dynamic>>> getProjectApplicants(
    String projectId,
  ) async {
    try {
      // Get applicants with status 'pending'
      final applicants = await client
          .from(SupabaseConfig.applicantsTable)
          .select('student_id')
          .eq('project_id', projectId)
          .eq('status', 'pending');

      if (applicants.isEmpty) return [];

      // Get user details for each applicant
      final studentIds = applicants
          .map((a) => a['student_id'] as String)
          .toList();

      final users = await client
          .from('users')
          .select()
          .inFilter('id', studentIds);

      return List<Map<String, dynamic>>.from(users);
    } catch (e) {
      print('Error fetching applicants: $e');
      return [];
    }
  }

  /// Get members for a project with user details
  Future<List<Map<String, dynamic>>> getProjectMembers(String projectId) async {
    try {
      // Get members
      final members = await client
          .from(SupabaseConfig.membersTable)
          .select('student_id')
          .eq('project_id', projectId);

      if (members.isEmpty) return [];

      // Get user details for each member
      final studentIds = members. map((m) => m['student_id'] as String).toList();

      final users = await client
          .from('users')
          .select()
          .inFilter('id', studentIds);

      return List<Map<String, dynamic>>.from(users);
    } catch (e) {
      print('Error fetching members: $e');
      return [];
    }
  }

  /// Accept applicant (move from applicants to members)
  Future<void> acceptApplicant({
    required String projectId,
    required String studentId,
  }) async {
    try {
      // Update applicant status to 'accepted'
      await client
          . from(SupabaseConfig. applicantsTable)
          . update({'status': 'accepted'})
          .eq('project_id', projectId)
          .eq('student_id', studentId);

      // Add to members table
      await client. from(SupabaseConfig. membersTable).insert({
        'project_id': projectId,
        'student_id': studentId,
      });
    } catch (e) {
      print('Error accepting applicant: $e');
      rethrow;
    }
  }

  /// Reject applicant
  Future<void> rejectApplicant({
    required String projectId,
    required String studentId,
  }) async {
    try {
      await client
          .from(SupabaseConfig.applicantsTable)
          .update({'status': 'rejected'})
          . eq('project_id', projectId)
          .eq('student_id', studentId);
    } catch (e) {
      print('Error rejecting applicant: $e');
      rethrow;
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

  /// Fetch portfolio projects by user ID
  Future<List<Map<String, dynamic>>> getPortfolioProjectsByUserId(
    String userId,
  ) async {
    try {
      final response = await client
          .from(SupabaseConfig.portfolioProjectsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching portfolio projects by user: $e');
      return [];
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

  /// Fetch portfolio certificates by user ID
  Future<List<Map<String, dynamic>>> getPortfolioCertificatesByUserId(
    String userId,
  ) async {
    try {
      final response = await client
          .from(SupabaseConfig.portfolioCertificatesTable)
          . select()
          .eq('user_id', userId)
          . order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching portfolio certificates by user: $e');
      return [];
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

  /// Fetch portfolio organizations by user ID
  Future<List<Map<String, dynamic>>> getPortfolioOrganizationsByUserId(
    String userId,
  ) async {
    try {
      final response = await client
          .from(SupabaseConfig.portfolioOrganizationsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching portfolio organizations by user: $e');
      return [];
    }
  }

  /// Add portfolio project
  Future<Map<String, dynamic>?> addPortfolioProject({
    required String userId,
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
            'user_id': userId,
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
    required String userId,
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
            'user_id': userId,
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
    required String userId,
    required String title,
    required String position,
    required String duration,
    required String description,
  }) async {
    try {
      final response = await client
          .from(SupabaseConfig.portfolioOrganizationsTable)
          .insert({
            'user_id': userId,
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
            'updated_at': DateTime.now(). toIso8601String(),
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
          . eq('id', id);
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