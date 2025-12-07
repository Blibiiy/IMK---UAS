-- Script untuk membersihkan nama dosen yang memiliki prefix "Dosen Pembimbing:"
-- Menghapus prefix dan hanya menyimpan nama dosen saja

-- Preview data yang akan diubah
SELECT 
  id,
  title,
  supervisor as supervisor_lama,
  CASE 
    WHEN supervisor LIKE 'Dosen Pembimbing:%' THEN TRIM(SUBSTRING(supervisor FROM 18))
    WHEN supervisor LIKE 'Dosen:%' THEN TRIM(SUBSTRING(supervisor FROM 7))
    ELSE supervisor
  END as supervisor_baru
FROM projects
WHERE supervisor LIKE 'Dosen%:%';

-- Update nama dosen - hapus prefix "Dosen Pembimbing:" atau "Dosen:"
UPDATE projects
SET supervisor = CASE 
  WHEN supervisor LIKE 'Dosen Pembimbing:%' THEN TRIM(SUBSTRING(supervisor FROM 18))
  WHEN supervisor LIKE 'Dosen:%' THEN TRIM(SUBSTRING(supervisor FROM 7))
  ELSE supervisor
END
WHERE supervisor LIKE 'Dosen%:%';

-- Verifikasi hasil update
SELECT 
  id,
  title,
  supervisor
FROM projects
ORDER BY posted_at DESC
LIMIT 10;
