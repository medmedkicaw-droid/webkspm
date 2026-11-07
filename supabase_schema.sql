-- ==============================================================================
-- KSPM UNIVERSITAS JENDERAL SOEDIRMAN — SUPABASE COMPLETE DATABASE SCHEMA
-- ==============================================================================
-- Cukup salin seluruh isi file ini, lalu tempel di menu SQL Editor di Supabase,
-- dan klik tombol RUN (Ctrl + Enter). Semua tabel, storage foto, dan keamanan langsung aktif!
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. TABEL: EVENTS (PAKET ACARA & PRESS RELEASE SEPAKET)
CREATE TABLE IF NOT EXISTS public.events (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    schedule TEXT NOT NULL,
    date_badge TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Upcoming',
    location TEXT NOT NULL,
    author TEXT DEFAULT 'Divisi Humas & Eksternal KSPM',
    cover_image TEXT,
    drive_link TEXT,
    description TEXT,
    article TEXT,
    article_paragraphs JSONB DEFAULT '[]'::jsonb,
    gallery JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. TABEL: RESEARCH REPORTS (LAPORAN RISET INVESTORY)
CREATE TABLE IF NOT EXISTS public.research_reports (
    id TEXT PRIMARY KEY,
    ticker TEXT NOT NULL,
    company TEXT NOT NULL,
    sector TEXT DEFAULT 'Sektor Pasar Modal',
    title TEXT NOT NULL,
    subtitle TEXT,
    recommendation TEXT NOT NULL DEFAULT 'BUY',
    target_price TEXT NOT NULL,
    current_price TEXT DEFAULT 'Market Price',
    upside TEXT DEFAULT '+12.5%',
    release_date TEXT DEFAULT '2026',
    pdf_url TEXT,
    cover_image TEXT,
    tags JSONB DEFAULT '[]'::jsonb,
    thesis JSONB DEFAULT '[]'::jsonb,
    contributors JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. TABEL: PARTNERS (LOGO MITRA RUNNING TRACK)
CREATE TABLE IF NOT EXISTS public.partners (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    tooltip TEXT NOT NULL,
    logo TEXT NOT NULL,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. TABEL: INQUIRIES (PESAN FORMULIR KEMITRAAN BERANDA)
CREATE TABLE IF NOT EXISTS public.inquiries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL,
    organization TEXT NOT NULL,
    topic TEXT NOT NULL,
    message TEXT NOT NULL,
    status TEXT DEFAULT 'Pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. ROW LEVEL SECURITY (RLS) KEAMANAN DATA
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.research_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inquiries ENABLE ROW LEVEL SECURITY;

-- Hak Akses Publik (Read-only data publik)
DROP POLICY IF EXISTS "Public Read Events" ON public.events;
CREATE POLICY "Public Read Events" ON public.events FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Read Research" ON public.research_reports;
CREATE POLICY "Public Read Research" ON public.research_reports FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Read Partners" ON public.partners;
CREATE POLICY "Public Read Partners" ON public.partners FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Insert Inquiries" ON public.inquiries;
CREATE POLICY "Public Insert Inquiries" ON public.inquiries FOR INSERT WITH CHECK (true);

-- Hak Akses Admin (Hanya akun pengurus terotentikasi yang bisa ubah/hapus/tambah data)
DROP POLICY IF EXISTS "Admin Full Events" ON public.events;
CREATE POLICY "Admin Full Events" ON public.events FOR ALL TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Admin Full Research" ON public.research_reports;
CREATE POLICY "Admin Full Research" ON public.research_reports FOR ALL TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Admin Full Partners" ON public.partners;
CREATE POLICY "Admin Full Partners" ON public.partners FOR ALL TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Admin Full Inquiries" ON public.inquiries;
CREATE POLICY "Admin Full Inquiries" ON public.inquiries FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 7. STORAGE BUCKET: MEDIA, FOTO DOKUMENTASI & PDF RISET (GRATIS 1 GB, MAX 5MB)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) 
VALUES (
  'kspm-media',
  'kspm-media',
  true,
  5242880, -- Batas 5 MB per file
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml', 'application/pdf']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml', 'application/pdf'];

DROP POLICY IF EXISTS "Public Access Storage" ON storage.objects;
CREATE POLICY "Public Access Storage" ON storage.objects FOR SELECT USING (bucket_id = 'kspm-media');

DROP POLICY IF EXISTS "Admin Upload Storage" ON storage.objects;
CREATE POLICY "Admin Upload Storage" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'kspm-media');

DROP POLICY IF EXISTS "Admin Update Storage" ON storage.objects;
CREATE POLICY "Admin Update Storage" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'kspm-media');

DROP POLICY IF EXISTS "Admin Delete Storage" ON storage.objects;
CREATE POLICY "Admin Delete Storage" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'kspm-media');

