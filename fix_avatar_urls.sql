-- ============================================
-- FIX AVATAR URL - Ganti SVG ke PNG
-- ============================================
-- Run script ini untuk update avatar URL yang sudah ada di database
-- dari format SVG ke PNG agar bisa ditampilkan di Flutter

-- Update avatar mahasiswa dan dosen
UPDATE users 
SET avatar_url = REPLACE(avatar_url, '/svg?seed=', '/png?seed=')
WHERE avatar_url LIKE '%dicebear.com%/svg?seed=%';

-- Verifikasi perubahan
SELECT id, full_name, role, avatar_url 
FROM users 
ORDER BY role, full_name;

-- ============================================
-- Expected results:
-- - Isra: https://api.dicebear.com/7.x/avataaars/png?seed=Isra
-- - Aldi: https://api.dicebear.com/7.x/avataaars/png?seed=Aldi
-- - Budi: https://api.dicebear.com/7.x/avataaars/png?seed=Budi
-- ============================================
