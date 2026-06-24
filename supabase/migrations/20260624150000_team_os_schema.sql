-- Servicos Corporativos Team OS
-- Target project: wagner-performance-os
-- Safety: run this preflight first and confirm no object conflict.
select table_schema, table_name
from information_schema.tables
where table_schema not in ('pg_catalog', 'information_schema')
order by table_schema, table_name;

create schema if not exists team_os;
create extension if not exists pgcrypto;

create or replace function team_os.team_os_set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists team_os.team_os_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  role_name text not null,
  seniority text,
  expected_scope text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists team_os.team_os_people (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  role_id uuid references team_os.team_os_roles(id) on delete set null,
  name text not null,
  current_role text not null,
  current_seat text,
  potential_seat text,
  career_moment text,
  development_plan text,
  is_open_position boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists team_os.team_os_wallets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category text not null,
  owner_person_id uuid references team_os.team_os_people(id) on delete set null,
  owner_name text not null default 'TBD',
  wallet_type text not null default 'Rotina',
  baseline_afs numeric not null default 0,
  baseline_spend numeric not null default 0,
  bid_afs numeric not null default 0,
  bid_spend numeric not null default 0,
  challenge_afs numeric not null default 0,
  challenge_spend numeric not null default 0,
  suppliers_count numeric not null default 0,
  challenge_action text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists team_os.team_os_structure_baseline (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null default 'Baseline',
  source_name text,
  snapshot jsonb not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists team_os.team_os_structure_scenarios (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  description text,
  baseline_id uuid references team_os.team_os_structure_baseline(id) on delete set null,
  snapshot jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists team_os.team_os_competencies (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  group_name text not null check (group_name in ('Hard Skill', 'Soft Skill')),
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists team_os.team_os_expected_competency_matrix (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  role_name text not null,
  competency_id uuid not null references team_os.team_os_competencies(id) on delete cascade,
  expected_score numeric not null check (expected_score between 0 and 5),
  expected_label text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, role_name, competency_id)
);

create table if not exists team_os.team_os_people_assessments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  person_id uuid not null references team_os.team_os_people(id) on delete cascade,
  competency_id uuid not null references team_os.team_os_competencies(id) on delete cascade,
  expected_score numeric not null check (expected_score between 0 and 5),
  current_score numeric not null check (current_score between 0 and 5),
  qualitative_comment text,
  assessed_at date default current_date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, person_id, competency_id, assessed_at)
);

create table if not exists team_os.team_os_sommos_assessments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  person_id uuid not null references team_os.team_os_people(id) on delete cascade,
  status text not null check (status in ('Abaixo do esperado', 'Em desenvolvimento', 'Dentro do esperado', 'Acima do esperado', 'Referencia')),
  score numeric check (score between 0 and 5),
  career_moment text,
  development_plan text,
  assessed_at date default current_date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists team_os.team_os_candidate_vacancies (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  expected_matrix jsonb not null default '{}'::jsonb,
  status text not null default 'Aberta',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists team_os.team_os_candidates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  vacancy_id uuid references team_os.team_os_candidate_vacancies(id) on delete set null,
  name text not null,
  source_type text not null check (source_type in ('Interno', 'Externo')),
  status text not null check (status in ('Mapeado', 'Em avaliacao', 'Entrevistado', 'Finalista', 'Aprovado', 'Reprovado', 'Banco de talentos')),
  interview_notes text,
  cultural_fit_notes text,
  communication_notes text,
  autonomy_notes text,
  analytical_capacity_notes text,
  growth_potential_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists team_os.team_os_candidate_assessments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  candidate_id uuid not null references team_os.team_os_candidates(id) on delete cascade,
  competency_id uuid not null references team_os.team_os_competencies(id) on delete cascade,
  expected_score numeric not null check (expected_score between 0 and 5),
  candidate_score numeric not null check (candidate_score between 0 and 5),
  comment text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, candidate_id, competency_id)
);

