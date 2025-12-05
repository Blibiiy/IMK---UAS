import 'package:flutter/material.dart';

// Reuse model PortfolioItem dari provider portfolio
import './portfolio_provider.dart';
import './chat_provider.dart';
import '../services/supabase_service.dart';

enum ProjectStatus { tersedia, diproses, diterima, selesai }

class Student {
  final String id;
  final String name;
  final String program;
  final String avatarUrl;
  final List<PortfolioItem> portfolio;

  Student({
    required this. id,
    required this.name,
    required this.program,
    required this.avatarUrl,
    required this.portfolio,
  });

  Student copyWith({
    String? id,
    String? name,
    String? program,
    String? avatarUrl,
    List<PortfolioItem>?  portfolio,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      program: program ?? this.program,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      portfolio: portfolio ?? this.portfolio,
    );
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id']. toString(),
      name: json['full_name'] ?? '',
      program: json['program'] ?? '',
      avatarUrl:
          json['avatar_url'] ?? 'https://placehold.co/100x100/E0E0E0/E0E0E0',
      portfolio: [],
    );
  }
}

class Project {
  final String id;
  final String title;
  final String supervisor;
  final String supervisorId;
  final String description;
  final String deadline;
  final String participants;
  final List<String> requirements;
  final List<String> benefits;
  final DateTime postedAt;
  final DateTime?  editedAt;
  final ProjectStatus status;
  final List<Student> members;
  final List<Student> applicants;
  final String?  groupChatId;

  Project({
    required this.id,
    required this.title,
    required this.supervisor,
    required this.supervisorId,
    required this.description,
    required this.deadline,
    required this. participants,
    required this.requirements,
    required this.benefits,
    required this.postedAt,
    this.editedAt,
    required this.status,
    required this.members,
    required this. applicants,
    this.groupChatId,
  });

  String get statusText {
    switch (status) {
      case ProjectStatus.tersedia:
        return 'Tersedia';
      case ProjectStatus. diproses:
        return 'Diproses';
      case ProjectStatus.diterima:
        return 'Diterima';
      case ProjectStatus. selesai:
        return 'Selesai';
    }
  }

