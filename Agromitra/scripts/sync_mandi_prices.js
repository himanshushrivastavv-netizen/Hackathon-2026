/**
 * AgroMitra - Automated Daily Mandi Price Sync Script
 * 
 * Fetches latest commodity rates from Data.gov.in (Agmarknet)
 * and automatically upserts them into Supabase 'public.prices' table.
 */

const https = require('https');

const DATA_GOV_API_KEY = "579b464db66ec23bdd00000190cd99fd52804ab77183303a7fc4a2bd";
const RESOURCE_ID = "9ef84268-d588-465a-a308-a864a43d0070";
const DATA_GOV_URL = `https://api.data.gov.in/resource/${RESOURCE_ID}?api-key=${DATA_GOV_API_KEY}&format=json&limit=100`;

const SUPABASE_URL = "https://iquaslkxihnxdfzamtps.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_9qqvfJuraQnSnqspglZ0CQ_uGmfNdBT";

function fetchGovData() {
  return new Promise((resolve, reject) => {
    https.get(DATA_GOV_URL, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

function upsertToSupabase(records) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify(records);
    const url = new URL(`${SUPABASE_URL}/rest/v1/prices`);
    
    const options = {
      hostname: url.hostname,
      path: `${url.pathname}?on_conflict=id`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Prefer': 'resolution=merge-duplicates',
        'Content-Length': Buffer.byteLength(payload)
      }
    };

    const req = https.request(options, (res) => {
      let responseBody = '';
      res.on('data', chunk => responseBody += chunk);
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(responseBody);
        } else {
          reject(new Error(`Supabase error ${res.statusCode}: ${responseBody}`));
        }
      });
    });

    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

async function runSync() {
  console.log("🌾 [AgroMitra AutoSync] Fetching daily prices from Data.gov.in...");
  try {
    const govData = await fetchGovData();
    const records = govData.records || [];
    console.log(`✅ [AgroMitra AutoSync] Fetched ${records.length} records from Agmarknet.`);

    if (records.length === 0) {
      console.log("⚠️ No records returned from Agmarknet API today.");
      return;
    }

    const todayStr = new Date().toISOString().split('T')[0];
    const formatted = records.slice(0, 30).map((r, i) => {
      const comm = r.commodity || 'Commodity';
      const mkt = r.market || 'APMC Mandi';
      let min = parseFloat(r.min_price || '0');
      let modal = parseFloat(r.modal_price || '0');
      let max = parseFloat(r.max_price || '0');

      if (modal > 100) {
        min = parseFloat((min / 100.0).toFixed(2));
        modal = parseFloat((modal / 100.0).toFixed(2));
        max = parseFloat((max / 100.0).toFixed(2));
      }

      return {
        id: `pr-sync-${i + 1}-${comm.toLowerCase().replace(/[^a-z0-9]/g, '')}`,
        commodity: comm,
        market: mkt,
        min_price: min,
        modal_price: modal,
        max_price: max,
        date: r.arrival_date || todayStr,
        source: 'Data.gov.in / Agmarknet (Live Sync)',
        is_live: true
      };
    });

    console.log(`📤 [AgroMitra AutoSync] Upserting ${formatted.length} commodity rates to Supabase...`);
    await upsertToSupabase(formatted);
    console.log("🎉 [AgroMitra AutoSync] Successfully updated Supabase prices with real-time Govt rates!");
  } catch (err) {
    console.error("❌ [AgroMitra AutoSync] Sync failed:", err.message);
  }
}

runSync();
