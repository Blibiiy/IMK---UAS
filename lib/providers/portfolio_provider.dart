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

  // Getter untuk list portfolio
  List<PortfolioItem> get portfolioItems => _portfolioItems;

  // Load portfolios from Supabase for specific user
  Future<void> loadPortfolios({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // If no userId provided, return empty list
      if (userId == null) {
        _portfolioItems = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch portfolio by user ID
      final projects = await _supabaseService.getPortfolioProjectsByUserId(
        userId,
      );
      final certificates = await _supabaseService
          .getPortfolioCertificatesByUserId(userId);
      final organizations = await _supabaseService
          .getPortfolioOrganizationsByUserId(userId);

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
      // On error, show empty list (not dummy data)
      _portfolioItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method untuk menambahkan portfolio
  Future<void> addPortfolio(PortfolioItem item, String userId) async {
    try {
      if (item is ProjectPortfolio) {
        final response = await _supabaseService.addPortfolioProject(
          userId: userId,
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
          userId: userId,
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
          userId: userId,
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
