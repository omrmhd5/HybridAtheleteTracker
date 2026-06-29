const { createClient } = require('@supabase/supabase-js');
const env = require('./env');

// Service-role client — used server-side for all data access. Bypasses RLS,
// so every query must scope ownership explicitly (.eq('user_id', userId)).
const supabaseAdmin = createClient(
  env.SUPABASE_URL,
  env.SUPABASE_SERVICE_ROLE_KEY,
  { auth: { autoRefreshToken: false, persistSession: false } }
);

// Anon client — used for password sign-in / token refresh (Supabase Auth).
const supabaseAnon = createClient(
  env.SUPABASE_URL,
  env.SUPABASE_ANON_KEY,
  { auth: { autoRefreshToken: false, persistSession: false } }
);

module.exports = { supabaseAdmin, supabaseAnon };
