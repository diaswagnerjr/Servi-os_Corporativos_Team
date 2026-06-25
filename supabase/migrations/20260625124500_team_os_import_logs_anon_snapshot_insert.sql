grant insert on team_os.team_os_import_logs to anon;

create policy "team_os_import_logs_insert_anon_snapshot"
on team_os.team_os_import_logs
for insert
to anon
with check (user_id is null and source_name in ('github_pages_snapshot', 'local_snapshot'));
