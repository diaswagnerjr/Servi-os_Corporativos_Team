create or replace function public.team_os_get_access(p_email text)
returns jsonb
language plpgsql
security definer
set search_path = team_os, public
as $$
declare
  v_row record;
begin
  select email, access_role, display_name, active
    into v_row
  from team_os.team_os_user_access
  where lower(email) = lower(p_email)
    and active = true
  limit 1;

  if v_row.email is null then
    return jsonb_build_object(
      'email', lower(p_email),
      'access_role', 'viewer',
      'display_name', lower(p_email),
      'active', true,
      'source', 'fallback'
    );
  end if;

  return jsonb_build_object(
    'email', v_row.email,
    'access_role', v_row.access_role,
    'display_name', coalesce(v_row.display_name, v_row.email),
    'active', v_row.active,
    'source', 'team_os'
  );
end;
$$;

create or replace function public.team_os_save_snapshot(p_email text, p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = team_os, public
as $$
declare
  v_role text;
  v_count integer := 0;
begin
  select access_role into v_role
  from team_os.team_os_user_access
  where lower(email) = lower(p_email)
    and active = true
  limit 1;

  if coalesce(v_role, 'viewer') <> 'editor' then
    raise exception 'Usuario sem permissao de editor para salvar snapshot Team OS';
  end if;

  v_count := coalesce((p_payload->>'row_count')::integer, 0);

  insert into team_os.team_os_import_logs (source_name, status, row_count, payload)
  values (
    'github_pages_snapshot',
    'reviewed',
    v_count,
    p_payload || jsonb_build_object('saved_by', lower(p_email), 'saved_at', now())
  );

  return jsonb_build_object('ok', true, 'saved_by', lower(p_email), 'row_count', v_count);
end;
$$;

revoke all on function public.team_os_get_access(text) from public;
revoke all on function public.team_os_save_snapshot(text, jsonb) from public;
grant execute on function public.team_os_get_access(text) to anon, authenticated;
grant execute on function public.team_os_save_snapshot(text, jsonb) to anon, authenticated;
