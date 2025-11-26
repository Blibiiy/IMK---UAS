# Fitur Upload Bukti Sertifikat - Portfolio

## 📋 Deskripsi

Fitur untuk mengupload file bukti sertifikat pada kategori "Sertifikat" di portfolio mahasiswa. File dapat berupa PDF atau gambar dengan maksimal ukuran 10 MB.

## ✨ Fitur

### Spesifikasi File
- **Format yang Didukung**: PDF, JPG, JPEG, PNG, GIF, WEBP
- **Ukuran Maksimal**: 10 MB
- **Jumlah File**: 1 file per sertifikat
- **Sifat**: Opsional (tidak wajib)

### Kemampuan
- ✅ Upload file saat menambah sertifikat baru
- ✅ Upload/ganti file saat edit sertifikat
- ✅ Hapus file yang sudah diupload
- ✅ Preview nama file yang dipilih
- ✅ Validasi ukuran file
- ✅ Validasi format file
- ✅ Loading indicator saat upload

## 🛠️ Implementasi

### 1. Dependencies yang Ditambahkan

**File**: `pubspec.yaml`

```yaml
dependencies:
  file_picker: ^8.1.6    # Untuk memilih file dari device
  image_picker: ^1.1.2   # Untuk memilih gambar (alternatif)
  path: ^1.9.0           # Untuk manipulasi path file
```

Jalankan:
```bash
flutter pub get
```

### 2. Supabase Storage Service

**File**: `lib/services/supabase_service.dart`

Ditambahkan 2 method baru:

#### a. Upload File
```dart
Future<String?> uploadFile({
  required File file,
  required String bucket,
  required String path,
}) async {
  // Validasi ukuran file (max 10MB)
  // Validasi format file
  // Upload ke Supabase Storage
  // Return public URL
}
```

#### b. Delete File
```dart
Future<void> deleteFile({
  required String bucket,
  required String path,
}) async {
  // Delete file dari Supabase Storage
}
```

### 3. Portfolio Form Screen Updates

**File**: `lib/screens/portfolio_form_screen.dart`

#### State Variables Baru:
```dart
String? _certificateFile;  // URL atau filename
File? _selectedFile;       // File object yang dipilih
bool _isUploading;         // Status upload
```

#### Method Baru:

**a. Pick File**
```dart
Future<void> _pickFile() async {
  // Gunakan FilePicker untuk pilih file
  // Validasi ukuran file
  // Simpan file ke state
}
```

**b. Upload File to Storage**
```dart
Future<String?> _uploadFileToStorage(String userId) async {
  // Generate unique filename
  // Upload file ke bucket 'portfolios'
  // Return public URL
}
```

**c. Updated Submit Handler**
```dart
Future<void> _handleSubmit() async {
  // Upload file jika ada file baru
  // Simpan URL ke database
  // Submit portfolio
}
```

## 📁 Struktur Penyimpanan

### Supabase Storage
```
Bucket: portfolios/
  └── certificates/
      └── {userId}/
          └── certificate_{userId}_{timestamp}.{ext}
```

### Contoh Path:
```
portfolios/certificates/11111111-1111-1111-1111-111111111111/certificate_11111111_1234567890.pdf
```

### Database Field
Tabel: `portfolio_certificates`
Field: `certificate_file` (TEXT)
Value: Public URL dari Supabase Storage

## 🎨 UI/UX

### Upload Button
- Icon upload dari `assets/logos/upload.svg`
- Text: "Pilih File" (jika belum ada file)
- Text: "Ganti File" (jika sudah ada file)
- Disabled saat upload sedang berlangsung

### File Preview
Setelah file dipilih, ditampilkan:
- Icon (PDF atau Image) berdasarkan tipe file
- Nama file (truncated dengan ellipsis)
- Button close untuk hapus file

### Loading State
- Circular progress indicator pada button
- Text berubah menjadi "Mengupload..."
- Button disabled

### Validation Messages
- "Ukuran file tidak boleh lebih dari 10 MB"
- "Format file tidak didukung. Gunakan PDF atau gambar"
- "Gagal memilih file: {error}"

## 🚀 Setup Supabase Storage

