insert into team_os.team_os_user_access (email, access_role, display_name, active)
values
  ('diaswagnerjr@gmail.com', 'editor', 'Wagner Dias', true),
  ('keyzealmeida@suzano.com.br', 'editor', 'Keyze Almeida', true),
  ('julianagomes@suzano.com.br', 'editor', 'Juliana Gomes', true),
  ('thaisdias@suzano.com.br', 'editor', 'Thais Dias', true)
on conflict (email) do update
set access_role = excluded.access_role,
    display_name = excluded.display_name,
    active = true,
    updated_at = now();

update team_os.team_os_user_access
set active = false,
    updated_at = now()
where lower(email) not in (
  'diaswagnerjr@gmail.com',
  'keyzealmeida@suzano.com.br',
  'julianagomes@suzano.com.br',
  'thaisdias@suzano.com.br'
);

create or replace function team_os.team_os_enforce_auth_allowlist()
returns trigger
language plpgsql
security definer
set search_path = team_os, public
as $$
begin
  if not exists (
    select 1
    from team_os.team_os_user_access a
    where lower(a.email) = lower(new.email)
      and a.active = true
      and a.access_role = 'editor'
  ) then
    raise exception 'Email nao autorizado para o Board Gestao';
  end if;

  return new;
end;
$$;

drop trigger if exists team_os_auth_allowlist on auth.users;
create trigger team_os_auth_allowlist
before insert on auth.users
for each row
execute function team_os.team_os_enforce_auth_allowlist();

create or replace function public.team_os_get_access(p_email text)
returns jsonb
language plpgsql
security definer
set search_path = team_os, public
as $$
declare
  v_row record;
  v_auth_email text;
begin
  select lower(u.email)
    into v_auth_email
  from auth.users u
  where u.id = auth.uid();

  if v_auth_email is null or v_auth_email <> lower(p_email) then
    raise exception 'access denied';
  end if;

  select email, access_role, display_name, active
    into v_row
  from team_os.team_os_user_access
  where lower(email) = lower(p_email)
    and active = true
  limit 1;

  if v_row.email is null then
    raise exception 'access denied';
  end if;

  return jsonb_build_object(
    'email', lower(v_row.email),
    'access_role', v_row.access_role,
    'display_name', coalesce(v_row.display_name, v_row.email),
    'active', v_row.active,
    'source', 'team_os_auth'
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
  v_auth_email text;
  v_count integer := 0;
begin
  select lower(u.email)
    into v_auth_email
  from auth.users u
  where u.id = auth.uid();

  if v_auth_email is null or v_auth_email <> lower(p_email) then
    raise exception 'access denied';
  end if;

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

create or replace function public.team_os_get_latest_snapshot(p_email text)
returns jsonb
language plpgsql
security definer
set search_path = team_os, public
as $$
declare
  v_payload jsonb;
  v_auth_email text;
begin
  select lower(u.email)
    into v_auth_email
  from auth.users u
  where u.id = auth.uid();

  if v_auth_email is null or v_auth_email <> lower(p_email) then
    raise exception 'access denied';
  end if;

  if not exists (
    select 1
    from team_os.team_os_user_access a
    where lower(a.email) = lower(p_email)
      and coalesce(a.active, true) = true
      and a.access_role = 'editor'
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

revoke all on function public.team_os_get_access(text) from public;
revoke all on function public.team_os_save_snapshot(text, jsonb) from public;
revoke all on function public.team_os_get_latest_snapshot(text) from public;
grant execute on function public.team_os_get_access(text) to authenticated;
grant execute on function public.team_os_save_snapshot(text, jsonb) to authenticated;
grant execute on function public.team_os_get_latest_snapshot(text) to authenticated;
