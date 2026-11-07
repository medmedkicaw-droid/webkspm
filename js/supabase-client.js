/**
 * KSPM UNSOED — SUPABASE BACKEND CLIENT
 * Arsitektur Static CDN: Menghubungkan Web Frontend & Panel Admin langsung ke Cloud Database Supabase
 */

(function(window) {
  'use strict';

  // XSS Protection / Sanitization Helper
  function sanitizeHTML(str) {
    if (typeof str !== 'string') return str;
    return str.replace(/[&<>"']/g, function(tag) {
      const charsToReplace = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;'
      };
      return charsToReplace[tag] || tag;
    });
  }

  let supabaseClient = null;

  // 1. Initial Connection Setup
  function initClient() {
    const url = (localStorage.getItem('kspm_supabase_url') || '').trim();
    const key = (localStorage.getItem('kspm_supabase_key') || '').trim();

    if (!url || !key) {
      supabaseClient = null;
      return false;
    }

    if (window.supabase) {
      try {
        supabaseClient = window.supabase.createClient(url, key);
        console.log('[KSPM Backend] Connected to Supabase Cloud:', url);
        return true;
      } catch (err) {
        console.warn('[KSPM Backend] Failed to initialize Supabase client:', err);
        supabaseClient = null;
      }
    }
    return false;
  }

  // 2. Helper to check if cloud is active
  function isCloudConnected() {
    initClient();
    return supabaseClient !== null;
  }

  // 3. Database Operations
  const kspmDB = {
    isCloudConnected,

    // --- EVENTS & PRESS RELEASES ---
    async getEvents() {
      if (isCloudConnected()) {
        try {
          const { data, error } = await supabaseClient
            .from('events')
            .select('*')
            .order('created_at', { ascending: false });
          if (!error && data && data.length > 0) {
            // Map SQL columns to frontend JS object
            return data.map(row => ({
              id: row.id,
              name: row.name,
              category: row.category,
              schedule: row.schedule,
              dateBadge: row.date_badge,
              status: row.status,
              location: row.location,
              author: row.author,
              coverImage: row.cover_image,
              driveLink: row.drive_link,
              desc: row.description,
              article: row.article,
              articleParagraphs: row.article_paragraphs || [],
              gallery: row.gallery || []
            }));
          }
        } catch (e) {
          console.warn('[KSPM Backend] Error fetching cloud events, using local fallback:', e);
        }
      }
      return JSON.parse(localStorage.getItem('kspm_events') || '[]');
    },

    async saveEvent(item) {
      // Always save locally first for instant offline responsiveness
      let localEvents = JSON.parse(localStorage.getItem('kspm_events') || '[]');
      const idx = localEvents.findIndex(e => e.id === item.id);
      if (idx !== -1) localEvents[idx] = item;
      else localEvents.unshift(item);
      localStorage.setItem('kspm_events', JSON.stringify(localEvents));

      // Sync to cloud if connected
      if (isCloudConnected()) {
        try {
          const row = {
            id: item.id,
            name: item.name,
            category: item.category,
            schedule: item.schedule,
            date_badge: item.dateBadge || '2026',
            status: item.status,
            location: item.location,
            author: item.author || 'Divisi Humas & Eksternal KSPM',
            cover_image: item.coverImage,
            drive_link: item.driveLink,
            description: item.desc,
            article: item.article,
            article_paragraphs: item.articleParagraphs || [],
            gallery: item.gallery || [],
            updated_at: new Date().toISOString()
          };
          const { error } = await supabaseClient.from('events').upsert(row);
          if (error) console.error('[KSPM Backend] Cloud saveEvent error:', error);
          else console.log('[KSPM Backend] Event synced to Supabase:', item.id);
        } catch (e) {
          console.warn('[KSPM Backend] Failed to sync event to cloud:', e);
        }
      }
      return item;
    },

    async deleteEvent(id) {
      let localEvents = JSON.parse(localStorage.getItem('kspm_events') || '[]');
      localEvents = localEvents.filter(e => e.id !== id);
      localStorage.setItem('kspm_events', JSON.stringify(localEvents));

      if (isCloudConnected()) {
        try {
          await supabaseClient.from('events').delete().eq('id', id);
          console.log('[KSPM Backend] Event deleted from Supabase:', id);
        } catch (e) {
          console.warn('[KSPM Backend] Error deleting cloud event:', e);
        }
      }
    },

    // --- RESEARCH REPORTS ---
    async getResearch() {
      if (isCloudConnected()) {
        try {
          const { data, error } = await supabaseClient
            .from('research_reports')
            .select('*')
            .order('created_at', { ascending: false });
          if (!error && data && data.length > 0) {
            return data.map(row => ({
              id: row.id,
              ticker: row.ticker,
              company: row.company,
              sector: row.sector,
              title: row.title,
              subtitle: row.subtitle,
              rec: row.recommendation,
              targetPrice: row.target_price,
              currentPrice: row.current_price,
              upside: row.upside,
              date: row.release_date,
              pdfUrl: row.pdf_url,
              coverImage: row.cover_image,
              tags: row.tags || [],
              thesis: row.thesis || [],
              contributors: row.contributors || []
            }));
          }
        } catch (e) {
          console.warn('[KSPM Backend] Error fetching cloud research:', e);
        }
      }
      return JSON.parse(localStorage.getItem('kspm_research') || '[]');
    },

    async saveResearch(item) {
      let localRes = JSON.parse(localStorage.getItem('kspm_research') || '[]');
      const idx = localRes.findIndex(r => r.id === item.id);
      if (idx !== -1) localRes[idx] = item;
      else localRes.unshift(item);
      localStorage.setItem('kspm_research', JSON.stringify(localRes));

      if (isCloudConnected()) {
        try {
          const row = {
            id: (item.ticker || item.id).toLowerCase(),
            ticker: item.ticker,
            company: item.company,
            sector: item.sector || 'Sektor Pasar Modal',
            title: item.title,
            subtitle: item.subtitle || `Kajian Fundamental ${item.ticker}`,
            recommendation: item.rec || 'BUY',
            target_price: item.targetPrice,
            current_price: item.currentPrice || 'Market Price',
            upside: item.upside || '+12.5%',
            release_date: item.date || '2026',
            pdf_url: item.pdfUrl,
            cover_image: item.coverImage || 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?auto=format&fit=crop&w=1200&q=80',
            tags: item.tags || ['Equity Research', 'Fundamental'],
            thesis: item.thesis || [item.desc || ''],
            contributors: item.contributors || [],
            updated_at: new Date().toISOString()
          };
          await supabaseClient.from('research_reports').upsert(row);
          console.log('[KSPM Backend] Research synced to Supabase:', item.ticker);
        } catch (e) {
          console.warn('[KSPM Backend] Failed to sync research to cloud:', e);
        }
      }
      return item;
    },

    async deleteResearch(id) {
      let localRes = JSON.parse(localStorage.getItem('kspm_research') || '[]');
      localRes = localRes.filter(r => r.id !== id);
      localStorage.setItem('kspm_research', JSON.stringify(localRes));

      if (isCloudConnected()) {
        try {
          await supabaseClient.from('research_reports').delete().eq('id', id);
        } catch (e) {}
      }
    },

    // --- PARTNERS MARQUEE ---
    async getPartners() {
      if (isCloudConnected()) {
        try {
          const { data, error } = await supabaseClient
            .from('partners')
            .select('*')
            .order('sort_order', { ascending: true });
          if (!error && data && data.length > 0) return data;
        } catch (e) {}
      }
      return JSON.parse(localStorage.getItem('kspm_partners') || '[]');
    },

    // --- HOMEPAGE PARTNERSHIP INQUIRIES SUBMIT ---
    async submitInquiry(formObj) {
      // Always store locally as well
      let localInquiries = JSON.parse(localStorage.getItem('kspm_inquiries') || '[]');
      const newEntry = {
        id: 'inq-' + Date.now(),
        ...formObj,
        created_at: new Date().toISOString()
      };
      localInquiries.unshift(newEntry);
      localStorage.setItem('kspm_inquiries', JSON.stringify(localInquiries));

      // Push to Supabase if connected
      if (isCloudConnected()) {
        try {
          const { data, error } = await supabaseClient.from('inquiries').insert([{
            first_name: sanitizeHTML(formObj.firstName),
            last_name: sanitizeHTML(formObj.lastName),
            email: sanitizeHTML(formObj.email),
            organization: sanitizeHTML(formObj.organization),
            topic: sanitizeHTML(formObj.topic),
            message: sanitizeHTML(formObj.message),
            status: 'Pending'
          }]);
          if (error) console.error('[KSPM Backend] Inquiry submit cloud error:', error);
          else console.log('[KSPM Backend] Inquiry successfully stored in Supabase!');
        } catch (err) {
          console.warn('[KSPM Backend] Inquiry cloud submit fallback to local:', err);
        }
      }
      return newEntry;
    },

    // --- FILE UPLOAD TO SUPABASE STORAGE (BUCKET: kspm-media) ---
    async uploadMedia(file, folder = 'uploads') {
      if (!isCloudConnected()) {
        alert('Supabase belum terhubung. Konfigurasi URL dan Anon Key di menu Database.');
        return null;
      }
      try {
        const fileExt = file.name.split('.').pop();
        const fileName = `${folder}/${Date.now()}_${Math.random().toString(36).substring(2, 8)}.${fileExt}`;
        const { data, error } = await supabaseClient.storage
          .from('kspm-media')
          .upload(fileName, file, { cacheControl: '3600', upsert: false });

        if (error) throw error;

        // Get public download URL
        const { data: publicUrlData } = supabaseClient.storage
          .from('kspm-media')
          .getPublicUrl(fileName);

        console.log('[KSPM Backend] File uploaded successfully:', publicUrlData.publicUrl);
        return publicUrlData.publicUrl;
      } catch (err) {
        console.error('[KSPM Backend] Storage upload error:', err);
        alert('Gagal mengunggah berkas ke Supabase: ' + err.message);
        return null;
      }
    },

    // --- AUTHENTICATION (ADMIN LOGIN / LOGOUT) ---
    async adminLogin(email, password) {
      if (!isCloudConnected()) {
        // Local developer bypass mode if not connected to cloud
        console.log('[KSPM Backend] Dev bypass login active');
        localStorage.setItem('kspm_admin_session', JSON.stringify({ email: email, role: 'admin_local' }));
        return { success: true, user: { email: email } };
      }
      try {
        const { data, error } = await supabaseClient.auth.signInWithPassword({
          email: email,
          password: password
        });
        if (error) throw error;
        localStorage.setItem('kspm_admin_session', JSON.stringify(data.session));
        return { success: true, session: data.session };
      } catch (err) {
        return { success: false, error: err.message };
      }
    },

    async adminLogout() {
      localStorage.removeItem('kspm_admin_session');
      if (isCloudConnected()) {
        try {
          await supabaseClient.auth.signOut();
        } catch (e) {}
      }
    },

    getAdminSession() {
      const saved = localStorage.getItem('kspm_admin_session');
      if (saved) {
        try { return JSON.parse(saved); } catch(e) {}
      }
      return null;
    }
  };

  // Auto initialize on load
  if (typeof window !== 'undefined') {
    window.addEventListener('DOMContentLoaded', initClient);
    window.kspmDB = kspmDB;
  }

})(window);
