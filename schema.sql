-- =========================================================
-- FacturAI — Schéma Supabase
-- Copie-colle ce script dans Supabase → SQL Editor → Run
-- =========================================================

-- ---------- Table des entreprises (chaque user appartient à une company) ----------
create table companies (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references auth.users(id) on delete cascade,
  raison_sociale text not null,
  siret text,
  adresse text,
  tva_intra text,
  iban text,
  plan text default 'free',
  created_at timestamptz default now()
);

-- ---------- Clients de la PME ----------
create table clients (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete cascade not null,
  nom text not null,
  email text,
  telephone text,
  adresse text,
  ville text,
  siret text,
  created_at timestamptz default now()
);

-- ---------- Produits / services ----------
create table products (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete cascade not null,
  ref text,
  nom text not null,
  prix numeric not null default 0,
  tva numeric default 20,
  unite text default 'unité',
  created_at timestamptz default now()
);

-- ---------- Factures ----------
create table invoices (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete cascade not null,
  client_id uuid references clients(id),
  numero text not null,
  objet text not null,
  date_emission timestamptz default now(),
  date_echeance timestamptz not null,
  montant_ht numeric not null default 0,
  montant_tva numeric not null default 0,
  montant_ttc numeric not null default 0,
  statut text default 'brouillon',  -- brouillon | envoyée | payée | en_retard | annulée
  notes text,
  created_at timestamptz default now()
);

-- ---------- Lignes de facture ----------
create table invoice_lines (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid references invoices(id) on delete cascade not null,
  description text not null,
  quantite numeric default 1,
  prix_unit numeric not null default 0,
  tva numeric default 20,
  total numeric not null default 0
);

-- ---------- Devis ----------
create table quotes (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete cascade not null,
  client_id uuid references clients(id),
  numero text not null,
  objet text not null,
  date_emission timestamptz default now(),
  date_validite timestamptz,
  montant_ht numeric default 0,
  montant_tva numeric default 0,
  montant_ttc numeric default 0,
  statut text default 'brouillon',
  created_at timestamptz default now()
);

-- =========================================================
-- Row Level Security (RLS)
-- Chaque utilisateur ne voit QUE les données de SON entreprise
-- =========================================================

alter table companies    enable row level security;
alter table clients      enable row level security;
alter table products     enable row level security;
alter table invoices     enable row level security;
alter table invoice_lines enable row level security;
alter table quotes       enable row level security;

-- Helper : l'id de la company de l'utilisateur connecté
create or replace function my_company_id()
returns uuid language sql stable as $$
  select id from companies where owner_id = auth.uid() limit 1;
$$;

-- Politiques pour companies : l'utilisateur ne voit que sa propre company
create policy "Lire sa company"   on companies for select using (owner_id = auth.uid());
create policy "Créer sa company"  on companies for insert with check (owner_id = auth.uid());
create policy "Modifier sa company" on companies for update using (owner_id = auth.uid());

-- Politiques génériques pour toutes les autres tables
create policy "Lire clients"   on clients   for select using (company_id = my_company_id());
create policy "Insérer clients" on clients  for insert with check (company_id = my_company_id());
create policy "Modifier clients" on clients for update using (company_id = my_company_id());
create policy "Supprimer clients" on clients for delete using (company_id = my_company_id());

create policy "Lire products"   on products   for select using (company_id = my_company_id());
create policy "Insérer products" on products  for insert with check (company_id = my_company_id());
create policy "Modifier products" on products for update using (company_id = my_company_id());
create policy "Supprimer products" on products for delete using (company_id = my_company_id());

create policy "Lire invoices"   on invoices   for select using (company_id = my_company_id());
create policy "Insérer invoices" on invoices  for insert with check (company_id = my_company_id());
create policy "Modifier invoices" on invoices for update using (company_id = my_company_id());
create policy "Supprimer invoices" on invoices for delete using (company_id = my_company_id());

create policy "Lire lignes" on invoice_lines for select
  using (invoice_id in (select id from invoices where company_id = my_company_id()));
create policy "Insérer lignes" on invoice_lines for insert
  with check (invoice_id in (select id from invoices where company_id = my_company_id()));
create policy "Modifier lignes" on invoice_lines for update
  using (invoice_id in (select id from invoices where company_id = my_company_id()));
create policy "Supprimer lignes" on invoice_lines for delete
  using (invoice_id in (select id from invoices where company_id = my_company_id()));

create policy "Lire quotes"   on quotes   for select using (company_id = my_company_id());
create policy "Insérer quotes" on quotes  for insert with check (company_id = my_company_id());
create policy "Modifier quotes" on quotes for update using (company_id = my_company_id());
create policy "Supprimer quotes" on quotes for delete using (company_id = my_company_id());

-- =========================================================
-- Index pour les performances
-- =========================================================
create index idx_clients_company   on clients(company_id);
create index idx_products_company  on products(company_id);
create index idx_invoices_company  on invoices(company_id);
create index idx_invoices_client   on invoices(client_id);
create index idx_invoice_lines_inv on invoice_lines(invoice_id);
create index idx_quotes_company    on quotes(company_id);