-- 8. DATA AWAL RESMI (SEED DATA AUTENTIK KSPM UNSOED)
INSERT INTO public.events (id, name, category, schedule, date_badge, status, location, author, cover_image, drive_link, description, article, article_paragraphs, gallery)
VALUES 
(
  'siw',
  'Soedirman Investment Week 2026 X SPM II',
  'Annual Flagship',
  '24 - 28 Oktober 2026',
  'OKT 2026',
  'Running',
  'Auditorium Graha Widyatama Unsoed',
  'Divisi Project Management & Humas KSPM',
  'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=800&q=80',
  'https://drive.google.com/drive/folders/kspm-unsoed-siw-2026',
  'Konferensi akbar pasar modal nasional terbesar yang mempertemukan praktisi BEI, analis, dan 1.200+ investor muda.',
  'Purwokerto — Kelompok Studi Pasar Modal (KSPM) FEB Universitas Jenderal Soedirman sukses menyelenggarakan rangkaian akbar tahunan Soedirman Investment Week (SIW) 2026 berkolaborasi dengan Sekolah Pasar Modal II di Auditorium Graha Widyatama.',
  '["Purwokerto — Kelompok Studi Pasar Modal (KSPM) FEB Universitas Jenderal Soedirman sukses menyelenggarakan rangkaian akbar tahunan Soedirman Investment Week (SIW) 2026 berkolaborasi dengan Sekolah Pasar Modal II di Auditorium Graha Widyatama.", "Mengusung tema ''Outthink the Algorithm, Outinvest the Rhythm, Outperform the System'', kegiatan ini menghadirkan narasumber dari BEI dan OJK Purwokerto.", "Seluruh dokumentasi kegiatan dan materi paparan telah diarsipkan secara resmi."]'::jsonb,
  '[{"title": "Sesi Keynote Speaker BEI & OJK", "img": "https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=800&q=80"}, {"title": "Antusiasme 1.200 Peserta Mahasiswa", "img": "https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=800&q=80"}]'::jsonb
),
(
  'spm',
  'Sekolah Pasar Modal (SPM) Level 1 & 2',
  'Certification',
  'Setiap Sabtu (Reguler)',
  'REGULER',
  'Running',
  'Laboratorium Terpadu Lantai 1 FEB Unsoed',
  'Divisi Project Management & Edukasi',
  'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&w=800&q=80',
  'https://drive.google.com/drive/folders/kspm-unsoed-spm-2026',
  'Pelatihan berjenjang resmi bersama Bursa Efek Indonesia dan Sinarmas Sekuritas dengan sertifikasi dan fasilitas pembukaan RDN.',
  'Purwokerto — Galeri Investasi BEI FEB Unsoed dan KSPM Unsoed secara konsisten menyelenggarakan Sekolah Pasar Modal (SPM) Level 1 dan Level 2 di Laboratorium Terpadu Lantai 1 FEB Unsoed.',
  '["Purwokerto — Galeri Investasi BEI FEB Unsoed dan KSPM Unsoed secara konsisten menyelenggarakan Sekolah Pasar Modal (SPM) Level 1 dan Level 2 di Laboratorium Terpadu Lantai 1 FEB Unsoed.", "Bekerja sama erat dengan PT Sinarmas Sekuritas untuk pembukaan rekening dana nasabah (RDN) dan sertifikasi edukasi BEI."]'::jsonb,
  '[{"title": "Praktik Transaksi Saham Perdana", "img": "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?auto=format&fit=crop&w=800&q=80"}]'::jsonb
),
(
  'legacy',
  'LEGACY National Trading Competition',
  'National Competition',
  '20 Agustus 2026',
  'AGU 2026',
  'Completed',
  'Platform Daring Nasional',
  'Divisi Research & HRM',
  'https://images.unsplash.com/photo-1535320903710-d993d3d77d29?auto=format&fit=crop&w=800&q=80',
  'https://drive.google.com/drive/folders/kspm-unsoed-legacy-2026',
  'Kompetisi analisis riset saham dan virtual trading bergengsi berskala nasional bagi mahasiswa seluruh Indonesia.',
  'Purwokerto — Sebagai wujud komitmen dalam mencetak analis dan trader muda yang rasional, KSPM Unsoed kembali sukses menggelar kompetisi nasional tahunan LEGACY.',
  '["Purwokerto — Sebagai wujud komitmen dalam mencetak analis dan trader muda yang rasional, KSPM Unsoed kembali sukses menggelar kompetisi nasional tahunan LEGACY."]'::jsonb,
  '[{"title": "Penjurian Babak Presentasi Finalis", "img": "https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=800&q=80"}]'::jsonb
)
ON CONFLICT (id) DO UPDATE SET 
  name = EXCLUDED.name,
  schedule = EXCLUDED.schedule,
  updated_at = now();

