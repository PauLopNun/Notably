# 🚀 Configuración de Notably

## 📋 Prerrequisitos

- Flutter SDK instalado
- Cuenta de Supabase
- Editor de código (VS Code recomendado)

## 🔧 Configuración de Supabase

### 1. Crear proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com)
2. Crea una nueva cuenta o inicia sesión
3. Crea un nuevo proyecto
4. Anota la **URL** y **Anon Key** del proyecto

### 2. Configurar la base de datos

Ejecuta este SQL en el editor SQL de Supabase:

```sql
-- Crear tabla de notas
CREATE TABLE notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content JSONB NOT NULL DEFAULT '[]',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS (Row Level Security)
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- Crear políticas de seguridad
CREATE POLICY "Users can view their own notes" ON notes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own notes" ON notes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own notes" ON notes
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own notes" ON notes
  FOR DELETE USING (auth.uid() = user_id);

-- Crear índice para mejorar el rendimiento
CREATE INDEX idx_notes_user_id ON notes(user_id);
CREATE INDEX idx_notes_created_at ON notes(created_at DESC);
```

### 3. Configurar autenticación

1. En Supabase Dashboard, ve a **Authentication > Settings**
2. Habilita **Email Auth**
3. Configura las plantillas de email si lo deseas

### 4. Actualizar configuración en Flutter

1. Abre `lib/config/supabase_config.dart`
2. Reemplaza las constantes con tus valores:

```dart
static const String supabaseUrl = 'https://tu-proyecto.supabase.co';
static const String supabaseAnonKey = 'tu-anon-key-aqui';
```

3. Abre `lib/main.dart`
4. Asegúrate de que las credenciales estén configuradas:

```dart
await Supabase.initialize(
  url: SupabaseConfig.supabaseUrl,
  anonKey: SupabaseConfig.supabaseAnonKey,
);
```

## 🏃‍♂️ Ejecutar la aplicación

1. Instala las dependencias:
```bash
flutter pub get
```

2. Ejecuta la aplicación:
```bash
flutter run
```

## 🧪 Probar la funcionalidad

1. **Registro/Login**: Crea una cuenta o inicia sesión
2. **Crear nota**: Toca el botón + para crear una nueva nota
3. **Editar nota**: Toca una nota existente para editarla
4. **Eliminar nota**: Usa el botón de eliminar en cada nota

## 🔍 Solución de problemas

### Error de conexión a Supabase
- Verifica que las credenciales en `supabase_config.dart` sean correctas
- Asegúrate de que el proyecto esté activo en Supabase

### Error de permisos
- Verifica que las políticas RLS estén configuradas correctamente
- Asegúrate de que la tabla `notes` tenga las políticas de seguridad

### Error de autenticación
- Verifica que Email Auth esté habilitado en Supabase
- Revisa los logs de autenticación en el dashboard

## 📱 Características implementadas

- ✅ Autenticación con email/contraseña
- ✅ CRUD completo de notas
- ✅ Editor de texto rico con Flutter Quill
- ✅ Sincronización en tiempo real con Supabase
- ✅ UI moderna con Material Design 3
- ✅ State management con Riverpod
- ✅ Manejo de errores robusto
- ✅ Indicadores de carga y estado

## 🚧 Próximas características

- [ ] Búsqueda de notas
- [ ] Categorías y etiquetas
- [ ] Compartir notas
- [ ] Sincronización offline
- [ ] Temas personalizables
- [ ] Exportar notas (PDF, Markdown)
