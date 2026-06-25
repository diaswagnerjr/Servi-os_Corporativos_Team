create table if not exists team_os.team_os_user_access (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  access_role text not null check (access_role in ('editor', 'viewer')),
  display_name text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table team_os.team_os_user_access enable row level security;

drop policy if exists "team_os_user_access_read_all" on team_os.team_os_user_access;
create policy "team_os_user_access_read_all"
on team_os.team_os_user_access
for select
to anon, authenticated
using (active = true);

grant select on team_os.team_os_user_access to anon, authenticated;
grant insert, update, delete on team_os.team_os_user_access to authenticated;

alter table team_os.team_os_people
  add column if not exists leader_name text,
  add column if not exists sommos_status text check (sommos_status is null or sommos_status in ('Abaixo do esperado', 'Em desenvolvimento', 'Dentro do esperado', 'Acima do esperado', 'Referência')),
  add column if not exists delivery_score numeric check (delivery_score is null or delivery_score between 0 and 5),
  add column if not exists last_modified_by_email text;

alter table team_os.team_os_wallets
  add column if not exists leader_name text,
  add column if not exists similarity_group text,
  add column if not exists last_modified_by_email text;

alter table team_os.team_os_structure_scenarios
  add column if not exists leader_filter text,
  add column if not exists last_modified_by_email text;

alter table team_os.team_os_candidate_vacancies
  add column if not exists role_name text,
  add column if not exists salary_range text,
  add column if not exists target_hire_date date,
  add column if not exists process_stage text not null default 'Mapeamento' check (process_stage in ('Mapeamento', 'Triagem', 'Entrevistas', 'Finalistas', 'Oferta', 'Admissão', 'Encerrado')),
  add column if not exists priority text not null default 'Média' check (priority in ('Baixa', 'Média', 'Alta', 'Crítica')),
  add column if not exists process_owner_email text,
  add column if not exists final_decision text,
  add column if not exists last_modified_by_email text;

alter table team_os.team_os_candidates
  add column if not exists process_notes text,
  add column if not exists salary_expectation text,
  add column if not exists availability text,
  add column if not exists last_modified_by_email text;

create index if not exists team_os_user_access_email_idx on team_os.team_os_user_access (email);
create index if not exists team_os_people_leader_name_idx on team_os.team_os_people (leader_name);
create index if not exists team_os_wallets_leader_name_idx on team_os.team_os_wallets (leader_name);
create index if not exists team_os_candidate_vacancies_stage_idx on team_os.team_os_candidate_vacancies (process_stage);

insert into team_os.team_os_user_access (email, access_role, display_name, active)
values ('diaswagnerjr@gmail.com', 'editor', 'Wagner Dias', true)
on conflict (email) do update
set access_role = excluded.access_role,
    display_name = excluded.display_name,
    active = true,
    updated_at = now();
