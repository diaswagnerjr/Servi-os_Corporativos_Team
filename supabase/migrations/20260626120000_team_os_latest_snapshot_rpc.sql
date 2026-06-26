create or replace function public.team_os_get_latest_snapshot(p_email text)
returns jsonb
language plpgsql
security definer
set search_path = team_os, public
as $$
declare
  v_payload jsonb;
begin
  if not exists (
    select 1
    from team_os.team_os_user_access a
    where lower(a.email) = lower(p_email)
      and coalesce(a.active, true) = true
      and a.access_role in ('editor','viewer')
  ) then
    raise exception 'access denied';
  end if;

  select l.payload
    into v_payload
  from team_os.team_os_import_logs l
  where l.source_name = 'github_pages_snapshot'
    and l.status = 'reviewed'
  order by l.created_at desc
  limit 1;

  return coalesce(v_payload, '{}'::jsonb);
end;
$$;

revoke all on function public.team_os_get_latest_snapshot(text) from public;
grant execute on function public.team_os_get_latest_snapshot(text) to anon, authenticated;
