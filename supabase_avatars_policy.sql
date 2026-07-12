-- Mengizinkan akses publik untuk membaca file dari bucket 'avatars'
CREATE POLICY "Avatar images are publicly accessible."
  ON storage.objects FOR SELECT
  USING ( bucket_id = 'avatars' );

-- Mengizinkan user yang sudah login (authenticated) untuk mengupload file ke bucket 'avatars'
CREATE POLICY "Anyone can upload an avatar."
  ON storage.objects FOR INSERT
  WITH CHECK ( bucket_id = 'avatars' AND auth.role() = 'authenticated' );

-- Mengizinkan user untuk mengupdate avatar mereka sendiri
CREATE POLICY "Anyone can update an avatar."
  ON storage.objects FOR UPDATE
  WITH CHECK ( bucket_id = 'avatars' AND auth.role() = 'authenticated' );

-- Mengizinkan user untuk menghapus avatar mereka sendiri
CREATE POLICY "Anyone can delete their avatar."
  ON storage.objects FOR DELETE
  USING ( bucket_id = 'avatars' AND auth.role() = 'authenticated' );