-- SEED DATA RISET INVESTORY (AMMN, BRPT, BBCA)
INSERT INTO public.research_reports (id, ticker, company, sector, title, subtitle, recommendation, target_price, current_price, upside, release_date, pdf_url, cover_image, tags, thesis, contributors)
VALUES 
(
  'ammn',
  'AMMN',
  'PT Amman Mineral Internasional Tbk',
  'Tambang Emas & Tembaga',
  'Top 50 Tambang Dunia & Komersialisasi Smelter Emas-Tembaga',
  'Kajian Fundamental Sektor Komoditas & Efek Katalis Smelter Sumbawa Barat',
  'BUY',
  'Rp 12.800',
  'Rp 9.650',
  '+32.6%',
  'September 2026',
  'https://kspm.unsoed.ac.id/research/AMMN-Report-2026.pdf',
  'https://images.unsplash.com/photo-1618042164219-62c820f10723?auto=format&fit=crop&w=1200&q=80',
  '["[INVESTORY]", "Mining", "Gold"]'::jsonb,
  '["Purwokerto — PT Amman Mineral Internasional Tbk (AMMN) berhasil mencatatkan rekor kapitalisasi pasar yang membawanya masuk ke dalam jajaran 50 Perusahaan Tambang Terbesar di Dunia.", "Proyek smelter tembaga di Sumbawa Barat telah mencapai tahap commissioning dan siap beroperasi komersial penuh."]'::jsonb,
  '[{"name": "Raka Pratama", "role": "Lead Equity Analyst", "avatar": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=120&q=80"}]'::jsonb
),
(
  'brpt',
  'BRPT',
  'PT Barito Pacific Tbk',
  'Petrokimia & Energi Hijau',
  'Ekspansi Kilang Singapura & Optimalisasi Geotermal Star Energy',
  'Pertumbuhan Arus Kas Operasional Energi Terbarukan & Dividen Tunai',
  'BUY',
  'Rp 1.450',
  'Rp 1.150',
  '+26.1%',
  'Agustus 2026',
  'https://kspm.unsoed.ac.id/research/BRPT-Report-2026.pdf',
  'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?auto=format&fit=crop&w=1200&q=80',
  '["[INVESTORY]", "Renewable Energy", "Geothermal"]'::jsonb,
  '["Purwokerto — PT Barito Pacific Tbk (BRPT) membukukan lonjakan pendapatan berkat rampungnya ekspansi kilang Singapura dan stabilitas arus kas Star Energy Geothermal."]'::jsonb,
  '[{"name": "Ilham Kurnia", "role": "Lead Industrial Analyst", "avatar": "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=120&q=80"}]'::jsonb
),
(
  'bbca',
  'BBCA',
  'PT Bank Central Asia Tbk',
  'Perbankan & Finansial',
  'Solid NIM amidst Digital Expansion & High CASA Franchise',
  'Kajian Fundamental, Tinjauan Valuasi DCF & Multiple PE Kuartal I 2026',
  'BUY',
  'Rp 11.200',
  'Rp 9.850',
  '+13.7%',
  'Oktober 2026',
  'https://kspm.unsoed.ac.id/research/BBCA-Report-2026.pdf',
  'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?auto=format&fit=crop&w=1200&q=80',
  '["[INVESTORY]", "Perbankan", "Blue Chip"]'::jsonb,
  '["Purwokerto — PT Bank Central Asia Tbk (BBCA) terus menunjukkan resiliensi kinerja keuangan yang solid didukung rasio dana murah (CASA) di atas 81%."]'::jsonb,
  '[{"name": "Farhan Maulana", "role": "Lead Banking Analyst", "avatar": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&q=80"}]'::jsonb
)
ON CONFLICT (id) DO UPDATE SET 
  title = EXCLUDED.title,
  target_price = EXCLUDED.target_price,
  updated_at = now();

-- SEED PARTNERS RUNNING MARQUEE
INSERT INTO public.partners (id, name, tooltip, logo, sort_order)
VALUES
('pt-1', 'Universitas Indonesia', 'KSPM FEB UI · Universitas Indonesia', 'assets/logo-ui.png', 1),
('pt-2', 'Universitas Gadjah Mada', 'KSPM FEB UGM · Universitas Gadjah Mada', 'assets/logo-ugm.png', 2),
('pt-3', 'Institut Teknologi Bandung', 'KSPM ITB · Institut Teknologi Bandung', 'assets/logo-itb.png', 3),
('pt-4', 'Universitas Diponegoro', 'KSPM FEB Undip · Universitas Diponegoro', 'assets/logo-undip.png', 4),
('pt-5', 'Universitas Padjadjaran', 'Young Investor · Universitas Padjadjaran', 'assets/logo-yi-unpad.png', 5),
('pt-6', 'Institut Pertanian Bogor', 'IPB Finance Club · Institut Pertanian Bogor', 'assets/logo-ipb.png', 6)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, tooltip = EXCLUDED.tooltip;
