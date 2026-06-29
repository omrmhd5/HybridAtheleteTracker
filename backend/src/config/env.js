require('dotenv').config();

module.exports = {
  PORT: process.env.PORT || 3000,
  SUPABASE_URL: process.env.SUPABASE_URL || '',
  SUPABASE_ANON_KEY: process.env.SUPABASE_ANON_KEY || '',
  SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY || '',
  GEMINI_API_KEY: process.env.GEMINI_API_KEY || ''
};
