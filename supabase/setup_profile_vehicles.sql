-- =====================================================================
-- Configuración de Tablas para Perfil y Vehículos
-- Ejecutar en: Supabase > SQL Editor
-- =====================================================================

-- 1) Tabla de Usuarios
CREATE TABLE IF NOT EXISTS public.usuario (
  id_usuario bigserial primary key,
  nombre text not null,
  telefono text,
  correo text,
  rol text default 'cliente',
  created_at timestamptz not null default now()
);

ALTER TABLE public.usuario ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "usuario_all" ON public.usuario;
CREATE POLICY "usuario_all" ON public.usuario FOR ALL USING (true) WITH CHECK (true);

-- Insertar un usuario de prueba (ID 1) para evitar errores
INSERT INTO public.usuario (id_usuario, nombre, telefono, correo, rol) 
VALUES (1, 'Carlos M.', '3000000000', 'carlos@ejemplo.com', 'cliente')
ON CONFLICT (id_usuario) DO NOTHING;


-- 2) Tabla de Vehículos
CREATE TABLE IF NOT EXISTS public.vehiculo (
  id_vehiculo bigserial primary key,
  id_usuario bigint not null,
  marca text not null,
  modelo text not null,
  placa text not null,
  created_at timestamptz not null default now()
);

ALTER TABLE public.vehiculo ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "vehiculo_all" ON public.vehiculo;
CREATE POLICY "vehiculo_all" ON public.vehiculo FOR ALL USING (true) WITH CHECK (true);

-- Insertar un vehículo de prueba (ID 1)
INSERT INTO public.vehiculo (id_vehiculo, id_usuario, marca, modelo, placa)
VALUES (1, 1, 'Generica', '2023', 'AAA-123')
ON CONFLICT (id_vehiculo) DO NOTHING;
