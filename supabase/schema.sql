-- ============================================================
-- Wirtschaftsforum Stralsund – Supabase-Datenbankschema
-- ============================================================
-- Ausführen in: Supabase Dashboard → SQL Editor → "New query" → einfügen → Run
-- ============================================================

create extension if not exists pgcrypto;

-- ---------- Tabellen ----------

create table if not exists participants (
  id uuid primary key default gen_random_uuid(),
  anrede text,
  titel text,
  vorname text not null,
  nachname text not null,
  firma text,
  funktion text,
  strasse text,
  stadt text,
  plz text,
  email text not null unique,
  telefon text,
  checked_in boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists cancellations (
  id uuid primary key default gen_random_uuid(),
  vorname text,
  nachname text,
  email text not null,
  created_at timestamptz not null default now()
);

create table if not exists waitlist (
  id uuid primary key default gen_random_uuid(),
  vorname text not null,
  nachname text not null,
  firma text,
  email text not null,
  telefon text,
  created_at timestamptz not null default now()
);

-- ---------- Row Level Security ----------
-- Grundprinzip:
--  - Anonyme Website-Besucher:innen (Rolle "anon") dürfen NUR neue Zeilen
--    in participants/cancellations EINFÜGEN – aber nichts lesen, ändern
--    oder löschen. So kann niemand über die öffentliche Website die
--    Teilnehmerliste einsehen.
--  - Eingeloggte Admin-Nutzer:innen (Rolle "authenticated", via Supabase
--    Auth) haben vollen Zugriff auf alle drei Tabellen fürs Dashboard.

alter table participants enable row level security;
alter table cancellations enable row level security;
alter table waitlist enable row level security;

-- Öffentliches Anmeldeformular (teilnehmen.html)
create policy "Öffentliche Anmeldung erlauben"
  on participants for insert
  to anon
  with check (true);

-- Öffentliches Absageformular (absagen.html)
create policy "Öffentliche Absage erlauben"
  on cancellations for insert
  to anon
  with check (true);

-- Admin-Dashboard: voller Zugriff für eingeloggte Nutzer:innen
create policy "Admin Vollzugriff participants"
  on participants for all
  to authenticated
  using (true) with check (true);

create policy "Admin Vollzugriff cancellations"
  on cancellations for all
  to authenticated
  using (true) with check (true);

create policy "Admin Vollzugriff waitlist"
  on waitlist for all
  to authenticated
  using (true) with check (true);

-- ============================================================
-- Danach im Supabase Dashboard:
-- Authentication → Users → "Add user" → deine Admin-E-Mail + Passwort
-- anlegen. Damit meldest du dich später im Dashboard (admin/index.html) an.
-- ============================================================
