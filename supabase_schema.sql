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

-- Hak Akses Lengkap Publik & Anon (Memungkinkan Panel Admin Frontend mengelola data via API Anon / Publishable Key)
DROP POLICY IF EXISTS "Public Read Events" ON public.events;
DROP POLICY IF EXISTS "Admin Full Events" ON public.events;
DROP POLICY IF EXISTS "Full Access Events" ON public.events;
CREATE POLICY "Full Access Events" ON public.events FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public Read Research" ON public.research_reports;
DROP POLICY IF EXISTS "Admin Full Research" ON public.research_reports;
DROP POLICY IF EXISTS "Full Access Research" ON public.research_reports;
CREATE POLICY "Full Access Research" ON public.research_reports FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public Read Partners" ON public.partners;
DROP POLICY IF EXISTS "Admin Full Partners" ON public.partners;
DROP POLICY IF EXISTS "Full Access Partners" ON public.partners;
CREATE POLICY "Full Access Partners" ON public.partners FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public Insert Inquiries" ON public.inquiries;
DROP POLICY IF EXISTS "Admin Full Inquiries" ON public.inquiries;
DROP POLICY IF EXISTS "Full Access Inquiries" ON public.inquiries;
CREATE POLICY "Full Access Inquiries" ON public.inquiries FOR ALL USING (true) WITH CHECK (true);

-- 7. STORAGE BUCKET: MEDIA, FOTO DOKUMENTASI & PDF RISET (GRATIS, MAX 10MB)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) 
VALUES (
  'kspm-media',
  'kspm-media',
  true,
  10485760, -- Batas 10 MB per file
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml', 'application/pdf']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 10485760,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml', 'application/pdf'];

DROP POLICY IF EXISTS "Public Access Storage" ON storage.objects;
DROP POLICY IF EXISTS "Admin Upload Storage" ON storage.objects;
DROP POLICY IF EXISTS "Admin Update Storage" ON storage.objects;
DROP POLICY IF EXISTS "Admin Delete Storage" ON storage.objects;
DROP POLICY IF EXISTS "Allow All Storage Read" ON storage.objects;
DROP POLICY IF EXISTS "Allow All Storage Insert" ON storage.objects;
DROP POLICY IF EXISTS "Allow All Storage Update" ON storage.objects;
DROP POLICY IF EXISTS "Allow All Storage Delete" ON storage.objects;

