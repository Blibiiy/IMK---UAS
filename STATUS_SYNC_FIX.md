# Fix: Sinkronisasi Status Project Mahasiswa

## ❌ Masalah Sebelumnya

Ketika dosen menyelesaikan project (mengubah status menjadi "Selesai"), status di sisi mahasiswa tetap menampilkan "Diterima" alih-alih "Selesai".

## 🔍 Penyebab

1. **Cache Status Lokal**: Method `getUserStatusInProject` menggunakan data project dari cache lokal (`getProjectById`) yang tidak selalu up-to-date
2. **Parsing Status Tidak Lengkap**: `Project.fromJson` tidak meng-handle status 'selesai'
3. **Tidak Ada Auto-Refresh**: Mahasiswa harus restart aplikasi untuk melihat perubahan status

## ✅ Solusi yang Diterapkan

### 1. Query Database Real-Time
**File**: `lib/providers/project_provider.dart`

```dart
Future<String> getUserStatusInProject(String projectId, String userId) async {
  // Sebelumnya: menggunakan cache lokal
  // final project = getProjectById(projectId);
  
  // Sekarang: query langsung ke database
  final projectData = await _supabaseService.getProjectById(projectId);
  final projectStatus = projectData?['status'] ?? 'tersedia';
  
  // Check if user is member
  if (isMember) {
    if (projectStatus == 'selesai') {
      return 'Selesai'; // ✓ Sekarang akan update otomatis
    }
    return 'Diterima';
  }
  // ...
}
```

**Benefit**: Status selalu up-to-date dari database, bukan dari cache lokal

### 2. Parsing Status Lengkap
**File**: `lib/providers/project_provider.dart`

```dart
factory Project.fromJson(Map<String, dynamic> json) {
  ProjectStatus status = ProjectStatus.tersedia;
  if (json['status'] == 'diproses') {
    status = ProjectStatus.diproses;
  } else if (json['status'] == 'diterima') {
    status = ProjectStatus.diterima;
  } else if (json['status'] == 'selesai') {
    status = ProjectStatus.selesai; // ✓ Tambahan parsing untuk 'selesai'
  }
  // ...
}
```

**Benefit**: Semua status dari database dapat di-parse dengan benar

### 3. Auto-Refresh dengan WidgetsBindingObserver
**File**: `lib/screens/home_screen.dart`

```dart
class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ✓ Register observer
    // ...
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // ✓ Refresh ketika app resume dari background
    if (state == AppLifecycleState.resumed) {
      _loadUserStatusForAllProjects();
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ✓ Cleanup
    // ...
  }
}
```

**Benefit**: Status otomatis refresh ketika mahasiswa kembali ke aplikasi

### 4. Pull-to-Refresh
**File**: `lib/screens/home_screen.dart`

```dart
return Scaffold(
  body: RefreshIndicator(
    onRefresh: _loadProjectsAndStatuses, // ✓ Reload data
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        // Project list...
      ),
    ),
  ),
);
```

**Benefit**: Mahasiswa bisa manual refresh dengan swipe down

## 🎯 Flow Status Project

### Dari Sisi Dosen:
1. Dosen membuat project → Status: **Tersedia**
2. Mahasiswa mendaftar → Dosen lihat di tab "Pendaftar"
3. Dosen terima mahasiswa → Mahasiswa pindah ke tab "Anggota"
4. Dosen tutup pendaftaran → Status: **Diproses** (opsional)
5. **Dosen selesaikan project** → Status: **Selesai**

### Dari Sisi Mahasiswa (Setelah Fix):
1. Belum daftar → Status: **Tersedia** ✓
2. Sudah daftar, belum diterima → Status: **Diproses** ✓
3. Sudah diterima, project belum selesai → Status: **Diterima** ✓
4. Sudah diterima, **project sudah diselesaikan dosen** → Status: **Selesai** ✓

## 🧪 Testing

### Test Case 1: Dosen Menyelesaikan Project
1. Login sebagai dosen
2. Buka project yang memiliki anggota
3. Klik "Tandai Selesai"
4. Login sebagai mahasiswa (yang menjadi anggota)
5. **Expected**: Status project berubah menjadi "Selesai"

### Test Case 2: Pull-to-Refresh
1. Login sebagai mahasiswa
2. (Di perangkat lain) Dosen menyelesaikan project
3. Di aplikasi mahasiswa, swipe down untuk refresh
4. **Expected**: Status terupdate menjadi "Selesai"

### Test Case 3: Auto-Refresh
1. Login sebagai mahasiswa
2. Minimize aplikasi (home button)
3. (Di perangkat lain) Dosen menyelesaikan project
4. Maximize aplikasi kembali
5. **Expected**: Status otomatis terupdate

## 📝 Catatan Penting

1. **Real-time vs Polling**: 
   - Saat ini menggunakan polling (refresh manual/on-resume)
   - Untuk real-time updates bisa gunakan Supabase Realtime subscriptions

2. **Performance**:
   - `getUserStatusInProject` sekarang query database setiap kali dipanggil
   - Untuk banyak project, pertimbangkan caching dengan TTL

3. **Database Dependency**:
   - Status mahasiswa sepenuhnya tergantung status project di database
   - Pastikan RLS policy mengizinkan read access

## 🚀 Next Steps (Optional)

1. **Implementasi Realtime Subscriptions**:
   ```dart
   // Listen to project updates
   supabase
     .from('projects')
     .stream(primaryKey: ['id'])
     .eq('id', projectId)
     .listen((data) {
       // Auto update UI
     });
   ```

2. **Add Loading States**: Tampilkan loading indicator saat refresh status

3. **Notification**: Push notification ketika project diselesaikan dosen
