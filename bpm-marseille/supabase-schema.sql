-- Annubus : structure de la base (aucune donnée de contact ici).
-- À coller dans Supabase > SQL Editor > New query, puis « Run ».
-- Peut être relancé sans risque : rien n'est effacé (utile pour appliquer une mise à jour).
-- Seules les adresses e-mail listées dans la table « membres » peuvent lire ou modifier l'annuaire.

-- 1. Membres autorisés -------------------------------------------------------
create table if not exists public.membres (
  email     text primary key,
  nom       text,
  ajoute_le timestamptz not null default now()
);
-- administrateurs : peuvent ajouter et retirer des membres depuis l'application
alter table public.membres add column if not exists admin boolean not null default false;

create or replace function public.est_membre()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.membres
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

create or replace function public.est_admin()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.membres
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', '')) and admin
  );
$$;

-- adresses toujours en minuscules, et jamais zéro administrateur
create or replace function public.membres_controle()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if tg_op in ('INSERT', 'UPDATE') then
    new.email := lower(trim(new.email));
  end if;
  if (tg_op = 'DELETE' and old.admin) or (tg_op = 'UPDATE' and old.admin and not new.admin) then
    if not exists (select 1 from public.membres where admin and email <> old.email) then
      raise exception 'Il doit rester au moins un administrateur.';
    end if;
  end if;
  if tg_op = 'DELETE' then return old; end if;
  return new;
end;
$$;
drop trigger if exists membres_controle on public.membres;
create trigger membres_controle before insert or update or delete on public.membres
  for each row execute function public.membres_controle();

-- 2. Fiches de l'annuaire ---------------------------------------------------
create table if not exists public.contacts (
  id               text primary key,
  nom              text not null,
  categorie        text not null default '',
  telephones       text not null default '',
  email            text not null default '',
  adresse          text not null default '',
  cp               text not null default '',
  ville            text not null default '',
  notes            text not null default '',
  maj_origine      date,
  rev              integer not null default 1,      -- numéro de version, sert à détecter les modifications simultanées
  updated_at       timestamptz not null default now(),
  updated_by       text,                             -- e-mail de la personne qui a modifié
  updated_by_label text
);

-- 3. Historique (gardé 7 jours) ---------------------------------------------
create table if not exists public.historique (
  id         bigint generated always as identity primary key,
  action     text not null check (action in ('ajout', 'modif', 'suppression', 'restauration')),
  contact_id text not null,
  nom        text,
  at         timestamptz not null default now(),
  par        text,
  par_label  text,
  avant      jsonb,
  apres      jsonb
);
create index if not exists historique_at_idx on public.historique (at desc);

-- 4. « Qui est en train de modifier quelle fiche » --------------------------
create table if not exists public.verrous (
  contact_id text primary key,
  par        text not null,
  jusqua     timestamptz not null
);

-- 5. Accès : réservé aux membres -------------------------------------------
alter table public.membres    enable row level security;
alter table public.contacts   enable row level security;
alter table public.historique enable row level security;
alter table public.verrous    enable row level security;

drop policy if exists "membres lisent membres" on public.membres;
create policy "membres lisent membres" on public.membres
  for select to authenticated using (public.est_membre());
drop policy if exists "admins ajoutent membres" on public.membres;
create policy "admins ajoutent membres" on public.membres
  for insert to authenticated with check (public.est_admin());
drop policy if exists "admins modifient membres" on public.membres;
create policy "admins modifient membres" on public.membres
  for update to authenticated using (public.est_admin()) with check (public.est_admin());
drop policy if exists "admins retirent membres" on public.membres;
create policy "admins retirent membres" on public.membres
  for delete to authenticated using (public.est_admin());

drop policy if exists "membres gèrent contacts" on public.contacts;
create policy "membres gèrent contacts" on public.contacts
  for all to authenticated using (public.est_membre()) with check (public.est_membre());

drop policy if exists "membres gèrent historique" on public.historique;
create policy "membres gèrent historique" on public.historique
  for all to authenticated using (public.est_membre()) with check (public.est_membre());

drop policy if exists "membres gèrent verrous" on public.verrous;
create policy "membres gèrent verrous" on public.verrous
  for all to authenticated using (public.est_membre()) with check (public.est_membre());

-- 6. Mises à jour en direct entre collègues ---------------------------------
alter table public.contacts replica identity full;
do $$ begin
  alter publication supabase_realtime add table public.contacts;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.historique;
exception when duplicate_object then null; end $$;

-- 7. Effacement automatique de l'historique de plus de 7 jours (chaque nuit à 3 h)
create extension if not exists pg_cron;
select cron.unschedule('annuaire-purge-historique')
  where exists (select 1 from cron.job where jobname = 'annuaire-purge-historique');
select cron.schedule(
  'annuaire-purge-historique', '0 3 * * *',
  $$ delete from public.historique where at < now() - interval '7 days';
     delete from public.verrous where jusqua < now(); $$
);
