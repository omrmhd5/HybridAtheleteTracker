-- Hybrid Athlete Tracker — Supabase Postgres schema
-- Applied via the Supabase MCP (apply_migration). All tables live in `public`
-- and are keyed to auth.users(id). RLS is enabled with `auth.uid() = user_id`
-- policies as defence-in-depth; the backend uses the service-role key, which
-- bypasses RLS.

-- ---------------------------------------------------------------------------
-- profiles — one row per auth user (mirrors the old Mongo `User`)
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id                 uuid primary key references auth.users(id) on delete cascade,
  name               text not null,
  username           text not null unique,
  email              text not null,
  unit_preference    text not null default 'kg' check (unit_preference in ('kg', 'lbs')),
  daily_protein_goal integer not null default 150,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- lifting_sessions
-- exercises: jsonb array of { name, sets: [{ reps, weight }] }
-- ---------------------------------------------------------------------------
create table if not exists public.lifting_sessions (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references auth.users(id) on delete cascade,
  date             timestamptz not null default now(),
  session_name     text,
  exercises        jsonb not null default '[]'::jsonb,
  voice_transcript text,
  notes            text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- food_logs
-- ---------------------------------------------------------------------------
create table if not exists public.food_logs (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references auth.users(id) on delete cascade,
  date             timestamptz not null default now(),
  meal_name        text not null,
  calories         integer not null default 0,
  protein          integer not null default 0,
  carbs            integer not null default 0,
  fat              integer not null default 0,
  protein_goal_met boolean not null default false,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- cardio_logs
-- ---------------------------------------------------------------------------
create table if not exists public.cardio_logs (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references auth.users(id) on delete cascade,
  date             timestamptz not null default now(),
  type             text not null check (type in ('run', 'cycle', 'swim', 'other')),
  duration_minutes integer not null,
  distance         numeric not null default 0,
  avg_heart_rate   integer,
  notes            text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- body_weights
-- ---------------------------------------------------------------------------
create table if not exists public.body_weights (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  date       timestamptz not null default now(),
  weight     numeric not null,
  unit       text not null check (unit in ('kg', 'lbs')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- tips — AI weekly insights
-- ---------------------------------------------------------------------------
create table if not exists public.tips (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users(id) on delete cascade,
  week_start_date timestamptz not null,
  tip_text        text not null,
  data_snapshot   jsonb,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Indexes for the common (user_id, date) access pattern
-- ---------------------------------------------------------------------------
create index if not exists idx_lifting_user_date  on public.lifting_sessions (user_id, date desc);
create index if not exists idx_food_user_date      on public.food_logs (user_id, date desc);
create index if not exists idx_cardio_user_date    on public.cardio_logs (user_id, date desc);
create index if not exists idx_bodyweight_user_date on public.body_weights (user_id, date desc);
create index if not exists idx_tips_user_week       on public.tips (user_id, week_start_date desc);

-- ---------------------------------------------------------------------------
-- Row Level Security — defence in depth. The backend uses the service-role
-- key (bypasses RLS); these policies protect against any anon/authenticated
-- direct access.
-- ---------------------------------------------------------------------------
alter table public.profiles         enable row level security;
alter table public.lifting_sessions enable row level security;
alter table public.food_logs        enable row level security;
alter table public.cardio_logs      enable row level security;
alter table public.body_weights     enable row level security;
alter table public.tips             enable row level security;

create policy "Profiles are self-accessible"
  on public.profiles for all
  using (auth.uid() = id) with check (auth.uid() = id);

create policy "Own lifting sessions"
  on public.lifting_sessions for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Own food logs"
  on public.food_logs for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Own cardio logs"
  on public.cardio_logs for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Own body weights"
  on public.body_weights for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Own tips"
  on public.tips for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
