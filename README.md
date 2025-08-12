# Notably

---

## 🚀 Notably

Notably es una aplicación multiplataforma inspirada en Notion, que combina edición colaborativa de texto en tiempo real, gestión de espacios de trabajo y equipos, y funcionalidades de productividad potenciadas con inteligencia artificial.

---

## 🎯 Objetivos

- Editor de texto colaborativo con soporte en tiempo real para múltiples usuarios simultáneos.  
- Gestión de espacios y proyectos colaborativos con invitaciones y permisos.  
- Experiencia limpia y moderna basada en Material 3.  
- Integración con IA para ayudar a la productividad (resumen, generación de notas, búsqueda semántica).  
- Multiplataforma: web, móvil (Android/iOS) y escritorio.

---

## 🧰 Stack Tecnológico

### Frontend

- **Framework:** Flutter (Dart)  
- **Diseño:** Material 3 con paleta personalizada  
- **Gestión de estado:** Riverpod o Bloc  
- **Iconos:** Lucide / Phosphor Icons  
- **Colaboración en tiempo real:**  
  - Motor CRDT: **Y.js** (compilado a WebAssembly para usar en Flutter)  
  - Sincronización: **Supabase Realtime** o **Liveblocks** (canales WebSocket)

### Backend

- **Plataforma:** Supabase (PostgreSQL + APIs)  
- **Autenticación:** Supabase Auth (OAuth, email/contraseña)  
- **Permisos:** Roles y políticas en PostgreSQL para seguridad y acceso  
- **Almacenamiento:** Supabase Storage para archivos adjuntos

### IA Integrada

- APIs: OpenAI o Llama 3 para procesamiento y productividad (resúmenes, generación, búsqueda semántica)

---

## 🔄 Flujo de Datos

1. Usuario inicia sesión con Supabase Auth desde Flutter.  
2. Entra a un espacio o documento de equipo.  
3. Flutter se conecta a un canal WebSocket para ese documento usando Supabase Realtime o Liveblocks.  
4. Usuario escribe y el motor CRDT (Y.js) actualiza localmente y propaga cambios por WebSocket.  
5. Cambios se sincronizan en tiempo real con todos los clientes conectados.  
6. Cambios se guardan incrementalmente en PostgreSQL con versionado.  
7. IA puede analizar el contenido bajo demanda para mejorar la productividad.

---

## ✔️ Ventajas de este stack

- Código único para web, móvil y escritorio con Flutter.  
- Infraestructura escalable sin necesidad de servidores propios.  
- Edición colaborativa robusta y probada con Y.js.  
- Fácil integración de IA para funcionalidades avanzadas.  
- Seguridad y control con permisos gestionados desde la base de datos.

