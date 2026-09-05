-- Kyvykkyysmittari — Supabase-tietokannan skeema
-- Aja tämä kokonaisuudessaan uuden Supabase-projektin SQL-editorissa
-- (Project → SQL Editor → New query), jos haluat pystyttää oman
-- erillisen taustajärjestelmän sovellukselle.

-- 1) Taulu mittaussarjoille
create table if not exists public.measurement_series (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null default 'Nimetön sarja',
  unit text default '',
  mode text not null default 'individual' check (mode in ('individual','subgroup')),
  subgroup_size int,
  limit_mode text not null default 'direct' check (limit_mode in ('direct','target')),
  usl double precision,
  lsl double precision,
  target double precision,
  tolerance double precision,
  values jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists measurement_series_user_id_idx on public.measurement_series(user_id);

-- 2) updated_at-aikaleiman automaattinen päivitys
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_measurement_series_updated_at on public.measurement_series;
create trigger set_measurement_series_updated_at
  before update on public.measurement_series
  for each row execute function public.set_updated_at();

-- 3) Rivikohtainen suojaus (Row Level Security)
-- Jokainen käyttäjä näkee ja muokkaa vain omia rivejään.
alter table public.measurement_series enable row level security;

drop policy if exists "select own rows" on public.measurement_series;
create policy "select own rows" on public.measurement_series
  for select using (auth.uid() = user_id);

drop policy if exists "insert own rows" on public.measurement_series;
create policy "insert own rows" on public.measurement_series
  for insert with check (auth.uid() = user_id);

drop policy if exists "update own rows" on public.measurement_series;
create policy "update own rows" on public.measurement_series
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "delete own rows" on public.measurement_series;
create policy "delete own rows" on public.measurement_series
  for delete using (auth.uid() = user_id);

-- 4) Reaaliaikaisuus (Realtime) päälle tälle taululle
alter publication supabase_realtime add table public.measurement_series;