  Project copyWith({
    String? title,
    String? description,
    String? deadline,
    String? participants,
    List<String>? requirements,
    DateTime? editedAt,
    ProjectStatus?  status,
    List<Student>? members,
    List<Student>? applicants,
    String? groupChatId,
  }) {
    return Project(
      id: id,
      title: title ?? this.title,
      supervisor: supervisor,
      supervisorId: supervisorId,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      participants: participants ?? this.participants,
      requirements: requirements ?? this.requirements,
      benefits: benefits,
      postedAt: postedAt,
      editedAt: editedAt ?? this.editedAt,
      status: status ?? this.status,
      members: members ?? this.members,
      applicants: applicants ?? this.applicants,
      groupChatId: groupChatId ?? this.groupChatId,
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    ProjectStatus status = ProjectStatus.tersedia;
    if (json['status'] == 'diproses') {
      status = ProjectStatus.diproses;
    } else if (json['status'] == 'diterima') {
      status = ProjectStatus. diterima;
    } else if (json['status'] == 'selesai') {
      status = ProjectStatus.selesai;
    }

    return Project(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      supervisor: json['supervisor'] ?? '',
      supervisorId: json['supervisor_id']?.toString() ?? '',
      description: json['description'] ?? '',
      deadline: json['deadline'] ??  '',
      participants: json['participants'] ?? '',
      requirements: json['requirements'] != null
          ? List<String>. from(json['requirements'])
          : [],
      benefits: json['benefits'] != null
          ? List<String>.from(json['benefits'])
          : [],
      postedAt: json['posted_at'] != null
          ? DateTime.parse(json['posted_at'])
          : DateTime.now(),
      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'])
          : null,
      status: status,
      members: [],
      applicants: [],
      groupChatId: json['group_chat_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'supervisor': supervisor,
      'supervisor_id': supervisorId,
      'description': description,
      'deadline': deadline,
      'participants': participants,
      'requirements': requirements,
      'benefits': benefits,
      'posted_at': postedAt.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
      'status': statusText. toLowerCase(),
      'group_chat_id': groupChatId,
    };
  }
}

class ProjectProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final List<Project> _dummyProjects = [];

  List<Project> get projects => _projects;

  List<Project> getProjectsByLecturer(String lecturerFullName) {
    if (lecturerFullName.isEmpty) return _projects;
    return _projects. where((project) {
      return project.supervisor. contains(lecturerFullName);
    }).toList();
  }

  Future<void> loadProjects() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _supabaseService. getAllProjects();
      _projects = data.map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = 'Gagal memuat projects: $e';
      print(_errorMessage);
      _projects = _dummyProjects;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Project?  getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> registerProject(String projectId, String studentId) async {
    try {
      final alreadyApplied = await _supabaseService.isAlreadyApplied(
        projectId: projectId,
        studentId: studentId,
      );

      if (alreadyApplied) {
        throw Exception('Anda sudah mendaftar ke project ini sebelumnya');
      }

      await _supabaseService.addApplicant(
        projectId: projectId,
        studentId: studentId,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal mendaftar project: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> closeRegistration(String projectId) async {
    try {
      await _supabaseService.closeRegistration(projectId);

      final idx = _projects.indexWhere((p) => p.id == projectId);
      if (idx != -1) {
        final old = _projects[idx];
        final newStatus = old.status == ProjectStatus.tersedia
            ? ProjectStatus.diproses
            : old.status;
        _projects[idx] = old.copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Gagal menutup pendaftaran: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> completeProject(String projectId) async {
    try {
      final response = await _supabaseService. updateProjectStatus(
        id: projectId,
        status: 'selesai',
      );

      if (response != null) {
        final idx = _projects.indexWhere((p) => p.id == projectId);
        if (idx != -1) {
          _projects[idx] = _projects[idx].copyWith(
            status: ProjectStatus.selesai,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = 'Gagal menyelesaikan project: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> addProject({
    required String title,
    required String deadline,
    required String participants,
    required String description,
    required List<String> requirements,
    required String lecturerFullName,
    required String lecturerId,
    required ChatProvider chatProvider,
  }) async {
    try {
      final response = await _supabaseService. addProject(
        title: title,
        supervisor: 'Dosen Pembimbing: $lecturerFullName',
        supervisorId: lecturerId,
        description: description,
        deadline: deadline,
        participants: participants,
        requirements: requirements,
        benefits: [],
      );

      if (response != null) {
        final projectId = response['id']. toString();
        
        final groupChatId = await chatProvider.createProjectGroupChat(
          projectId,
          title,
          [lecturerId],
        );

        if (groupChatId != null) {
          await _supabaseService.updateProjectGroupChatId(projectId, groupChatId);
          response['group_chat_id'] = groupChatId;
        }

        final newProject = Project.fromJson(response);
        _projects.insert(0, newProject);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Gagal menambahkan project: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> updateProject({
    required String id,
    String? title,
    String? deadline,
    String? participants,
    String? description,
    List<String>? requirements,
  }) async {
    try {
      final response = await _supabaseService.updateProject(
        id: id,
        title: title,
        deadline: deadline,
        participants: participants,
        description: description,
        requirements: requirements,
      );

      if (response != null) {
        final idx = _projects.indexWhere((p) => p.id == id);
        if (idx != -1) {
          _projects[idx] = Project.fromJson(response);
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = 'Gagal mengupdate project: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _supabaseService.deleteProject(id);
      _projects.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menghapus project: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> loadApplicants(String projectId) async {
    try {
      final data = await _supabaseService. getProjectApplicants(projectId);
      final applicants = data.map((json) => Student.fromJson(json)).toList();

      final idx = _projects.indexWhere((p) => p.id == projectId);
      if (idx != -1) {
        _projects[idx] = _projects[idx].copyWith(applicants: applicants);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading applicants: $e');
    }
  }

  Future<void> loadMembers(String projectId) async {
    try {
      final data = await _supabaseService.getProjectMembers(projectId);
      final members = data. map((json) => Student.fromJson(json)).toList();

      final idx = _projects.indexWhere((p) => p. id == projectId);
      if (idx != -1) {
        _projects[idx] = _projects[idx].copyWith(members: members);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading members: $e');
    }
  }

  Future<void> acceptApplicant(
    String projectId,
    String studentId,
    ChatProvider chatProvider,
  ) async {
    try {
      await _supabaseService.acceptApplicant(
        projectId: projectId,
        studentId: studentId,
      );

      await loadApplicants(projectId);
      await loadMembers(projectId);

      final project = getProjectById(projectId);
      if (project?. groupChatId != null) {
        await chatProvider.addMemberToGroupChat(
          project! .groupChatId!,
          studentId,
        );
      }
    } catch (e) {
      print('Error accepting applicant: $e');
      rethrow;
    }
  }

  Future<void> rejectApplicant(String projectId, String studentId) async {
    try {
      await _supabaseService.rejectApplicant(
        projectId: projectId,
        studentId: studentId,
      );

      await loadApplicants(projectId);
    } catch (e) {
      print('Error rejecting applicant: $e');
      rethrow;
    }
  }

  /// FIXED: Handle status "Ditolak" dengan benar
  Future<String> getUserStatusInProject(String projectId, String userId) async {
    try {
      print('🔍 Checking status for user $userId in project $projectId');
      
      // Check if user has applied
      final applicationData = await _supabaseService.getApplicationStatus(
        projectId: projectId,
        studentId: userId,
      );

      if (applicationData == null) {
        print('✅ User hasn\'t applied yet');
        return 'Tersedia';
      }

      final appStatus = applicationData['status'] as String? ;
      print('📊 Application status from DB: $appStatus');

      // Map application status to display status
      switch (appStatus) {
        case 'pending':
          return 'Diproses';
        case 'accepted':
          // Check if project is completed
          final projectData = await _supabaseService.getProjectById(projectId);
          if (projectData? ['status'] == 'selesai') {
            return 'Selesai';
          }
          return 'Diterima';
        case 'rejected':  // FIXED: Handle rejected properly
          return 'Ditolak';
        default:
          return 'Tersedia';
      }
    } catch (e) {
      print('❌ Error getting user status: $e');
      return 'Tersedia';
    }
  }
}