### 1. Jalankan SQL Setup
Jalankan file `supabase_storage_setup.sql` di Supabase SQL Editor.

Script ini akan:
- Create bucket `portfolios` (public)
- Enable RLS pada storage.objects
- Create policies untuk read, insert, update, delete

### 2. Verifikasi di Dashboard
1. Buka Supabase Dashboard → Storage
2. Pastikan bucket `portfolios` ada
3. Test upload file manual untuk memastikan policy bekerja

### 3. Optional: Set Size Limit di Dashboard
Storage → portfolios → Settings → Max file size: 10MB

## 📝 Cara Penggunaan

### Untuk User (Mahasiswa):

1. **Tambah Sertifikat Baru:**
   - Pilih kategori "Sertifikat"
   - Isi form (judul, penerbit, tanggal, skills)
   - (Opsional) Klik "Pilih File" untuk upload bukti
   - Pilih file PDF atau gambar dari device
   - Preview file muncul dengan nama file
   - Klik "Tambah" untuk simpan

2. **Edit Sertifikat:**
   - Buka detail sertifikat → Klik Edit
   - File lama tetap ada (jika ada)
   - Klik "Ganti File" untuk upload file baru
   - Atau klik X untuk hapus file
   - Klik "Update" untuk simpan perubahan

3. **Hapus File:**
   - Klik icon X pada file preview
   - File akan dihapus dari form (belum dari storage)
   - Simpan perubahan untuk update database

## 🔒 Keamanan & Best Practices

### Current Implementation (Development):
- ✅ File size validation di client
- ✅ File type validation di client
- ✅ Public read access untuk semua file
- ✅ Authenticated users dapat CRUD

### Untuk Production:
1. **Restrictive RLS Policies:**
   ```sql
   -- User hanya bisa upload file mereka sendiri
   CREATE POLICY "Users upload own files"
   ON storage.objects FOR INSERT
   TO authenticated
   WITH CHECK (
     bucket_id = 'portfolios' 
     AND (storage.foldername(name))[1] = 'certificates'
     AND (storage.foldername(name))[2] = auth.uid()::text
   );
   ```

2. **Proper Authentication:**
   - Gunakan Supabase Auth (bukan table users)
   - Validate user session di setiap request

3. **Server-side Validation:**
   - Implement edge functions untuk validate file
   - Virus scanning untuk uploaded files

4. **Cleanup Policy:**
   - Delete file dari storage saat sertifikat dihapus
   - Scheduled cleanup untuk orphaned files

## 🐛 Troubleshooting

### Error: "Bucket not found"
**Solusi:** Jalankan `supabase_storage_setup.sql`

### Error: "Permission denied"
**Solusi:** Check RLS policies di storage.objects

### File tidak bisa didownload
**Solusi:** Pastikan bucket bersifat public atau policy read benar

### File terlalu besar
**Solusi:** Compress file atau ubah max size limit

### Format file tidak didukung
**Solusi:** Convert file ke format yang didukung (PDF/JPG/PNG)

## 📊 Testing

### Test Cases:

1. **Upload File Valid:**
   - PDF < 10MB ✓
   - JPG < 10MB ✓
   - PNG < 10MB ✓

2. **Upload File Invalid:**
   - File > 10MB → Error message ✓
   - Format .docx → Error message ✓
   - No file selected → Optional, lanjut tanpa file ✓

3. **Edit File:**
   - Ganti file lama dengan baru ✓
   - Hapus file (set null) ✓
   - Tidak ubah file ✓

4. **Edge Cases:**
   - Upload saat offline → Error handling ✓
   - Cancel upload mid-process ✓
   - Upload file dengan special characters di nama ✓

## 🔄 Future Enhancements

1. **Multiple Files:** Support upload multiple files per sertifikat
2. **Image Preview:** Tampilkan thumbnail untuk gambar
3. **PDF Preview:** Tampilkan preview PDF inline
4. **Drag & Drop:** Upload dengan drag & drop
5. **Progress Bar:** Tampilkan upload progress
6. **Compress Images:** Auto-compress gambar sebelum upload
7. **OCR:** Extract text dari PDF/gambar otomatis
