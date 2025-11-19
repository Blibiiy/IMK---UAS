import 'package:flutter/material.dart';

// Reuse model PortfolioItem dari provider portfolio
import './portfolio_provider.dart';

enum ProjectStatus { tersedia, diproses, diterima }

class Student {
  final String id;
  final String name;
  final String program; // contoh: 'Prodi Informatika (S1)'
  final String avatarUrl;
  final List<PortfolioItem> portfolio;

  Student({
    required this.id,
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
    List<PortfolioItem>? portfolio,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      program: program ?? this.program,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      portfolio: portfolio ?? this.portfolio,
    );
  }
}

class Project {
  final String id;
  final String title;
  final String supervisor; // "Dosen Pembimbing: <Nama Lengkap>"
  final String description; // Detail project
  final String deadline;
  final String participants;
  final List<String> requirements;
  final List<String> benefits;
  final DateTime postedAt;
  final DateTime? editedAt;
  final ProjectStatus status;

  // Kolaborasi
  final List<Student> members; // diterima
  final List<Student> applicants; // pendaftar

  Project({
    required this.id,
    required this.title,
    required this.supervisor,
    required this.description,
    required this.deadline,
    required this.participants,
    required this.requirements,
    required this.benefits,
    required this.postedAt,
    this.editedAt,
    required this.status,
    required this.members,
    required this.applicants,
  });

  String get statusText {
    switch (status) {
      case ProjectStatus.tersedia:
        return 'Tersedia';
      case ProjectStatus.diproses:
        return 'Diproses';
      case ProjectStatus.diterima:
        return 'Diterima';
    }
  }

  Project copyWith({
    String? title,
    String? description,
    String? deadline,
    String? participants,
    List<String>? requirements,
    DateTime? editedAt,
    ProjectStatus? status,
    List<Student>? members,
    List<Student>? applicants,
  }) {
    return Project(
      id: id,
      title: title ?? this.title,
      supervisor: supervisor,
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
    );
  }
}

class ProjectProvider extends ChangeNotifier {
  final List<Project> _projects = [
    Project(
      id: '1',
      title: 'Project 1',
      supervisor: 'Dosen Pembimbing: Mas Isra',
      description:
          'Project Mobile App Yang Ditujukan Untuk Membantu Riset Dan Penelitian Terhadap Masalah 19 Juta Lapangan Pekerjaan',
      deadline: '10 Oktober 2025',
      participants: '10',
      status: ProjectStatus.tersedia,
      requirements: [
        '1. Mampu Bertanggung Jawab Dan Jujur Dalam Melaksanakan Tugas',
        '2. Menguasai Semua Bahasa Pemograman Yang Ada Di Dunia.',
        '3. Dapat Bekerja Kapan Pun Yang Dibutuhkan Oleh Dosen Pembimbing',
      ],
      benefits: [
        '1. Mendapatkan Uang 1 Milliar',
        '2. Nilai Matakuliah Pasti A++',
      ],
      postedAt: DateTime(2025, 10, 1, 9, 0),
      members: [],
      applicants: [
        Student(
          id: 's1',
          name: 'Isra',
          program: 'Prodi Informatika (S1)',
          avatarUrl: 'https://placehold.co/200x200/999/FFF?text=Isra',
          portfolio: [
            ProjectPortfolio(
              id: 'p_isra_1',
              title: 'Project Deteksi Plat Kendaraan Bermotor',
              lecturer: 'Dr. Bahlul Amba, S.Pd',
              deadline: '10 Oktober 2025',
              description:
                  'Project riset pendeteksian plat nomor berbasis visi komputer.',
              requirements: [
                'Python',
                'OpenCV',
              ],
              benefits: [
                'Publikasi',
              ],
            ),
            CertificatePortfolio(
              id: 'c_isra_1',
              title: 'Certified IBM AI Engineer',
              issuer: 'IBM',
              startDate: '10 Oktober 2025',
              endDate: '10 Oktober 2027',
              skills: ['Python', 'ML', 'Leadership'],
              certificateFile: 'IBM-AI.pdf',
            ),
            OrganizationPortfolio(
              id: 'o_isra_1',
              title: 'Himpunan Mahasiswa Elektronika',
              position: 'Ketua Divisi Teknologi',
              duration: '1 Tahun 6 Bulan',
              description: 'Mengelola program kerja divisi.',
            ),
          ],
        ),
        Student(
          id: 's2',
          name: 'Aldi',
          program: 'Prodi Informatika (S1)',
          avatarUrl: 'https://placehold.co/200x200/888/FFF?text=Aldi',
          portfolio: [
            CertificatePortfolio(
              id: 'c_aldi_1',
              title: 'Certified IBM AI Engineer',
              issuer: 'IBM',
              startDate: '10 Oktober 2025',
              endDate: '10 Oktober 2027',
              skills: ['AI', 'Python'],
              certificateFile: 'cert.pdf',
            ),
          ],
        ),
        Student(
          id: 's3',
          name: 'Bahlil',
          program: 'Prodi Prodian (S1)',
          avatarUrl: 'https://placehold.co/200x200/777/FFF?text=Bahlil',
          portfolio: [
            OrganizationPortfolio(
              id: 'o_bah_1',
              title: 'Himpunan Mahasiswa Elektro',
              position: 'Koordinator Acara',
              duration: '1 Tahun',
              description: 'Mengatur acara dan kolaborasi lintas prodi.',
            ),
          ],
        ),
      ],
    ),
    Project(
      id: '2',
      title: 'Project 2',
      supervisor: 'Dosen Pembimbing: Pak Budi',
      description: 'Project Lorem Ipsum Project Lorem Ipsum Project Lorem Ipsum',
      deadline: '10 Oktober 2025',
      participants: '10',
      status: ProjectStatus.diproses,
      requirements: [
        '1. Requirement Lorem Ipsum',
        '2. Requirement Lorem Ipsum',
      ],
      benefits: ['1. Benefit Lorem Ipsum', '2. Benefit Lorem Ipsum'],
      postedAt: DateTime(2025, 10, 5, 14, 30),
      members: [],
      applicants: [],
    ),
    Project(
      id: '3',
      title: 'Project 3',
      supervisor: 'Dosen Pembimbing: Bu Ani',
      description: 'Project Lorem Ipsum Project Lorem Ipsum Project Lorem Ipsum',
      deadline: '10 Oktober 2025',
      participants: '10',
      status: ProjectStatus.tersedia,
      requirements: [
        '1. Requirement Lorem Ipsum',
        '2. Requirement Lorem Ipsum',
      ],
      benefits: ['1. Benefit Lorem Ipsum', '2. Benefit Lorem Ipsum'],
      postedAt: DateTime(2025, 10, 7, 8, 0),
      members: [],
      applicants: [],
    ),
  ];

