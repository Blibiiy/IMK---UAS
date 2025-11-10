import 'package:flutter/material.dart';

enum ProjectStatus { tersedia, diproses, diterima }

class Project {
  final String id;
  final String title;
  final String supervisor;
  final String description;
  final String deadline;
  final String participants;
  final List<String> requirements;
  final List<String> benefits;
  ProjectStatus status;

  Project({
    required this.id,
    required this.title,
    required this.supervisor,
    required this.description,
    required this.deadline,
    required this.participants,
    required this.requirements,
    required this.benefits,
    required this.status,
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
    ),
    Project(
      id: '2',
      title: 'Project 2',
      supervisor: 'Dosen Pembimbing: Pak Budi',
      description:
          'Project Lorem Ipsum Project Lorem Ipsum Project Lorem Ipsum',
      deadline: '10 Oktober 2025',
      participants: '10',
      status: ProjectStatus.diproses,
      requirements: [
        '1. Requirement Lorem Ipsum',
        '2. Requirement Lorem Ipsum',
      ],
      benefits: ['1. Benefit Lorem Ipsum', '2. Benefit Lorem Ipsum'],
    ),
    Project(
      id: '3',
      title: 'Project 3',
      supervisor: 'Dosen Pembimbing: Bu Ani',
      description:
          'Project Lorem Ipsum Project Lorem Ipsum Project Lorem Ipsum',
      deadline: '10 Oktober 2025',
      participants: '10',
      status: ProjectStatus.tersedia,
      requirements: [
        '1. Requirement Lorem Ipsum',
        '2. Requirement Lorem Ipsum',
      ],
      benefits: ['1. Benefit Lorem Ipsum', '2. Benefit Lorem Ipsum'],
    ),
  ];

  List<Project> get projects => _projects;

  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }

  void registerProject(String projectId) {
    final project = getProjectById(projectId);
    if (project != null) {
      project.status = ProjectStatus.diproses;
      notifyListeners();
    }
  }
}
