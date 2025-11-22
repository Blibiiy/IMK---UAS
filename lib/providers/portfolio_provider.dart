import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

// Sealed class PortfolioItem (abstract base class)
abstract class PortfolioItem {
  final String id;
  final String title;

  PortfolioItem({required this.id, required this.title});
}

// ProjectPortfolio subclass
class ProjectPortfolio extends PortfolioItem {
  final String lecturer;
  final String deadline;
  final String description;
  final List<String> requirements;
  final List<String> benefits;

  ProjectPortfolio({
    required super.id,
    required super.title,
    required this.lecturer,
    required this.deadline,
    required this.description,
    required this.requirements,
    required this.benefits,
  });

  factory ProjectPortfolio.fromJson(Map<String, dynamic> json) {
    return ProjectPortfolio(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      lecturer: json['lecturer'] ?? '',
      deadline: json['deadline'] ?? '',
      description: json['description'] ?? '',
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'])
          : [],
      benefits: json['benefits'] != null
          ? List<String>.from(json['benefits'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lecturer': lecturer,
      'deadline': deadline,
      'description': description,
      'requirements': requirements,
      'benefits': benefits,
    };
  }
}

// CertificatePortfolio subclass
class CertificatePortfolio extends PortfolioItem {
  final String issuer;
  final String startDate;
  final String endDate;
  final List<String> skills;
  final String? certificateFile;

  CertificatePortfolio({
    required super.id,
    required super.title,
    required this.issuer,
    required this.startDate,
    required this.endDate,
    required this.skills,
    this.certificateFile,
  });

  factory CertificatePortfolio.fromJson(Map<String, dynamic> json) {
    return CertificatePortfolio(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      issuer: json['issuer'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
      certificateFile: json['certificate_file'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'issuer': issuer,
      'start_date': startDate,
      'end_date': endDate,
      'skills': skills,
      'certificate_file': certificateFile,
    };
  }
}

// OrganizationPortfolio subclass
class OrganizationPortfolio extends PortfolioItem {
  final String position;
  final String duration;
  final String description;

  OrganizationPortfolio({
    required super.id,
    required super.title,
    required this.position,
    required this.duration,
    required this.description,
  });

  factory OrganizationPortfolio.fromJson(Map<String, dynamic> json) {
    return OrganizationPortfolio(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      position: json['position'] ?? '',
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'position': position,
      'duration': duration,
      'description': description,
    };
  }
}

// PortfolioProvider with ChangeNotifier
class PortfolioProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<PortfolioItem> _portfolioItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Data dummy untuk fallback
  final List<PortfolioItem> _dummyPortfolioItems = [
    // Dummy data - ProjectPortfolio
    ProjectPortfolio(
      id: '1',
      title: 'Project Deteksi Plat Kendaraan Bermotor',
      lecturer: 'Dr. Bahlul Amba, S.Pd',
      deadline: '10 Oktober 2025',
      description:
          'Project Mobile App Yang Ditujukan Untuk Membantu Riset Dan Penelitian Terhadap Masalah 19 Juta Lapangan Pekerjaan',
      requirements: [
        'Mampu Bertanggung Jawab Dan Jujur Dalam Melaksanakan Tugas',
        'Menguasai Semua Bahasa Pemograman Yang Ada Di Dunia',
        'Dapat Bekerja Kapan Pun Yang Dibutuhkan Oleh Dosen Pembimbing',
      ],
      benefits: ['Mendapatkan Uang 1 Milliar', 'Nilai Matakuliah Pasti A++'],
    ),

    // Dummy data - CertificatePortfolio
    CertificatePortfolio(
      id: '2',
      title: 'Certified IBM AI Software Engineer',
      issuer: 'IBM',
      startDate: '10 Oktober 2025',
      endDate: '10 Oktober 2027',
      skills: [
        'Problem Solving',
        'Leadership',
        'Advanced Python',
        'Data Analytics',
      ],
      certificateFile: 'IMG-21231.pdf',
    ),

    // Dummy data - OrganizationPortfolio
    OrganizationPortfolio(
      id: '3',
      title: 'Himpunan Mahasiswa Elektronika',
      position: 'Ketua Divisi Teknologi',
      duration: '1 Tahun 6 Bulan',
      description: '''Kegiatan Dan Kontribusi:

1. Mengatur Jalannya Acara Greet & Meet Mas Amba Dengan Mahasiswa Himanika

2. Memberikan Kata Sambutan Pada Acara Pengajian Bahlil Dengan Tema "Menjawab Pertanyaan Munkar-Nakir Dengan Bantuan AI"

3. Kolaborasi Dengan Direktur Pertamina Untuk Melakukan Kegiatan Bermain Uno Truth & Dare Dimana Yang Kalah Akan Melakukan Korupsi 1000 Triliun

4. Memimpin Kegiatan Ospek Maba Elektronika Tahun Masuk 2025 Yang Dilakukan Pada Tanggal 32 September 2025 Di Lantai 1 Perpustakaan UNP''',
    ),
  ];

  // Getter untuk list portfolio
  List<PortfolioItem> get portfolioItems => _portfolioItems;

  // Load all portfolios from Supabase
  Future<void> loadPortfolios() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch all portfolio types
      final projects = await _supabaseService.getAllPortfolioProjects();
      final certificates = await _supabaseService.getAllPortfolioCertificates();
      final organizations = await _supabaseService
          .getAllPortfolioOrganizations();

      // Convert to objects
      final List<PortfolioItem> items = [];

      for (var json in projects) {
        items.add(ProjectPortfolio.fromJson(json));
      }

      for (var json in certificates) {
        items.add(CertificatePortfolio.fromJson(json));
      }

      for (var json in organizations) {
        items.add(OrganizationPortfolio.fromJson(json));
      }

      _portfolioItems = items;
    } catch (e) {
      _errorMessage = 'Gagal memuat portfolio: $e';
      print(_errorMessage);
      // Fallback to dummy data
      _portfolioItems = _dummyPortfolioItems;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method untuk menambahkan portfolio
  Future<void> addPortfolio(PortfolioItem item) async {
    try {
      if (item is ProjectPortfolio) {
        final response = await _supabaseService.addPortfolioProject(
          title: item.title,
          lecturer: item.lecturer,
          deadline: item.deadline,
          description: item.description,
          requirements: item.requirements,
          benefits: item.benefits,
        );
        if (response != null) {
          _portfolioItems.add(ProjectPortfolio.fromJson(response));
        }
      } else if (item is CertificatePortfolio) {
        final response = await _supabaseService.addPortfolioCertificate(
          title: item.title,
          issuer: item.issuer,
          startDate: item.startDate,
          endDate: item.endDate,
          skills: item.skills,
          certificateFile: item.certificateFile,
        );
        if (response != null) {
          _portfolioItems.add(CertificatePortfolio.fromJson(response));
        }
      } else if (item is OrganizationPortfolio) {
        final response = await _supabaseService.addPortfolioOrganization(
          title: item.title,
          position: item.position,
          duration: item.duration,
          description: item.description,
        );
        if (response != null) {
          _portfolioItems.add(OrganizationPortfolio.fromJson(response));
        }
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menambahkan portfolio: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  // Method untuk update portfolio
  Future<void> updatePortfolio(PortfolioItem item) async {
    try {
      if (item is ProjectPortfolio) {
        final response = await _supabaseService.updatePortfolioProject(
          id: item.id,
          title: item.title,
          lecturer: item.lecturer,
          deadline: item.deadline,
          description: item.description,
          requirements: item.requirements,
          benefits: item.benefits,
        );
        if (response != null) {
          final index = _portfolioItems.indexWhere((p) => p.id == item.id);
          if (index != -1) {
            _portfolioItems[index] = ProjectPortfolio.fromJson(response);
          }
        }
      } else if (item is CertificatePortfolio) {
        final response = await _supabaseService.updatePortfolioCertificate(
          id: item.id,
          title: item.title,
          issuer: item.issuer,
          startDate: item.startDate,
          endDate: item.endDate,
          skills: item.skills,
          certificateFile: item.certificateFile,
        );
        if (response != null) {
          final index = _portfolioItems.indexWhere((p) => p.id == item.id);
          if (index != -1) {
            _portfolioItems[index] = CertificatePortfolio.fromJson(response);
          }
        }
      } else if (item is OrganizationPortfolio) {
        final response = await _supabaseService.updatePortfolioOrganization(
          id: item.id,
          title: item.title,
          position: item.position,
          duration: item.duration,
          description: item.description,
        );
        if (response != null) {
          final index = _portfolioItems.indexWhere((p) => p.id == item.id);
          if (index != -1) {
            _portfolioItems[index] = OrganizationPortfolio.fromJson(response);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal mengupdate portfolio: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  // Method untuk delete portfolio
  Future<void> deletePortfolio(String id) async {
    try {
      // Find the item to determine its type
      final item = _portfolioItems.firstWhere((item) => item.id == id);

      if (item is ProjectPortfolio) {
        await _supabaseService.deletePortfolioProject(id);
      } else if (item is CertificatePortfolio) {
        await _supabaseService.deletePortfolioCertificate(id);
      } else if (item is OrganizationPortfolio) {
        await _supabaseService.deletePortfolioOrganization(id);
      }

      _portfolioItems.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menghapus portfolio: $e';
      print(_errorMessage);
      rethrow;
    }
  }
}