  List<Project> get projects => _projects;

  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void registerProject(String projectId) {
    final idx = _projects.indexWhere((p) => p.id == projectId);
    if (idx != -1) {
      final old = _projects[idx];
      _projects[idx] = old.copyWith(status: ProjectStatus.diproses);
      notifyListeners();
    }
  }

  void closeRegistration(String projectId) {
    final idx = _projects.indexWhere((p) => p.id == projectId);
    if (idx != -1) {
      final old = _projects[idx];
      final newStatus =
          old.status == ProjectStatus.tersedia ? ProjectStatus.diproses : old.status;
      _projects[idx] = old.copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void addProject({
    required String title,
    required String deadline,
    required String participants,
    required String description,
    required List<String> requirements,
    String lecturerFullName = 'Muhammad Isra Alfattah',
  }) {
    final newProject = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      supervisor: 'Dosen Pembimbing: $lecturerFullName',
      description: description,
      deadline: deadline,
      participants: participants,
      requirements: requirements,
      benefits: const [],
      postedAt: DateTime.now(),
      status: ProjectStatus.tersedia,
      members: [],
      applicants: [],
    );
    _projects.insert(0, newProject);
    notifyListeners();
  }

  void updateProject({
    required String id,
    String? title,
    String? deadline,
    String? participants,
    String? description,
    List<String>? requirements,
  }) {
    final idx = _projects.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final old = _projects[idx];
    _projects[idx] = old.copyWith(
      title: title,
      deadline: deadline,
      participants: participants,
      description: description,
      requirements: requirements,
      editedAt: DateTime.now(),
    );
    notifyListeners();
  }

  // ====== Applicants & Members ======
  void acceptApplicant(String projectId, String studentId) {
    final idx = _projects.indexWhere((p) => p.id == projectId);
    if (idx == -1) return;
    final project = _projects[idx];

    final applicantIndex =
        project.applicants.indexWhere((student) => student.id == studentId);
    if (applicantIndex == -1) return;

    final student = project.applicants[applicantIndex];
    final updatedApplicants = List<Student>.from(project.applicants)
      ..removeAt(applicantIndex);
    final updatedMembers = List<Student>.from(project.members)..add(student);

    _projects[idx] = project.copyWith(
      applicants: updatedApplicants,
      members: updatedMembers,
      editedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void rejectApplicant(String projectId, String studentId) {
    final idx = _projects.indexWhere((p) => p.id == projectId);
    if (idx == -1) return;
    final project = _projects[idx];

    final updatedApplicants =
        project.applicants.where((s) => s.id != studentId).toList();

    _projects[idx] = project.copyWith(
      applicants: updatedApplicants,
      editedAt: DateTime.now(),
    );
    notifyListeners();
  }
}