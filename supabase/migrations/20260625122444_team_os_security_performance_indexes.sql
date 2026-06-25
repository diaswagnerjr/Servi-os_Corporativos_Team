create or replace function team_os.team_os_set_updated_at()
returns trigger
language plpgsql
set search_path = team_os, pg_temp
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create index if not exists team_os_roles_user_id_idx on team_os.team_os_roles (user_id);
create index if not exists team_os_people_user_id_idx on team_os.team_os_people (user_id);
create index if not exists team_os_people_role_id_idx on team_os.team_os_people (role_id);
create index if not exists team_os_wallets_user_id_idx on team_os.team_os_wallets (user_id);
create index if not exists team_os_wallets_owner_person_id_idx on team_os.team_os_wallets (owner_person_id);
create index if not exists team_os_structure_baseline_user_id_idx on team_os.team_os_structure_baseline (user_id);
create index if not exists team_os_structure_scenarios_user_id_idx on team_os.team_os_structure_scenarios (user_id);
create index if not exists team_os_structure_scenarios_baseline_id_idx on team_os.team_os_structure_scenarios (baseline_id);
create index if not exists team_os_expected_competency_matrix_competency_id_idx on team_os.team_os_expected_competency_matrix (competency_id);
create index if not exists team_os_people_assessments_person_id_idx on team_os.team_os_people_assessments (person_id);
create index if not exists team_os_people_assessments_competency_id_idx on team_os.team_os_people_assessments (competency_id);
create index if not exists team_os_sommos_assessments_user_id_idx on team_os.team_os_sommos_assessments (user_id);
create index if not exists team_os_sommos_assessments_person_id_idx on team_os.team_os_sommos_assessments (person_id);
create index if not exists team_os_candidate_vacancies_user_id_idx on team_os.team_os_candidate_vacancies (user_id);
create index if not exists team_os_candidates_user_id_idx on team_os.team_os_candidates (user_id);
create index if not exists team_os_candidates_vacancy_id_idx on team_os.team_os_candidates (vacancy_id);
create index if not exists team_os_candidate_assessments_candidate_id_idx on team_os.team_os_candidate_assessments (candidate_id);
create index if not exists team_os_candidate_assessments_competency_id_idx on team_os.team_os_candidate_assessments (competency_id);
create index if not exists team_os_comments_user_id_idx on team_os.team_os_comments (user_id);
create index if not exists team_os_import_logs_user_id_idx on team_os.team_os_import_logs (user_id);
