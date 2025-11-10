import 'package:flutter/material.dart';

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
}

// PortfolioProvider with ChangeNotifier
class PortfolioProvider extends ChangeNotifier {
  // Single source of truth
  final List<PortfolioItem> _portfolioItems = [
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

  // Method untuk menambahkan portfolio
  void addPortfolio(PortfolioItem item) {
    _portfolioItems.add(item);
    notifyListeners();
  }

  // Method untuk update portfolio
  void updatePortfolio(PortfolioItem item) {
    final index = _portfolioItems.indexWhere((p) => p.id == item.id);
    if (index != -1) {
      _portfolioItems[index] = item;
      notifyListeners();
    }
  }

  // Method untuk delete portfolio
  void deletePortfolio(String id) {
    _portfolioItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