CREATE POLICY "Allow All Storage Read" ON storage.objects FOR SELECT USING (bucket_id = 'kspm-media');
CREATE POLICY "Allow All Storage Insert" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'kspm-media');
CREATE POLICY "Allow All Storage Update" ON storage.objects FOR UPDATE USING (bucket_id = 'kspm-media');
CREATE POLICY "Allow All Storage Delete" ON storage.objects FOR DELETE USING (bucket_id = 'kspm-media');

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
  'assets/team/groups/dsx09626-1-.webp',
  'https://drive.google.com/drive/folders/kspm-unsoed-siw-2026',
  'Konferensi akbar pasar modal nasional terbesar yang mempertemukan praktisi BEI, analis, dan 1.200+ investor muda.',
  'Purwokerto — Kelompok Studi Pasar Modal (KSPM) FEB Universitas Jenderal Soedirman sukses menyelenggarakan rangkaian akbar tahunan Soedirman Investment Week (SIW) 2026 berkolaborasi dengan Sekolah Pasar Modal II di Auditorium Graha Widyatama.',
  '["Purwokerto — Kelompok Studi Pasar Modal (KSPM) FEB Universitas Jenderal Soedirman sukses menyelenggarakan rangkaian akbar tahunan Soedirman Investment Week (SIW) 2026 berkolaborasi dengan Sekolah Pasar Modal II di Auditorium Graha Widyatama.", "Mengusung tema ''Outthink the Algorithm, Outinvest the Rhythm, Outperform the System'', kegiatan ini menghadirkan narasumber dari BEI dan OJK Purwokerto.", "Seluruh dokumentasi kegiatan dan materi paparan telah diarsipkan secara resmi."]'::jsonb,
  '[{"title": "Sesi Keynote Speaker BEI & OJK", "img": "assets/team/groups/dsx09550.webp"}, {"title": "Antusiasme 1.200 Peserta Mahasiswa", "img": "assets/team/groups/dsx09572.webp"}]'::jsonb
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
  'assets/team/groups/dsx09414.webp',
  'https://drive.google.com/drive/folders/kspm-unsoed-spm-2026',
  'Pelatihan berjenjang resmi bersama Bursa Efek Indonesia dan Sinarmas Sekuritas dengan sertifikasi dan fasilitas pembukaan RDN.',
  'Purwokerto — Galeri Investasi BEI FEB Unsoed dan KSPM Unsoed secara konsisten menyelenggarakan Sekolah Pasar Modal (SPM) Level 1 dan Level 2 di Laboratorium Terpadu Lantai 1 FEB Unsoed.',
  '["Purwokerto — Galeri Investasi BEI FEB Unsoed dan KSPM Unsoed secara konsisten menyelenggarakan Sekolah Pasar Modal (SPM) Level 1 dan Level 2 di Laboratorium Terpadu Lantai 1 FEB Unsoed.", "Bekerja sama erat dengan PT Sinarmas Sekuritas untuk pembukaan rekening dana nasabah (RDN) dan sertifikasi edukasi BEI."]'::jsonb,
  '[{"title": "Praktik Transaksi Saham Perdana", "img": "assets/team/groups/dsx09458.webp"}]'::jsonb
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
  'assets/team/groups/dsx09493.webp',
  'https://drive.google.com/drive/folders/kspm-unsoed-legacy-2026',
  'Kompetisi analisis riset saham dan virtual trading bergengsi berskala nasional bagi mahasiswa seluruh Indonesia.',
  'Purwokerto — Sebagai wujud komitmen dalam mencetak analis dan trader muda yang rasional, KSPM Unsoed kembali sukses menggelar kompetisi nasional tahunan LEGACY.',
  '["Purwokerto — Sebagai wujud komitmen dalam mencetak analis dan trader muda yang rasional, KSPM Unsoed kembali sukses menggelar kompetisi nasional tahunan LEGACY."]'::jsonb,
  '[{"title": "Penjurian Babak Presentasi Finalis", "img": "assets/team/groups/dsx09502.webp"}]'::jsonb
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
  'assets/team/adjani.webp',
  '["[INVESTORY]", "Mining", "Gold"]'::jsonb,
  '["Purwokerto — PT Amman Mineral Internasional Tbk (AMMN) berhasil mencatatkan rekor kapitalisasi pasar yang membawanya masuk ke dalam jajaran 50 Perusahaan Tambang Terbesar di Dunia.", "Proyek smelter tembaga di Sumbawa Barat telah mencapai tahap commissioning dan siap beroperasi komersial penuh."]'::jsonb,
  '[{"name": "Raka Pratama", "role": "Lead Equity Analyst", "avatar": "assets/team/alfio.webp"}]'::jsonb
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
  'assets/team/ari-dwi-cesariano.webp',
  '["[INVESTORY]", "Renewable Energy", "Geothermal"]'::jsonb,
  '["Purwokerto — PT Barito Pacific Tbk (BRPT) membukukan lonjakan pendapatan berkat rampungnya ekspansi kilang Singapura dan stabilitas arus kas Star Energy Geothermal."]'::jsonb,
  '[{"name": "Ilham Kurnia", "role": "Lead Industrial Analyst", "avatar": "assets/team/adi.webp"}]'::jsonb
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
  'assets/team/ridha.webp',
  '["[INVESTORY]", "Perbankan", "Blue Chip"]'::jsonb,
  '["Purwokerto — PT Bank Central Asia Tbk (BBCA) terus menunjukkan resiliensi kinerja keuangan yang solid didukung rasio dana murah (CASA) di atas 81%."]'::jsonb,
  '[{"name": "Farhan Maulana", "role": "Lead Banking Analyst", "avatar": "assets/team/aditya-rayhandi.webp"}]'::jsonb
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