create table if not exists team_os.team_os_comments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  entity_type text not null,
  entity_id uuid,
  comment_text text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists team_os.team_os_import_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null default auth.uid(),
  source_name text not null,
  status text not null default 'reviewed',
  row_count integer not null default 0,
  payload jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table team_os.team_os_roles enable row level security;
alter table team_os.team_os_people enable row level security;
alter table team_os.team_os_wallets enable row level security;
alter table team_os.team_os_structure_baseline enable row level security;
alter table team_os.team_os_structure_scenarios enable row level security;
alter table team_os.team_os_competencies enable row level security;
alter table team_os.team_os_expected_competency_matrix enable row level security;
alter table team_os.team_os_people_assessments enable row level security;
alter table team_os.team_os_sommos_assessments enable row level security;
alter table team_os.team_os_candidate_vacancies enable row level security;
alter table team_os.team_os_candidates enable row level security;
alter table team_os.team_os_candidate_assessments enable row level security;
alter table team_os.team_os_comments enable row level security;
alter table team_os.team_os_import_logs enable row level security;

grant usage on schema team_os to authenticated;
grant select, insert, update, delete on all tables in schema team_os to authenticated;
alter default privileges in schema team_os grant select, insert, update, delete on tables to authenticated;

create policy "competencies read" on team_os.team_os_competencies for select to authenticated using (true);

create policy "roles own" on team_os.team_os_roles for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "people own" on team_os.team_os_people for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "wallets own" on team_os.team_os_wallets for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "baseline own" on team_os.team_os_structure_baseline for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "scenarios own" on team_os.team_os_structure_scenarios for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "matrix own" on team_os.team_os_expected_competency_matrix for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "assessments own" on team_os.team_os_people_assessments for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "sommos own" on team_os.team_os_sommos_assessments for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "vacancies own" on team_os.team_os_candidate_vacancies for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "candidates own" on team_os.team_os_candidates for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "candidate assessments own" on team_os.team_os_candidate_assessments for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "comments own" on team_os.team_os_comments for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "import logs own" on team_os.team_os_import_logs for all to authenticated using ((select auth.uid()) = user_id or user_id is null) with check ((select auth.uid()) = user_id or user_id is null);

insert into team_os.team_os_competencies (slug, name, group_name, description) values
('negociacao','Negociacao','Hard Skill','Processo de interacao para atingir acordos sustentaveis.'),
('fornecedores_stakeholders','Gestao de Fornecedores e Stakeholders','Hard Skill','Relacionamento, qualificacao, performance, SLAs e conectividade.'),
('strategic_sourcing','Strategic Sourcing','Hard Skill','Analise de gastos, mercado, negociacao e contratacao.'),
('ferramentas','Ferramentas, sistemas e idiomas','Hard Skill','SAP, plataformas de compras, dados, Office e idiomas.'),
('mercado_categoria','Analise de Mercado, Funcao Suprimentos, Estrategia de Categoria e Sustentabilidade','Hard Skill','Leitura de mercado, drivers, req-to-pay, valor e sustentabilidade.'),
('flexibilidade','Flexibilidade e Resiliencia','Soft Skill','Adaptacao e continuidade de entrega diante de mudancas.'),
('comunicacao','Comunicacao de alto impacto','Soft Skill','Mensagens claras, concisas e influentes.'),
('autonomia','Autonomia, Protagonismo & Solucao de Problemas','Soft Skill','Responsabilidade, riscos, problemas e decisoes.'),
('organizacao','Organizacao, priorizacao, foco e senso de urgencia','Soft Skill','Organizacao, planejamento, priorizacao e execucao.'),
('risco_decisao','Analise de Risco e Tomada de Decisao','Soft Skill','Identificacao, avaliacao e mitigacao de riscos.'),
('equipe','Trabalho em Equipe/Espirito Coletivo','Soft Skill','Colaboracao e integracao de conhecimento.')
on conflict (slug) do update set name = excluded.name, group_name = excluded.group_name, description = excluded.description, updated_at = now();
