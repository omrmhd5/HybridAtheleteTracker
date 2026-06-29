const app = require('./src/app');
const env = require('./src/config/env');

const startServer = () => {
  const missing = ['SUPABASE_URL', 'SUPABASE_ANON_KEY', 'SUPABASE_SERVICE_ROLE_KEY']
    .filter((key) => !env[key]);

  if (missing.length) {
    console.error(`Missing required environment variables: ${missing.join(', ')}`);
    console.error('Set them in backend/.env (see backend/.env.example).');
    process.exit(1);
  }

  app.listen(env.PORT, () => {
    console.log(`Server running on port ${env.PORT}`);
  });
};

startServer();
