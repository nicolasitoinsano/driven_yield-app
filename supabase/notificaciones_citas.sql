-- =====================================================================
-- Notificaciones al registrar una cita
-- SOLO CREA OBJETOS NUEVOS. No modifica ninguna tabla existente
-- (cita, servicio, usuario, vehiculo, etc.).
-- Ejecutar en: Supabase > SQL Editor
-- =====================================================================

-- 1) Tabla de notificaciones (in-app)
create table if not exists public.notificacion (
  id_notificacion   bigserial primary key,
  id_usuario        bigint not null,
  id_cita           bigint not null,
  titulo            text not null,
  mensaje           text not null,
  tipo              text not null default 'cita_creada',
  leida             boolean not null default false,
  created_at        timestamptz not null default now()
);

create index if not exists idx_notificacion_id_usuario on public.notificacion (id_usuario);
create index if not exists idx_notificacion_leida on public.notificacion (id_usuario, leida);

-- 2) Tabla de tokens de dispositivo (para push/FCM)
create table if not exists public.dispositivo_push (
  id_dispositivo    bigserial primary key,
  id_usuario        bigint not null,
  token             text not null unique,
  plataforma        text not null default 'android',
  created_at        timestamptz not null default now()
);

create index if not exists idx_dispositivo_push_id_usuario on public.dispositivo_push (id_usuario);

-- 3) RLS permisivo (misma postura que el resto de la app, que hoy usa
--    la anon key sin sesion real). Ajustar cuando exista auth real.
alter table public.notificacion enable row level security;
alter table public.dispositivo_push enable row level security;

drop policy if exists "notificacion_all" on public.notificacion;
create policy "notificacion_all" on public.notificacion for all using (true) with check (true);

drop policy if exists "dispositivo_push_all" on public.dispositivo_push;
create policy "dispositivo_push_all" on public.dispositivo_push for all using (true) with check (true);

-- 4) Habilitar pg_net para poder llamar la Edge Function desde el trigger
create extension if not exists pg_net with schema extensions;

-- 5) Funcion + trigger: al INSERTAR una cita, crea la notificacion in-app
--    (cliente + admins) y dispara la Edge Function que envia el push.
--    NOTA: asume que existe public.usuario(id_usuario, nombre, rol) con
--    rol = 'admin' para el staff. Si tu tabla/columna se llama distinto,
--    ajusta solo esa parte (marcada abajo).
create or replace function public.fn_notificar_nueva_cita()
returns trigger
language plpgsql
security definer
as $$
declare
  v_servicio_nombre text;
  v_admin record;
begin
  select nombre into v_servicio_nombre from public.servicio where id_servicio = new.id_servicio;

  -- Notificacion para el cliente que agendo
  insert into public.notificacion (id_usuario, id_cita, titulo, mensaje, tipo)
  values (
    new.id_usuario,
    new.id_cita,
    'Cita registrada',
    concat('Tu cita de ', coalesce(v_servicio_nombre, 'servicio'), ' para el ', new.fecha, ' a las ', new.hora, ' fue registrada.'),
    'cita_creada'
  );

  -- Notificacion para cada admin (ajusta la tabla/columna 'rol' si es distinta)
  for v_admin in select id_usuario from public.usuario where rol = 'admin' loop
    insert into public.notificacion (id_usuario, id_cita, titulo, mensaje, tipo)
    values (
      v_admin.id_usuario,
      new.id_cita,
      'Nueva cita agendada',
      concat('Se registro una nueva cita para el ', new.fecha, ' a las ', new.hora, '.'),
      'cita_creada_admin'
    );
  end loop;

  -- Dispara la Edge Function que manda el push (no bloquea el insert si falla)
  perform net.http_post(
    url := current_setting('app.settings.edge_function_url', true),
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', concat('Bearer ', current_setting('app.settings.edge_function_anon_key', true))
    ),
    body := jsonb_build_object(
      'id_cita', new.id_cita,
      'id_usuario', new.id_usuario,
      'titulo', 'Cita registrada',
      'mensaje', concat('Tu cita de ', coalesce(v_servicio_nombre, 'servicio'), ' para el ', new.fecha, ' a las ', new.hora, ' fue registrada.')
    )
  );

  return new;
exception when others then
  -- Nunca romper el insert de la cita por un fallo de notificacion/push
  return new;
end;
$$;

drop trigger if exists trg_notificar_nueva_cita on public.cita;
create trigger trg_notificar_nueva_cita
  after insert on public.cita
  for each row
  execute function public.fn_notificar_nueva_cita();

-- 6) Configura estas dos claves UNA VEZ con tu URL real de la Edge Function
--    y el anon key del proyecto (Settings > API). Reemplaza los valores:
-- alter database postgres set app.settings.edge_function_url = 'https://TU-PROYECTO.supabase.co/functions/v1/send-cita-notification';
-- alter database postgres set app.settings.edge_function_anon_key = 'TU_ANON_KEY';
